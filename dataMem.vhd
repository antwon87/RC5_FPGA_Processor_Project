-- The data memory takes a 9-bit address as input and outputs outputs 
-- the byte stored at that location and the following three bytes. 
-- The byte at the address is the most significant and the byte at (addr + 3) 
-- is the least significant.
-- 
-- If wrtEnable is high, then the data on the wrtData input is written into 
-- memory locations {addr, addr+1, addr+2, addr+3}. Writes occur on the rising clock edge.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity dataMem is
    Port ( addr : in STD_LOGIC_VECTOR(8 downto 0);		-- Can add more bits if needed, but probably won't need more.
           wrtData : in STD_LOGIC_VECTOR (31 downto 0);
           wrtEnable : in STD_LOGIC;
           clk : in STD_LOGIC;
           rdData : out STD_LOGIC_VECTOR (31 downto 0));
end dataMem;

architecture a1 of dataMem is

    type ram is array (0 to 514) of std_logic_vector(31 downto 0);  
    signal dMem : ram := (
	    
--        x"AC", x"13", x"C0", x"F7",
--        x"52", x"89", x"2B", x"5B",
    
        -- Test s-keys

--        x"9B", x"BB", x"D8", x"C8",
--        x"1A", x"37", x"F7", x"FB",
--        x"46", x"F8", x"E8", x"C5", 
--        x"46", x"0C", x"60", x"85", 
--        x"70", x"F8", x"3B", x"8A", 
--        x"28", x"4B", x"83", x"03", 
--        x"51", x"3E", x"14", x"54", 
--        x"F6", x"21", x"ED", x"22", 
--        x"31", x"25", x"06", x"5D", 
--        x"11", x"A8", x"3A", x"5D", 
--        x"D4", x"27", x"68", x"6B", 
--        x"71", x"3A", x"D8", x"2D", 
--        x"4B", x"79", x"2F", x"99", 
--        x"27", x"99", x"A4", x"DD", 
--        x"A7", x"90", x"1C", x"49", 
--        x"DE", x"DE", x"87", x"1A", 
--        x"36", x"C0", x"31", x"96", 
--        x"A7", x"EF", x"C2", x"49", 
--        x"61", x"A7", x"8B", x"B8", 
--        x"3B", x"0A", x"1D", x"2B", 
--        x"4D", x"BF", x"CA", x"76", 
--        x"AE", x"16", x"21", x"67", 
--        x"30", x"D7", x"6B", x"0A", 
--        x"43", x"19", x"23", x"04", 
--        x"F6", x"CC", x"14", x"31", 
--        x"65", x"04", x"63", x"80",  -- 104
        
        -- L-array from User key 1 in rc5ref.c
--        x"00", x"00", x"00", x"00",
--        x"00", x"00", x"00", x"00",
--        x"00", x"00", x"00", x"00",
--        x"00", x"00", x"00", x"00",

        -- L-array from User key 2 in rc5ref.c (91 5F 46 19 BE 41 B2 51 63 55 A5 01 10 A9 CE 91)
--        x"19", x"46", x"5F", x"91", 
--        x"51", x"B2", x"41", x"BE", 
--        x"01", x"A5", x"55", x"63", 
--        x"91", x"CE", x"A9", x"10",
        
        -- L-array from User key 3 in rc5ref.c (78 33 48 E7 5A EB 0F 2F D7 B1 69 BB 8D C1 67 87), works
--        x"E7", x"48", x"33", x"78", 
--        x"2F", x"0F", x"EB", x"5A", 
--        x"BB", x"69", x"B1", x"D7", 
--        x"87", x"67", x"C1", x"8D",

        -- User key 4 from rc5ref.c
--        DC 49 DB 13 
--        75 A5 58 4F 
--        64 85 B4 13 
--        B5 F1 2B AF
        
        -- Raw Input data 1 from rc5ref.c
--        x"00", x"00", x"00", x"00",
--        x"00", x"00", x"00", x"00",

        -- Encrypted data 1 from rc5ref.c
--        x"EE", x"DB", x"A5", x"21",
--        x"6D", x"8F", x"4B", x"15",
        
        -- Raw Input data, test case 4
--        x"58", x"7B", x"9D", x"3A",
--        x"09", x"2F", x"4E", x"EC",
        
        -- Encrypted data, test case 4
--        x"8D", x"2A", x"14", x"69",
--        x"A7", x"D7", x"E7", x"7D",
        
        others => (others => '0'));

begin

    rdData <=   dMem(to_integer(unsigned(addr)));
--              dMem(to_integer(unsigned(addr))) & 
--              dMem(to_integer(unsigned(addr)) + 1) & 
--              dMem(to_integer(unsigned(addr)) + 2) & 
--              dMem(to_integer(unsigned(addr)) + 3);
    
    -- Written for word-addressable memory with 32-bit words
    write : process(clk)
    begin
        if(rising_edge(clk) and wrtEnable = '1') then
              dMem(to_integer(unsigned(addr))) <= wrtData;
--            dMem(to_integer(unsigned(addr))) <= wrtData(31 downto 24);
--            dMem(to_integer(unsigned(addr) + 1)) <= wrtData(23 downto 16);
--            dMem(to_integer(unsigned(addr) + 2)) <= wrtData(15 downto 8);
--            dMem(to_integer(unsigned(addr) + 3)) <= wrtData(7 downto 0);
        end if;
    end process write;
    
end a1;
