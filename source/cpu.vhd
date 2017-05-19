library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.minipic.all;

entity cpu is
  port(
    reset               : in    std_logic              := '0';
    err                 : out   std_logic              := '0';
    portA_out           : out   address                := (others => '0');
    portB_out           : out   address                := (others => '0')
    );
end entity;


architecture a_cpu of cpu is
  component pcA is
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
  end component;
  component regA is
    port (
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      write_enable      : in    std_logic              := '0';
      data_in           : in    address                := (others => '0');
      data_out          : out   address                := (others => '0')
      );
  end component;
  component romW is
    port( 
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      write_enable      : in    std_logic              := '0';
      position          : in    address                := (others => '0');
      instruction       : out   word                   := (others => '0')
      );
  end component;
  component ramPxSxA is
    port(
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      write_enable      : in    std_logic              := '0';
      read_enable       : in    std_logic              := '0';
      position          : in    addressP1              := (others => '0');
      data              : inout address                := (others => '0')
      );
  end component;
  component regW is
    port (
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      write_enable      : in    std_logic              := '0';
      data_in           : in    word                   := (others => '0');
      data_out          : out   word                   := (others => '0')
      );
  end component;
  component muxAPx1bit is
    port(
      selection         : in    std_logic              := '0';
      input0            : in    addressP1              := (others => '0');
      input1            : in    addressP1              := (others => '0');
      output            : out   addressP1              := (others => '0')
      );
  end component;
  component stackDxA is
    port (
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      push              : in    std_logic              := '0';
      pop               : in    std_logic              := '0';
      data_in           : in    address                := (others => '0');
      data_out          : out   address                := (others => '0')
      );
  end component;
  component aluA is
    port(
      clock             : in    std_logic              :='0';
      write_enable      : in    std_logic              :='0';
      status            : out   unsigned (2 downto 0)  := (others => '0');
      bit_sel           : in    unsigned (2 downto 0)  := (others => '0');
      selection         : in    alu_opcode             := op_nop;
      input             : in    address                := (others => '0');
      w_in              : in    address                := (others => '0');
      output            : out   address                := (others => '0')
      );
  end component;
  component statusS is
    port (
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      write_enable      : in    std_logic              := '0';
      data_in           : in    address                := (others => '0');
      data_out          : out   address                := (others => '0')
      );
  end component;
  component cuW is
    port (
      clock             : in    std_logic              := '0';
      reset             : in    std_logic              := '0';
      cu2rom_wr         : out   std_logic              := '0';
      cu2ir_wr          : out   std_logic              := '0';
      cu2alu_wr         : out   std_logic              := '0';
      cu2pc_wr          : out   std_logic              := '0';
      cu2w_wr           : out   std_logic              := '0';
      cu2status_wr      : out   std_logic              := '0';
      cu2fsr_wr         : out   std_logic              := '0';
      cu2ram_wr         : out   std_logic              := '0';
      cu2portA_wr       : out   std_logic              := '0';
      cu2portB_wr       : out   std_logic              := '0';
      cu2stack_pop      : out   std_logic              := '0';
      cu2stack_push     : out   std_logic              := '0';
      cu2ram_re         : out   std_logic              := '0';
      cu2mux_ram_sel    : out   std_logic              := '0';
      cu2mux_alu_sel    : out   std_logic              := '0';
      cu2pc_sel2        : out   unsigned (1 downto 0)  := (others => '0');
      cu2alu_bit_sel3   : out   unsigned (2 downto 0)  := (others => '0');
      cu2alu_sel        : out   alu_opcode             := op_nop;
      word_in           : in    word                   := (others => '0')
      );
  end component;

  --bus signals
  signal bus_aluA       : address                      := (others => '0');
  signal clock          : std_logic                    := '0';

  --cu signals
  signal cu2rom_wr      : std_logic                    := '0';
  signal cu2ir_wr       : std_logic                    := '0';
  signal cu2alu_wr      : std_logic                    := '0';
  signal cu2pc_wr       : std_logic                    := '0';
  signal cu2w_wr        : std_logic                    := '0';
  signal cu2status_wr   : std_logic                    := '0';
  signal cu2fsr_wr      : std_logic                    := '0';
  signal cu2ram_wr      : std_logic                    := '0';
  signal cu2portA_wr    : std_logic                    := '0';
  signal cu2portB_wr    : std_logic                    := '0';
  signal cu2stack_pop   : std_logic                    := '0';
  signal cu2stack_push  : std_logic                    := '0';
  signal cu2ram_re      : std_logic                    := '0';
  signal cu2mux_ram_sel : std_logic                    := '0';
  signal cu2mux_alu_sel : std_logic                    := '0';
  signal cu2pc_sel2     : unsigned (1 downto 0)        := (others => '0');
  signal cu2alu_bit_sel3: unsigned (2 downto 0)        := (others => '0');
  signal cu2alu_selAL   : alu_opcode                   := op_nop;

  --pc signals
  signal pc2romA        : address                      := (others => '0');
  signal pc2stackA      : address                      := (others => '0');

  --rom signals
  signal rom2irW        : word                         := (others => '0');

  --ir signals
  signal ir2outW        : word                         := (others => '0');

  --fsr signals
  signal fsr2mux_ramA   : address                      := (others => '0');

  --mux_ram
  signal mux_ram2ramAP  : addressP1                    := (others => '0');

  --mux_alu
  signal mux_alu2aluAP  : addressP1                    := (others => '0');

  --alu signals
  signal alu2status3    : unsigned (2 downto 0)        := (others => '0');
  
  --w signals
  signal w2aluA         : address                      := (others => '0');

  --stack signals
  signal stack2pcA      : address                      := (others => '0');
    
  --status signal
  signal status2outA    : address                      := (others => '0');

  --mixed signals
  signal mix2mux_aluAP  : addressP1                    := (others => '0');
  signal mix2statusA    : address                      := (others => '0');
  signal mix2mux_ram0AP : addressP1                    := (others => '0');
  signal mix2mux_ram1AP : addressP1                    := (others => '0');
