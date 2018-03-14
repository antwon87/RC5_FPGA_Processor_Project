library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity processor is
    port ( sys_clk : in std_logic;
           sw : in std_logic_vector(15 downto 0);
           BTNS : in std_logic_vector(4 downto 0);
           reset : in std_logic;
           uart_rxd : in std_logic;
           uart_txd : out std_logic;
           C : out std_logic_vector(7 downto 0);
           AN : out std_logic_vector(7 downto 0);
           LED : out std_logic_vector(3 downto 0));
end processor;

architecture a1 of processor is

    type skey_array is array (0 to 25) of std_logic_vector(31 downto 0);
    signal skey : skey_array := (others => (others => '0'));
    signal skeyIndex : integer := 0;

    component insMem is
        port ( addr : in std_logic_vector(10 downto 0);
               readData : out std_logic_vector(31 downto 0));
    end component insMem;
    
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
    
    component ALU is
        port ( data1 : in std_logic_vector(31 downto 0);
           data2 : in std_logic_vector(31 downto 0);
           aluOp : in std_logic_vector(3 downto 0);
           result : out std_logic_vector(31 downto 0);
           branch : out std_logic);
    end component ALU;
    
    component dataMem is
        port ( addr : in STD_LOGIC_VECTOR(8 downto 0);
               wrtData : in STD_LOGIC_VECTOR (31 downto 0);
               wrtEnable : in STD_LOGIC;
               clk : in STD_LOGIC;
               rdData : out STD_LOGIC_VECTOR (31 downto 0));
    end component dataMem;
    
    component controlUnit is
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
    end component controlUnit;
    
    component UART_TX_CTRL
    port ( SEND : in std_logic;
           DATA : in std_logic_vector(7 downto 0);
           CLK : in std_logic;
           READY : out std_logic;
           UART_TX : out std_logic);
    end component;
    
    component UART_RX_CTRL
    port ( UART_RX : in std_logic;
           CLK : in std_logic;
           DATA : out std_logic_vector(7 downto 0);
           READ_DATA : out std_logic;
           RESET_READ : in std_logic);
    end component;
    
    component sevenSeg
    port ( clk : in std_logic;
        data : in std_logic_vector(31 downto 0);
        AN : out std_logic_vector(7 downto 0);
        C : out std_logic_vector(7 downto 0));
    end component;
    
    component debouncer
    generic ( DEBNC_CLOCKS : integer;
              PORT_WIDTH : integer);
    port ( SIGNAL_I : in std_logic_vector(4 downto 0);
           CLK_I : in std_logic;
           SIGNAL_O : out std_logic_vector(4 downto 0));
    end component;
    
    constant PLAINTEXT_ADDR : integer := 0;
    constant CIPHERTEXT_ADDR : integer := 30;
    constant DECRYPTED_ADDR : integer := 28;
    constant LARRAY_ADDR : integer := 32;
    constant ENC_DEC_STR_LEN : natural := 40;
    constant STEP_STR_LEN : natural := 158;
    constant ENCR_START_ADDR : std_logic_vector(31 downto 0) := x"00000298";
    constant DECR_START_ADDR : std_logic_vector(31 downto 0) := x"000003F4";
    constant KEYGEN_START_ADDR : std_logic_vector(31 downto 0) := x"00000338";
    
    alias mode_sel : std_logic_vector(2 downto 0) is sw(14 downto 12);
    alias execute : std_logic is sw(15);
    alias skey_select : std_logic_vector(4 downto 0) is sw(4 downto 0);
    alias step_mode : std_logic is sw(6);
        
    signal clk : std_logic := '0';
    
    type procState_type is (idling, encrypt, decrypt, txResult, keygen, rxUkey, rxDin);
    
    signal procState : procState_type := idling;
    signal keyGenerated : std_logic := '0';
    signal executeReg, executeDetected, 
           step_btn_reg, step_btn_detected,
           step_btn_reg2, step_btn_fall : std_logic := '0';
    signal better_BTNS : std_logic_vector(4 downto 0);
    alias step_btn : std_logic is better_BTNS(0);
    
    -- UART TX signals
    type uart_tx_state_type is (tx_rst, send_byte, rdy_low, wait_rdy, tx_idling, load_string);
    type char_array is array (integer range<>) of std_logic_vector(7 downto 0);
    signal uart_tx_state : uart_tx_state_type := tx_rst;
    signal startTx, startTx_step, txDone, send, tx_rdy, txSource : std_logic := '0';
    signal tx_byte : std_logic_vector(7 downto 0);
    signal txAddr : integer := 0;
    signal byteIndex : natural;
    signal strEnd : natural := 0;
    signal sendStr : char_array(0 to (STEP_STR_LEN - 1));
    signal string_load_cnt : natural range 0 to 4 := 0;
    signal reset_cntr : std_logic_vector(17 downto 0) := (others => '0');
    signal txDone_count : std_logic_vector(2 downto 0) := "000";
    constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";
    constant ENC_STRING : char_array(0 to 18) := (x"45", x"6E", x"63", x"72", x"79", x"70", x"74", x"69", x"6F", x"6E", x"20",
                                               -- E      n      c      r      y      p      t      i      o      n      space
                                                  x"72", x"65", x"73", x"75", x"6C", x"74", x"3A", x"20");
                                               -- r      e      s      u      l      t      :      space
    constant DEC_STRING : char_array(0 to 18) := (x"44", x"65", x"63", x"72", x"79", x"70", x"74", x"69", x"6F", x"6E", x"20",
                                               -- D      e      c      r      y      p      t      i      o      n      space
                                                  x"72", x"65", x"73", x"75", x"6C", x"74", x"3A", x"20");
                                               -- r      e      s      u      l      t      :      space
    
    -- Converts 5-bit register address to a decimal ASCII representation
    function regToDecimal (reg : std_logic_vector(4 downto 0)) return char_array is
    begin
        case reg is
            when "00000" => return (x"00", x"30");
            when "00001" => return (x"00", x"31");
            when "00010" => return (x"00", x"32");
            when "00011" => return (x"00", x"33");
            when "00100" => return (x"00", x"34");
            when "00101" => return (x"00", x"35");
            when "00110" => return (x"00", x"36");
            when "00111" => return (x"00", x"37");
            when "01000" => return (x"00", x"38");
            when "01001" => return (x"00", x"39");
            when "01010" => return (x"31", x"30");
            when "01011" => return (x"31", x"31");
            when "01100" => return (x"31", x"32");
            when "01101" => return (x"31", x"33");
            when "01110" => return (x"31", x"34");
            when "01111" => return (x"31", x"35");
            when "10000" => return (x"31", x"36");
            when "10001" => return (x"31", x"37");
            when "10010" => return (x"31", x"38");
            when "10011" => return (x"31", x"39");
            when "10100" => return (x"32", x"30");
            when "10101" => return (x"32", x"31");
            when "10110" => return (x"32", x"32");
            when "10111" => return (x"32", x"33");
            when "11000" => return (x"32", x"34");
            when "11001" => return (x"32", x"35");
            when "11010" => return (x"32", x"36");
            when "11011" => return (x"32", x"37");
            when "11100" => return (x"32", x"38");
            when "11101" => return (x"32", x"39");
            when "11110" => return (x"33", x"30");
            when "11111" => return (x"33", x"31");
            when others => return (x"00", x"00");
        end case;
    end regToDecimal;
    
    -- Converts a single hex digit into an ASCII representation
    function hexToASCII (hex : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case hex is
            when "0000" => return x"30";
            when "0001" => return x"31";
            when "0010" => return x"32";
            when "0011" => return x"33";
            when "0100" => return x"34";
            when "0101" => return x"35";
            when "0110" => return x"36";
            when "0111" => return x"37";
            when "1000" => return x"38";
            when "1001" => return x"39";
            when "1010" => return x"41";
            when "1011" => return x"42";
            when "1100" => return x"43";
            when "1101" => return x"44";
            when "1110" => return x"45";
            when "1111" => return x"46";
            when others => return x"00";
        end case;
    end hexToASCII;
    
    -- Decodes instruction binary into assembly instruction
    function instrToStr (instr : std_logic_vector(31 downto 0)) return char_array is
        variable returnStr : char_array(0 to 20);
    begin
        case instr(31 downto 26) is
            when "000000" =>
                case instr(5 downto 0) is
                    when "010000" =>
                        returnStr(0 to 5) := (x"61", x"64", x"64", x"00", x"20", x"72");  -- add r
                    when "010001" =>
                        returnStr(0 to 5) := (x"73", x"75", x"62", x"00", x"20", x"72");  -- sub r
                    when "010010" =>
                        returnStr(0 to 5) := (x"61", x"6E", x"64", x"00", x"20", x"72");  -- and r
                    when "010011" =>
                        returnStr(0 to 5) := (x"6F", x"72", x"00", x"00", x"20", x"72");  -- or r
                    when "010100" =>
                        returnStr(0 to 5) := (x"6E", x"6F", x"72", x"00", x"20", x"72");  -- nor r
                    when others => returnStr := (others => x"00");
                end case;
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 15) := (x"2C", x"20", x"72");  -- , r
                returnStr(16 to 17) := regToDecimal(instr(15 downto 11));
                returnStr(18 to 20) := (x"00", x"0D", x"0A");
            when "000001" =>
                returnStr(0 to 5) := (x"61", x"64", x"64", x"69", x"20", x"72");  -- addi r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000010" =>
                returnStr(0 to 5) := (x"73", x"75", x"62", x"69", x"20", x"72");  -- subi r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000011" =>
                returnStr(0 to 5) := (x"61", x"6E", x"64", x"69", x"20", x"72");  -- andi r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000100" =>
                returnStr(0 to 5) := (x"6F", x"72", x"00", x"69", x"20", x"72");  -- ori r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000101" =>
                returnStr(0 to 5) := (x"73", x"68", x"6C", x"00", x"20", x"72");  -- shl r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000110" =>
                returnStr(0 to 5) := (x"73", x"68", x"72", x"00", x"20", x"72");  -- shr r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "000111" =>
                returnStr(0 to 5) := (x"6C", x"77", x"00", x"00", x"20", x"72");  -- lw r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "001000" =>
                returnStr(0 to 5) := (x"73", x"77", x"00", x"00", x"20", x"72");  -- sw r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "001001" =>
                returnStr(0 to 5) := (x"62", x"6C", x"74", x"00", x"20", x"72");  -- blt r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "001010" =>
                returnStr(0 to 5) := (x"62", x"65", x"71", x"00", x"20", x"72");  -- beq r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "001011" =>
                returnStr(0 to 5) := (x"62", x"6E", x"65", x"00", x"20", x"72");  -- bne r
                returnStr(6 to 7) := regToDecimal(instr(25 downto 21));
                returnStr(8 to 10) := (x"2C", x"20", x"72");  -- , r
                returnStr(11 to 12) := regToDecimal(instr(20 downto 16));
                returnStr(13 to 14) := (x"2C", x"20");  -- ", "
                returnStr(15 to 20) := (hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"0D", x"0A");
            when "001100" =>
                returnStr(0 to 5) := (x"6A", x"6D", x"70", x"00", x"20", x"72");  -- jmp r
                returnStr(6 to 20) := (hexToASCII("00" & instr(25 downto 24)),
                                       hexToASCII(instr(23 downto 20)),
                                       hexToASCII(instr(19 downto 16)),
                                       hexToASCII(instr(15 downto 12)),
                                       hexToASCII(instr(11 downto 8)),
                                       hexToASCII(instr(7 downto 4)),
                                       hexToASCII(instr(3 downto 0)),
                                       x"00", x"00", x"00", x"00", x"00", x"00", x"0D", x"0A");
            when "111111" =>
                returnStr(0 to 3) := (x"48", x"41", x"4C", x"54");  -- HALT
                returnStr(4 to 18) := (others => (others => '0'));
                returnStr(19 to 20) := (x"0D", x"0A");
            when others => returnStr := (others => x"00");
        end case;
        return returnStr;
    end instrToStr;
       
    -- UART RX signals
    signal rxData : std_logic_vector(7 downto 0);
    signal rx_data_valid, reset_read : std_logic := '0';
    signal bytesRxdCnt : integer range 0 to 16 := 0;
    signal rxAddr : integer := 0;
    signal rxWriteMem : std_logic := '0';
    signal rxWord : std_logic_vector(31 downto 0);
    
    -- 7 segment
    signal sevenData : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Processor signals
    signal pc, pcPlus4, pcBranch, pcJump, pcIn : std_logic_vector(31 downto 0) := (others => '0');
    signal iMemAddr : std_logic_vector(10 downto 0) := (others => '0');
    signal instr : std_logic_vector(31 downto 0) := (others => '0');
    signal signExtImm, shiftedSignExtImm : std_logic_vector(31 downto 0) := (others => '0');
    signal halt : std_logic := '0';  -- indicates that a halt instruction has been fetched
    
    -- Control unit outputs
    signal memToReg, memWriteCU, aluSrc, regDst, regWrite, branch, jump : std_logic := '0';
    signal idle : std_logic := '1';  -- Ensures no writes occur once halt is reached or in idling state
    signal aluOp : std_logic_vector(3 downto 0) := "0000";
    
    -- Register file signals    
    signal rfWrtData, rfRdData1, rfRdData2 : std_logic_vector(31 downto 0) := (others => '0');
    signal rfWrtAddr : std_logic_vector(4 downto 0) := (others => '0');
    
    -- ALU signals
    signal aluIn2, aluResult : std_logic_vector(31 downto 0) := (others => '0');
    signal takeBranch : std_logic := '0';
    
    -- Data memory signals
    signal memRdData, memWrtData : std_logic_vector(31 downto 0) := (others => '0');
    signal memAddr : std_logic_vector(8 downto 0) := (others => '0');
    signal memWrite : std_logic := '0';
    
