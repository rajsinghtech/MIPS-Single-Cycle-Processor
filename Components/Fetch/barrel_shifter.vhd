-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- edge-triggered flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Data_Types.all;

entity barrel_shifter is
  generic(MAX_SHIFT: integer := 5; WORD_SIZE : integer := 32; SHIFT_TYPE_BITS: integer := 2);
  port (
	i_src : in std_logic_vector( WORD_SIZE - 1 downto 0 );
	i_shift_type: in std_logic_vector( SHIFT_TYPE_BITS - 1 downto 0);
	i_shamt: in std_logic_vector( MAX_SHIFT - 1 downto 0 );
	o_shift_out : out std_logic_vector( WORD_SIZE - 1 downto 0 )
  );
end barrel_shifter;

architecture structure of barrel_shifter is

	component mux2t1_N is
		generic(N : integer := 32);
		port(i_S          : in std_logic;
			i_D0         : in std_logic_vector(WORD_SIZE - 1 downto 0);
			i_D1         : in std_logic_vector(WORD_SIZE - 1 downto 0);
			o_O          : out std_logic_vector(WORD_SIZE - 1 downto 0));
	end component;
  
  signal sll_res : std_logic_vector( WORD_SIZE - 1 downto 0 );
  signal srl_res : std_logic_vector( WORD_SIZE - 1 downto 0 );
  signal sra_res : std_logic_vector( WORD_SIZE - 1 downto 0 );
  signal sll_srl_out : std_logic_vector( WORD_SIZE - 1 downto 0);
  
begin

	sll_res <= std_logic_vector(unsigned(i_src) * (2 ** unsigned(i_shamt)));
	srl_res <= std_logic_vector(unsigned(i_src) / (2 ** unsigned(i_shamt)));
	sra_res <= std_logic_vector(signed(i_src) / (2 ** signed(i_shamt)));
	
	  Shift_LL_Sel: mux2t1_N
	  port map(
				i_S     => i_shift_type(0),
				i_D0    => sll_res,
				i_D1    => srl_res,
				o_O     => sll_srl_out);
				
	  Shift_LA_Sel: mux2t1_N
	  port map(
				i_S     => i_shift_type(1),
				i_D0    => sll_srl_out,
				i_D1    => sra_res,
				o_O     => o_shift_out);

end structure;