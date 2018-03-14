library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity proc_tb is
end proc_tb;

architecture a1 of proc_tb is

    component processor is
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
    end component;
    
    signal clk : std_logic := '0';
    constant half_period : time := 5 ns;
    constant proc_period : time := 20 ns;
    constant ENC : std_logic_vector(1 downto 0) := "10";
    constant DEC : std_logic_vector(1 downto 0) := "01";
    constant KEY : std_logic_vector(1 downto 0) := "00";
    constant L0ADDR : std_logic_vector(8 downto 0) := "000100000";
    constant L1ADDR : std_logic_vector(8 downto 0) := "000100001";
    constant L2ADDR : std_logic_vector(8 downto 0) := "000100010";
    constant L3ADDR : std_logic_vector(8 downto 0) := "000100011";
    constant A_ADDR : std_logic_vector(8 downto 0) := "000000000";
    constant B_ADDR : std_logic_vector(8 downto 0) := "000000001";
    signal rst : std_logic := '1';
    signal mode_sel : std_logic_vector(1 downto 0) := "00";
    signal dataToMem : std_logic_vector(31 downto 0) := (others => '0');
    signal addrToMem : std_logic_vector(8 downto 0) := (others => '0');
    signal tbMemWrite : std_logic := '0';
    signal encOut, decOut : std_logic_vector(63 downto 0) := (others => '0');
    signal encRdy, decRdy, keyRdy : std_logic := '0';  

begin

    clk <= not clk after half_period;
    
    uut : processor
        port map (
            sys_clk => clk,
            rst => rst,
            mode_sel => mode_sel,
            dataToMem => dataToMem,
            addrToMem => addrToMem,
            tbMemWrite => tbMemWrite,
            encOut => encOut,
            decOut => decOut,
            encRdy => encRdy,
            decRdy => decRdy,
            keyRdy => keyRdy
    );
    
    testing : process is
        file infile : text is in "rc5_test_inputs.txt";
        
        -- Three different file instantiation styles. The third goes with 
        -- the file_open and file_close commands.
        file outfile : text is out "rc5_test_outputs.txt";                -- Stand-alone statement
--        file outfile : text open write_mode is "rc5_test_outputs.txt";    -- Stand-alone statement
--        file outfile : text;                                              -- To be used with file_open and file_close 
                        
        variable inline, outline : line;
        variable ukey : std_logic_vector(127 downto 0);
        variable plaintext, ciphertext : std_logic_vector(63 downto 0);
        variable L0, L1, L2, L3 : std_logic_vector(31 downto 0);
        variable case_cnt, enc_cycles, dec_cycles, key_cycles : integer := 0;
        variable startTime, encTime, decTime, keyTime : time := 0 ns;
        variable errors : integer := 0;
    begin
--        file_open(outfile, "rc5_test_outputs.txt", write_mode);
    
        wait for 120 ns;
        while not(endfile(infile)) loop
--        for i in 0 to 9 loop
            rst <= '1';
            readline(infile, inline);
            next when inline'length = 0;
            hread(inline, ukey);
            hread(inline, plaintext);
            hread(inline, ciphertext);
            L0 := ukey(103 downto 96) & ukey(111 downto 104) & ukey(119 downto 112) & ukey(127 downto 120);
            L1 := ukey(71 downto 64) & ukey(79 downto 72) & ukey(87 downto 80) & ukey(95 downto 88);
            L2 := ukey(39 downto 32) & ukey(47 downto 40) & ukey(55 downto 48) & ukey(63 downto 56);
            L3 := ukey(7 downto 0) & ukey(15 downto 8) & ukey(23 downto 16) & ukey(31 downto 24);
            dataToMem <= L0;
            addrToMem <= L0ADDR;
            tbMemWrite <= '1';
            wait for proc_period;
            dataToMem <= L1;
            addrToMem <= L1ADDR;
            wait for proc_period;
            dataToMem <= L2;
            addrToMem <= L2ADDR;
            wait for proc_period;
            dataToMem <= L3;
            addrToMem <= L3ADDR;
            wait for proc_period;
            dataToMem <= plaintext(63 downto 32);
            addrToMem <= A_ADDR;
            wait for proc_period;
            dataToMem <= plaintext(31 downto 0);
            addrToMem <= B_ADDR;
            wait for proc_period;
            tbMemWrite <= '0';
            wait for proc_period;
            
            mode_sel <= KEY;  -- Round key generation
            wait for proc_period;
            rst <= '0';
            startTime := now;
            wait until keyRdy = '1';
            keyTime := keyTime + (now - startTime);
            wait for proc_period/2;
            
            wait for 2*proc_period;
            rst <= '1';
            mode_sel <= ENC;  -- Encryption
            wait for 4*half_period;
            rst <= '0';            
            startTime := now;
            wait until encRdy = '1';
            encTime := encTime + (now - startTime);
            assert (encOut = ciphertext) report "Case " & integer'image(case_cnt+1) & ": Encryption error! dout = " & integer'image(to_integer(unsigned(encOut))) & " and ciphertext = " & integer'image(to_integer(unsigned(ciphertext))) severity ERROR;
            if (encOut /= ciphertext) then
                errors := errors + 1;
            end if;
            wait for proc_period/2;
            
            wait for 2*proc_period;
            rst <= '1';
            dataToMem <= ciphertext(63 downto 32);
            addrToMem <= A_ADDR;
            tbMemWrite <= '1';
            wait for proc_period;
            dataToMem <= ciphertext(31 downto 0);
            addrToMem <= B_ADDR;
            wait for proc_period;
            tbMemWrite <= '0';
            wait for proc_period;        
            mode_sel <= DEC;  -- Decryption
            wait for proc_period;
            rst <= '0';
            startTime := now;
            wait until decRdy = '1';
            decTime := decTime + (now - startTime);
            assert (decOut = plaintext) report "Case " & integer'image(case_cnt+1) & ": Decryption error! dout = " & integer'image(to_integer(unsigned(decOut))) & " and plaintext = " & integer'image(to_integer(unsigned(plaintext))) severity ERROR;
            if (decOut /= plaintext) then
                errors := errors + 1;
            end if;
            wait for proc_period/2;
            wait for 10*proc_period;
            case_cnt := case_cnt + 1;
--            report "Case " & integer'image(case_cnt) & " complete.";
        end loop;        
 
        write(outline, string'("Tests complete. "));
        write(outline, case_cnt);
        write(outline, string'(" cases tested at clock period of "));
        write(outline, proc_period);
        write(outline, string'("."));
        writeline(outfile, outline);
        write(outline, errors);
        write(outline, string'(" errors detected."));
        writeline(outfile, outline);
        writeline(outfile, outline);
        
        write(outline, string'("Average key generation time: "));
        write(outline, keyTime/case_cnt);
        writeline(outfile, outline);
        write(outline, string'("Average key generation clock cycles: "));
        write(outline, (keyTime/case_cnt)/proc_period);
        writeline(outfile, outline);
        writeline(outfile, outline);

        write(outline, string'("Average encryption time: "));
        write(outline, encTime/case_cnt);
        writeline(outfile, outline);
        write(outline, string'("Average encryption clock cycles: "));
        write(outline, (encTime/case_cnt)/proc_period);
        writeline(outfile, outline);
        writeline(outfile, outline);

        write(outline, string'("Average decryption time: "));
        write(outline, decTime/case_cnt);
        writeline(outfile, outline);
        write(outline, string'("Average decryption clock cycles: "));
        write(outline, (decTime/case_cnt)/proc_period);
        writeline(outfile, outline);

--        file_close(outfile);

        stop(0);
        wait;
    end process testing;

end a1;