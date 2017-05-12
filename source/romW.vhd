--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      romW                                  --
-- Type:        entity                                --
-- Date:        2017-04-10                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.2                                   --
-- Revision by:                                       --
--                                                    --
-- Description: The read only memory that contains all--
--              program instructions                  --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity romW is
  port(
    clock          : in  std_logic              := '0';
    reset          : in  std_logic              := '0';
    write_enable   : in  std_logic              := '0';
    position       : in  address                := (others => '0');
    instruction    : out word                   := (others => '0')
    );
end entity;

architecture a_romW of romW is
begin
  process(clock)
  begin
    if reset = '1' then
      instruction <= (others => '0');
    elsif write_enable = '1' then
      if(rising_edge(clock)) then
        instruction <= memory_data(to_integer(position));
      end if;
    end if;
  end process;
end architecture;
