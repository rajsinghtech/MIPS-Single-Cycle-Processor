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
	o_shift_out : out std_logic_vector( WORD_SIZE - 1 downto 0 );
  
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
  
  signal sll_layers : shift_layers( MAX_SHIFT downto 0 );
  signal srl_layers : shift_layers( MAX_SHIFT downto 0 );
  signal sra_layers : shift_layers( MAX_SHIFT downto 0 );
  
  signal sll_temp : shift_layers( MAX_SHIFT - 1 downto 0 );
  signal srl_temp : shift_layers( MAX_SHIFT - 1 downto 0 );
  signal sra_temp : shift_layers( MAX_SHIFT - 1 downto 0 );
  
  signal sll_srl_out : std_logic_vector( WORD_SIZE - 1 downto 0 );
  
begin

	sll_layers(0) <= i_src;
	srl_layers(0) <= i_src;
	sra_layers(0) <= i_src;


-- Shift Left Logical

	MUX_GEN_SLL: 
	for i in 0 to MAX_SHIFT - 1 generate
	
	  sll_temp(i)( WORD_SIZE - 1 downto (2 ** i) - 1) <= sll_layers(i)( WORD_SIZE - 1 - (2 ** i) downto 0);
	  sll_temp(i) <= (others => '0');
	
	  Shift_LL_Mult: mux2t1_N
	  port map(
				i_S     => i_shift_type(i),
				i_D0    => sll_layers(i),
				i_D1    => sll_temp(i),
				o_O     => sll_layers(i + 1));
	
	end generate

-- Shift Right Logical

	MUX_GEN_SRL: 
	for i in 0 to MAX_SHIFT - 1 generate
	
	  srl_temp(i)( WORD_SIZE - 1 - (2 ** i) downto 0 ) <= srl_layers(i)( WORD_SIZE - 1 downto (2 ** i) - 1 );
	  srl_temp(i) <= (others => '0');
	
	  Shift_LL_Mult: mux2t1_N
	  port map(
				i_S     => i_shift_type(i),
				i_D0    => srl_layers(i),
				i_D1    => srl_temp(i),
				o_O     => srl_layers(i+1));
	
	end generate

-- Shift Right Arithmetic

	MUX_GEN_SRA: 
	for i in 0 to MAX_SHIFT - 1 generate
	
	  sra_temp(i)( WORD_SIZE - 1 - (2 ** i) downto 0 ) <= sra_layers(i)( WORD_SIZE - 1 downto (2 ** i) - 1 );
	  sra_temp(i) <= (others => i_src(WORD_SIZE - 1));
	
	  Shift_LL_Mult: mux2t1_N
	  port map(
				i_S     => i_shift_type(i),
				i_D0    => sra_layers(i),
				i_D1    => sra_temp(i),
				o_O     => sra_layers(i+1));
	
	end generate
	
	  Shift_LL_Sel: mux2t1_N
	  port map(
				i_S     => i_shift_type(0),
				i_D0    => sll_layers(5),
				i_D1    => srl_layers(5),
				o_O     => sll_srl_out);
				
	  Shift_LA_Sel: mux2t1_N
	  port map(
				i_S     => i_shift_type(1),
				i_D0    => sll_srl_out,
				i_D1    => sra_layers(5),
				o_O     => o_shift_out);

end structure;