library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dMem_tb is
end dMem_tb;

architecture a1 of dMem_tb is

    component dataMem is
    port (addr : in std_logic_vector(8 downto 0);
          wrtData : in std_logic_vector(31 downto 0);
          wrtEnable : in std_logic;
          clk : in std_logic;
          rdData : out std_logic_vector(31 downto 0));
    end component dataMem;
    
    signal tb_addr : std_logic_vector(8 downto 0);
    signal tb_wrtData, tb_rdData : std_logic_vector(31 downto 0);
    signal tb_wrtEnable : std_logic;
    signal tb_clk : std_logic := '0';
    constant half_period : time := 5 ns;

begin

    dMem : dataMem
    port map (
        addr => tb_addr,
        wrtData => tb_wrtData,
        wrtEnable => tb_wrtEnable,
        clk => tb_clk,
        rdData => tb_rdData
    );
    
    tb_clk <= not tb_clk after half_period;
    
    testing : process is
    begin
		wait for 100 ns;
		tb_wrtEnable <= '1';
        tb_addr <= "000000100";
		tb_wrtData <= x"00000004";
        wait for 10 ns;
        tb_addr <= "000001000";
		tb_wrtData <= x"00000008";
        wait for 10 ns;
        tb_addr <= "000001100";
		tb_wrtData <= x"0000000C";
		wait for 10 ns;
		tb_wrtEnable <= '0';
		tb_addr <= "000000000";
		wait for 10 ns;
		tb_addr <= "000000100";
		wait for 10 ns;
		tb_addr <= "000001000";
		wait for 10 ns;
		tb_addr <= "000001100";
		
        wait;
    end process testing;
    
end a1;
