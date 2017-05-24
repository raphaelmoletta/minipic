--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      stackDxA                              --
-- Type:        entity                                --
-- Date:        2017-05-18                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.2                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is the stack for call and goto   --
--              instructions                          --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------


--TODO change stack size to constant in minipic package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity stackDxA is
  port (
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    push              : in    std_logic              := '0';
    pop               : in    std_logic              := '0';
    data_in           : in    address                := (others => '0');
    data_out          : out   address                := (others => '0')
    );
end entity;

architecture a_stackDxA of stackDxA is
  type memory is array (stack_deep - 1 downto 0) of address;
  signal registry     : address                      := (others => '0');
  signal stack        : memory                       := (others => (others => '0'));
  signal pointer      : unsigned (2 downto 0)        := (others => '0');
  
begin
  process(clock, reset)
  begin
    if reset = '1' then
      stack      <= (others => (others => '0'));
      pointer    <= (others => '0');
      registry   <= (others => '0');
    elsif rising_edge(clock) then
      if pop = '1' then
        registry <= stack(to_integer(pointer - 1));
        pointer  <= pointer - 1;
      elsif push = '1' then
        stack(to_integer(pointer)) <= (data_in + 1);
        pointer  <= pointer + 1;
      end if;
    end if;
  end process;
  data_out       <= registry;
end architecture;


