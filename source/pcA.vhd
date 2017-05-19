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
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    write_enable      : in    std_logic              := '0';
    selection         : in    unsigned(1 downto 0)   := B"00";
    push              : in    std_logic              := '0';
    pop               : in    std_logic              := '0';
    data_in           : in    address                := (others => '0');
    data_out          : out   address                := (others => '0');
    stack_in          : in    address                := (others => '0');
    stack_out         : out   address                := (others => '0')
    );
end entity;

architecture a_pcA of pcA is
  signal registry     : address                      := (others => '0');
begin
  process (clock, reset) is
  begin
    if reset = '1' then
      registry <= (others => '0');
    elsif write_enable = '1' then
      if rising_edge(clock) then
        case selection is
          when B"00"          => registry <= registry + 1;
          when B"01"          => registry <= registry + 1 + data_in;
          when B"10"          => registry <= data_in;
          when B"11"          => registry <= stack_in;
          when others => null;
        end case;
      end if;
    end if;
  end process;
  data_out  <= registry;
  stack_out <= data_in;
end architecture;
