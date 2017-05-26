---------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      ramPxSxA                              --
-- Type:        entity                                --
-- Date:        2017-05-08                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.4                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is the RAM unit for project      --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity ramPxSxA is
  port(
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    write_enable      : in    std_logic              := '0';
    read_enable       : in    std_logic              := '0';
    status_in         : in    address                := (others => '0');
    position          : in    addressP1              := (others => '0');
    data              : inout address                := (others => 'Z')
    );
end entity;

architecture a_ramPxSxA of ramPxSxA is
  type memory is array (0 to 511) of address;
  signal ram : memory                                             := (others => (others => '0'));
begin
  process(clock, reset)
  begin
    
    if reset = '1' then
      ram <= (others => (others => '0'));
      data <= (others => 'Z');
    elsif write_enable = '1' then
      if rising_edge(clock) then
        ram(to_integer(position)) <= data;
      end if;
    elsif read_enable = '1' then
      if rising_edge(clock) then
        if position(6 downto 0) = B"0000011" then
          data <= status_in;
        else
          data <= ram(to_integer(position));
        end if;
      end if;
    else
      if rising_edge(clock) then
        data <= (others => 'Z');
      end if;
    end if;
  end process;
end architecture;
