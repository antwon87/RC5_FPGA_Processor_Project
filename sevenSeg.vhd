-- EL6463 Lab 4
-- Anthony Fisher
-- 
-- Description: 
-- This code is the same as in sevenSeg.vhd, except that the debouncing modules
-- have been removed for simulation purposes. The debounce module requires button 
-- inputs to remain constant for 10ms, which is prohibitively long for simulation.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity sevenSeg is
    Port ( clk : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR(31 downto 0);
           AN : out STD_LOGIC_VECTOR(7 downto 0);  -- 7-segment anodes
           C : out STD_LOGIC_VECTOR(7 downto 0)   -- 7-segment cathodes
           );
end sevenSeg;

architecture Behavioral of sevenSeg is
    
    -- 7-segment clocking and cathode signals
    signal clkDown: std_logic_vector(19 downto 0) := (others => '0');
    signal C0, C1, C2, C3, C4, C5, C6, C7 : std_logic_vector(7 downto 0);
            
    -- 7-segment decoding, if that wasn't obvious
    function hexTo7 (hex : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        if (hex = "0000") then return "1000000";
        elsif (hex = "0001") then return "1111001";
        elsif (hex = "0010") then return "0100100";
        elsif (hex = "0011") then return "0110000";
        elsif (hex = "0100") then return "0011001";
        elsif (hex = "0101") then return "0010010";
        elsif (hex = "0110") then return "0000010";
        elsif (hex = "0111") then return "1111000";
        elsif (hex = "1000") then return "0000000";
        elsif (hex = "1001") then return "0011000";
        elsif (hex = "1010") then return "0001000";
        elsif (hex = "1011") then return "0000011";
        elsif (hex = "1100") then return "1000110";
        elsif (hex = "1101") then return "0100001";
        elsif (hex = "1110") then return "0000110";
        elsif (hex = "1111") then return "0001110";
        else return "1111111";
        end if;
           
    end hexTo7;
         
begin
     
    -- 7-segment assignment
    process(clk) begin
        if (clk'event and clk = '1') then
            clkDown <= clkDown + 1;
        end if;
        
        if (clkDown(19 downto 17) = "000") then
            AN <= "11111110";
            C <= C0;
        elsif (clkDown(19 downto 17) = "001") then
            AN <= "11111101";
            C <= C1;
        elsif (clkDown(19 downto 17) = "010") then
            AN <= "11111011";
            C <= C2;
        elsif (clkDown(19 downto 17) = "011") then
            AN <= "11110111";
            C <= C3;
        elsif (clkDown(19 downto 17) = "100") then
            AN <= "11101111";
            C <= C4;
        elsif (clkDown(19 downto 17) = "101") then
            AN <= "11011111";
            C <= C5;
        elsif (clkDown(19 downto 17) = "110") then
            AN <= "10111111";
            C <= C6;
        elsif (clkDown(19 downto 17) = "111") then
            AN <= "01111111";
            C <= C7;
        end if;
        
    end process;

    -- Decoded value of each hex digit of data
    C0(6 downto 0) <= hexTo7(data(3 downto 0));
    C1(6 downto 0) <= hexTo7(data(7 downto 4));
    C2(6 downto 0) <= hexTo7(data(11 downto 8));
    C3(6 downto 0) <= hexTo7(data(15 downto 12));
    C4(6 downto 0) <= hexTo7(data(19 downto 16));
    C5(6 downto 0) <= hexTo7(data(23 downto 20));
    C6(6 downto 0) <= hexTo7(data(27 downto 24));
    C7(6 downto 0) <= hexTo7(data(31 downto 28));   
    
    -- Setting all decimal points to be off for now. Not sure how to handle them.
    C0(7) <= '1';
    C1(7) <= '1';
    C2(7) <= '1';
    C3(7) <= '1';
    C4(7) <= '1';
    C5(7) <= '1';
    C6(7) <= '1';
    C7(7) <= '1';
    
    
end Behavioral;
