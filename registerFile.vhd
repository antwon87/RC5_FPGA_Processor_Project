-- The register file is a set of 32 32-bit registers.
-- 
-- Port Description:
-- 	Inputs:
-- 	rdAddr1, rdAddr2 	5-bit addresses to be read from
-- 	wrtAddr 			5-bit address to be written to
-- 	wrtData				Data to be written to wrtAddr
-- 	wrtEnable			When '1', a write is performed. Otherwise no write.
-- 	clk					clock to allow for synchronous writes
-- 	
-- 	Outputs:
-- 	rdData1, rdData2	Data read from rdAddr1 and rdAddr2, respectively

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity registerFile is
    port ( rdAddr1 : in STD_LOGIC_VECTOR (4 downto 0);
           rdAddr2 : in STD_LOGIC_VECTOR (4 downto 0);
           wrtAddr : in STD_LOGIC_VECTOR (4 downto 0);
           wrtData : in STD_LOGIC_VECTOR (31 downto 0);
           wrtEnable : in STD_LOGIC;
           clk : in STD_LOGIC;
           rdData1 : out STD_LOGIC_VECTOR (31 downto 0);
           rdData2 : out STD_LOGIC_VECTOR (31 downto 0));
end registerFile;

architecture a1 of registerFile is

    type ram is array (0 to 31) of std_logic_vector(31 downto 0);
    signal rf : ram := (others => x"00000000");
    
begin

    rdData1 <= rf(conv_integer(rdAddr1));
    rdData2 <= rf(conv_integer(rdAddr2));
    
    write : process(clk)
    begin
        if (rising_edge(clk) and wrtEnable = '1') then
            rf(conv_integer(wrtAddr)) <= wrtData;
        end if;
    end process write;
    
end a1;
