library ieee;
use ieee.std_logic_1164.all;

entity rf_tb is
end entity rf_tb;

architecture a1 of rf_tb is

    component registerFile is
    port ( rdAddr1 : in STD_LOGIC_VECTOR (4 downto 0);
           rdAddr2 : in STD_LOGIC_VECTOR (4 downto 0);
           wrtAddr : in STD_LOGIC_VECTOR (4 downto 0);
           wrtData : in STD_LOGIC_VECTOR (31 downto 0);
           wrtEnable : in STD_LOGIC;
           clk : in STD_LOGIC;
           rdData1 : out STD_LOGIC_VECTOR (31 downto 0);
           rdData2 : out STD_LOGIC_VECTOR (31 downto 0));
    end component registerFile;
    
    signal rdAddr1, rdAddr2, wrtAddr : std_logic_vector(4 downto 0) := (others => '0');
    signal wrtData, rdData1, rdData2 : std_logic_vector(31 downto 0) := (others => '0');
    signal wrtEnable, clk : std_logic := '0';
    constant half_period : time := 5 ns;
    
begin

    clk <= not clk after half_period;
    
    rf : registerFile
    port map (
        rdAddr1 => rdAddr1,
        rdAddr2 => rdAddr2,
        wrtAddr => wrtAddr,
        wrtData => wrtData,
        wrtEnable => wrtEnable,
        clk => clk,
        rdData1 => rdData1,
        rdData2 => rdData2
    );
    
    testing : process is
    begin
        wrtEnable <= '1';
        wrtAddr <= "00001";
        wrtData <= x"00000001";
        wait for 10 ns;
        wrtAddr <= "00010";
        wrtData <= x"00000002";
        wait for 10 ns;
        wrtAddr <= "00011";
        wrtData <= x"00000003";
        wait for 3 ns;
        wrtAddr <= "00100";
        wrtData <= x"00000004";
        wait for 7 ns;
        wrtEnable <= '0';
        wrtAddr <= "00101";
        wrtData <= x"00000005";
        wait for 10 ns;
        rdAddr1 <= "00001";
        rdAddr2 <= "00010";
        wait for 10 ns;
        rdAddr1 <= "00011";
        rdAddr2 <= "00100";
        wait for 10 ns;
        rdAddr1 <= "00101";
        rdAddr2 <= "00000";
        
        wait for 10 sec;
        
    end process testing;

end a1;