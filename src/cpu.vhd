library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity cpu is
    port( clk,rst:in std_logic;  
          complete: out std_logic;  
          result:out signed(data_width-1 downto 0));
end cpu;	

architecture arch of cpu is

component alu is
   generic(width: natural:= 16);       
    port( inp:in signed_array(0 to 1);
      op:in opcode;
      result: out signed(width-1 downto 0);
      flag: out std_logic);
end component;
	
component data_bus is
    generic(data_width: natural:= 16);      
    port( sel:in std_logic_vector(1 downto 0);
      wr_val:in signed_array(0 to 2);       
      data:out signed(data_width-1 downto 0));
end component;	

component decoder is
      generic( instr_width: natural:= 16;
            reg_add_width: natural:= 3;
            offset_width: natural:= 5;
            imm_width: natural:= 8;
            data_width:natural:= 16);       
    port( instr:in std_logic_vector(instr_width-1 downto 0); 
      reg_add_0,reg_add_1:out unsigned(reg_add_width-1 downto 0);
      op:out opcode;
      offset:out signed(data_width-1 downto 0);
      immediate:out signed(data_width-1 downto 0);
      ar,im,br:out std_logic);
end component;	

component prog_counter is
    generic(width: natural:= 16);       
    port( clk,rst,branch:in std_logic;
      offset:in signed(width-1 downto 0);
      wr_en:in std_logic;  
      pc:out unsigned(width-1 downto 0));
end component;

component reg_bank is
    generic(data_width: natural:= 16; 
            data_depth: natural:= 8;
            add_width: natural:= 3);       
    port( clk:in std_logic;
      rd_add_0,rd_add_1:in unsigned(add_width-1 downto 0);
      wr_add:in unsigned(add_width-1 downto 0);
      wr_val:in signed_array(0 to 1);       
      wr_en,sel:in std_logic;  
      rd_val:out signed_array(0 to 1));
end component;

component controller is
    port( clk,rst,ar,im,br,flag:in std_logic;
      op:in opcode;         
      pc_br,pc_rst,mem_we,ir_we,pc_we,reg_we,done,alu_inp_en,wr_reg_sel:out std_logic;
      d0_sel,d1_sel:out std_logic_vector(1 downto 0));
end component;	

constant data_width: natural:= 16;
constant data_depth: natural:= 2**5; 
constant mem_add_width: natural:= 16;            
constant reg_depth: natural:= 8;
constant reg_add_width: natural:= 3;
constant offset_width: natural:=5;
constant opcode_width: natural:=5;
constant instr_width: natural:=16;

signal reg_val,mem_val,data,alu_inp: signed_array(0 to 1); 
signal alu_result,immediate: signed(data_width-1 downto 0);
signal pc: unsigned(mem_add_width-1 downto 0);
signal instr: std_logic_vector(instr_width-1 downto 0);
signal op: opcode;
signal reg_add_0,reg_add_1: unsigned(reg_add_width-1 downto 0);
signal mem_rd_add,mem_wr_add: unsigned(mem_add_width-1 downto 0);
signal offset: signed(data_width-1 downto 0);
signal pc_br,pc_rst,pc_we,ir_we,mem_we,reg_we,d0_we,d1_we,ar,im,br,alu_inp_en,wr_reg_sel,flag,done: std_logic;
signal d0_sel,d1_sel: std_logic_vector(1 downto 0);
signal mem: signed_array(0 to data_depth-1):= InitRamFromFile("memory.coe",data_depth);
constant result_address: natural := 18;

begin
    
mem_wr_add <= unsigned(data(0));
mem_rd_add <= unsigned(data(0));  

process(clk)
  begin
    if (clk'event and clk='1') then
      if (mem_we='1') then
         mem(to_integer(mem_wr_add(4 downto 0))) <= data(1);
      end if;  
      mem_val(0) <= mem( to_integer(pc(4 downto 0)) ) ;
      mem_val(1) <= mem( to_integer(mem_rd_add(4 downto 0)) ); 
     if (alu_inp_en='1') then
          alu_inp(0) <= data(1);
          alu_inp(1) <= data(0);
      end if;
    end if;
  end process;    

    instr <= std_logic_vector(mem_val(0)) when ir_we = '1';

    result <= mem(result_address) when done = '1' else x"0000";
    complete <= done;
    
    pr_count:prog_counter 
                generic map(width => mem_add_width) 
                port map(clk => clk, branch => pc_br,rst => pc_rst,offset => offset ,wr_en => pc_we,pc => pc);
   
    dec:decoder
    generic map (instr_width => instr_width,reg_add_width =>reg_add_width,offset_width =>offset_width,imm_width =>8,data_width => data_width)       
            port map(instr => instr, reg_add_0 => reg_add_0,reg_add_1 => reg_add_1 ,op => op,offset => offset,immediate => immediate,ar => ar,im => im ,br => br);
    
    ctl:controller 
    port map( clk => clk, rst => rst, ar => ar,im => im ,br => br,op => op,pc_br => pc_br,pc_rst => pc_rst,mem_we => mem_we,ir_we => ir_we,pc_we => pc_we,reg_we => reg_we,d0_sel => d0_sel,d1_sel => d1_sel,wr_reg_sel => wr_reg_sel,alu_inp_en => alu_inp_en,done => done,flag => flag);
  
    reg_file:reg_bank 
             generic map(data_width =>data_width, data_depth => data_depth, add_width => reg_add_width)      
             port map(clk => clk ,rd_add_0 => reg_add_0,rd_add_1 => reg_add_1,wr_add =>reg_add_0,wr_val => data,wr_en => reg_we,sel => wr_reg_sel,rd_val => reg_val);

    data_bus_0: data_bus
                generic map(data_width => data_width)       
                port map(sel => d0_sel , wr_val(0) =>alu_result,wr_val(1) => reg_val(1),wr_val(2) => immediate,data => data(0));
    
    data_bus_1: data_bus
                generic map(data_width => data_width)       
                port map( sel => d1_sel, wr_val(0) => reg_val(0),wr_val(1) => offset, wr_val(2) => mem_val(1),data => data(1));                       

    al: alu 
         generic map(width => data_width)
        port map( inp => alu_inp ,op => op,result => alu_result,flag => flag);       

end arch;
