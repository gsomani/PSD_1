library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_memory.all;

entity decoder is
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
end decoder;	

architecture arch of decoder is

constant opcode_width: natural:= 5;

signal imm:signed(imm_width-1 downto 0);
signal opc:std_logic_vector(opcode_width-1 downto 0); 
signal op_code:opcode;
signal zero_im:signed(opcode_width+reg_add_width-1 downto 0):= (others => '0'); 
signal zero_ofs:signed(instr_width-offset_width-1 downto 0):= (others => '0'); 
signal offs:signed(offset_width-1 downto 0);

begin

op <= op_code;
imm <= signed(instr(instr_width-1 downto opcode_width+reg_add_width));
immediate <= imm & zero_im when (op_code = lui) else
             zero_im & imm;

offset <= zero_ofs & offs when (op_code = load or op_code = store) else
          to_signed(to_integer(offs),data_width);          

offs <= signed(instr(instr_width-1 downto instr_width-offset_width));
reg_add_0 <= unsigned(instr(opcode_width+reg_add_width-1 downto opcode_width));
reg_add_1 <= unsigned(instr(instr_width-offset_width-1 downto opcode_width+reg_add_width));

opc <= instr(opcode_width-1 downto 0);

with op_code select
    ar <= '1' when add | sub | op_xor | op_and | op_or , 
          '0' when others;

with op_code select
    br <= '1' when bne | beq | blt | bltu ,
          '0' when others;

with op_code select
    im <= '1' when addi | xori | andi | ori | slli | srli | srai ,
          '0' when others;

with opc select 
   op_code <= add when "00001",
           sub when "00010",
           op_xor when "00011",
           op_and when "00100",
           op_or when "00101",
           addi  when "01001",
           xori when "01011",
           andi when "01100",
           ori when "01101",
           slli when "01110",
           srli when "01111",
           srai when "10000",
           lui when "10001",
           load when "10010",
           store when "10011",
           bne when "10100",
           beq when "10101",
           blt when "10110",
           bltu when "10111",
           mov when "11000",        
           halt when others;

end arch;

