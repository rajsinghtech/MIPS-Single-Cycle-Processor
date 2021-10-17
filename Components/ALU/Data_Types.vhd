-- Quartus Prime VHDL Template
-- Single-port RAM with single read/write address

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Data_Types is

	type DATA_FIELD is array(integer range <>) of std_logic_vector(31 downto 0);
	
	type OP_CODE is ( add, addi, lw, sw);
	
	type OPCODE_ARRAY is array(OP_CODE) of std_logic_vector(5 downto 0);
	
	constant DECODE_OP : OPCODE_ARRAY;

end package Data_Types;

package body Data_Types is

	constant DECODE_OP : OPCODE_ARRAY := ( add => "100000", addi => "111000", lw => "111001", sw => "011010" );

end package body Data_Types;