begin

    insMem1 : insMem
        port map (
            addr => iMemAddr,
            readData => instr
    );
    
    controlUnit1 : controlUnit
        port map (
            opCode => instr(31 downto 26),
            funct => instr(5 downto 0),
            idle => idle,
            halt => halt,
            memToReg => memToReg,
            memWrite => memWriteCU,
            branch => branch,
            jump => jump,
            aluOp => aluOp,
            aluSrc => aluSrc,
            regDst => regDst,
            regWrite => regWrite
    );

    registerFile1 : registerFile
        port map (
            rdAddr1 => instr(25 downto 21),
            rdAddr2 => instr(20 downto 16),
            wrtAddr => rfWrtAddr,
            wrtData => rfWrtData,
            wrtEnable => regWrite,
            clk => clk,
            rdData1 => rfRdData1,
            rdData2 => rfRdData2
    );
    
    alu1 : ALU
        port map (
            data1 => rfRdData1,
            data2 => aluIn2,
            aluOp => aluOp,
            result => aluResult,
            branch => takeBranch
    );
    
    dataMem1 : dataMem
        port map (
            addr => memAddr,
            wrtData => memWrtData,
            wrtEnable => memWrite,
            clk => clk,
            rdData => memRdData
    );
        
    proc_clock : process(sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (step_mode = '0') then
                clk <= not clk;
            else
                clk <= step_btn_detected;
            end if;
        end if;
    end process proc_clock;
    
    pcPlus4 <= pc + 4;
    shiftedSignExtImm <= signExtImm(29 downto 0) & "00";
    pcBranch <= pcPlus4 + shiftedSignExtImm;
    pcJump <= pcPlus4(31 downto 28) & instr(25 downto 0) & "00";
    pcIn <= pcBranch when (branch = '1' and takeBranch = '1') else
            pcJump when jump = '1' else
            pcPlus4;
            
    -- Rising edge detection for the execute switch
    executeReg_update : process (clk)
    begin
        if (rising_edge(clk)) then
            executeReg <= execute;
        end if;
    end process;
    
    executeDetected <= '1' when (execute = '1' and executeReg = '0') else
                   '0';
    
    update_procState : process (clk)
    begin
        if (reset = '0') then
            procState <= idling;
        elsif (rising_edge(clk)) then
            keyGenerated <= keyGenerated;
            case procState is
                when idling =>
                    idle <= '1';
                    if (executeDetected = '1') then
                        if (mode_sel = "010") then
                            procState <= encrypt;
                            pc <= ENCR_START_ADDR; 
                            idle <= '0';
                            txSource <= '0';
                        elsif (mode_sel = "100") then
                            procState <= decrypt;
                            pc <= DECR_START_ADDR; 
                            idle <= '0';
                            txSource <= '1';
                        elsif (mode_sel = "011") then
                            procState <= rxUkey;
                            pc <= pc;
                            keyGenerated <= '0';
                            idle <= '1';
                        elsif (mode_sel = "111") then
                            procState <= rxDin;
                            pc <= pc;
                            idle <= '1';
                        elsif (mode_sel = "001" and keyGenerated = '0') then
                            procState <= keygen;
                            pc <= KEYGEN_START_ADDR; 
                            idle <= '0';
                        else
                            procState <= idling;
                            idle <= '1';
                        end if;
                    end if;
                when encrypt =>
                    if (halt = '1') then
                        procState <= txResult;
                        startTx <= '1';
                        idle <= '1';
                    else
                        pc <= pcIn;
                    end if;
                when decrypt =>
                    if (halt = '1') then
                        procState <= txResult;
                        startTx <= '1';
                        idle <= '1';
                    else
                        pc <= pcIn;
                    end if;
                when keygen =>
                    if (halt = '1') then
                        procState <= idling;
                        keyGenerated <= '1';
                        idle <= '1';
                    else
                        pc <= pcIn;
                    end if;
                when txResult =>
                    startTx <= '0';
                    if (txDone = '1') then
                        procState <= idling;
                    end if;
                when rxUkey =>
                    if (bytesRxdCnt = 16) then
                        procState <= idling;
                    end if;
                when rxDin =>
                    if (bytesRxdCnt = 8) then
                        procState <= idling;
                    end if;
                when others => procState <= idling;
            end case;
        end if;
    end process update_procState;
    
    iMemAddr <= pc(10 downto 0);
   
    signExtImm <= (31 downto 16 => instr(15)) & instr(15 downto 0);
    aluIn2 <= rfRdData2 when aluSrc = '0' else
              signExtImm;
    
    rfWrtAddr <= instr(20 downto 16) when regDst = '0' else
                 instr(15 downto 11);
    rfWrtData <= aluResult when memToReg = '0' else
                 memRdData;
    
    -- Memory address differs based on operation. Different addresses needed if receiving input data,
    -- transmitting computed data, or simply running a program on the processor.
    memAddr <= std_logic_vector(to_unsigned(rxAddr, 9)) when (procState = rxUkey or procState = rxDin) else
               std_logic_vector(to_unsigned(txAddr + string_load_cnt, 9)) when (uart_tx_state = load_string and procState = txResult) else
               aluResult(8 downto 0) when (memToReg = '1' or memWrite = '1') else
               (others => '0');
    
    -- Data either comes from processor during program execution or UART when receiving input.
    -- Write enable is similar.
    memWrtData <= rxWord when (procState = rxUkey or procState = rxDin) else
                  rfRdData2;
       
    memWrite <= rxWriteMem when (procState = rxUkey or procState = rxDin) else
                memWriteCU;
-------------------------------------------------------------
--            UART Transmit
-------------------------------------------------------------
                
    inst_uart_tx_ctrl : UART_TX_CTRL
    port map (
        SEND => send,
        DATA => tx_byte,
        CLK => sys_clk,
        READY => tx_rdy,
        UART_TX => uart_txd
    );
    
    -- Prevent UART from transmitting randomly when system starts or is reset.
    process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if ((reset_cntr = RESET_CNTR_MAX) or (uart_tx_state /= tx_rst)) then
                reset_cntr <= (others => '0');
            else
                reset_cntr <= reset_cntr + 1;
            end if;
        end if;
    end process;
    
    next_uartState : process (sys_clk)
    begin
        if (reset = '0') then
            uart_tx_state <= tx_rst;
        elsif (rising_edge(sys_clk)) then
            case uart_tx_state is
                when tx_rst =>
                    if (reset_cntr = RESET_CNTR_MAX) then
                        uart_tx_state <= tx_idling;
                    end if;
                when tx_idling =>
                    if (startTx = '1' or startTx_step = '1') then
                        uart_tx_state <= load_string;
                    end if;
                when load_string =>
                    if (string_load_cnt = 1) then
                        uart_tx_state <= send_byte;
                    end if;
                when send_byte => 
                    uart_tx_state <= rdy_low;
                when rdy_low =>  -- wait for the transmit module to start sending
                    uart_tx_state <= wait_rdy;
                when wait_rdy =>  -- wait for the transmit module to finish sending
                    if (tx_rdy = '1') then
                        if (strEnd = byteIndex) then
                            uart_tx_state <= tx_idling;
                        else
                            uart_tx_state <= send_byte;
                        end if;
                    end if;
                when others =>
                    uart_tx_state <= tx_rst;
            end case;
        end if;
        
    end process;
    
    -- Start transmitting step mode data on the falling edge of the step button
    tx_start_process : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (step_mode = '1') then
                startTx_step <= step_btn_fall;
            else
                startTx_step <= '0';    
            end if;
        end if;
    end process;    
    
    -- I don't like how I've done this. I need to make it better.
    tx_done_set : process (sys_clk)
    begin
        txDone <= txDone;
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = wait_rdy and tx_rdy = '1' and strEnd = byteIndex) then
                txDone <= '1';
            elsif (txDone = '1' and txDone_count = 1) then
                txDone <= '0';
            end if;
        end if;
    end process tx_done_set;
    
    -- This is because of the clock difference between the transmit module and processor.
    -- txDone must stay high long enough for the processor clock to detect it. There is 
    -- probably a better way to handle this. Modify the transmit module to run with the 
    -- slower clock, maybe?
    tx_done_counter : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (txDone = '1') then
                txDone_count <= txDone_count + 1;
            else
                txDone_count <= "000";
            end if;
        end if;
    end process tx_done_counter;
    
    -- Set memory addresses to send data from based on whether encryption or decryption was run.
    tx_mem_address_set : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = tx_idling) then
                if (txSource = '0') then
                    txAddr <= CIPHERTEXT_ADDR;
                else
                    txAddr <= DECRYPTED_ADDR;
                end if;
            end if;
        end if;
    end process tx_mem_address_set;
        
    -- Set up the string to be sent. Different string for encryption/decryption/step mode
    string_load : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = load_string) then
                if (step_mode = '0') then
                    if (txSource = '0') then  -- transmit ciphertext 
                        sendStr(0 to 18) <= ENC_STRING;
                    else                      -- transmit decrypted data
                        sendStr(0 to 18) <= DEC_STRING;
                    end if;
                    
                    if (string_load_cnt = 0) then
                        sendStr(19 to 26) <= (hexToASCII(memRdData(31 downto 28)),
                                              hexToASCII(memRdData(27 downto 24)),
                                              hexToASCII(memRdData(23 downto 20)),
                                              hexToASCII(memRdData(19 downto 16)),
                                              hexToASCII(memRdData(15 downto 12)),
                                              hexToASCII(memRdData(11 downto 8)),
                                              hexToASCII(memRdData(7 downto 4)),
                                              hexToASCII(memRdData(3 downto 0)));
                        sendStr(27) <= x"20";
                    else
                        sendStr(28 to 35) <= (hexToASCII(memRdData(31 downto 28)),
                                              hexToASCII(memRdData(27 downto 24)),
                                              hexToASCII(memRdData(23 downto 20)),
                                              hexToASCII(memRdData(19 downto 16)),
                                              hexToASCII(memRdData(15 downto 12)),
                                              hexToASCII(memRdData(11 downto 8)),
                                              hexToASCII(memRdData(7 downto 4)),
                                              hexToASCII(memRdData(3 downto 0)));
                        sendStr(36 to 39) <= (x"0D", x"0A", x"0D", x"0A");
                    end if;
                    strEnd <= ENC_DEC_STR_LEN;
                else
                    sendStr(0 to 22) <= (x"50", x"43", x"3A", x"20",
                                      -- P      C      :      space
                                  hexToASCII(pc(15 downto 12)),
                                  hexToASCII(pc(11 downto 8)),
                                  hexToASCII(pc(7 downto 4)),
                                  hexToASCII(pc(3 downto 0)),
                                  x"0D", x"0A",  -- \n
                                  x"49", x"6E", x"73", x"74", x"72", x"75", x"63", x"74", x"69", x"6F", x"6E", x"3A", x"20");
                               -- I      n      s      t      r      u      c      t      i      o      n      :      space
                    sendStr(23 to 43) <= instrToStr(instr);  -- includes new line
                    sendStr(44 to 157)<= (x"49", x"6E", x"73", x"74", x"72", x"75", x"63", x"74", x"69", x"6F", x"6E", 
                               -- I      n      s      t      r      u      c      t      i      o      n      
                                  x"20", x"68", x"65", x"78", x"3A", x"20",
                               -- space  h      e      x      :      space
                                  hexToASCII(instr(31 downto 28)),
                                  hexToASCII(instr(27 downto 24)),
                                  hexToASCII(instr(23 downto 20)),
                                  hexToASCII(instr(19 downto 16)),
                                  hexToASCII(instr(15 downto 12)),
                                  hexToASCII(instr(11 downto 8)),
                                  hexToASCII(instr(7 downto 4)),
                                  hexToASCII(instr(3 downto 0)),
                                  x"0D", x"0A",  -- \n
                                  x"52", x"46", x"20", x"77", x"72", x"74", x"45", x"6E", x"2F",
                               -- R      F      space  w      r      t      E      n      /
                                  x"61", x"64", x"64", x"72", x"65", x"73", x"73", x"2F",
                               -- a      d      d      r      e      s      s      /
                                  x"64", x"61", x"74", x"61", x"3A", x"20", 
                               -- d      a      t      a      :      space
                                  hexToASCII("000" & regWrite), x"20", x"2F", x"20",
                                                             -- space  /      space
                                  hexToASCII("000" & rfWrtAddr(4)),
                                  hexToASCII(rfWrtAddr(3 downto 0)), x"20", x"2F", x"20",
                                                                  -- space  /      space
                                  hexToASCII(rfWrtData(31 downto 28)),
                                  hexToASCII(rfWrtData(27 downto 24)),
                                  hexToASCII(rfWrtData(23 downto 20)),
                                  hexToASCII(rfWrtData(19 downto 16)),
                                  hexToASCII(rfWrtData(15 downto 12)),
                                  hexToASCII(rfWrtData(11 downto 8)),
                                  hexToASCII(rfWrtData(7 downto 4)),
                                  hexToASCII(rfWrtData(3 downto 0)),
                                  x"0D", x"0A",  -- \n
                                  x"4D", x"65", x"6D", x"20", x"77", x"72", x"74", x"45", x"6E", x"2F",
                               -- M      e      m      space  w      r      t      E      n      /
                                  x"61", x"64", x"64", x"72", x"65", x"73", x"73", x"2F",
                               -- a      d      d      r      e      s      s      /
                                  x"64", x"61", x"74", x"61", x"3A", x"20", 
                               -- d      a      t      a      :      space
                                  hexToASCII("000" & memWrite), x"20", x"2F", x"20",
                                                             -- space  /      space
                                  hexToASCII(memAddr(7 downto 4)),
                                  hexToASCII(memAddr(3 downto 0)), x"20", x"2F", x"20",
                                                                 -- space  /      space
                                  hexToASCII(memWrtData(31 downto 28)),
                                  hexToASCII(memWrtData(27 downto 24)),
                                  hexToASCII(memWrtData(23 downto 20)),
                                  hexToASCII(memWrtData(19 downto 16)),
                                  hexToASCII(memWrtData(15 downto 12)),
                                  hexToASCII(memWrtData(11 downto 8)),
                                  hexToASCII(memWrtData(7 downto 4)),
                                  hexToASCII(memWrtData(3 downto 0)),
                                  x"0D", x"0A", x"0D", x"0A");  -- \n \n
                    strEnd <= STEP_STR_LEN;
                end if;                
            end if;
        end if;
    end process;           
    
    -- It takes two clock cycles to load the string for encryption and
    -- decryption because two memory locations must be read.
    string_load_cnt_update : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = load_string) then
                string_load_cnt <= string_load_cnt + 1;
            else
                string_load_cnt <= 0;
            end if;
        end if;
    end process string_load_cnt_update;
    
    -- Track the byte to be sent in the send string.
    byte_count : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = load_string) then
                byteIndex <= 0;
            elsif (uart_tx_state = send_byte) then
                byteIndex <= byteIndex + 1;
            end if;
        end if;    
    end process;
    
    -- Give current byte to transmit module for sending.
    byte_load : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (uart_tx_state = send_byte) then
                send <= '1';
                tx_byte <= sendStr(byteIndex);
            else
                send <= '0';
            end if;
        end if;
    end process;
                   
