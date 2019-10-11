library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity controller is
    generic ( data_width :natural:=16);
    port( clk,rst,ar,im,br,flag:in std_logic;
      op:in opcode;         
      pc_br,pc_rst,mem_we,ir_we,pc_we,reg_we,done,alu_inp_en,wr_reg_sel:out std_logic;
      d0_sel,d1_sel:out std_logic_vector(1 downto 0));
    end controller;	

architecture arch of controller is

type statetype is (s_rst,s_fetch,s_decode,s_alu_bin,s_alu_im,s_alu_ofs,s_branch,s_lui,s_mov,s_store_alu,s_store_mem,s_load,s_load_mem,s_done); 
signal pr_state, nx_state: statetype;

begin

fsmff: process (clk) 
begin  
    if (rising_edge(clk)) then  
        if (rst = '1') then pr_state <= s_rst;        
        else pr_state <= nx_state; 
        end if;
    end if;
end process; 

fsm: process (ar,br,im,op,flag,pr_state,clk) 
    begin 
        case pr_state is 
            when s_rst => 
	            pc_br <= '-'; pc_rst <='1'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '-';
                nx_state <=s_fetch;
            
            when s_fetch =>
                pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '1';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0'; wr_reg_sel <= '-';
                nx_state <=s_decode;    

            when s_decode => 
	            pc_br <= '-'; pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; alu_inp_en <= '0'; wr_reg_sel <= '0';done <= '0';               
                if(ar = '1' or br ='1') then                       
                        nx_state <= s_alu_bin ;               
                elsif( im = '1' ) then
                        nx_state <= s_alu_im;
                elsif( op = load or op = store ) then
                        nx_state <= s_alu_ofs;
                elsif( op = lui ) then
                        nx_state <= s_lui;
                elsif( op = mov ) then
                        nx_state <= s_mov;
                else
                        nx_state <= s_done;            
                end if;

            when s_mov => 
                pc_br <= '0'; pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '1';
                d0_sel <= "01"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '0';
                nx_state <= s_fetch;

            when s_alu_bin => 
                pc_rst <='0';pc_br <= '0'; pc_we <='0';  
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "01"; d1_sel <= "00"; done <= '0';alu_inp_en <= '1';wr_reg_sel <= '0';
                if(br ='1') then
                    nx_state <= s_branch;
                else 
                     nx_state <= s_store_alu;
                end if;
                                     
            when s_branch => 
                pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '0';
                if(flag = '1') then 
                        pc_br <= '1';
                else
                        pc_br <= '0';
                end if;     
                nx_state <= s_fetch;
                
             when s_lui => 
                pc_br <= '0'; pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '1';
                d0_sel <= "10"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '0';
                nx_state <= s_fetch;                          
     
            when s_alu_im => 
                pc_br <= '-'; pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "10"; d1_sel <= "00"; done <= '0';alu_inp_en <= '1';wr_reg_sel <= '-';
                nx_state <= s_store_alu;                

            when s_alu_ofs => 
                pc_br <= '-'; pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "01"; d1_sel <= "01"; done <= '0';alu_inp_en <= '1';wr_reg_sel <= '-';
                if(op = load) then
                    nx_state <= s_load;
                else                
                    nx_state <= s_store_mem;
                end if;             
   
            when s_store_alu => 
	            pc_br <= '0'; pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '1';
                d0_sel <= "00"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '0';
                nx_state <= s_fetch;         
                
            when s_load => 
	            pc_br <= '-'; pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "00"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '-';
                nx_state <= s_load_mem;
            
            when s_load_mem => 
	            pc_br <= '0'; pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '1';
                d0_sel <= "--"; d1_sel <= "10"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '1';
                nx_state <= s_fetch;
                            
            when s_store_mem => 
	            pc_br <= '0'; pc_rst <='0'; pc_we <= '1'; 
                mem_we <= '1';ir_we <= '0';reg_we <= '0';
                d0_sel <= "00"; d1_sel <= "00"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '-';
                nx_state <= s_fetch;    
                
            when s_done => 
	            pc_br <= '-'; pc_rst <='0'; pc_we <= '0'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; done <= '1';alu_inp_en <= '0';wr_reg_sel <= '-';        
                nx_state <= s_done;

            when others =>
                pc_br <= '-'; pc_rst <='-'; pc_we <= '-'; 
                mem_we <= '0';ir_we <= '0';reg_we <= '0';
                d0_sel <= "--"; d1_sel <= "--"; done <= '0';alu_inp_en <= '0';wr_reg_sel <= '-';
                nx_state <= s_rst;
        end case;
    end process fsm;
 
   
end arch;