begin
-- Mixed signals definition
  mix2mux_aluAP  <= '0' & bus_aluA;
  mix2statusA    <= bus_aluA(memory_size - 1 downto page_bits) & alu2status3;
  mix2mux_ram0AP <= status2outA(memory_size - 2 downto memory_size - 3) & ir2outW(memory_size - 2 downto 0);
  mix2mux_ram1AP <= status2outA(memory_size - 1) & fsr2mux_ramA;

--Program Counter
  pc      :  pcA           port map (clock, reset, cu2pc_wr, cu2pc_sel2, cu2stack_push, cu2stack_pop, bus_aluA, pc2romA, stack2pcA, pc2stackA);
--Read Only Memory
  rom     :  romW          port map (clock, reset, cu2rom_wr, pc2romA, rom2irW);
--Instruction Register
  ir      :  regW          port map (clock, reset, cu2ir_wr, rom2irW, ir2outW);
--Random Access Memory
  ram     :  ramPxSxA      port map (clock, reset, cu2ram_wr, cu2ram_re, mux_ram2ramAP, bus_aluA);
--File Select Register
  fsr     :  regA          port map (clock, reset, cu2fsr_wr, bus_aluA, fsr2mux_ramA);
--Accumulator register
  w       :  regA          port map (clock, reset, cu2w_wr, bus_aluA, w2aluA);
--Stack
  stack   :  stackDxA      port map (clock, reset, cu2stack_push, cu2stack_pop, pc2stackA, stack2pcA);
--Multiplexer to RAM
  mux_ram :  muxAPx1bit    port map (cu2mux_ram_sel, mix2mux_ram0AP, mix2mux_ram1AP, mux_ram2ramAP);
--Multiplexer to ALU
  mux_alu :  muxAPx1bit    port map (cu2mux_alu_sel, ir2outW(memory_size downto 0), mix2mux_aluAP, mux_alu2aluAP);
--Aritimetic Logical Unity
  alu     :  aluA          port map (clock, cu2alu_wr, alu2status3, cu2alu_bit_sel3, cu2alu_selAL,
                                     mux_alu2aluAP(memory_size - 1 downto 0), w2aluA, bus_aluA);
--Status register
  status  :  statusS       port map (clock, reset, cu2status_wr, mix2statusA, status2outA);
--Accumulator register
  portA   :  regA          port map (clock, reset, cu2portA_wr, bus_aluA, portA_out);
--Accumulator register
  portB   :  regA          port map (clock, reset, cu2portB_wr, bus_aluA, portB_out);

--Control Unity
  cu      :  cuW           port map (clock,
                                     reset,
                                     cu2rom_wr,
                                     cu2ir_wr,
                                     cu2alu_wr,
                                     cu2pc_wr,
                                     cu2w_wr,
                                     cu2status_wr,
                                     cu2fsr_wr,
                                     cu2ram_wr,
                                     cu2portA_wr,
                                     cu2portB_wr,
                                     cu2stack_pop,
                                     cu2stack_push,
                                     cu2ram_re,
                                     cu2mux_ram_sel,
                                     cu2mux_alu_sel,
                                     cu2pc_sel2,
                                     cu2alu_bit_sel3,
                                     cu2alu_selAL,
                                     ir2outW
                                     );

  --Clock process
  process
  begin
    wait for clock_time;
    clock <= not(clock);
  end process;
end architecture;
