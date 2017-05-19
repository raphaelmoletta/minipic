--------------------------------------------------------
-- Project:     Mini PIC                              --
-- Module:      minipic                               --
-- Type:        Package                               --
-- Date:        2017-05-09                            --
-- Author:      Raphael Zagonel Moletta               --
-- Version:     0.1                                   --
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
  type alu_opcode is (op_inc, op_add, op_dec, op_sub, op_and, op_or, op_xor, op_com, op_swap, op_rl, op_rr,  op_nop, op_zero, op_movw,
                      op_bc, op_bs, op_btc, op_bts);
  type instructions is (addwf, andwf, clrf, clrw, comf, decf, decfsz, incf, incfsz, iorwf, movf, movwf, nop, rlf, rrf, subwf, swapf,
                        xorwf, bcf, bsf, btfsc, btfss, addlw, andlw, i_call, clrwdt, i_goto, iorlw, movlw, retfie, retlw, i_return, i_sleep,
                        sublw, xorlw);
  type pc_selection is (pc_address, pc_one, pc_two, pc_stack);
  type microinstructions is array (0 to 6) of unsigned(19 downto 0);

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
    movwf       => op_movw,
    others      => op_nop
    );
  
  --------------------- PROGRAM BLOCK --------------------
  --Type for memory ROM
  type rom_memory is array (0 to 256) of word;
  --Contains the program instructions
  constant memory_data : rom_memory := (
    0   => B"11111000001000",           -- addlw 8
    1   => B"11110000000001",           -- sublw 1
    2   => B"11101000000001",           -- xorlw 1
    3   => B"11100000000001",           -- iorlw 1
    4   => B"11100100000011",           -- andlw 3
    5   => B"11000011111111",           -- movlw 255
    6   => B"00000000000000",           -- nop
    7   => B"10100000001010",           -- goto 0x0A
    8   => B"00000000000000",           -- nop
    9   => B"00000000000000",           -- nop
    10  => B"10000000001011",           -- call 0x0B
    11  => B"11000000000001",           -- movlw 1
    12  => B"01000000000001",           -- bcf 1
    13  => B"00000100000000",           -- clrw
    14  => B"11000000000010",           -- movlw 2
    15  => B"00000010000010",           -- movwf 2
    16  => B"00000110000010",           -- clrf 1
    17  => B"00000000001000",           -- return
    others => (others => '0')
    );
end package;

package body minipic is
  function cpu_microcode (signal inst : instructions)
    return microinstructions is
    begin
      if inst = addlw or inst = andlw or inst = iorlw or inst = movlw or inst = sublw or inst = xorlw then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_1000_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = movwf then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_0001_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = bcf then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0000_0000_0000_1_00_00_000",
        3 => B"0011_0001_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = clrf then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_0001_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = clrw then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_1000_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = i_return then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0000_0000_0010_0_00_00_000",
        3 => B"0001_0000_0000_0_00_11_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = addwf or inst = andwf or inst = subwf or inst = xorwf then return(--NOT WORKING
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0000_0001_0000_0_00_00_000",
        3 => B"0011_0000_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = i_goto then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_0000_0000_0_00_10_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      elsif inst = i_call then return (
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0010_0000_0000_0_00_00_000",
        3 => B"0011_0000_0001_0_00_10_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000");
      else return (                  --nop
        0 => B"1000_0000_0000_0_00_00_000",
        1 => B"0100_0000_0000_0_00_00_000",
        2 => B"0000_0000_0000_0_00_00_000",
        3 => B"0001_0000_0000_0_00_00_000",
        4 => B"0000_0000_0000_0_00_00_000",
        5 => B"0000_0000_0000_0_00_00_000",
        6 => B"0000_0000_0000_0_00_00_000" );
    end if;  
  end function cpu_microcode;
    
  --Implementation of alu_function. Changes are allowed to modify the ALU's operations.
  function alu_function (w_in, input : in unsigned(memory_size downto 0); selection : in alu_opcode; bit_sel : in unsigned(2 downto 0))
    return unsigned is
    variable output : unsigned(memory_size downto 0) := (others => '0');
    variable middle : integer := memory_size / 2;
  begin
    case selection is
      --Increment
      when op_inc   => output := input + 1;
      --Addition
      when op_add   => output := input + w_in;
      --Decrement
      when op_dec   => output := input - 1;
      --Subtraction
      when op_sub   => output :=  w_in - input;
      --Logical AND
      when op_and   => output := input and w_in;
      --Logical OR
      when op_or    => output := input or w_in;
      --Logical XOR
      when op_xor   => output :=  input xor w_in;
      --Logical NOT for bus
      when op_com   => output := not input;
      --Swap nibbles
      when op_swap  => output := input(middle-1 downto 0) & input(memory_size-1 downto middle);
      --Rotate to left 1 bit
      when op_rl    => output := input sll 1;
      --Rotate to right 1 bit
      when op_rr    => output := input srl 1;
      --Clear bit on bit_sel's position
      when op_bc    => output := input; output(to_integer(bit_sel)) := '0';
      --Set bit on bit_sel's position
      when op_bs    => output := input; output(to_integer(bit_sel)) := '1';
      --Test if bit is clear on bit_sel's positon, return 0 if true
      when op_btc   => if input(to_integer(bit_sel)) = '0' then
                         output := (others => '1');
                       else
                         output := (others => '0');
                       end if;
      --Test if bit is set on bit_sel's positon, return 0 if true
      when op_bts   => if input(to_integer(bit_sel)) = '1' then
                         output := (others => '1');
                       else
                         output := (others => '0');
                       end if;
      --No operation is executate
      when op_nop   => output := input;
      --Move w's content to bus
      when op_movw  => output := w_in;
      --Set zero
      when op_zero  => output := (others => '0');
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
