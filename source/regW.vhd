--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      regW                                  --
-- Type:        entity                                --
-- Date:        2017-04-01                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.2                                   --
-- Revision by:                                       --
--                                                    --
-- Description: Register size of Word type            --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity regW is
  port (
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    write_enable      : in    std_logic              := '0';
    data_in           : in    word                   := (others => '0');
    data_out          : out   word                   := (others => '0')
    );
end entity;

architecture a_regW of regW is
  signal registry : word                           := (others => '0');
begin
  process (clock, reset, write_enable)
  begin
    if reset = '1' then
      registry <= (others => '0');
    elsif write_enable = '1' then
      if rising_edge(clock) then
        registry <= data_in;
      end if;
    end if;
  end process;
  data_out <= registry;
end architecture;
