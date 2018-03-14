library ieee;
use ieee.std_logic_1164.all;

entity control_tb is
end control_tb;

architecture a1 of control_tb is
    
    component controlUnit is
    port ( opCode : in std_logic_vector(5 downto 0);
           funct : in std_logic_vector(5 downto 0);
           memToReg : out std_logic;
           memWrite : out std_logic;
           pcSrc : out std_logic_vector(1 downto 0);  -- Changed from 'branch' in block diagram, to include jumps 
           aluOp : out std_logic_vector(2 downto 0);
           aluSrc : out std_logic;
           regDst : out std_logic;
           regWrite : out std_logic);
    end component controlUnit;
    
    signal opCode, funct : std_logic_vector(5 downto 0) := (others => '0');
    signal memToReg, memWrite, aluSrc, regDst, regWrite : std_logic := '0';
    signal pcSrc : std_logic_vector(1 downto 0) := "00";
    signal aluOp : std_logic_vector(2 downto 0) := "000";

begin

    controller : controlUnit
    port map (
        opCode => opCode,
        funct => funct,
        memToReg => memToReg,
        memWrite => memWrite,
        pcSrc => pcSrc,
        aluOp => aluOp,
        aluSrc => aluSrc,
        regDst => regDst,
        regWrite => regWrite
    );

    testing : process is
    begin
    
        opCode <= "000000";  -- R-type
        funct <= "010000";   -- add
        wait for 10 ns;
        funct <= "010001";   -- sub
        wait for 10 ns;
        funct <= "010010";   -- and
        wait for 10 ns;
        funct <= "010011";   -- or
        wait for 10 ns;
        funct <= "010100";   -- nor
        wait for 10 ns;
        
        -- I-type
        opCode <= "000001";  -- addi
        wait for 10 ns;
        opCode <= "000010";  -- subi
        wait for 10 ns;
        opCode <= "000011";  -- andi
        wait for 10 ns;
        opCode <= "000100";  -- ori
        wait for 10 ns;
        opCode <= "000111";  -- lw
        wait for 10 ns;
        opCode <= "001000";  -- sw
        wait for 10 ns;
        opCode <= "001001";  -- blt
        wait for 10 ns;
        opCode <= "001010";  -- beq
        wait for 10 ns;
        opCode <= "001011";  -- bne
        wait for 10 ns;
        opCode <= "001100";  -- jmp
        wait for 10 ns;
        opCode <= "111111";  -- hal
        
        wait for 10 sec;
        
    end process testing;

end a1;