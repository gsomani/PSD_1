library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity data_bus is
    generic(data_width: natural:= 16);      
    port( sel:in std_logic_vector(1 downto 0);
      wr_val:in signed_array(0 to 2);       
      data:out signed(data_width-1 downto 0));
end data_bus;	

architecture arch of data_bus is
begin         
    with sel select
        data <= wr_val(0) when "00",
                wr_val(1) when "01",
                wr_val(2) when others;    
end arch;

