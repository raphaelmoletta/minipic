--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      regA                                  --
-- Type:        entity                                --
-- Date:        2017-04-01                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.2                                   --
-- Revision by:                                       --
--                                                    --
-- Description: Register size of Address type         --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity regA is
  port (
    clock           : in    std_logic              := '0';
    reset           : in    std_logic              := '0';
    write_enable    : in    std_logic              := '0';
    data_in         : in    address                := (others => '0');
    data_out        : out   address                := (others => '0')
    );
end entity;

architecture a_regA of regA is
  signal registry : address                := (others => '0');
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
