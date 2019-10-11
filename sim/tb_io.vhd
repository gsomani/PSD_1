library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_io is
end tb_io;

architecture Behavioral of tb_io is

component io_ctl is
    port ( clk,rst,sw:in std_logic;
           led : out STD_LOGIC_VECTOR(15 downto 0));        
end component;

signal clk,rst,sw:std_logic;
signal led: STD_LOGIC_VECTOR(15 downto 0);
constant period:time:= 10 ns;

begin

io:io_ctl port map(clk => clk,rst => rst,led => led,sw => sw);

process

begin

wait for 30 ns;

cloop: loop

clk <= '0';
wait for (period/2);
clk <= '1';
wait for (period/2);

end loop;

end process;

process

begin

wait for 50 ns;
rst<='1';
sw <= '0';
wait for 200 ns;
rst <= '0';
wait for 8000 ns;
sw <= '1';
wait; 

end process;


end Behavioral;
