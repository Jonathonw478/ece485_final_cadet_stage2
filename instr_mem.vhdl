library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem is
    Port (
        addr    : in  STD_LOGIC_VECTOR(31 downto 0);
        instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem;

-- Note: the Real RISC-V uses the ADDI for the NOP instruction, but I'm pretending 0x0000000000000000 is a NOP
-- inserting NOPs to avoid hazards
architecture Behavioral of instr_mem is
    type memory_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : memory_array := (
        0 => x"00900293", -- addi x5, x0, 9
        1 => x"00000317", -- load_addr x6, array (custom instruction), where array is 0x10000000
        2 => x"00000000", -- NOP
        3 => x"00000000", -- NOP
        4 => x"00000000", -- NOP
        5 => x"00032383", -- lw x7, 0(x6)           
        6 => x"00430313", -- loop: addi x6, x6, 4  
        7 => x"00000000", -- NOP
        8 => x"00000000", -- NOP
        9 => x"00000000", -- NOP 
        10 => x"00032503", -- lw x10, 0(x6)    
        11 => x"00000000", -- NOP
        12 => x"00000000", -- NOP
        13 => x"00000000", -- NOP
        14 => x"007503B3", -- add x7, x10, x7 
        15 => x"00129293", -- subi x5, x5, 1 (or "addi x5, x5, -1")
        16 => x"00000000", -- NOP
        17 => x"00000000", -- NOP
        18 => x"00000000", -- NOP 
        19 => x"F20291E3", -- bne x5, x0, loop  
        20 => x"00000000", -- NOP
        21 => x"00000000", -- NOP
        22 => x"00000000", -- NOP  
        23 => x"FF1FF06F", -- done: j done            [-4; note: assumes PC is already incremented by 4]
        others => (others => '0')    
    );
    
-- bne
-- imm = 64 = 000000110100 = 2 complement 111111001100
-- imm = 64 = 000001101000 = 2 complement 111110011000 shifted
-- 1 111|001 0|0000 |0010|1 001 |0100 |1 110|0011|

-- 0xF20291E3 ... somehow this is the correct number? the above math is off for some reason.

-- imm = 56 = 000001110000 = 111110010000
-- 1 111|001 0|0000 | 0010|1 001 |0000 |1 110|0011|
-- 0xF20290E3
-- imm = 60 = 000001111000 = 111110001000
-- 1 111|000 0|0000 | 0010|1 001 |1000 |1 110|0011|
-- 0xF00298E3

-- imm = 4 =  000000001000 =            1111111111 1111111000
-- imm = 000000000100 2's complement -> 1111111111 1111111100
-- 1 111|1111|000 1 |1111|1111 |0000|0 110|1111
-- FF1FF06F
-- Typing new code so that it updates github

begin
    process(addr)
    begin
        instr <= memory(to_integer(unsigned(addr(7 downto 0))));
    end process;
end Behavioral;