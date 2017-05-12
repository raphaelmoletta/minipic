--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      muxAx1bit                             --
-- Type:        entity                                --
-- Date:        2017-05-09                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.5                                   --
-- Revision by:                                       --
--                                                    --
-- Description: This is the control unit for project  --
--                                                    --
-- Observation:                                       --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity muxAPx1bit is
  port(
    selection       : in    std_logic              := '0';
    input0          : in    addressP1              := (others => '0');
    input1          : in    addressP1              := (others => '0');
    output          : out   addressP1              := (others => '0')
    );
end entity;

architecture a_muxAPx1bit of muxAPx1bit is
begin
  output <= input0 when selection = '0' else
            input1;
end architecture;

       
       
