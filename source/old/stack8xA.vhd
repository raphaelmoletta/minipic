--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      stack8xA                              --
-- Type:        entity                                --
-- Date:        2017-04-27                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.1                                   --
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

entity stack8xA is
  port (
    clock           : in    std_logic              := '0';
    reset           : in    std_logic              := '0';
    push            : in    std_logic              := '0';
    pop             : in    std_logic              := '0';
    err             : out   std_logic              := '0';
    data_in         : in    address                := (others => '0');
    data_out        : out   address                := (others => '0')
    );
end entity;

architecture a_stack8xA of stack8xA is
  type memory is array (7 downto 0) of address;
  
  signal stack       : memory                                  := (others => (others => '0'));
  signal pointer     : integer range 7 downto 0                :=  0;
  signal empty       : std_logic                               := '1';
  signal full        : std_logic                               := '0';
  
begin
  process(reset, clock, data_in)
  begin
    data_out <= data_in;
    if reset = '1' then
      stack <= (others => (others => '0'));
      full <= '0';
      empty <= '1';
      pointer <= 0;
      err <= '0';
    elsif rising_edge(clock) then
      if push = '1' and pop = '1' then         -- invalid state case
        --ERROR invalid state
        err <= '1';
      elsif push = '0' and pop = '1' then      -- pop case
        -- ERROR pop on empty stack
        full <= '0';
        if empty = '1' then
          err <= '1';
        else
          data_out <= stack(pointer);
          if pointer > 0 and full = '0' then
            pointer <= pointer - 1;
          else
            empty <= '1';
            pointer <= pointer;
          end if;
        end if;
      elsif push = '1' and pop = '0' then      --push case
        if full = '1' then
          --ERROR stackoverflow
          err <= '1';
        else
          empty <= '0';
          stack(pointer) <= data_in + 1;
          if pointer < 7 then
            pointer <= pointer + 1;
          else
            pointer <= pointer;
            full <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;


