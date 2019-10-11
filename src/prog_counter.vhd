library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prog_counter is
    generic(width: natural:= 16);       
    port( clk,rst,branch:in std_logic;
      offset:in signed(width-1 downto 0);
      wr_en:in std_logic;  
      pc:out unsigned(width-1 downto 0));
end prog_counter;	

architecture arch of prog_counter is

signal counter:unsigned(width-1 downto 0);

begin
   
 pc <= counter;
 process(clk)
  begin
    if (clk'event and clk='1') then
      if (rst='1') then
             counter <= X"0000";
      elsif(wr_en = '1') then  
            if (branch = '1') then
                counter <= counter + unsigned(offset);
            else
                counter <= counter + 1;             
            end if;
      end if;
    end if;
  end process;     
end arch;

