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
    data_in           : in    address                := (others => '0');
    data_out          : out   address                := (others => '0')
    );
end entity;

architecture a_statusS of statusS is
  signal registry : address                          := (others => '0');
begin
  process (clock, reset, write_enable)
  begin
    if reset = '1' then
      registry <= (others => '0');
    elsif rising_edge(clock) then
      if write_enable = '1' then
        registry <= data_in(memory_size - 1 downto memory_size - page_bits) & registry(memory_size - page_bits - 1 downto 0);
      end if;
      registry <= registry(memory_size - 1 downto 3) & data_in(2 downto 0);
    end if;
  end process;
  data_out <= registry;
end architecture;
