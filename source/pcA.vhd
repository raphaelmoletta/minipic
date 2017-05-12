--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      pcA                                   --
-- Type:        entity                                --
-- Date:        2017-05-09                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.6                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is the program counter           --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity pcA is
  port (
    clock           : in    std_logic              := '0';
    reset           : in    std_logic              := '0';
    write_enable    : in    std_logic              := '0';
    selection       : in    std_logic              := '0';
    data_in         : in    address                := (others => '0');
    data_out        : out   address                := (others => '0');
    stack_in        : in    address                := (others => '0');
    stack_out       : out   address                := (others => '0')
    );
end entity;

architecture a_pcA of pcA is
  signal registry : address                        := (others => '0');
begin
  stack_out <= data_in;
  process (clock, reset, write_enable)
  begin
    if reset = '1' then
      registry <= (others => '0');
    elsif write_enable = '1' then
      if rising_edge(clock) then
        if selection = '0' then
          registry <= registry + 1;
        else
          registry <= stack_in;
        end if;
      end if;
    end if;
  end process;
  data_out <= registry;
end architecture;
