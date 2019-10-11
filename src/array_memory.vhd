library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package array_memory is
    
    constant data_width :integer := 16;    
    
    type unsigned_array is array (NATURAL range <>) of unsigned(data_width-1 downto 0);
    type signed_array is array (NATURAL range <>) of signed(data_width-1 downto 0);
    
    type opcode is (add,sub,op_xor,op_and,op_or,addi,xori,andi,ori,slli,srli,srai,lui,load,store,bne,beq,blt,bltu,mov,halt);   

    impure function InitRamFromFile(RamFileName : in string; RamDepth : in natural) return signed_array;

end package array_memory;

