library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlUnit is
    port ( opCode : in std_logic_vector(5 downto 0);
           funct : in std_logic_vector(5 downto 0);
           idle : in std_logic;
           halt : out std_logic;
           memToReg : out std_logic;
           memWrite : out std_logic;
           branch : out std_logic;
           jump : out std_logic;
           aluOp : out std_logic_vector(3 downto 0);
           aluSrc : out std_logic;
           regDst : out std_logic;
           regWrite : out std_logic);
end controlUnit;

architecture a1 of controlUnit is

begin
    
    memToReg <= '1' when opCode = "000111" else  -- lw
                '0';
                
    memWrite <= '1' when (opCode = "001000" and idle = '0') else  -- sw
                '0';
    
    branch <= '1' when (opCode = "001001" or opCode = "001010" or opCode = "001011") else  
              '0';
    
    jump <= '1' when opCode = "001100" else
            '0';
             
    alu_control : process(opCode, funct)
    begin
        case opCode is
            when "000000" =>  -- R-type
                case funct is
                    when "010000" => aluOp <= "0000";  -- add
                    when "010001" => aluOp <= "0001";  -- sub
                    when "010010" => aluOp <= "0010";  -- and
                    when "010011" => aluOp <= "0011";  -- or
                    when "010100" => aluOp <= "0100";  -- nor
                    when others => aluOp <= "0000";  -- Is there a better way to handle the "others" case?
                end case;
            when "000001" => aluOp <= "0000";  -- addi
            when "000010" => aluOp <= "0001";  -- subi
            when "000011" => aluOp <= "0010";  -- andi 
            when "000100" => aluOp <= "0011";  -- ori
            when "000111" => aluOp <= "0000";  -- lw performs add
            when "001000" => aluOp <= "0000";  -- sw performs add
            when "001001" => aluOp <= "0101";  -- blt
            when "001010" => aluOp <= "0110";  -- beq
            when "001011" => aluOp <= "0111";  -- bne
            when "000101" => aluOp <= "1000";  -- shl
            when "000110" => aluOp <= "1001";  -- shr
            when others => aluOp <= "0000";  -- Is there a better way to handle the "others" case?
        end case;
        
    end process alu_control;
              
    -- aluSrc = 1 for addi, subi, andi, ori, lw, sw, shl, shr
    aluSrc <= '1' when (opCode = "000001" or opCode = "000010" or opCode = "000011" or
                        opCode = "000100" or opCode = "000111" or opCode = "001000" or
                        opCode = "000101" or opCode = "000110") else 
              '0';
              
    -- regDst is rd for R-type instructions, rt for others 
    regDst <= '1' when opCode = "000000" else
              '0';
              
    -- regWrite = 0 for sw, blt, beq, bne, jmp, hal, reset, and instruction of all 0s 
    regWrite <= '0' when (opCode = "001000" or opCode = "001001" or opCode = "001010" or
                          opCode = "001011" or opCode = "001100" or opCode = "111111" or
                          idle = '1' or (opCode = "000000" and funct = "000000")) else
                '1';
                
    halt <= '1' when opCode = "111111" else
            '0';
end a1;