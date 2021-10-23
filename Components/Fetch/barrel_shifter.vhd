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
  generic(MAX_SHIFT: integer := 5; WORD_SIZE : integer := 32);
  port (
	i_src : in std_logic_vector( WORD_SIZE - 1 downto 0 );
	i_shift_type: in std_logic;
	i_shamt: in std_logic_vector( MAX_SHIFT - 1 downto 0 );
	o_shift_out : out std_logic_vector( WORD_SIZE - 1 downto 0 )
  );
end barrel_shifter;

architecture structure of barrel_shifter is

	component mux4t1 is
		generic(N : integer := 32);
		port(i_S          : in std_logic_vector( 1 downto 0);
			i_D0         : in std_logic;
			i_D1         : in std_logic;
			i_D2         : in std_logic;
			i_D3         : in std_logic;
			o_O          : out std_logic);
	end component;

  signal shift_layer_data : shift_layers;
  
  
begin

  G_SHIFT_LAYER: for i in 0 to MAX_SHIFT-1 generate
	G_SHIFT_MUX: for j in 0 to WORD_SIZE-1 generate
		SHIFT_RIGHT_START : IF j + 2 ** i > WORD_SIZE-1 generate

			MUX: mux4t1 port map( 
				i_S => i_shamt(i) & i_shift_type,
				i_D0 => shift_layer_data(i,j),
				i_D1 => shift_layer_data(i, j - (2 ** i)),
				i_D2 => '0',
				i_D3 => '1',
				o_O => shift_layer_data(i, j));

		end generate SHIFT_RIGHT_START;

		SHIFT_LEFT_END : if j - 2 ** i < 0 generate

			MUX: mux4t1 port map( 
				i_S => ( 0 => i_shamt(i), 1 => i_shift_type),
				i_D0 => shift_layer_data(i,j),
				i_D1 => '0',
				i_D2 => shift_layer_data(i, j + (2 ** i)),
				i_D3 => shift_layer_data(i, j + (2 ** i)),
				o_O => shift_layer_data(i, j));
		
		end generate SHIFT_LEFT_END;

		NORMAL_SHIFT : if j + 2 ** i < WORD_SIZE-1 AND j - 2 ** i > 0 generate

		MUX: mux4t1 port map( 
			i_S => ( 0 => i_shamt(i), 1 => i_shift_type),
			i_D0 => shift_layer_data(i,j),
			i_D1 => shift_layer_data(i, j - (2 ** i)),
			i_D2 => shift_layer_data(i, j + (2 ** i)),
			i_D3 => shift_layer_data(i, j + (2 ** i)),
			o_O => shift_layer_data(i, j));

		end generate NORMAL_SHIFT;
	
	end generate G_SHIFT_MUX;
  end generate G_SHIFT_LAYER;

	

end structure;