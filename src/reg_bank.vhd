library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity reg_bank is
    generic(data_width: natural:= 16; 
            data_depth: natural:= 8;
            add_width: natural:= 3);       
    port( clk:in std_logic;
      rd_add_0,rd_add_1:in unsigned(add_width-1 downto 0);
      wr_add:in unsigned(add_width-1 downto 0);
      wr_val:in signed_array(0 to 1);       
      wr_en,sel:in std_logic;  
      rd_val:out signed_array(0 to 1));
end reg_bank;	

architecture arch of reg_bank is

signal reg: signed_array(0 to data_depth-1);

begin

process(clk)
  begin
    reg(0) <= X"0000"; 
    if (clk'event and clk='1') then
      if (wr_en='1') then
          if(sel='0') then        
            reg(to_integer(wr_add)) <= wr_val(0);
          else
            reg(to_integer(wr_add)) <= wr_val(1); 
          end if;  
      end if;
      rd_val(0) <= reg( to_integer(rd_add_0) ) ;
      rd_val(1) <= reg( to_integer(rd_add_1) );
    end if;
  end process;     
end arch;

