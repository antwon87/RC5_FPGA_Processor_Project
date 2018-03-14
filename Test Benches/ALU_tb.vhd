library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_tb is
end ALU_tb;

architecture a1 of ALU_tb is

    component ALU is
    port ( data1 : in std_logic_vector(31 downto 0);
           data2 : in std_logic_vector(31 downto 0);
           aluOp : in std_logic_vector(3 downto 0);
           result : out std_logic_vector(31 downto 0);
           branch : out std_logic);
    end component ALU;
    
    signal data1, data2, result : std_logic_vector(31 downto 0) := (others => '0');
    signal aluOp : std_logic_vector(3 downto 0) := "0000";
    signal branch : std_logic := '0';

begin

    ALU_INST : ALU 
    port map (
        data1 => data1,
        data2 => data2,
        aluOp => aluOp,
        result => result,
        branch => branch
    );

    testing : process
    begin
        data1 <= x"00000001";
        data2 <= x"00000001";
        wait for 10 ns;
        aluOp <= "0001";
        wait for 10 ns;
        aluOp <= "0010";
        wait for 10 ns;
        aluOp <= "0011";
        wait for 10 ns;
        aluOp <= "0100";
        
        wait for 10 ns;
        aluOp <= "0101";
        data1 <= x"00000000";  -- data1 < data2
        data2 <= x"00000001";
        wait for 10 ns;
        aluOp <= "0110";
        wait for 10 ns;
        aluOp <= "0111";
        wait for 10 ns;
        aluOp <= "0101";
        data1 <= x"00000005";  -- data1 = data2
        data2 <= x"00000005";
        wait for 10 ns;
        aluOp <= "0110";
        wait for 10 ns;
        aluOp <= "0111";
        wait for 10 ns;
        aluOp <= "0101";
        data1 <= x"00000005";  -- data1 > data2
        data2 <= x"00000004";
        wait for 10 ns;
        aluOp <= "0110";
        wait for 10 ns;
        aluOp <= "0111";
        
        wait for 10 ns;
        data1 <= x"FFFFFFFF";
        data2 <= x"00000002";
        aluOp <= "1000";
        wait for 10 ns;
        aluOp <= "1001";
                
        wait for 10 sec;
    end process testing;
    
    
end a1;
