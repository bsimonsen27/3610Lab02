----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2023 09:21:15 AM
-- Design Name: 
-- Module Name: SPI_master - Behavioral
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

entity SPI_master is
-- spi_clk_f is limited to 30 MHz for DA2
generic(m_clk_f : in integer := 100e6;      -- FPGA clk speed
        spi_clk_f : in integer := 10e6);    -- DAC clk speed
port ( clk : in std_logic;	-- clock input
	   reset : in std_logic;	-- reset, active high
	   load : in std_logic; 		-- notification to send data
	   data_in : in std_logic_vector(15 downto 0);	-- pdata in
	   sdata_0 : out std_logic;	-- serial data out 1
	   --sdata_1 : out std_logic;	-- serial data out 2
	   spi_clk : out std_logic;		-- clk out to SPI devices
	   CS0_n : out std_logic);	-- chip select 1, active low

end SPI_master;

architecture Behavioral of SPI_master is

type state_SPI is (IDLE, TX1, TX2);

---------------- SIGNAL DECLARATION ---------------------
constant FULL_COUNT : integer := m_clk_f/spi_clk_f;     -- baud rate
--constant HALF_COUNT : integer := FULL_COUNT/2;
signal state: state_SPI := IDLE;
signal clk_cnt : integer;       -- baud counter
signal bit_cnt : integer := 15;       -- keeps track of # of bits sent
signal data_buff : std_logic_vector(15 downto 0);       -- buffer for sda line

begin

spi_clk <= '0' when state = TX2 else '1';
--spi_clk <= '1' when state = TX1 else
--           '0' when state = TX2 else
--          '1';
CS0_n <= '1' when state = IDLE else '0';
sdata_0 <= data_buff(bit_cnt);
--sdata_1 <= data_buff(bit_cnt);

------------------ BEGIN PROCESS ----------------------
process(clk)
begin
    if reset = '1' then
        state <= idle;
    
    elsif rising_edge(clk) then
        state <= state;             -- stays the same
        data_buff <= data_buff;
        case state is 
------------------------------------------------------
            when IDLE =>
                if load = '1' then 
                    state <= TX1;
                    bit_cnt <= 15;
                    clk_cnt <= FULL_COUNT;
                    data_buff <= data_in;       -- load data into buffer
                --else
                    --state <= IDLE;      -- don't do anything
                end if;
------------------------------------------------------
            when TX1 =>     -- change SDA line
                --if clk_cnt < 1 then
                if clk_cnt = 0 then 
                    state <= TX2;
                    --bit_cnt <= bit_cnt - 1;     -- move to next value
                    clk_cnt <= FULL_COUNT;      -- reset counter
                else        -- clk_cnt > 0
                    clk_cnt <= clk_cnt - 1;     -- count
                end if;
------------------------------------------------------
            when TX2 =>     -- DAC reads data
                --if clk_cnt < 1 then
                if clk_cnt = 0 then
                    if bit_cnt = 0 then
                        state <= idle;
                    else -- bit_cnt != 0
                        state <= tx1;
                        clk_cnt <= FULL_COUNT;
                        bit_cnt <= bit_cnt - 1;
                    end if;
                
                else                        -- keep counting 
                    clk_cnt <= clk_cnt -1;  -- count another clock cycle
                end if;
                
                --                   state <= idle;
--                elsif clk_cnt = 0 then
--                    state <= tx1;
--                    clk_cnt <= FULL_COUNT;
--                    bit_cnt <= bit_cnt - 1;
            
            when others =>
                state <= IDLE; 
        
        end case;
    
    --else
    
    end if;


end process;


end Behavioral;