-------------------------------------------------------------
--            UART Receive
-------------------------------------------------------------

    inst_uart_rx_ctrl : UART_RX_CTRL
    port map (
        UART_RX => uart_rxd,
        CLK => clk,
        DATA => rxData,
        READ_DATA => rx_data_valid,
        RESET_READ => reset_read
    );
    
    -- Shift received bytes into a word. Store in data memory when full word received.
    capture_read_data : process (clk)
    begin
        if (rising_edge(clk)) then
            if (rx_data_valid = '1' and reset_read = '0') then
                rxWord <= rxWord;
                if (procState = rxUkey) then
                    rxWord <= rxData & rxWord(31 downto 8);
                    if (bytesRxdCnt = 3) then
                        rxAddr <= LARRAY_ADDR;
                        rxWriteMem <= '1';
                    elsif (bytesRxdCnt = 7) then
                        rxAddr <= LARRAY_ADDR + 1;
                        rxWriteMem <= '1';
                    elsif (bytesRxdCnt = 11) then
                        rxAddr <= LARRAY_ADDR + 2;
                        rxWriteMem <= '1';
                    elsif (bytesRxdCnt = 15) then
                        rxAddr <= LARRAY_ADDR + 3;
                        rxWriteMem <= '1';
                    else
                        rxAddr <= rxAddr;
                        rxWriteMem <= '0';
                    end if;
                elsif (procState = rxDin) then
                    rxWord <= rxWord(23 downto 0) & rxData;
                    if (bytesRxdCnt = 3) then
                        rxAddr <= PLAINTEXT_ADDR;
                        rxWriteMem <= '1';
                    elsif (bytesRxdCnt = 7) then
                        rxAddr <= PLAINTEXT_ADDR + 1;
                        rxWriteMem <= '1';
                    else
                        rxAddr <= rxAddr;
                        rxWriteMem <= '0';
                    end if;
                end if;
                reset_read <= '1';
            else
                rxWriteMem <= '0';
                reset_read <= '0';
            end if;
        end if;
    end process;
    
    -- Count number of bytes received to know when all data has arrived.
    rx_byte_count : process (clk)
    begin
        if (rising_edge(clk)) then
            if (procState = rxUkey or procState = rxDin) then
                if (rx_data_valid = '1' and reset_read = '0') then
                    bytesRxdCnt <= bytesRxdCnt + 1;
                else
                    bytesRxdCnt <= bytesRxdCnt;
                end if;
            else
                bytesRxdCnt <= 0;
            end if;
        end if;
    end process rx_byte_count;

               
