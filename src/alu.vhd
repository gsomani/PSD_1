library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity alu is
    generic(width: natural:= 16);       
    port( inp:in signed_array(0 to 1);
      op:in opcode;
      result: out signed(width-1 downto 0);
      flag: out std_logic);
end alu;	

architecture arch of alu is

signal in_add,in_sub,in_xor,in_and,in_or,in_sll,in_srl,in_sra:signed(width-1 downto 0);
signal eq,lt,ltu:std_logic;

begin

    in_add <= inp(0) + inp(1);
    in_sub <= inp(0) - inp(1);
    in_xor <= inp(0) xor inp(1);
    in_and <= inp(0) and inp(1);
    in_or <= inp(0) or inp(1);
    in_sll <= inp(0) sll 1;
    in_srl <= inp(0) srl 1;
    in_sra <= inp(0)(data_width-1) & inp(0)(data_width-1 downto 1);
    
    lt <= in_sub(width-1) when inp(0)(width-1) = inp(1)(width-1) else
          inp(0)(width-1);
    
    ltu <= in_sub(width-1) when inp(0)(width-1) = inp(1)(width-1) else
          inp(1)(width-1);  
    
    eq <= '1' when in_sub = x"0000" else
          '0' ;  

    with op select
           result <= in_add when add | addi | load | store,
                  in_sub when sub,
                  in_xor when op_xor | xori, 
                  in_and when op_and | andi,
                  in_or when op_or | ori,
                  in_sll when slli,
                  in_srl when srli,
                  in_sra when srai,
                  x"0000" when others;
    
    with op select
          flag <= eq       when beq,
                  not eq   when bne,
                  lt       when blt,
                  ltu      when bltu,
                  '0'      when others;
      
end arch;

