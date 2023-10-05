----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/04/2023 05:09:46 PM
-- Design Name: 
-- Module Name: RX - Behavioral
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

entity RX is
generic ( baud_rate_p : in integer := 115200;
	      clk_f_p : in integer := 100e6); -- Using _p to indicate it's a parameter
	port (clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		sdata : in std_logic;	-- serial data in
		pdata : out std_logic_vector(7 downto 0);	-- parallel data out
		ready : out std_logic);	-- ready strobe, active high
end RX;

architecture Behavioral of RX is
-- Create internal buffer for pdata so that the output port doesn't change
-- except when a complete data packet has been received
signal pdata_s : std_logic_vector(7 downto 0);
-- Create states
type STATE_TYPE is (IDLE, START, DATA, DATA_READY, STOP);
signal STATE_RX : STATE_TYPE := IDLE;

-- Create constants for loading the baud counter
constant FULL_COUNT : integer := 2; --clk_f_p/baud_rate_p;
constant HALF_COUNT : integer := FULL_COUNT/2;

-- Create the timer to convert from full-speed clock to baud clock
signal baud_timer : integer := HALF_COUNT;
signal baud_load : std_logic := '0';
signal baud_load_val : integer;

signal BIT_COUNT : integer := 0;
signal bit_rst : std_logic := '0';
signal BIT_En : std_logic := '0';

begin

-- Asserts ready when in DATA_READY state
-- Using combinational logic means it doesn't need to be assigned in every state
ready <= '1' when STATE_RX = DATA_READY else '0';
baud_load_val <= HALF_COUNT when STATE_RX = START else FULL_COUNT;
bit_rst <= '0' when STATE_RX = DATA else '1';

process(clk, reset)
begin
    if reset = '1' then 
        -- all control signals used inside SM specified in rst
        STATE_RX <= IDLE;
        PDATA <= (OTHERS => '0');
        baud_load <= '1';
        BIT_En <= '0';
    elsif rising_edge(clk) then
        -- Set defaults for control signals so they don't have to be in every state
        baud_load <= '0';
        BIT_En <= '0'; -- bit counter will only ever be enabled for 1 clk
        
        case STATE_RX is
            when IDLE =>
                -- Wait for sdata to drop to 0, then load timer
                if sdata = '0' then
                    STATE_RX <= START;
                    baud_load <= '1';
                else
                    STATE_RX <= IDLE;
                end if;
            
            when START =>
                if baud_timer = 0 then
                    STATE_RX <= DATA;
                    baud_load <= '1';
                else 
                    STATE_RX <= START;                   
                end if;
                
            when DATA =>
                if baud_timer = 0 AND BIT_COUNT < 8 then
                    STATE_RX <= DATA;
                    baud_load <= '1';
                    pdata_s(BIT_COUNT) <= sdata;
                    BIT_En <= '1'; -- bit counter is FE triggered, so no race condition
                elsif baud_timer = 0 AND BIT_COUNT = 8 then
                    -- Transitions out of data halfway through stop bit. 
                    -- No sample taken
                    STATE_RX <= STOP;
                    pdata <= pdata_s; 
                else 
                    STATE_RX <= DATA;
                end if;
                
            when STOP =>
               STATE_RX <= DATA_READY;
               
               
            when DATA_READY =>
               -- ready signal is assert by combinational logic above the process
               STATE_RX <= IDLE;
                
            
               
            -- Required when there is a number of states other than 2^N
            when OTHERS =>
               STATE_RX <= IDLE;
                
        
        end case;
    
    end if;
end process;

--Baud counter
process (clk, reset)
begin
    if reset = '1' then
        baud_timer <= HALF_COUNT;
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
        BIT_COUNT <= 0;
    elsif falling_edge(clk) then
        if bit_rst = '1' then
            BIT_COUNT <= 0;
        elsif BIT_COUNT < 8 AND BIT_En = '1' then --BC can't exceed 8
            BIT_COUNT <= BIT_COUNT + 1;
        else
            BIT_COUNT <= BIT_COUNT;
        end if;
    end if;
end process;

end Behavioral;
