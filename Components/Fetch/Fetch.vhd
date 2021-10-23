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

entity instruction_decoder is
  generic(J_TYPE_LEN: integer := 4; IMMEDIATE_LEN: integer := 16; ADDR_LEN: integer := 32; WORD_SIZE: integer := 32);
  port (
	i_imm : in std_logic_vector( IMMEDIATE_LEN - 1 downto 0 );
	i_addr: in std_logic_vector( ADDR_LEN - 1 downto 0 );
	i_clk : in std_logic;
	j_type: in std_logic_vector( J_TYPE_LEN - 1 downto 0);
	o_inst : out std_logic_vector( WORD_SIZE - 1 downto 0 );
  );
end instruction_decoder;

architecture structure of instruction_decoder is
  

  component mem
  port(
	clk		: in std_logic;
	addr	        : in std_logic_vector((ADDR_LEN-1) downto 0);
	data	        : in std_logic_vector((WORD_SIZE-1) downto 0);
	we		: in std_logic := '1';
	q		: out std_logic_vector((WORD_SIZE -1) downto 0));
  end component;

  component Ripple_Adder is
    port(i_A : in std_logic_vector(WORD_SIZE - 1 downto 0);
	     i_B : in std_logic_vector(WORD_SIZE - 1 downto 0);
	     o_S : out std_logic_vector(WORD_SIZE - 1 downto 0));
  end component;

  component mux2t1_N is
    generic(N : integer := 32);
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(WORD_SIZE - 1 downto 0);
         i_D1         : in std_logic_vector(WORD_SIZE - 1 downto 0);
         o_O          : out std_logic_vector(WORD_SIZE - 1 downto 0));
  end component;

  component dffg_N
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
       	 i_D          : in std_logic_vector( WORD_SIZE - 1 downto 0);     -- Data value input
       	 o_Q          : out std_logic_vector( WORD_SIZE - 1 downto 0));   -- Data value output
  end component;

  signal instruction_offset : std_logic_vector( WORD_SIZE - 1 downto 0):=  to_stdlogicvector(x"00000004");  
  signal program_counter : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal next_address : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal next_instruction : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal jump_address : std_logic_vector( ADDR_LEN - 1 downto 0);
  signal instruction : std_logic_vector( ADDR_LEN - 1 downto 0);
  
  signal branch_address : std_logic_vector( WORD_SIZE - 1 downto 0) := to_stdlogicvector(x"00000000");
  signal branch_immediate : std_logic_vector( WORD_SIZE - 1 downto 0);
  
  
  signal branch_or_register : std_logic_vector( WORD_SIZE - 1 downto 0);
  signal branch_jump : std_logic_vector( WORD_SIZE - 1 downto 0);
  
begin
  branch_immediate(17 downto 2) <= i_imm(15 downto 0);
  
  

  PC: dffg_N
  port map(
    i_CLK => i_clk,
	i_RST => '1',
	i_WE => '1',
	i_D => next_address,
	o_Q => program_counter
  );

  program_plus_four: Ripple_Adder
  port map(
            i_A    => instruction_offset,
			i_B    => program_counter,
            o_S    => next_instruction);


  branch_address: Ripple_Adder
  port map(
            i_A    => next_instruction,
			i_B    => branch_immediate,
            o_S    => branch_address);


  dmem: mem 
  port map(data => (others => '0'), 
           we => '0',
           clk => i_clk,
           addr => program_counter,
           q => instruction);
		   
	jump_address( 31 downto 28) <= program_counter( 31 downto 28);
	jump_address( 27 downto 2) <= instruction( 25 downto 0);
	jump_address( 1 downto 0) <= "00";
	

  Branch_Reg: mux2t1_N
  port map(
            i_S     => j_type(3),
            i_D0    => branch_address,
            i_D1    => i_addr,
            o_O     => branch_or_register);

  Branch_Jump: mux2t1_N
  port map(
            i_S     => j_type(2),
            i_D0    => jump_address,
            i_D1    => branch_or_register,
            o_O     => branch_jump);

  Next_Address: mux2t1_N
  port map(
            i_S     => j_type(1),
            i_D0    => next_instruction,
            i_D1    => branch_jump,
            o_O     => next_address);	

end structure;