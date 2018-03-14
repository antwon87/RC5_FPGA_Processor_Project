library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
    port ( sys_clk : in std_logic;
           rst : in std_logic;
           mode_sel : in std_logic_vector(1 downto 0);
           dataToMem : in std_logic_vector(31 downto 0);
           addrToMem : in std_logic_vector(8 downto 0);
           tbMemWrite : in std_logic;
           encOut : out std_logic_vector(63 downto 0);
           decOut : out std_logic_vector(63 downto 0);
           encRdy : out std_logic;
           decRdy : out std_logic;
           keyRdy : out std_logic);
end processor;

architecture a1 of processor is

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
    
    signal clk : std_logic := '0';
        
--    constant pcLength : integer := 32;
    signal pc, pcPlus4, pcBranch, pcJump, pcIn : std_logic_vector(31 downto 0) := (others => '0');
    signal iMemAddr : std_logic_vector(10 downto 0) := (others => '0');
    signal instr : std_logic_vector(31 downto 0) := (others => '0');
    signal signExtImm, shiftedExtdImm : std_logic_vector(31 downto 0) := (others => '0');
    signal halt : std_logic := '0';
    signal rst_reg : std_logic := '1';
    
    -- Control unit outputs
    signal memToReg, memWriteCU, aluSrc, regDst, regWrite, branch, jump : std_logic := '0';
    signal idle : std_logic := '1';
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
    signal memWrtEn : std_logic := '0';
    
    signal encOutTemp1, encOutTemp2, decOutTemp1, decOutTemp2 : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    clk_down : process (sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            clk <= not clk;
        end if;
    end process clk_down;

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
            wrtEnable => memWrtEn,
            clk => clk,
            rdData => memRdData
    );
    
    pcPlus4 <= pc + 4;
    shiftedExtdImm <= signExtImm(29 downto 0) & "00";
    pcBranch <= pcPlus4 + shiftedExtdImm;
    pcJump <= pcPlus4(31 downto 28) & instr(25 downto 0) & "00";
    pcIn <= pcBranch when (branch = '1' and takeBranch = '1') else
            pcJump when jump = '1' else
            pcPlus4;
    
    rst_reg_update : process (clk) is
    begin
        if (rising_edge(clk)) then
            rst_reg <= rst;
        end if;
    end process rst_reg_update;
    
    idle <= rst_reg or halt;
    
    pcUpdate : process (clk) is
    begin
        if rising_edge(clk) then
            if (rst_reg = '1') then
                if (mode_sel = "10") then
                    pc <= x"00000298";  -- Encryption start
                elsif (mode_sel = "01") then
                    pc <= x"000003F4";  -- Decryption start
                else
                    pc <= x"00000338"; -- Round key generation start
                end if;
            elsif (halt = '1') then
                pc <= pc;
            else
                pc <= pcIn;
            end if;
        end if;
    end process pcUpdate;
    
    encRdy <= '1' when pc = x"00000334" else
              '0';
    decRdy <= '1' when pc = x"000004C4" else
              '0';
    keyRdy <= '1' when pc = x"000003F0" else
              '0';
    
    iMemAddr <= pc(10 downto 0);
   
    signExtImm <= (31 downto 16 => instr(15)) & instr(15 downto 0);
    aluIn2 <= rfRdData2 when aluSrc = '0' else
              signExtImm;
    
    rfWrtAddr <= instr(20 downto 16) when regDst = '0' else
                 instr(15 downto 11);
    rfWrtData <= aluResult when memToReg = '0' else
                 memRdData;
                 
    memWrtData <= dataToMem when tbMemWrite = '1' else
                  rfRdData2;
                 
    memAddr <= addrToMem when tbMemWrite = '1' else
               aluResult(8 downto 0) when (memToReg = '1' or memWriteCU = '1') else
               (others => '0');
               
    memWrtEn <= memWriteCU or tbMemWrite;
               
               
    test_outputs : process (clk)
    begin
        if (rising_edge(clk)) then
            encOutTemp1 <= encOutTemp1;
            encOutTemp2 <= encOutTemp2;
            decOutTemp1 <= decOutTemp1;
            decOutTemp2 <= decOutTemp2;
            if (memWriteCU = '1') then
                case memAddr is
                    when "000011110" => encOutTemp1 <= rfRdData2;
                    when "000011111" => encOutTemp2 <= rfRdData2;
                    when "000011100" => decOutTemp1 <= rfRdData2;
                    when "000011101" => decOutTemp2 <= rfRdData2;
                    when others => null;
                end case;
            end if;
        end if;
    end process test_outputs;
    
--    encOutTemp1 <= rfRdData2 when (memWriteCU = '1' and memAddr = 30) else
--                                encOutTemp1;
--    encOutTemp2 <= rfRdData2 when (memWriteCU = '1' and memAddr = 31) else
--                               encOutTemp2;
--    decOutTemp1 <= rfRdData2 when (memWriteCU = '1' and memAddr = 28) else
--                                decOutTemp1;
--    decOutTemp2 <= rfRdData2 when (memWriteCU = '1' and memAddr = 29) else
--                               decOutTemp2;
                               
    encOut <= encOutTemp1 & encOutTemp2;
    decOut <= decOutTemp1 & decOutTemp2;
    
end a1;