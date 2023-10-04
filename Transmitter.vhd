----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2023 01:05:46 PM
-- Design Name: 
-- Module Name: Transmitter - Behavioral
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

entity Transmitter is
port ( clk : in std_logic; -- clock input
        reset : in std_logic; -- reset, active high
        pdata : in std_logic_vector(7 downto 0); -- parallel data in
        load : in std_logic; -- load signal, active high
        busy : out std_logic; -- busy indicator
        sdata : out std_logic); -- serial data out
end Transmitter;

architecture Behavioral of Transmitter is
    type STATE_TYPE is (IDLE, 
                        START_BIT,
                        DATA,
                        STOP_BIT, 
                        SAVE_DATA,
                        BUSY_T);
    signal state_tx: STATE_TYPE:= IDLE;
    signal BIT_COUNT : integer;
    signal COUNT_DOWN : integer;
    signal pbuff : std_logic_vector(7 downto 0);
    signal store_start_bit, store_stop_bit: std_logic;
    constant FULL_COUNT: integer:= 2;     -- 848 for hardware
    constant HALF_COUNT: integer:= FULL_COUNT/2;
begin
process(clk, reset)
begin
    if reset = '1' then
        state_tx <= IDLE;
  --      ready <= '1';
        --pdata <= "00000000";        -- no output
        pbuff <= "00000000";
        store_start_bit <= '0';
        store_stop_bit <= '0';
        BIT_COUNT <= 8;
        COUNT_DOWN <= FULL_COUNT;
    elsif rising_edge(clk) then
        pbuff <= pbuff;
        busy <= '0';
        case state_tx is
-----------------------------------------------------------
-- waiting for start condition
            when IDLE =>
                sdata <= '1';         -- hold sda line high until sending stop bit
                busy <= '1';
                COUNT_DOWN <= 0;
                BIT_COUNT <= 0;
                if load = '1' then  -- ready to transmit
                    pbuff <= pdata; -- load data on pdata line into a buffer
                    state_tx <= START_BIT;
                    --sdata <= '0';       -- send start bit
                    COUNT_DOWN <= FULL_COUNT; 
                    sdata <= '0';   -- start bit 
                    busy <= '1';          
                else
                    state_tx <= IDLE;
                end if;
-----------------------------------------------------------
            when START_BIT =>
                busy <= '1';
                sdata <= '0';   -- keep sending start bit
                BIT_COUNT <= 0;
                if COUNT_DOWN = 0 then
                    sdata <= pbuff(BIT_COUNT);
                    state_tx <= DATA;
                    BIT_COUNT <= BIT_COUNT + 1;
                    COUNT_DOWN <= FULL_COUNT;
                else --count_down > 0 then
                    COUNT_DOWN <= COUNT_DOWN - 1;
                    state_tx <= start_bit;
                end if;
-----------------------------------------------------------
            when DATA =>
            sdata <= pbuff(BIT_COUNT - 1);      -- continue sending previous bit
            busy <= '1';                        -- busy because sending data
            if COUNT_DOWN = 0 then
                busy <= '1';               
                if BIT_COUNT < 7 then
                    state_tx <= STOP_BIT;
                    sdata <= '1';               -- send stop bit
                else
                    sdata <= pbuff(BIT_COUNT);      -- sdata value assigned to buffer signal
                    BIT_COUNT <= BIT_COUNT + 1;
                    COUNT_DOWN <= FULL_COUNT;
                     
                    state_tx <= data;              
                end if;
            else
                COUNT_DOWN <= COUNT_DOWN - 1;
                state_tx <= data;
            end if;  
-----------------------------------------------------------
            when STOP_BIT =>
                sdata <= '1';   -- still sending stop bit/holding sda line high
                state_tx <= IDLE;
                busy <= '0';       -- ready to read 
            when others =>
                state_tx <= IDLE;             
        end case;
     end if;
               
end process;

end Behavioral;
