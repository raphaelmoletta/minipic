-- UNDER DEVELOPMENT

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity statusS is
  port (
    clock             : in    std_logic              := '0';
    reset             : in    std_logic              := '0';
    write_enable      : in    std_logic              := '0';
    alu_write_enable  : in    std_logic              := '0';
    data_in           : in    address                := (others => '0');
    data_out          : out   address                := (others => '0')
    );
end entity;

architecture a_statusS of statusS is
  signal status_reg : address                          := (others => '0');
begin
  process (clock, reset, write_enable)
  begin
    if reset = '1' then
      status_reg <= (others => '0');
    elsif rising_edge(clock) then
      if write_enable = '1' then
        status_reg <= data_in(memory_size - 1 downto memory_size - page_bits) & status_reg(2 downto 0);
      else
        status_reg <= status_reg(memory_size - 1 downto 3) & data_in(2 downto 0);
      end if;
    end if;
  end process;
  data_out <= status_reg;
end architecture;
