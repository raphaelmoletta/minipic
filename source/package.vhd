--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      minipic                               --
-- Type:        Package                               --
-- Date:        2017-05-09                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.8.5                                 --
-- Revision by:                                       --
--                                                    --
-- Description: Contains all configuration to         --
--   processor. Memory sizes, Instruction size, alu   --
--   procedure, control unit procedure. This file     --
--   remove all need to change any other file.        --
--                                                    --
-- Observation: Must be the first module to compile   --
--                                                    --
-- See: Mini PIC Developer Manual.pdf                 --
-- See: Mini PIC Coding Style and best pratices.pdf   --
-- See: Mini Pic ISA.pdf                              --
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package minipic is 
  --------------------- TYPE BLOCK --------------------
  --Codes to correct ALU's operations
  type alu_opcode is (op_inc, op_add, op_dec, op_sub, op_and, op_or, op_xor, op_com, op_swap, op_rl, op_rr,  op_nop, op_zero, op_nopw,
                      op_bc, op_bs, op_btc, op_bts);
  type instructions is (addwf, andwf, clrf, clrw, comf, decf, decfsz, incf, incfsz, iorwf, movf, movwf, nop, rlf, rrf, subwf, swapf,
                        xorwf, bcf, bsf, btfsc, btfss, addlw, andlw, i_call, clrwdt, i_goto, iorlw, movlw, retfie, retlw, i_return, i_sleep,
                        sublw, xorlw);
  type pc_selection is (pc_address, pc_one, pc_two, pc_stack);
  type microinstructions is array (0 to 4) of unsigned(16 downto 0);

  --------------------- CONSTANTS BLOCK --------------------
  --Size of all processors' memory and memory bus. Allowed change in constant value.
  constant memory_size       : integer                  := 8;
  --Size of instructions to Harvard Architecture. Allowed change in constant value.
  constant instructions_size : integer                  := 14;
  --Number of pages on RAM memory. Allowed change in constant value.
  constant pages             : integer                  := 8;
  --Number of bits for pages on RAM memory. Allow change in constant value.
  constant page_bits         : integer                  := 3;
  --Size of each page in RAM memory. Allowed change in constant value.
  constant page_size         : integer                  := 128;
  --Number of elements of stack
  constant stack_deep        : integer                  := 8;
  --Clock to each step of processor. Allowed change in constant value.
  constant clock_time        : time                     := 1 ns;

  --------------------- SUBTYPE BLOCK --------------------
  --DO NOT CHANGE. Define the bus and the memory's type.
  subtype address        is unsigned (memory_size-1       downto 0);
  --DO NOT CHANGE. Define the bus and the memory's type.
  subtype addressP1      is unsigned (memory_size         downto 0);
  --DO NOT CHANGE. Define the type to instructions.
  subtype word           is unsigned (instructions_size-1 downto 0);
  --Define the type to address page of memory. Change to number of bytes requested
  --to acommodate the number of 'pages'.
  subtype memory_page    is unsigned (page_bits - 1 downto 0);
  --TODO not implemented yet.
  subtype direct_address is unsigned (6 downto 0);

  --------------------- FUNCTION BLOCK --------------------
  --Function called by ALU on operation
  function alu_function (w_in, input : in unsigned(memory_size downto 0); selection : in alu_opcode; bit_sel : in unsigned(2 downto 0)) return unsigned;
  function instruction_type (instruction : in word) return instructions;
  function cpu_microcode (signal inst : instructions) return microinstructions;
  function memory_destiny (microcode : unsigned(16 downto 0); word_in : word; inst : instructions; state : integer) return unsigned;

