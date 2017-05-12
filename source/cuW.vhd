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
    err_in            : in    std_logic              := '0';
    cu2pc_wr          : out   std_logic              := '0';
    cu2rom_wr         : out   std_logic              := '0';
    cu2w_wr           : out   std_logic              := '0';
    cu2ram_wr         : out   std_logic              := '0';
    cu2ir_wr          : out   std_logic              := '0';
    cu2fsr_wr         : out   std_logic              := '0';
    cu2status_wr      : out   std_logic              := '0';
    cu2alu_wr         : out   std_logic              := '0';
    cu2ram_re         : out   std_logic              := '0';
    cu2pc_sel         : out   std_logic              := '0';
    cu2mux_ram_sel    : out   std_logic              := '0';
    cu2mux_alu_sel    : out   std_logic              := '0';
    cu2stack_pop      : out   std_logic              := '0';
    cu2stack_push     : out   std_logic              := '0';
    cu2alu_sel        : out   alu_opcode             := op_nop;
    ir                : in    word                   := (others => '0')
    );
end entity;

architecture a_cuW of cuW is
  signal state : unsigned (3 downto 0) := B"0010"; --machine state
begin
  process(clock, reset)
  begin
    if reset = '1' then
      state <= B"0010";
    elsif rising_edge(clock) then
      case state is
        when B"0001" =>
          state <= B"0010";
          cu_pc_procedure(cu2w_wr, cu2ram_wr, cu2fsr_wr, cu2status_wr, cu2ram_re, cu2pc_sel, cu2mux_alu_sel, cu2mux_ram_sel,
                           cu2stack_pop, cu2stack_push, cu2alu_sel, ir);
        when B"0010" =>
          state <= B"0100";
          cu_rom_procedure(cu2w_wr, cu2ram_wr, cu2fsr_wr, cu2status_wr, cu2ram_re, cu2pc_sel, cu2mux_alu_sel, cu2mux_ram_sel,
                           cu2stack_pop, cu2stack_push, cu2alu_sel, ir);
        when B"0100" =>
          state <= B"1000";
          cu_ir_procedure(cu2w_wr, cu2ram_wr, cu2fsr_wr, cu2status_wr, cu2ram_re, cu2pc_sel, cu2mux_alu_sel, cu2mux_ram_sel,
                           cu2stack_pop, cu2stack_push, cu2alu_sel, ir);
        when B"1000" =>
          state <= B"0001";
          cu_mem_procedure(cu2w_wr, cu2ram_wr, cu2fsr_wr, cu2status_wr, cu2ram_re, cu2pc_sel, cu2mux_alu_sel, cu2mux_ram_sel,
                           cu2stack_pop, cu2stack_push, cu2alu_sel, ir);
        when others =>
          state <= B"0000";
       end case;
      cu2pc_wr  <= state(0);
      cu2rom_wr <= state(1);
      cu2ir_wr  <= state(2);
    end if;
  end process;
end architecture;