-------------------------------------------------------------
--            7 segment
-------------------------------------------------------------

    inst_sevenSeg : sevenSeg 
    port map (
        clk => sys_clk,
        data => sevenData,
        AN => AN,
        C => C
    );
    
    -- Keep a local copy of skeys as they are generated to show them
    -- on the 7-segment display. Not feasible to read them from data memory
    -- for display.
    skeyIndex <= to_integer(unsigned(memAddr(8 downto 0)));
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (procState = keygen and memWrite = '1') then
                if (skeyIndex > 1 and skeyIndex < 28) then
                    skey(skeyIndex - 2) <= rfRdData2;
                end if;
            end if;
        end if;
    end process;
    
    -- 7-segment will display current pc when in step mode.
    -- Otherwise it will display the skey indexed by switches 0 to 4.
    sevenData <= pc when step_mode = '1' else
                 skey(0) when sw(4 downto 0) = "00000" else
                 skey(1) when sw(4 downto 0) = "00001" else
                 skey(2) when sw(4 downto 0) = "00010" else
                 skey(3) when sw(4 downto 0) = "00011" else
                 skey(4) when sw(4 downto 0) = "00100" else
                 skey(5) when sw(4 downto 0) = "00101" else
                 skey(6) when sw(4 downto 0) = "00110" else
                 skey(7) when sw(4 downto 0) = "00111" else
                 skey(8) when sw(4 downto 0) = "01000" else
                 skey(9) when sw(4 downto 0) = "01001" else
                 skey(10) when sw(4 downto 0) = "01010" else
                 skey(11) when sw(4 downto 0) = "01011" else
                 skey(12) when sw(4 downto 0) = "01100" else
                 skey(13) when sw(4 downto 0) = "01101" else
                 skey(14) when sw(4 downto 0) = "01110" else
                 skey(15) when sw(4 downto 0) = "01111" else
                 skey(16) when sw(4 downto 0) = "10000" else
                 skey(17) when sw(4 downto 0) = "10001" else
                 skey(18) when sw(4 downto 0) = "10010" else
                 skey(19) when sw(4 downto 0) = "10011" else
                 skey(20) when sw(4 downto 0) = "10100" else
                 skey(21) when sw(4 downto 0) = "10101" else
                 skey(22) when sw(4 downto 0) = "10110" else
                 skey(23) when sw(4 downto 0) = "10111" else
                 skey(24) when sw(4 downto 0) = "11000" else
                 skey(25) when sw(4 downto 0) = "11001" else
                 (others => '0');
                                
-------------------------------------------------------------
--            Button Handling
-------------------------------------------------------------
        
    debounce_inst : debouncer
    generic map (
        DEBNC_CLOCKS => (2**16),
        PORT_WIDTH => 5
    )
    port map (
        SIGNAL_I => BTNS,
        CLK_I => sys_clk,
        SIGNAL_O => better_BTNS
    );
    
    -- Rising edge detection of step button
    btn_reg : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            step_btn_reg <= step_btn;
        end if;
    end process btn_reg;
    
    step_btn_detected <= '1' when (step_btn = '1' and step_btn_reg = '0') else
                         '0';
    
    -- Falling edge detection of step button
    btn_reg2 : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            step_btn_reg2 <= step_btn_reg;
        end if;
    end process btn_reg2;
    
    step_btn_fall <= '1' when (step_btn_reg = '0' and step_btn_reg2 = '1') else
                     '0';
    
    -- LEDS show processor state. Mostly for testing.
    with procState select LED(2 downto 0) <= 
        "001" when idling,
        "010" when encrypt,
        "011" when decrypt,
        "100" when txResult,
        "101" when keygen,
        "110" when rxUkey,
        "111" when rxDin,
        "000" when others;
    
end a1;