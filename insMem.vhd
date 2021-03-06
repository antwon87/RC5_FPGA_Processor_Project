library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity insMem is
    Port ( addr : in STD_LOGIC_VECTOR(10 downto 0);
           readData : out STD_LOGIC_VECTOR(31 downto 0));
end insMem;

architecture a1 of insMem is

    type rom is array (0 to 2047) of std_logic_vector(7 downto 0);  -- Written for byte-addressable memory with 32-bit words
    constant instructions : rom := (
    
        -- Rotate Function (rd, rs, rt), starts at 0
        "00001111","11011100","00000000","00011111",  --ANDI r28, r30, 31       
        "00101011","10000000","00000000","10011010",  --BEQ r0, r28, 154        
        "00000100","00011011","00000000","00000001",  --ADDI r27, r0, 1         
        "00101011","10011011","00000000","00111011",  --BEQ r27, r28, 59        
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","00111100",  --BEQ r27, r28, 60        
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","00111101",  --BEQ r27, r28, 61        
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","00111110",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","00111111",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000000",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000001",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000010",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000011",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000100",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000101",  --BEQ r27, r28, 6
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000110",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01000111",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001000",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001001",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001010",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001011",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001100",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001101",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001110",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01001111",  --BEQ r27, r28, 7
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010000",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010001",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010010",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010011",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010100",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010101",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010110",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01010111",  --BEQ r27, r28, 8
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","10011011","00000000","01011000",  --BEQ r27, r28, 88   
        "00101000","00000000","00000000","01011010",  --BEQ r0, r0, 90          
        "00010111","10111010","00000000","00000001",  --SHL r26, r29, 1   
        "00011011","10111001","00000000","00011111",  --SHR r25, r29, 31   
        "00101000","00000000","00000000","01011001",  --BEQ r0, r0, 89          
        "00010111","10111010","00000000","00000010",  --SHL r26, r29, 2         
        "00011011","10111001","00000000","00011110",  --SHR r25, r29, 30   
        "00101000","00000000","00000000","01010110",  --BEQ r0, r0, 8
        "00010111","10111010","00000000","00000011",  --SHL r26, r29, 3   
        "00011011","10111001","00000000","00011101",  --SHR r25, r29, 29        
        "00101000","00000000","00000000","01010011",  --BEQ r0, r0, 83          
        "00010111","10111010","00000000","00000100",  --SHL r26, r29, 4   
        "00011011","10111001","00000000","00011100",  --SHR r25, r29, 28   
        "00101000","00000000","00000000","01010000",  --BEQ r0, r0, 8
        "00010111","10111010","00000000","00000101",  --SHL r26, r29, 5         
        "00011011","10111001","00000000","00011011",  --SHR r25, r29, 27        
        "00101000","00000000","00000000","01001101",  --BEQ r0, r0, 7
        "00010111","10111010","00000000","00000110",  --SHL r26, r29, 6   
        "00011011","10111001","00000000","00011010",  --SHR r25, r29, 26   
        "00101000","00000000","00000000","01001010",  --BEQ r0, r0, 74          
        "00010111","10111010","00000000","00000111",  --SHL r26, r29, 7         
        "00011011","10111001","00000000","00011001",  --SHR r25, r29, 25   
        "00101000","00000000","00000000","01000111",  --BEQ r0, r0, 7
        "00010111","10111010","00000000","00001000",  --SHL r26, r29, 8       
        "00011011","10111001","00000000","00011000",  --SHR r25, r29, 24        
        "00101000","00000000","00000000","01000100",  --BEQ r0, r0, 68          
        "00010111","10111010","00000000","00001001",  --SHL r26, r29, 9       
        "00011011","10111001","00000000","00010111",  --SHR r25, r29, 23       
        "00101000","00000000","00000000","01000001",  --BEQ r0, r0, 6
        "00010111","10111010","00000000","00001010",  --SHL r26, r29, 10        
        "00011011","10111001","00000000","00010110",  --SHR r25, r29, 22        
        "00101000","00000000","00000000","00111110",  --BEQ r0, r0, 6
        "00010111","10111010","00000000","00001011",  --SHL r26, r29, 11       
        "00011011","10111001","00000000","00010101",  --SHR r25, r29, 21       
        "00101000","00000000","00000000","00111011",  --BEQ r0, r0, 59          
        "00010111","10111010","00000000","00001100",  --SHL r26, r29, 12        
        "00011011","10111001","00000000","00010100",  --SHR r25, r29, 20       
        "00101000","00000000","00000000","00111000",  --BEQ r0, r0, 5
        "00010111","10111010","00000000","00001101",  --SHL r26, r29, 13       
        "00011011","10111001","00000000","00010011",  --SHR r25, r29, 19        
        "00101000","00000000","00000000","00110101",  --BEQ r0, r0, 53          
        "00010111","10111010","00000000","00001110",  --SHL r26, r29, 14       
        "00011011","10111001","00000000","00010010",  --SHR r25, r29, 18       
        "00101000","00000000","00000000","00110010",  --BEQ r0, r0, 5
        "00010111","10111010","00000000","00001111",  --SHL r26, r29, 15        
        "00011011","10111001","00000000","00010001",  --SHR r25, r29, 17        
        "00101000","00000000","00000000","00101111",  --BEQ r0, r0, 4
        "00010111","10111010","00000000","00010000",  --SHL r26, r29, 16       
        "00011011","10111001","00000000","00010000",  --SHR r25, r29, 16       
        "00101000","00000000","00000000","00101100",  --BEQ r0, r0, 44          
        "00010111","10111010","00000000","00010001",  --SHL r26, r29, 17        
        "00011011","10111001","00000000","00001111",  --SHR r25, r29, 15       
        "00101000","00000000","00000000","00101001",  --BEQ r0, r0, 4
        "00010111","10111010","00000000","00010010",  --SHL r26, r29, 18       
        "00011011","10111001","00000000","00001110",  --SHR r25, r29, 14        
        "00101000","00000000","00000000","00100110",  --BEQ r0, r0, 38          
        "00010111","10111010","00000000","00010011",  --SHL r26, r29, 19       
        "00011011","10111001","00000000","00001101",  --SHR r25, r29, 13       
        "00101000","00000000","00000000","00100011",  --BEQ r0, r0, 3
        "00010111","10111010","00000000","00010100",  --SHL r26, r29, 20        
        "00011011","10111001","00000000","00001100",  --SHR r25, r29, 12        
        "00101000","00000000","00000000","00100000",  --BEQ r0, r0, 3
        "00010111","10111010","00000000","00010101",  --SHL r26, r29, 21       
        "00011011","10111001","00000000","00001011",  --SHR r25, r29, 11       
        "00101000","00000000","00000000","00011101",  --BEQ r0, r0, 29          
        "00010111","10111010","00000000","00010110",  --SHL r26, r29, 22        
        "00011011","10111001","00000000","00001010",  --SHR r25, r29, 10       
        "00101000","00000000","00000000","00011010",  --BEQ r0, r0, 2
        "00010111","10111010","00000000","00010111",  --SHL r26, r29, 23       
        "00011011","10111001","00000000","00001001",  --SHR r25, r29, 9         
        "00101000","00000000","00000000","00010111",  --BEQ r0, r0, 23          
        "00010111","10111010","00000000","00011000",  --SHL r26, r29, 24       
        "00011011","10111001","00000000","00001000",  --SHR r25, r29, 8       
        "00101000","00000000","00000000","00010100",  --BEQ r0, r0, 2
        "00010111","10111010","00000000","00011001",  --SHL r26, r29, 25        
        "00011011","10111001","00000000","00000111",  --SHR r25, r29, 7         
        "00101000","00000000","00000000","00010001",  --BEQ r0, r0, 1
        "00010111","10111010","00000000","00011010",  --SHL r26, r29, 26       
        "00011011","10111001","00000000","00000110",  --SHR r25, r29, 6       
        "00101000","00000000","00000000","00001110",  --BEQ r0, r0, 14          
        "00010111","10111010","00000000","00011011",  --SHL r26, r29, 27        
        "00011011","10111001","00000000","00000101",  --SHR r25, r29, 5       
        "00101000","00000000","00000000","00001011",  --BEQ r0, r0, 1
        "00010111","10111010","00000000","00011100",  --SHL r26, r29, 28       
        "00011011","10111001","00000000","00000100",  --SHR r25, r29, 4         
        "00101000","00000000","00000000","00001000",  --BEQ r0, r0, 8           
        "00010111","10111010","00000000","00011101",  --SHL r26, r29, 29       
        "00011011","10111001","00000000","00000011",  --SHR r25, r29, 3       
        "00101000","00000000","00000000","00000101",  --BEQ r0, r0, 
        "00010111","10111010","00000000","00011110",  --SHL r26, r29, 30        
        "00011011","10111001","00000000","00000010",  --SHR r25, r29, 2         
        "00101000","00000000","00000000","00000010",  --BEQ r0, r0, 
        "00010111","10111010","00000000","00011111",  --SHL r26, r29, 31       
        "00011011","10111001","00000000","00000001",  --SHR r25, r29, 1       
        "00000011","01011001","11101000","00010011",  --OR r29, r26, r25        
        "00000100","00011011","00000000","00000001",  --ADDI r27, r0, 1         
        "00101011","01111111","00000000","00011011",  --BEQ r31, r27, 2
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 
        "00101011","01111111","00000000","00100110",  --BEQ r31, r27, 3
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 1        
        "00101011","01111111","00000000","01101100",  --BEQ r31, r27, 108       
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 
        "00101011","01111111","00000000","01111101",  --BEQ r31, r27, 125
        "00000111","01111011","00000000","00000001",  --ADDI r27, r27, 
        "00101011","01111111","00000000","01001011",  --BEQ r31, r27, 75        
        -- Ends at x"00000297" (663)                                            
        
        -- Parul's Encryption with new rotation (rd, rs, rt), starts at Addr x"00000298" (664)
        "00000000","00000000","00000000","00010001",  --SUB r0, r0, r0      
        "00011100","00001001","00000000","00000000",  --LW r9, 0(r0)            
        "00011100","00001010","00000000","00000001",  --LW r10, 1(r0)           
        "00011100","00001011","00000000","00000010",  --LW r11, 2(r0
        "00011100","00001100","00000000","00000011",  --LW r12, 3(r0
        "00000001","01101001","01001000","00010000",  --ADD r9, r11, r
        "00000001","10001010","01010000","00010000",  --ADD r10, r12, r10       
        "00000001","01101011","01011000","00010001",  --SUB r11, r11, r11       
        "00000001","11101111","01111000","00010001",  --SUB r15, r15, r1
        "00000101","11101111","00000000","00011000",  --ADDI r15, r15, 2
        "00000001","00101001","01100000","00010100",  --NOR r12,r9,r
        "00000001","01001010","01101000","00010100",  --NOR r13,r10,r10         
        "00000001","00101101","01001000","00010010",  --AND r9,r9,r13           
        "00000001","10001010","01100000","00010010",  --AND r12,r12,r1
        "00000001","00101100","01001000","00010011",  --OR r9,r9,r1
        "00000000","00001001","11101000","00010000",  --ADD r29,r0,r
        "00000000","00001010","11110000","00010000",  --ADD r30,r0,r10          
        "00000100","00011111","00000000","00000001",  --ADDI r31,r0,1           
        "00110000","00000000","00000000","00000000",  --JMP 
        "00000000","00011101","01001000","00010000",  --ADD r9,r0,r2
        "00011101","01101100","00000000","00000100",  --LW r12, 4(r11
        "00000001","10001001","01001000","00010000",  --ADD r9, r12,r9          
        "00000101","01101011","00000000","00000001",  --ADDI r11, r11, 1        
        "00000001","01001010","01100000","00010100",  --NOR r12,r10,r1
        "00000001","00101001","01101000","00010100",  --NOR r13,r9,r
        "00000001","01001101","01010000","00010010",  --AND r10,r10,r1
        "00000001","10001001","01100000","00010010",  --AND r12,r12,r9          
        "00000001","01001100","01010000","00010011",  --OR r10,r10,r12          
        "00000000","00001010","11101000","00010000",  --ADD r29,r0,r1
        "00000000","00001001","11110000","00010000",  --ADD r30,r0,r
        "00000100","00011111","00000000","00000010",  --ADDI r31,r0,
        "00110000","00000000","00000000","00000000",  --JMP 0                   
        "00000000","00011101","01010000","00010000",  --ADD r10,r0,r29          
        "00011101","01101100","00000000","00000100",  --LW r12, 4(r11
        "00000001","10001010","01010000","00010000",  --ADD r10, r12,r1
        "00000101","01101011","00000000","00000001",  --ADDI r11, r11, 
        "00101101","11101011","11111111","11100101",  --BNE r11, r15, -27       
        "00100000","00001001","00000000","00011110",  --SW r9, 30(r0)           
        "00100000","00001010","00000000","00011111",  --SW r10, 31(r0
        "11111100","00000000","00000000","00000000",  --HAL                    
        -- Ends at x"00000337" (823
                                                                                
        -- Keygen with new rotation (rd, rs, rt), starts at x"00000338" (824)   
        "00000000","00000000","00000000","00010001",  --SUB r0,r0,r0           
        "00000000","00000000","00001000","00010000",  --ADD r1,r0,r0  
        "00000000","00000000","00010000","00010000",  --ADD r2,r0,r0  
        "00000100","00000101","00000000","00000001",  --ADDI r5,r0,1            
        "00000000","00000000","00110000","00010000",  --ADD r6,r0,r0            
        "00000100","00000111","00000000","00011010",  --ADDI r7,r0,2
        "00000100","00001111","00000000","00000100",  --ADDI r15,r0,4           
        "00000100","00010000","00000000","01001110",  --ADDI r16,r0,78
        "00000100","00000011","10110111","11100001",  --ADDI r3,r0,-18463
        "00010100","01100011","00000000","00010000",  --SHL r3,r3,16
        "00000100","01100011","01010001","01100011",  --ADDI r3,r3,20835
        "00100000","00000011","00000000","00000010",  --SW r3,2(r0)
        "00000100","00001001","10011110","00110111",  --ADDI r9,r0,-25033
        "00010101","00101001","00000000","00010000",  --SHL r9,r9,16
        "00000101","00101001","01111001","10111001",  --ADDI r9,r9,31161
        "00000000","01101001","00011000","00010000",  --ADD r3,r3,r9   
        "00100000","10100011","00000000","00000010",  --SW r3,2(r5)
        "00000100","10100101","00000000","00000001",  --ADDI r5,r5,1
        "00101100","11100101","11111111","11111100",  --BNE r5,r7,-4
        "00000000","10100101","00101000","00010001",  --SUB r5,r5,r5
        "00011100","10100011","00000000","00000010",  --LW r3,2(r5)
        "00011100","11000100","00000000","00100000",  --LW r4,32(r6)
        "00000000","01100001","00011000","00010000",  --ADD r3,r3,r1   
        "00000000","01100010","00011000","00010000",  --ADD r3,r3,r2   
        "00011000","01101011","00000000","00011101",  --SHR r11,r3,29
        "00010100","01100011","00000000","00000011",  --SHL r3,r3,3
        "00000000","01101011","00011000","00010011",  --OR r3,r3,r11 
        "00000000","00000011","00001000","00010000",  --ADD r1,r0,r3
        "00100000","10100011","00000000","00000010",  --SW r3,2(r5) 
        "00000000","00100010","01100000","00010000",  --ADD r12,r1,r2   
        "00000000","10001100","00100000","00010000",  --ADD r4, r4,r12  
        "00000000","00000100","11101000","00010000",  --ADD r29,r0,r4   
        "00000000","00001100","11110000","00010000",  --ADD r30,r0,r12  
        "00000100","00011111","00000000","00000101",  --ADDI r31,r0,5
        "00110000","00000000","00000000","00000000",  --JMP 0      
        "00000000","00011101","00100000","00010000",  --ADD r4,r0,r29  
        "00000000","00000100","00010000","00010000",  --ADD r2,r0,r4   
        "00100000","11000100","00000000","00100000",  --SW r4,32(r6)
        "00000100","10100101","00000000","00000001",  --ADDI r5,r5,1
        "00101100","11100101","00000000","00000001",  --BNE r5,r7,1
        "00000000","10100101","00101000","00010001",  --SUB r5,r5,r5
        "00000100","11000110","00000000","00000001",  --ADDI r6,r6,1
        "00101101","11100110","00000000","00000001",  --BNE r6,r15,1
        "00000000","11000110","00110000","00010001",  --SUB r6,r6,r6
        "00001010","00010000","00000000","00000001",  --SUBI r16,r16,1
        "00101110","00000000","11111111","11100110",  --BNE r0,r16,-26
        "11111100","00000000","00000000","00000000",  --HAL                     
        -- Ends at x"000003F3" (1011)
        
        -- Parul's Decryption with new rotation (rs, rt, rd), starts at Addr x"000003F4" (1012)
        "00000000","00000000","00000000","00010001",  --SUB r0, r0, r0          
        "00000000","01000010","00010000","00010001",  --SUB r2, r2, r2
        "00000100","01000010","00000000","00011000",  --ADDI r2, r2, 24
        "00011100","00000011","00000000","00000000",  --LW r0, r3, 0 
        "00011100","00000100","00000000","00000001",  --LW r0, r4, 1
        "00100000","00000011","00000000","00011100",  --SW r0, r3, 28
        "00100000","00000100","00000000","00011101",  --SW r0, r4, 29
        "00011100","01000101","00000000","00000011",  --LW r2, r5, 3
        "00000000","10000101","00100000","00010001",  --SUB r4, r5, r4
        "00011100","00000110","00000000","00011100",  --LW r0, r6, 28
        "00001100","11000110","00000000","00011111",  --ANDI r6, r6, 31
        "00101000","00000110","00000000","00000110",  --BEQ r0, r6, 6
        "00000100","00000111","00000000","00100000",  --ADDI r0,r7, 32
        "00000000","11100110","11100000","00010001",  --SUB r7, r6, r28
        "00000000","00000100","11101000","00010000",  --ADD r0, r4, r29
        "00000100","00011111","00000000","00000011",  --ADDI r0, r31, 3
        "00110000","00000000","00000000","00000001",  --JMP 1
        "00000000","00011101","00100000","00010000",  --ADD r0, r29, r4
        "00011100","00000110","00000000","00011100",  --LW r0, r6, 28
        "00000000","11000110","00111000","00010100",  --NOR r6, r6, r7
        "00000000","10000100","01000000","00010100",  --NOR r4, r4, r8
        "00000000","11001000","00110000","00010010",  --AND r6, r8, r6
        "00000000","11100100","00100000","00010010",  --AND r7, r4, r4
        "00000000","10000110","00100000","00010011",  --OR r4, r6, r4
        "00100000","00000100","00000000","00011101",  --SW r0, r4, 29
        "00001000","01000010","00000000","00000001",  --SUBI r2, r2, 1
        "00011100","01000101","00000000","00000011",  --LW r2, r5, 3
        "00000000","01100101","00011000","00010001",  --SUB r3, r5, r3
        "00011100","00000110","00000000","00011101",  --LW r0, r6, 29
        "00001100","11000110","00000000","00011111",  --ANDI r6, r6, 31
        "00101000","00000110","00000000","00000110",  --BEQ r0, r6, 6
        "00000100","00000111","00000000","00100000",  --ADDI r0, r7, 32
        "00000000","11100110","11100000","00010001",  --SUB r7, r6, r28
        "00000000","00000011","11101000","00010000",  --ADD r0, r3, r29
        "00000100","00011111","00000000","00000100",  --ADDI r0, r31, 4
        "00110000","00000000","00000000","00000001",  --JMP 1
        "00000000","00011101","00011000","00010000",  --ADD r0, r29, r3
        "00011100","00000110","00000000","00011101",  --LW r0, r6, 29
        "00000000","11000110","00111000","00010100",  --NOR r6, r6, r7
        "00000000","01100011","01000000","00010100",  --NOR r3, r3, r8
        "00000000","11001000","00110000","00010010",  --AND r6, r8, r6
        "00000000","11100011","00011000","00010010",  --AND r7, r3, r3
        "00000000","01100110","00011000","00010011",  --OR r3, r6, r3
        "00100000","00000011","00000000","00011100",  --SW r0, r3, 28
        "00001000","01000010","00000000","00000001",  --SUBI r2, r2, 1
        "00101100","01000000","11111111","11011001",  --BNE r2, r0, -39
        "00011100","00000101","00000000","00000011",  --LW r0, r5, 3
        "00000000","10000101","00100000","00010001",  --SUB r4, r5, r4
        "00011100","00000101","00000000","00000010",  --LW r0, r5, 2
        "00000000","01100101","00011000","00010001",  --SUB r3, r5, r3
        "00100000","00000100","00000000","00011101",  --SW r0, r4, 29
        "00100000","00000011","00000000","00011100",  --SW r0, r3, 28
        "11111100","00000000","00000000","00000000",  --HAL
        -- Ends at x"000004C7" (1223)

    
        -- addi r0, r0, FFFF
--        x"04", x"00", x"FF", x"FF",

        -- small loop to test branching with blt
--        x"00", x"00", x"00", x"00",
--        x"04", x"00", x"00", x"05",  -- addi r0, r0, 5
--        x"24", x"01", x"00", x"02",  -- blt r0, r1, 2  (branch to pc = 20)
--        x"04", x"21", x"00", x"01",  -- addi r1, r1, 1
--        x"30", x"00", x"00", x"02",  -- j 2 (jump to pc = 8)
--        x"FF", x"FF", x"FF", x"FF",  -- halt
        
--        -- loop test with beq     
--        x"00", x"00", x"00", x"00",
--        x"04", x"00", x"00", x"05",  -- addi r0, r0, 5
--        x"28", x"01", x"00", x"02",  -- beq r0, r1, 2  (branch to pc = 20)
--        x"08", x"00", x"00", x"01",  -- subi r0, r0, 1 
--        x"30", x"00", x"00", x"02",  -- j 2 (jump to pc = 8)
--        x"FF", x"FF", x"FF", x"FF",  -- halt

--        -- loop test with bne
--        x"00", x"00", x"00", x"00",
--        x"04", x"00", x"00", x"05",  -- addi r0, r0, 5
--        x"04", x"21", x"00", x"01",  -- addi r1, r1, 1
--        x"2C", x"01", x"FF", x"FE",  -- bne r0, r1, -2  (branch to pc = 4)
--        x"FF", x"FF", x"FF", x"FF",  -- halt
        
                
    others => x"00");
    
begin
    
    -- Written for byte-addressable memory with 32-bit words
    readData <= instructions(to_integer(unsigned(addr))) & 
                instructions(to_integer(unsigned(addr)) + 1) & 
                instructions(to_integer(unsigned(addr)) + 2) &
                instructions(to_integer(unsigned(addr)) + 3);

end a1;