type aluop_microinstructions is array (addwf to xorlw) of alu_opcode;
  constant alu_op : aluop_microinstructions := (
    addwf       => op_add,
    andwf       => op_and,
    clrf        => op_zero,
    clrw        => op_zero,
    comf        => op_com,
    decf        => op_dec,
    decfsz      => op_dec,
    incf        => op_inc,
    incfsz      => op_inc,
    iorwf       => op_or,
    rlf         => op_rl,
    rrf         => op_rr,
    subwf       => op_sub,
    swapf       => op_swap,
    xorwf       => op_xor,
    bcf         => op_bc,
    bsf         => op_bs,
    btfsc       => op_btc,
    btfss       => op_bts,
    addlw       => op_add,
    andlw       => op_and,
    clrwdt      => op_zero,
    iorlw       => op_or,
    sublw       => op_sub,
    xorlw       => op_xor,
    movwf       => op_nopw,
    others      => op_nop
    );
  
  --------------------- PROGRAM BLOCK --------------------
  --Type for memory ROM
  type rom_memory is array (0 to 256) of word;
  --Contains the program instructions
  constant memory_data : rom_memory := (
    --START FULFILL TABLE
    0   => B"11_0000_0000_1100",        --movlw 0c                      w = 12
    1   => B"00_0000_1000_0100",        --movwf fsr                     fsr = w
    2   => B"00_0000_1000_1001",        --movwf 9                       firstPosition = w
    3   => B"11_0000_0010_0000",        --movlw 32                      w = 32
    4   => B"00_0000_1000_1000",        --movwf 8                       size = w
    5   => B"00_0000_1000_1010",        --movwf 0a                      count1 = w
    6   => B"11_0000_0000_0001",        --movlw 1                       w = 1
    7   => B"00_0000_1000_0111",        --movwf 7                       next = w
    8   => B"00_0000_1000_0000",        --movwf indf                    array[fsr] = w
    9   => B"00_1010_1000_0100",        --inc fsr                       fsr++
    10  => B"11_1110_0000_0001",        --addlw 1                       w++
    11  => B"00_1011_1000_1010",        --decfsz 0A                     if count1 - 1 = 0 exit loop
    12  => B"10_1000_0000_1000",        --goto 8                        loop line 8
    --END OF FULFILL TABLE / START BODY
    13  => B"00_1000_0000_1000",        --movf 8, w                     w = size // 32
    14  => B"00_0000_1000_1010",        --movwf 0a                      count1 = w
    15  => B"00_1000_0000_1000",        --movf 8, w                     w = size // 32
    16  => B"00_0000_1000_1011",        --movwf 0b                      count2 = w
    17  => B"00_1000_0000_1001",        --movf 9, w                     w = firstPosition
    18  => B"00_0000_1000_0100",        --movwf FSR                     fsr = w
    19  => B"00_1000_0000_0111",        --movf 7, w                     w = next
    20  => B"00_0111_1000_0100",        --addwf fsr, f                  fsr += w
    21  => B"00_1010_1000_0111",        --incf 7                        next++
    22  => B"00_1000_0000_0000",        --movf INDF, W                  w = array[fsr]
    23  => B"01_1101_0000_0011",        --btfss status, zero            if w = 0 skip
    24  => B"10_0000_0001_1100",        --call 28                       call functionEliminate
    25  => B"00_1011_1000_1011",        --decfsz 11, w                  if count1 - 1 = 0 skip
    26  => B"10_1000_0000_1111",        --goto 15                       loop line 15
    27  => B"10_1000_0010_1010",        --goto 42                       goto remove zeros
    --END BODY / START FUNCTION ELIMINATE
    28  => B"00_0000_0000_0000",        --movf 9, w                     w = firstPosition
    29  => B"00_0000_0000_0000",        --movwf fsr                     fsr = w
    30  => B"00_1000_0000_0111",        --movf 7, w                     w = next
    31  => B"00_0111_1000_0100",        --addwf fsr, f                  fsr += w
    32  => B"00_1000_0000_0000",        --movf INDF, W                  w = array[fsr]
    33  => B"00_0001_1000_0000",        --clrf INDF                     array[fsr] = 0
    34  => B"00_0000_1100_0000",        --movwf tmp                     tmp = w
    35  => B"00_1000_0000_1011",        --movf 11, w                    w = cont2
    36  => B"00_0010_0000_0111",        --subwf 11, w                   cont2 -= w
    37  => B"01_1000_0000_0011",        --btfsc                         if status = zero skip
    38  => B"00_0000_0000_1000",        --return                        return call
    39  => B"00_0000_1000_1011",        --movwf 11                      cont2 = w
    40  => B"00_1000_0100_0000",        --movf tmp, w                   w = tmp
    41  => B"10_1000_0001_1110",        --goto 30                       loop line 30
    --END FUNCTION ELIMINATE / START REMOVE ZEROS
    42  => B"00_1010_1000_1001",        --incf 9                        firstPosition++
    43  => B"00_1000_0000_1001",        --movf 9, w                     w = firstPosition
    44  => B"00_0000_1000_0100",        --movwf fsr                     fsr = w
    45  => B"00_1000_0000_1000",        --movf 8, w                     w = size // 32
    46  => B"00_0000_1000_1010",        --movwf 0a                      count1 = w
    47  => B"00_1000_0000_0000",        --movf INDF, W                  w = array[fsr]
    48  => B"01_1001_0000_0011",        --btfss                         if status != zero skip
    49  => B"10_0000_0011_0110",        --call 54                       call searchNoZero
    50  => B"00_1010_1000_0100",        --incf fsr, f                   fsr++
    51  => B"00_1011_1000_1010",        --decfsz 10, w                  if count1 - 1 = 0 skip
    52  => B"10_1000_0010_1111",        --goto 47                       loop line 47
    53  => B"10_1000_0100_1000",        --goto 72                       goto print
    --END REMOVE ZEROS / START searchNoZero
    54  => B"00_1000_0000_1010",        --movf 0a, w                    w = count1
    55  => B"00_0000_1000_1011",        --movwf 0b                      count2 = w
    56  => B"00_1000_0000_0100",        --movf fsr, w                   w = fsr
    57  => B"00_0000_1000_0111",        --movwf 7                       next = w
    58  => B"00_1010_1000_0100",        --incf fsr, f                   fsr++
    59  => B"00_1011_1000_1011",        --decfsz 11, w                  if count2 - 1 = 0 skip
    60  => B"10_1000_0011_1110",        --goto 62                       loop line 62
    61  => B"00_0000_0000_1000",        --return                        return call
    62  => B"00_1000_0000_0000",        --movf INDF, W                  w = array[fsr]
    63  => B"01_1001_0000_0011",        --btfsc                         if status = zero skip
    64  => B"10_1000_0011_1010",        --goto 58                       loop line 58
    65  => B"00_0000_1111_1111",        --movwf 127                     tmp = w
    66  => B"00_0001_1000_0000",        --clrf INDF                     array[fsr] = 0
    67  => B"00_1000_0000_0111",        --movf next, w                  w = next
    68  => B"00_0000_1000_0100",        --movwf fsr, f                  fsr = w
    69  => B"00_1000_0111_1111",        --movf tmp, w                   w = tmp
    70  => B"00_0000_1000_0000",        --movwf INDF, f                 array[fsr] = w
    71  => B"00_0000_0000_1000",        --return                        return call
    --END searchNoZero / START print
    72  => B"00_1000_0000_1001",        --movf 9, w                     w = firstPosition
    73  => B"00_0000_1000_0100",        --movwf fsr                     fsr = w
    74  => B"00_1000_0000_1000",        --movf 8, w                     w = size // 32
    75  => B"00_0000_1000_1010",        --movwf 0a                      count1 = w
    76  => B"00_0011_1000_1010",        --decf cont1, f                 count1--
    77  => B"00_1000_0000_0000",        --movf INDF, W                  w = array[fsr]
    78  => B"00_0000_1000_0101",        --movwf porta, f                porta = w
    79  => B"00_0000_1000_0110",        --movwf portb, f                portb = w
    80  => B"00_1010_1000_0100",        --incf fsr, f                   fsr++
    81  => B"00_1011_1000_1010",        --decfsz count1, f              if count2 - 1 = 0 skip
    82  => B"10_1000_0100_1101",        --goto 77                       loop line 77
    83  => B"00_0000_0000_0000",        --nop
    84  => B"10_1000_0101_0100",        --goto 83                       loop line 83
    
    others => (others => '0')
    );
