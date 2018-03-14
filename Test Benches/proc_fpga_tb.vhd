library ieee;
use ieee.std_logic_1164.all;

entity proc_tb is
end proc_tb;

architecture a1 of proc_tb is

    component processor is
        port ( sys_clk : in std_logic;
               sw : in std_logic_vector(15 downto 0);
               BTNS : in std_logic_vector(4 downto 0);
               reset : in std_logic;
               uart_rxd : in std_logic;
               uart_txd : out std_logic;
               C : out std_logic_vector(7 downto 0);
               AN : out std_logic_vector(7 downto 0));
--               test1 : out std_logic_vector(31 downto 0));
    end component;
    
    signal clk : std_logic := '0';
    constant half_period : time := 5 ns;
    signal uart_txd : std_logic;
    signal uart_rxd : std_logic := '1';
    signal C, AN : std_logic_vector(7 downto 0);
    signal test1 : std_logic_vector(31 downto 0);
    signal sw : std_logic_vector(15 downto 0) := (others => '0');
    signal BTNS : std_logic_vector(4 downto 0) := (others => '0');
    signal reset : std_logic := '1';
    alias mode_sel : std_logic_vector(2 downto 0) is sw(14 downto 12);
    alias execute : std_logic is sw(15);
    alias skey_select : std_logic_vector(4 downto 0) is sw(4 downto 0);
    alias step_mode : std_logic is sw(6);
    alias step_btn : std_logic is BTNS(0);

begin

    clk <= not clk after half_period;
    
    uut : processor
        port map (
            sys_clk => clk,
            sw => sw,
            BTNS => BTNS,
            reset => reset,
            uart_rxd => uart_rxd,
            uart_txd => uart_txd,
            C => C,
            AN => AN
--            test1 => test1
    );
    
    testing : process is
    begin
        wait for 120 ns;
--        mode_sel <= "111";  -- Receive Din
--        wait for 60 ns;
--        execute <= '1';
--        wait for 60 ns;
--        execute <= '0';
        
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '0';
--        wait for 104166 ns;
--        uart_rxd <= '1';
--        wait for 104166 ns;

        wait for 2 ms;
        
        mode_sel <= "001";  -- Round key generation
        wait for 60 ns;
        execute <= '1';
        wait for 900 us;
        execute <= '0';
        wait for 60 ns;
        
        mode_sel <= "010";  -- Encryption
        wait for 60 ns;
        execute <= '1';
        wait for 60 ns;
        execute <= '0';
        wait for 10 ms;
--        mode_sel <= "100";  -- Decryption
--        wait for 60 ns;
--        execute <= '1';

--        step_mode <= '1';
--        wait for 100 ns;
--        step_btn <= '1';
--        wait for 0.7 ms;
--        step_btn <= '0';
        
        
        
        wait;
    end process testing;

end a1;