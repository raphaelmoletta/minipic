--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      aluA                                  --
-- Type:        entity                                --
-- Date:        2017-04-05                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.8                                   --
-- Revision by:                                       --
--                                                    --
-- Description: Aritimetic Logical Unit               --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity aluA is
  port(
    clock             : in    std_logic              :='0';
    write_enable      : in    std_logic              :='0';
    status            : out   unsigned (2 downto 0)  := (others => '0');
    bit_sel           : in    unsigned (2 downto 0)  := (others => '0');
    selection         : in    alu_opcode             := op_nop;
    input             : in    address                := (others => '0');
    w_in              : in    address                := (others => '0');
    output            : out   address                := (others => '0')
    );
end entity;

architecture a_aluA of aluA is
begin
  process(clock)
    variable input0, input1, out0, zero: unsigned(memory_size downto 0) := (others => '0');
  begin
    if rising_edge(clock) then
      if write_enable = '1' then
        zero := (others => '0');
        input0 := '0' & w_in;
        input1 := '0' & input;
        out0 := alu_function(input0, input1, selection, bit_sel);
        status(0) <= out0(memory_size);
        status(1) <= out0(memory_size / 2 + 1);
        if out0 = zero then
          status(2) <= '1';
        else
          status(2) <= '0';
        end if;
        output <= out0(memory_size - 1 downto 0);
      else
        output <= (others => 'Z');
      end if;
    end if;
  end process;
end architecture;