end package;

package body minipic is
  function cpu_microcode (signal inst : instructions)
    return microinstructions is
  begin
    if inst = addlw or inst = andlw or inst = iorlw or inst = movlw or inst = sublw or inst = xorlw then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_1000_0000_0_00_00",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = movwf then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_0000_0000_0_00_00",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = bcf or inst = bsf then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0001_0000_0000_1_00_00",
      3 => B"0010_0000_0000_0_01_00",
      4 => B"0000_0001_0000_0_00_00");
    elsif inst = btfsc or inst = btfss then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0000_0000_0000_1_00_00",
      3 => B"0010_0000_0000_0_01_00",
      4 => B"0001_0000_0000_0_00_01");
    elsif inst = clrf then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_0001_0000_0_00_00",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = clrw then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_1000_0000_0_00_00",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = retlw then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0000_0000_0010_0_00_00",
      3 => B"0011_0000_0000_0_00_11",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = i_return then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0010_0_00_00",
      3 => B"0011_0000_0000_0_00_11",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = addwf or inst = andwf or inst = comf or inst = decf or inst = incf or inst = iorwf or
      inst = movf  or inst = rlf  or inst = rrf  or inst = subwf  or inst = swapf  or inst = xorwf then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0000_0000_0000_1_00_00",
      3 => B"0011_0000_0000_0_01_00",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = decfsz or inst = incfsz then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0000_0000_0000_1_00_00",
      3 => B"0010_0000_0000_0_01_00",
      4 => B"0001_0000_0000_0_00_01");
    elsif inst = i_goto then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_0000_0000_0_00_10",
      4 => B"0000_0000_0000_0_00_00");
    elsif inst = i_call then return (
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0010_0000_0000_0_00_00",
      3 => B"0011_0000_0001_0_00_10",
      4 => B"0000_0000_0000_0_00_00");
    else return (                  --nop
      0 => B"1000_0000_0000_0_00_00",
      1 => B"0100_0000_0000_0_00_00",
      2 => B"0000_0000_0000_0_00_00",
      3 => B"0001_0000_0000_0_00_00",
      4 => B"0000_0000_0000_0_00_00");
    end if;  
  end function cpu_microcode;

  function memory_destiny (microcode : unsigned(16 downto 0); word_in : word; inst : instructions; state : integer) return unsigned is
    variable ucode : unsigned(16 downto 0) := microcode;
  begin
    if (inst = addwf or inst = andwf or inst = comf or inst = decf or inst = decfsz or inst = incf or inst = incfsz or
       inst = iorwf or inst = movf  or inst = rlf  or inst = rrf  or inst = subwf  or inst = swapf  or inst = xorwf or inst = movwf) and state = 4 then
      if word_in(7) = '0' then
        return microcode or B"0000_1000_0000_0_00_00";
      else
        if word_in(6 downto 0) = B"0000101" then  -- port A --05h
          ucode := microcode or B"0000_0001_1000_0_00_00";
        elsif word_in(6 downto 0) = B"0000110" then  -- port B --06h
          ucode :=  microcode or B"0000_0001_0100_0_00_00";
        elsif word_in(6 downto 0) = B"0000011" then  -- status --03h
          ucode := microcode or B"0000_0101_0000_0_00_00";
        elsif word_in(6 downto 0) = B"0000100" then  -- fsr --04h
          ucode := microcode or B"0000_0011_0000_0_00_00";
        else
          ucode := microcode or B"0000_0001_0000_0_00_00";
        end if;
      end if;
    else
      ucode := microcode;
    end if;
    if word_in(6 downto 0) = B"0000000" and (ucode(4) = '1' or ucode(9) = '1') then
      return (ucode or B"0000_0000_0000_0_10_00");
    else
      return ucode;
    end if;
  end function memory_destiny;                                                                                               
    
  --Implementation of alu_function. Changes are allowed to modify the ALU's operations.
  function alu_function (w_in, input : in unsigned(memory_size downto 0); selection : in alu_opcode; bit_sel : in unsigned(2 downto 0))
    return unsigned is
    variable output : unsigned(memory_size downto 0) := (others => '0');
    variable middle : integer := memory_size / 2;
  begin
    case selection is
      --Increment
      when op_inc    => output := input + 1;
      --Addition
      when op_add    => output := input + w_in;
      --Decrement
      when op_dec    => output := input - 1;
      --Subtraction
      when op_sub    => output :=  w_in - input;
      --Logical AND
      when op_and    => output := input and w_in;
      --Logical OR
      when op_or     => output := input or w_in;
      --Logical XOR
      when op_xor    => output :=  input xor w_in;
      --Logical NOT for bus
      when op_com    => output := not input;
      --Swap nibbles
      when op_swap   => output := input(middle-1 downto 0) & input(memory_size-1 downto middle);
      --Rotate to left 1 bit
      when op_rl     => output := input sll 1;
      --Rotate to right 1 bit
      when op_rr     => output := input srl 1;
      --Clear bit on bit_sel's position
      when op_bc     => output := input; output(to_integer(bit_sel)) := '0';
      --Set bit on bit_sel's position
      when op_bs     => output := input; output(to_integer(bit_sel)) := '1';
      --Test if bit is clear on bit_sel's positon, return 0 if true
      when op_btc    => if input(to_integer(bit_sel)) = '0' then
                          output := B"000000000";
                        else
                          output := B"000000001";
                        end if;
      --Test if bit is set on bit_sel's positon, return 0 if true
      when op_bts    => if input(to_integer(bit_sel)) = '1' then
                          output := B"000000000";
                        else
                          output := B"000000001";
                        end if;
      --No operation is executate
      when op_nop    => output := input;
      --Move w's content to bus
      when op_nopw   => output := w_in;
      --Set zero
      when op_zero   => output := (others => '0');
    end case;
    return output;
  end function;

  -- function instruction_type
  function instruction_type (instruction : in word)
    return instructions is
  begin
    if instruction = B"00_0000_0000_0000" or instruction = B"00_0000_0010_0000" or
       instruction = B"00_0000_0100_0000" or instruction = B"00_0000_0110_0000" then
      return nop;
    elsif instruction = B"00_0000_0110_0100" then
      return clrwdt;
    elsif instruction = B"00_0000_0000_1000" then
      return i_return;
    elsif instruction = B"00_0000_0110_0011" then
      return i_sleep;
    elsif instruction = B"00_0000_0000_1001" then
      return retfie;
    elsif instruction(13 downto 7) = B"00_0001_1" then
      return clrf;
    elsif instruction(13 downto 7) = B"00_0001_0" then
      return clrw;
    elsif instruction(13 downto 7) = B"00_0000_1" then
      return movwf;
    elsif instruction(13 downto 8) = B"00_1000" then
      return movf;
    elsif instruction(13 downto 8) = B"00_0111" then
      return addwf;
    elsif instruction(13 downto 8) = B"00_0101" then
      return andwf;
    elsif instruction(13 downto 8) = B"00_1001" then
      return comf;
    elsif instruction(13 downto 8) = B"00_0011" then
      return decf;
    elsif instruction(13 downto 8) = B"00_1011" then
      return decfsz;
    elsif instruction(13 downto 8) = B"00_1010" then
      return incf;
    elsif instruction(13 downto 8) = B"00_1111" then
      return incfsz;
    elsif instruction(13 downto 8) = B"00_0100" then
      return iorwf;
    elsif instruction(13 downto 8) = B"00_1101" then
      return rlf;
    elsif instruction(13 downto 8) = B"00_1100" then
      return rrf;
    elsif instruction(13 downto 8) = B"00_0010" then
      return subwf;
    elsif instruction(13 downto 8) = B"00_1110" then
      return swapf;
    elsif instruction(13 downto 8) = B"11_1001" then
      return andlw;
    elsif instruction(13 downto 8) = B"11_1000" then
      return iorlw;
    elsif instruction(13 downto 8) = B"11_1010" then
      return xorlw;
    elsif instruction(13 downto 9) = B"11_111" then
      return addlw;
    elsif instruction(13 downto 9) = B"11_110" then
      return sublw;
    elsif instruction(13 downto 10) = B"01_00" then
      return bcf;
    elsif instruction(13 downto 10) = B"01_01" then
      return bsf;
    elsif instruction(13 downto 10) = B"01_10" then
      return btfsc;
    elsif instruction(13 downto 10) = B"01_11" then
      return btfss;
    elsif instruction(13 downto 10) = B"11_00" then
      return movlw;
    elsif instruction(13 downto 10) = B"11_01" then
      return retlw;
    elsif instruction(13 downto 11) = B"10_0" then
      return i_call;
    elsif instruction(13 downto 11) = B"10_1" then
      return i_goto;
    else
      return nop;
    end if;
  end function instruction_type;
end package body;
