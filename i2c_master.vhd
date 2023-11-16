----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2023 01:18:05 PM
-- Design Name: 
-- Module Name: i2c_master - Behavioral
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
library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_master is
generic(clk_fpga : in integer := 100e6;      -- FPGA clk speed
        clk_adc : in integer := 100e3);      -- ADC clk speed
  Port (sda_i2c : inout std_logic;      -- serial data line
        rst_i2c : in std_logic;         -- reset
        clk_i2c : in std_logic;             -- clk
        btn : in std_logic;             -- request btn for data
        sclk_i2c : out std_logic);      -- serial clk line
end i2c_master;

architecture Behavioral of i2c_master is

------------ SIGNAL DECLARATION ----------------
Type state is (idle,
               read);
               
signal cs : state := idle;

---------- signals ---------------
signal wr : std_logic;          -- read/write bit
signal busy_s : std_logic;      -- when 1 SDA line is in use
signal sda_s : std_logic;       -- controls sda line from main device
signal bit_cnt : std_logic;
signal sclk_en : std_logic;     -- when 1 sclk is one, 0 sclk holds at 1
signal scl_cnt : integer := 0;

----------- CONSTANT DECLARATION --------------
constant adc_addrs: std_logic_vector(7 downto 0) := x"28";      -- address for adc
constant b_rate: integer := clk_fpga/clk_adc;                   -- baud rate 

begin


------------ COMBINATIONAL LOGIC -----------------
--sda_i2c <= '0' when sda_s = 0 else 'Z';
process(clk_i2c, rst_i2c)
begin
      if rst_i2c = '1' then
            cs <= idle;
            busy_s <= '0';
            sclk_i2c <= '1';
            sda_i2c <= 'Z';
            scl_cnt <= b_rate;
      elsif rising_edge(clk_i2c) then
            cs <= cs;
            case cs is 
            when idle =>
                  busy <= 0;
                  sda_i2c <= 'Z';

                  if btn = '1' then
                        cs <= read;

                  end if;
            when read =>
                  
            end case;
      end if;

end process;

--sclk_i2c <= '0' WHEN (sclk_en = '1' AND sclk_i2c = '0') ELSE 'Z';
process(sclk_en)
begin
      if sclk_en = '1' then         -- sclk will be counting 
            if scl_cnt < 0 then
                  
            end if;
      else  -- hold sclk high
            sclk_i2c <= 'Z';        -- hold high
      end if;
end process;

end Behavioral;
