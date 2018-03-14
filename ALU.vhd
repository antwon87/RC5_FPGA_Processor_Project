library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALU is
    port ( data1 : in std_logic_vector(31 downto 0);
           data2 : in std_logic_vector(31 downto 0);
           aluOp : in std_logic_vector(3 downto 0);  -- May need to change this based on controller design
           result : out std_logic_vector(31 downto 0);
           branch : out std_logic);
end ALU;

architecture a1 of ALU is

begin

    result_calculation : process(data1, data2, aluOp)
    begin
--        shamt := to_integer(unsigned(data2(4 downto 0)));
        case aluOp is
            when "0000" => result <= data1 + data2;
            when "0001" => result <= data1 - data2;
            when "0010" => result <= data1 and data2;
            when "0011" => result <= data1 or data2;
            when "0100" => result <= data1 nor data2;
            when "1000" =>  -- shl
                case data2(4 downto 0) is
                    when "00000" => result <= data1;
                    when "00001" => result(31 downto 1) <= data1(30 downto 0); result(0) <= '0';
                    when "00010" => result(31 downto 2) <= data1(29 downto 0); result(1 downto 0) <= (others => '0');
                    when "00011" => result(31 downto 3) <= data1(28 downto 0); result(2 downto 0) <= (others => '0');
                    when "00100" => result(31 downto 4) <= data1(27 downto 0); result(3 downto 0) <= (others => '0');
                    when "00101" => result(31 downto 5) <= data1(26 downto 0); result(4 downto 0) <= (others => '0');
                    when "00110" => result(31 downto 6) <= data1(25 downto 0); result(5 downto 0) <= (others => '0');
                    when "00111" => result(31 downto 7) <= data1(24 downto 0); result(6 downto 0) <= (others => '0');
                    when "01000" => result(31 downto 8) <= data1(23 downto 0); result(7 downto 0) <= (others => '0');
                    when "01001" => result(31 downto 9) <= data1(22 downto 0); result(8 downto 0) <= (others => '0');
                    when "01010" => result(31 downto 10) <= data1(21 downto 0); result(9 downto 0) <= (others => '0');
                    when "01011" => result(31 downto 11) <= data1(20 downto 0); result(10 downto 0) <= (others => '0');
                    when "01100" => result(31 downto 12) <= data1(19 downto 0); result(11 downto 0) <= (others => '0');
                    when "01101" => result(31 downto 13) <= data1(18 downto 0); result(12 downto 0) <= (others => '0');
                    when "01110" => result(31 downto 14) <= data1(17 downto 0); result(13 downto 0) <= (others => '0');
                    when "01111" => result(31 downto 15) <= data1(16 downto 0); result(14 downto 0) <= (others => '0');
                    when "10000" => result(31 downto 16) <= data1(15 downto 0); result(15 downto 0) <= (others => '0');
                    when "10001" => result(31 downto 17) <= data1(14 downto 0); result(16 downto 0) <= (others => '0');
                    when "10010" => result(31 downto 18) <= data1(13 downto 0); result(17 downto 0) <= (others => '0');
                    when "10011" => result(31 downto 19) <= data1(12 downto 0); result(18 downto 0) <= (others => '0');
                    when "10100" => result(31 downto 20) <= data1(11 downto 0); result(19 downto 0) <= (others => '0');
                    when "10101" => result(31 downto 21) <= data1(10 downto 0); result(20 downto 0) <= (others => '0');
                    when "10110" => result(31 downto 22) <= data1(9 downto 0); result(21 downto 0) <= (others => '0');
                    when "10111" => result(31 downto 23) <= data1(8 downto 0); result(22 downto 0) <= (others => '0');
                    when "11000" => result(31 downto 24) <= data1(7 downto 0); result(23 downto 0) <= (others => '0');
                    when "11001" => result(31 downto 25) <= data1(6 downto 0); result(24 downto 0) <= (others => '0');
                    when "11010" => result(31 downto 26) <= data1(5 downto 0); result(25 downto 0) <= (others => '0');
                    when "11011" => result(31 downto 27) <= data1(4 downto 0); result(26 downto 0) <= (others => '0');
                    when "11100" => result(31 downto 28) <= data1(3 downto 0); result(27 downto 0) <= (others => '0');
                    when "11101" => result(31 downto 29) <= data1(2 downto 0); result(28 downto 0) <= (others => '0');
                    when "11110" => result(31 downto 30) <= data1(1 downto 0); result(29 downto 0) <= (others => '0');
                    when "11111" => result(31) <= data1(0); result(30 downto 0) <= (others => '0');
                    when others => result <= (others => '0');
                end case;
            when "1001" =>  -- shr
                case data2(4 downto 0) is
                    when "00000" => result <= data1;
                    when "00001" => result(30 downto 0) <= data1(31 downto 1); result(31) <= '0';
                    when "00010" => result(29 downto 0) <= data1(31 downto 2); result(31 downto 30) <= (others => '0');
                    when "00011" => result(28 downto 0) <= data1(31 downto 3); result(31 downto 29) <= (others => '0');
                    when "00100" => result(27 downto 0) <= data1(31 downto 4); result(31 downto 28) <= (others => '0');
                    when "00101" => result(26 downto 0) <= data1(31 downto 5); result(31 downto 27) <= (others => '0');
                    when "00110" => result(25 downto 0) <= data1(31 downto 6); result(31 downto 26) <= (others => '0');
                    when "00111" => result(24 downto 0) <= data1(31 downto 7); result(31 downto 25) <= (others => '0');
                    when "01000" => result(23 downto 0) <= data1(31 downto 8); result(31 downto 24) <= (others => '0');
                    when "01001" => result(22 downto 0) <= data1(31 downto 9); result(31 downto 23) <= (others => '0');
                    when "01010" => result(21 downto 0) <= data1(31 downto 10); result(31 downto 22) <= (others => '0');
                    when "01011" => result(20 downto 0) <= data1(31 downto 11); result(31 downto 21) <= (others => '0');
                    when "01100" => result(19 downto 0) <= data1(31 downto 12); result(31 downto 20) <= (others => '0');
                    when "01101" => result(18 downto 0) <= data1(31 downto 13); result(31 downto 19) <= (others => '0');
                    when "01110" => result(17 downto 0) <= data1(31 downto 14); result(31 downto 18) <= (others => '0');
                    when "01111" => result(16 downto 0) <= data1(31 downto 15); result(31 downto 17) <= (others => '0');
                    when "10000" => result(15 downto 0) <= data1(31 downto 16); result(31 downto 16) <= (others => '0');
                    when "10001" => result(14 downto 0) <= data1(31 downto 17); result(31 downto 15) <= (others => '0');
                    when "10010" => result(13 downto 0) <= data1(31 downto 18); result(31 downto 14) <= (others => '0');
                    when "10011" => result(12 downto 0) <= data1(31 downto 19); result(31 downto 13) <= (others => '0');
                    when "10100" => result(11 downto 0) <= data1(31 downto 20); result(31 downto 12) <= (others => '0');
                    when "10101" => result(10 downto 0) <= data1(31 downto 21); result(31 downto 11) <= (others => '0');
                    when "10110" => result(9 downto 0) <= data1(31 downto 22); result(31 downto 10) <= (others => '0');
                    when "10111" => result(8 downto 0) <= data1(31 downto 23); result(31 downto 9) <= (others => '0');
                    when "11000" => result(7 downto 0) <= data1(31 downto 24); result(31 downto 8) <= (others => '0');
                    when "11001" => result(6 downto 0) <= data1(31 downto 25); result(31 downto 7) <= (others => '0');
                    when "11010" => result(5 downto 0) <= data1(31 downto 26); result(31 downto 6) <= (others => '0');
                    when "11011" => result(4 downto 0) <= data1(31 downto 27); result(31 downto 5) <= (others => '0');
                    when "11100" => result(3 downto 0) <= data1(31 downto 28); result(31 downto 4) <= (others => '0');
                    when "11101" => result(2 downto 0) <= data1(31 downto 29); result(31 downto 3) <= (others => '0');
                    when "11110" => result(1 downto 0) <= data1(31 downto 30); result(31 downto 2) <= (others => '0');
                    when "11111" => result(0) <= data1(31); result(31 downto 1) <= (others => '0');
                    when others => result <= (others => '0');
                end case;
                
            when others => result <= x"00000000";
         end case;
    end process result_calculation;

--    result <= data1 + data2 when aluOp = "0000" else
--              data1 - data2 when aluOp = "0001" else
--              data1 and data2 when aluOp = "0010" else
--              data1 or data2 when aluOp = "0011" else
--              data1 nor data2 when aluOp = "0100" else
--              -- shl below
--              data1 when aluOp = "1000" and data2(4 downto 0) = "00000" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              -- shr below
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
--              data1( downto ) when aluOp = "1000" and data2(4 downto 0) = "" else
              
              
    -- May need to change op codes based on controller design
    -- Deprecated by restrictions on sll and slr implementation
--    with aluOp select result <=
--        data1 + data2 when "0000",
--        data1 - data2 when "0001",
--        data1 and data2 when "0010",
--        data1 or data2 when "0011",
--        data1 nor data2 when "0100",
--        (others => '0') when others;
        
    branch <= '1' when aluOp = "0101" and (data1 < data2) else
            '1' when aluOp = "0110" and (data1 = data2) else
            '1' when aluOp = "0111" and (data1 /= data2) else
            '0';
        
end a1;