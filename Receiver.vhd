----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/05/2023 01:11:30 PM
-- Design Name: 
-- Module Name: Receiver - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Receiver is
    -- generic(count_val : integer := 868);
    port ( clk : in std_logic;                  -- clock input
    reset : in std_logic;                       -- reset, active high
    sdata : in std_logic;                       -- serial data in
    pdata : out std_logic_vector(7 downto 0);   -- parallel data out
    ready : out std_logic;                      -- when 1, we are ready to receive more data
    idle_state : out std_logic_vector(1 downto 0)); -- DEBUG, identifies what state we are in
end Receiver;

architecture Behavioral of Receiver is
    type STATE_TYPE is (IDLE, 
                        START_BIT,
                        DATA,
                        STOP_BIT, 
                        SAVE_DATA);
    signal state_rx: STATE_TYPE:= IDLE;
    signal BIT_COUNT : integer;
    signal COUNT_DOWN : integer;
    signal pbuff : std_logic_vector(7 downto 0);
    signal store_start_bit, store_stop_bit: std_logic;
    constant FULL_COUNT: integer:= 3;
    constant HALF_COUNT: integer:= FULL_COUNT/2;
    
begin
process(clk, reset)
begin
    if reset = '1' then
        state_rx <= IDLE;
        ready <= '1';
        --pdata <= "00000000";        -- no output
        pbuff <= "00000000";
        store_start_bit <= '0';
        store_stop_bit <= '0';
        bit_count <= 8;
        count_down <= HALF_COUNT;
    elsif rising_edge(clk) then
        pbuff <= pbuff;
        ready <= '0';
        case state_rx is
-----------------------------------------------------------
-- waiting for start condition
            when IDLE =>
                COUNT_DOWN <= 0;
                idle_state <= "11"; --DEBUGGING
                if sdata = '0' then
                    state_rx <= START_BIT;
                    COUNT_DOWN <= HALF_COUNT;
                    ready <= '0';
                else
                    state_rx <= IDLE;
                end if;
-----------------------------------------------------------
            when START_BIT =>
                idle_state <= "00";
                if COUNT_DOWN = 0 then
                    state_rx <= DATA;
                    store_start_bit <= sdata;
                    BIT_COUNT <= 8;
                    COUNT_DOWN <= FULL_COUNT;
                else --count_down > 0 then
                    COUNT_DOWN <= COUNT_DOWN - 1;
                end if;
-----------------------------------------------------------
            when DATA =>
            
            if COUNT_DOWN = 0 then
                idle_state <= "01";
                if BIT_COUNT = 0 then
                    state_rx <= STOP_BIT;
                    store_stop_bit <= sdata;
                else
                    pbuff(BIT_COUNT - 1) <= sdata;      -- sdata value assigned to buffer signal
                    BIT_COUNT <= BIT_COUNT - 1;
                    COUNT_DOWN <= FULL_COUNT;               
                end if;
            else
                COUNT_DOWN <= COUNT_DOWN - 1;
            end if;  
-----------------------------------------------------------
            when STOP_BIT =>
                idle_state <= "10";
                state_rx <=IDLE;
                ready <= '1';       -- ready to read 
--                if store_stop_bit = '1' then
--                    state_rx <=IDLE;
--                    ready <= '1';       -- ready to read 
--                    --BIT_COUNT <= 8;
--                else 
--                    state_rx <= IDLE;
--                    ready <= '0';       -- something is wrong
--                end if;
            when others =>
                state_rx <= IDLE;             
        end case;
     end if;
               
end process;
pdata <= pbuff;

end Behavioral;