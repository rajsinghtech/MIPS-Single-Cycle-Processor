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

entity decode_logic is
  generic(WORD_SIZE : integer := 32; ALU_OPERATIONS : integer := 8; MAX_SHIFT : integer := 5; OP_CODE_SIZE : integer := 6; FUNC_CODE_SIZE : integer := 6);
  port (
      i_instruction : in std_logic_vector( WORD_SIZE - 1 downto 0 );
      o_jump : out std_logic;
      o_branch : out std_logic;
      o_memToReg : out std_logic;
      o_ALUOP : out std_logic_vector(ALU_OPERATIONS - 1 downto 0);
      o_ALUSrc : out std_logic;
      o_jumpIns : out std_logic;
      o_regWrite : out std_logic;
      o_shamt : out std_logic_vector( MAX_SHIFT - 1 downto 0);
      o_link : out std_logic,
      o_bne : out std_logic
    );
end decode_logic;

  -- Instruction format
  -- (31 downto 26) = opcode
  -- (25 downto 21) = rs
  -- (20 downto 16) = rt
  -- (15 downto 11) = rd
  -- (10 downto 6) = shamt
  -- (5 downto 0) = func

  -- (31 downto 26) = opcode
  -- (25 downto 21) = rs
  -- (20 downto 16) = rt
  -- (15 downto 0) = immediate

  -- (31 downto 26) = opcode
  -- (25 downto 0) = jump address

architecture structure of decode_logic is

  signal op_code : std_logic_vector(OP_CODE_SIZE - 1 downto 0);
  signal func_code : std_logic_vector(FUNC_CODE_SIZE - 1 downto 0);

  begin

  op_code <= i_instruction(31 downto 26);
  func_code <= i_instruction(5 downto 0);
  o_shamt <= i_instruction(10 downto 6);

  o_jump <= '1' when op_code = DECODE_OP(jc)
                else '1' when op_code = DECODE_OP(jalc)
                else '0';

  o_branch <= '1' when op_code = DECODE_OP(beqc)
                else '1' when op_code = DECODE_OP(bnec)
                else '0';

  o_memToReg <= '1' when op_code = DECODE_OP(lwc)
                else '0';

  o_ALUOP <= DECODE_ALU_ENCODING(op_add) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(addc)   |
                  func_code = DECODE_FUNC(addic)  |
                  func_code = DECODE_FUNC(addiuc) |
                  func_code = DECODE_FUNC(adduc)
                )
                else DECODE_ALU_ENCODING(op_sub) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(subc)   |
                  func_code = DECODE_FUNC(subuc)
                )
                else DECODE_ALU_ENCODING(op_and) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(andc)   |
                  func_code = DECODE_FUNC(andic)
                )
                else DECODE_ALU_ENCODING(op_or) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(orc)   |
                  func_code = DECODE_FUNC(oric)
                )
                else DECODE_ALU_ENCODING(op_nor) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(norc)
                )
                else DECODE_ALU_ENCODING(op_xor) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(xorc)   |
                  func_code = DECODE_FUNC(xori)
                )
                else DECODE_ALU_ENCODING(op_or) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(orc)   |
                  func_code = DECODE_FUNC(oric)
                )
                else DECODE_ALU_ENCODING(op_slt) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(sltc)   |
                  func_code = DECODE_FUNC(sltic)
                )
                else DECODE_ALU_ENCODING(op_sll) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(sllc)
                )
                else DECODE_ALU_ENCODING(op_srl) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(srlc)
                )
                else DECODE_ALU_ENCODING(op_sra) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(srac)
                )
                else DECODE_ALU_ENCODING(op_quad) when op_code = DECODE_OP(r_type) &
                (
                  func_code = DECODE_FUNC(quadc)
                )
                else "000000";



  o_ALUSrc <= '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(addic)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(addiuc)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(andic)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(luic)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(xori)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(oric)
                else '1' when op_code = DECODE_OP(r_type) & func_code = DECODE_FUNC(sltic)
                else '0';

  o_jumpIns <= '1' when op_code = DECODE_OP(jrc)
                else '0';

  o_regWrite <= '1' when DECODE_OP(r_type) & !(func_code = DECODE_FUNC(jrc))
                  else '0';

  o_link <= '1' when op_code = DECODE_OP(jalc)
              else '0';

  o_bne <= '1' when op_code = DECODE_OP(bnec)
            else '0';

end structure;
