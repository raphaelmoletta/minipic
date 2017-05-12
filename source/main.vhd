--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      Test Bench                            --
-- Type:        entity                                --
-- Date:        2017-05-15                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.1                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is test bench for project        --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity main is
end entity;

architecture a_main of main is
  component cpu
    port (
      clock : in std_logic                     := '0';
      reset : in std_logic                     := '0'
      );
  end component;
  signal clock : std_logic                     := '0';
  signal reset : std_logic                     := '0';
  
 begin
    uut : cpu port map (clock => clock, reset => reset);

    process
    begin
      wait for 1 ns;
      clock <= not(clock);
    end process;

  process
  begin
    wait for 500 ns;
    reset <= '1';
    wait for 2 ns;
    reset <= '0';
  end process;
end architecture;
