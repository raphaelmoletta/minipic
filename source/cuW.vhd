--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      cuW                                   --
-- Type:        entity                                --
-- Date:        2017-05-09                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.3                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is the control unit for project  --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity cuW is
  port (
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    cu2rom_wr         : out   std_logic              := '0';
    cu2ir_wr          : out   std_logic              := '0';
    cu2alu_wr         : out   std_logic              := '0';
    cu2pc_wr          : out   std_logic              := '0';
    cu2w_wr           : out   std_logic              := '0';
    cu2status_wr      : out   std_logic              := '0';
    cu2fsr_wr         : out   std_logic              := '0';
    cu2ram_wr         : out   std_logic              := '0';
    cu2portA_wr       : out   std_logic              := '0';
    cu2portB_wr       : out   std_logic              := '0';
    cu2stack_pop      : out   std_logic              := '0';
    cu2stack_push     : out   std_logic              := '0';
    cu2ram_re         : out   std_logic              := '0';
    cu2mux_ram_sel    : out   std_logic              := '0';
    cu2mux_alu_sel    : out   std_logic              := '0';
    cu2pc_sel2        : out   unsigned (1 downto 0)  := (others => '0');
    cu2alu_bit_sel3   : out   unsigned (2 downto 0)  := (others => '0');
    cu2alu_sel        : out   alu_opcode             := op_nop;
    word_in           : in    word                   := (others => '0')
    );
end entity;

architecture a_cuW of cuW is
  signal actual_instruction   : instructions            := nop;
  signal state                : integer                 := 0; --machine state
  signal microcode            : unsigned(19 downto 0)   := (others => '0');
begin
  process (clock, reset) is
  begin  -- process
    if reset = '1' then
      state <= 0;
    elsif rising_edge(clock) then
      if state = 6 then
        state <= 0;
      else
        state <= state + 1;
      end if;
    end if;
  end process;

  actual_instruction <= instruction_type(word_in);
  microcode <= cpu_microcode(actual_instruction)(state);
  
  cu2rom_wr         <= microcode(19);
  cu2ir_wr          <= microcode(18);
  cu2alu_wr         <= microcode(17);
  cu2pc_wr          <= microcode(16);
  cu2w_wr           <= microcode(15);
  cu2status_wr      <= microcode(14);
  cu2fsr_wr         <= microcode(13);
  cu2ram_wr         <= microcode(12);
  cu2portA_wr       <= microcode(11);
  cu2portB_wr       <= microcode(10);
  cu2stack_pop      <= microcode(9);
  cu2stack_push     <= microcode(8);
  cu2ram_re         <= microcode(7);
  cu2mux_ram_sel    <= microcode(6);
  cu2mux_alu_sel    <= microcode(5);
  cu2pc_sel2        <= microcode(4 downto 3);
  cu2alu_bit_sel3   <= microcode(2 downto 0);
  cu2alu_sel        <= alu_op(actual_instruction);
end architecture;
