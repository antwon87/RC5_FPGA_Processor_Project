library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity iMem_tb is
end iMem_tb;

architecture a1 of iMem_tb is

    component insMem is
    port (addr : in std_logic_vector(9 downto 0);
          readData : out std_logic_vector(31 downto 0));
    end component insMem;
    
    signal tb_addr : std_logic_vector(9 downto 0);
    signal tb_readData : std_logic_vector(31 downto 0);

begin

    iMem : insMem
    port map (
        addr => tb_addr,
        readData => tb_readData
    );
    
    testing : process is
    begin
        tb_addr <= "0000000000";
        wait for 10 ns;
        tb_addr <= "0000000100";
        wait for 10 ns;
        tb_addr <= "0000001000";
        wait for 10 sec;
    end process testing;
    
end a1;
