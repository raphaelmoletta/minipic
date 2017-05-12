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
  type alu_opcode is (op_inc, op_add, op_dec, op_sub, op_and, op_or, op_xor, op_com, op_swap, op_rl, op_rr,  op_nop, op_zero);

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
  function alu_function (w_in, input : in unsigned(memory_size downto 0); selection : in alu_opcode) return unsigned;
  
  --------------------- PROCEDURE BLOCK --------------------

  procedure cu_pc_procedure (signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                             signal alu_sel                                                 : out alu_opcode;
                             signal ir                                                      : in word
                            );

  procedure cu_rom_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                             signal alu_sel                                                 : out alu_opcode;
                             signal ir                                                      : in word
                            );

  procedure cu_ir_procedure (signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                             signal alu_sel                                                 : out alu_opcode;
                             signal ir                                                      : in word
                            );

  procedure cu_mem_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                             signal alu_sel                                                 : out alu_opcode;
                             signal ir                                                      : in word
                            );
  --------------------- PROGRAM BLOCK --------------------
  --Type for memory ROM
  type rom_memory is array (0 to 256) of word;
  --Contains the program instructions
  constant memory_data : rom_memory := (
    0   => B"11000000001000",
    1   => B"11111111111110",
    2   => B"00000000000100",
    3   => B"11111111111100",
    4   => B"00000000000110",
    5   => B"11111111111010",
    6   => B"00000000001000",
    7   => B"11111111111000",
    8   => B"00000000001010",
    9   => B"11111111110110",
    10  => B"00000000001100",
    others => (others => '0')
  );
end package;

package body minipic is
  --Implementation of alu_function. Changes are allowed to modify the ALU's operations.
  function alu_function (w_in, input : in unsigned(memory_size downto 0); selection : in alu_opcode) return unsigned is
    variable output : unsigned(memory_size downto 0) := (others => '0');
    variable middle : integer := memory_size / 2;
  begin
    case selection is
      --Increment
      when op_inc => output := input + 1;
      --Addition
      when op_add => output := input + w_in;
      --Decrement
      when op_dec => output := input - 1;
      --Subtraction
      when op_sub => output :=  w_in - input;
      --Logical AND
      when op_and => output := input and w_in;
      --Logical OR
      when op_or => output := input or w_in;
      --Logical XOR
      when op_xor => output :=  input xor w_in;
      --Logical NOT for bus
      when op_com => output := not input;
      --Swap nibbles
      when op_swap => output := input(middle-1 downto 0) & input(memory_size-1 downto middle);
      --Rotate to left 1 bit
      when op_rl => output := input sll 1;
      --Rotate to right 1 bit
      when op_rr => output := input srl 1;
      --No operation is executate
      when op_nop => output := input;
      --Set zero
      when op_zero => output := (others => '0');
    end case;
    return output;
  end function;

  function cu_function (signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : in std_logic;
                            signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : in std_logic;
                            signal alu_sel                                                 : in alu_opcode;
                            signal ir                                                      : in word
                        ) return std_logic is begin
      
  end function cu_function;
  procedure cu_pc_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                            signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                            signal alu_sel                                                 : out alu_opcode;
                            signal ir                                                      : in word
                           ) is begin

  end procedure cu_pc_procedure;

  procedure cu_rom_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push: out std_logic;
                             signal alu_sel                                                : out alu_opcode;
                             signal ir                                                     : in word
                            ) is begin
    
  end procedure cu_rom_procedure;
  
  procedure cu_ir_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                 : out std_logic;
                            signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push : out std_logic;
                            signal alu_sel                                                 : out alu_opcode;
                            signal ir                                                      : in word
                           ) is begin
                                   
  end procedure cu_ir_procedure;
  
  procedure cu_mem_procedure(signal w_wr, ram_wr, fsr_wr, status_wr, ram_re                : out std_logic;
                             signal pc_sel, mux_alu_sel, mux_ram_sel, stack_pop, stack_push: out std_logic;
                             signal alu_sel                                                : out alu_opcode;
                             signal ir                                                     : in word
                            ) is begin

  end procedure cu_mem_procedure;
end package body;
