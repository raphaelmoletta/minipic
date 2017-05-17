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
      reset               : in    std_logic              := '0';
      err                 : out   std_logic              := '0';
      portA_out           : out   address                := (others => '0');
      portB_out           : out   address                := (others => '0')
      );
  end component;
  
  signal reset, err       :       std_logic              := '0';
  signal portA_out        :       address                := (others => '0');
  signal portB_out        :       address                := (others => '0');
  
 begin
    uut : cpu port map (reset, err, portA_out, portB_out);

  process
  begin
    wait for 500 ns;
    reset <= '1';
    wait for 2 ns;
    reset <= '0';
  end process;
end architecture;
