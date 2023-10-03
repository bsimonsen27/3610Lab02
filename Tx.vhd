----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2023 01:47:38 PM
-- Design Name: 
-- Module Name: Tx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Tx is
    generic ( baud_rate_p : in integer := 9600;
	         clk_f_p : in integer := 100e6); -- Using _p to indicate it's a parameter
    port ( clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		pdata : in std_logic_vector(7 downto 0); -- parallel data in
		load : in std_logic;	-- load signal, active high
		busy : out std_logic; 	-- busy indicator
		sdata : out std_logic);	-- serial data out

end Tx;

architecture Behavioral of Tx is

-- Create internal buffer for pdata so that the output port doesn't change
-- except when a complete data packet has been received
signal pdata_s : std_logic_vector(9 downto 0);
-- Create states
type STATE_TYPE is (IDLE, START, DATA, STOP);
signal STATE_TX : STATE_TYPE := IDLE;

-- Create constants for loading the baud counter
constant FULL_COUNT : integer := clk_f_p/baud_rate_p;
constant HALF_COUNT : integer := FULL_COUNT/2;

-- Create the timer to convert from full-speed clock to baud clock
signal baud_timer : integer := FULL_COUNT;
signal baud_load : std_logic := '0';
constant baud_load_val : integer := FULL_COUNT;

signal BIT_COUNT : integer := 0;
signal bit_rst : std_logic := '0';
signal BIT_En : std_logic := '0';

--attribute mark_debug : string;
--attribute keep : string;
--attribute mark_debug of BIT_COUNT : signal is "true";
--attribute mark_debug of baud_timer : signal is "true";
--attribute mark_debug of STATE_TX : signal is "true";

begin

busy <= '0' when STATE_TX = IDLE else '1';
sdata <= pdata_s(BIT_COUNT);
process(clk, reset)
begin
    if reset = '1' then
        BIT_En <= '0';
        bit_rst <= '0';
        baud_load <= '1';
        pdata_s(0) <= '0'; -- start bit
        pdata_s(9) <= '1'; -- stop bit/idle high
    elsif rising_edge(clk) then-- set default signal values
        BIT_En <= '0';
        bit_rst <= '0';
        baud_load <= '0';
        case STATE_TX is
            when IDLE =>
                if load = '1' then 
                    STATE_TX <= START;
                    baud_load <= '1';
                    bit_rst <= '1';
                    pdata_s(8 downto 1) <= pdata;
                else
                    STATE_TX <= IDLE;
                end if;
                
            when START =>
                if baud_timer = 0 then
                    STATE_TX <= DATA;
                    baud_load <= '1';
                    BIT_En <= '1';
                else 
                    STATE_TX <= START;
                end if;
                
            when DATA => 
                if baud_timer = 0 then
                    BIT_En <= '1';
                    baud_load <= '1';
                    if BIT_COUNT = 9 then
                        STATE_TX <= IDLE;
                    else
                        STATE_TX <= DATA;
                    end if;
                else
                    STATE_TX <= DATA;
                end if;
            
            when OTHERS =>
                STATE_TX <= IDLE;
            
        end case; 
    end if;           
end process;

--Baud counter
process (clk, reset)
begin
    if reset = '1' then
        baud_timer <= FULL_COUNT;
    elsif falling_edge(clk) then
        if baud_load = '1' then
            baud_timer <= baud_load_val;
        elsif baud_timer > 0 then
            baud_timer <= baud_timer - 1;
        else
            baud_timer <= 0; -- prevents baud timer from going negative
        end if;
    end if;
end process;

--bit counter
process (clk, reset)
begin
    if reset = '1' then
        BIT_COUNT <= 9;
    elsif falling_edge(clk) then
        if bit_rst = '1' then
            BIT_COUNT <= 0;
        elsif BIT_COUNT < 9 AND BIT_En = '1' then --BC can't exceed 9
            BIT_COUNT <= BIT_COUNT + 1;
        else
            BIT_COUNT <= BIT_COUNT;
        end if;
    end if;
end process;

end Behavioral;