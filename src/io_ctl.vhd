library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity io_ctl is
    port ( clk,rst,sw:in std_logic;
          led : out STD_LOGIC_VECTOR(15 downto 0));
end io_ctl;

architecture arch of io_ctl is

signal done:std_logic;
signal result:signed(data_width-1 downto 0);

component cpu is
    port( clk,rst:in std_logic;  
          complete: out std_logic;  
          result:out signed(data_width-1 downto 0));
end component;	

begin

cp:cpu port map(clk => clk ,rst => rst,complete => done,result => result);

led <= std_logic_vector(result) when sw='1' else 
       x"000" & "000" & done  ;

end arch;
