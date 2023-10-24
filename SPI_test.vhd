----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2023 02:21:41 PM
-- Design Name: 
-- Module Name: SPI_test - Behavioral
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

entity SPI_test is
--  Port ( );
end SPI_test;

architecture Behavioral of SPI_test is

component SPI_master is
-- spi_clk_f is limited to 30 MHz for DA2
generic(m_clk_f : in integer := 100e6;      -- FPGA clk speed
        spi_clk_f : in integer := 10e6);    -- DAC clk speed
port ( clk : in std_logic;	-- clock input
	   reset : in std_logic;	-- reset, active high
	   load : in std_logic; 		-- notification to send data
	   data_in : in std_logic_vector(15 downto 0);	-- pdata in
	   sdata_0 : out std_logic;	-- serial data out 1
	   sdata_1 : out std_logic;	-- serial data out 2
	   spi_clk : out std_logic;		-- clk out to SPI devices
	   CS0_n : out std_logic);	-- chip select 1, active low

end component;
------------- SIGNAL DECLARATION ---------------

signal clk_tb : std_logic := '0'; 
signal rst_tb : std_logic := '0';
signal ld_tb : std_logic := '0';
signal data_in_tb : std_logic_vector(15 downto 0); 
signal sdata_0_tb : std_logic; 
signal sdata_1_tb : std_logic; 
signal spi_clk_tb : std_logic; 
signal CS0_n_tb : std_logic;
signal ind : integer := 0;
signal rx_rec : std_logic_vector(15 downto 0);
--type test_record is array (0 to 3) of std_logic_vector(15 downto 0);

type test_array_type is array (0 to 3) of std_logic_vector(15 downto 0);
signal test_record : test_array_type;

procedure SPI_RX(
    signal serial_in, spi_clk_in : in std_logic;
    signal p_out : out std_logic_vector(15 downto 0)) is
begin
    for ii in 15 downto 0 loop
        wait until falling_edge(spi_clk_in);
        p_out(ii) <= serial_in;
        wait for 1 ns;
    end loop;
end SPI_RX;
 

begin
UT_SPI: SPI_master port map(
        reset => rst_tb,
        clk => clk_tb,
        load => ld_tb,
        data_in => data_in_tb,
        sdata_0 => sdata_0_tb,
        sdata_1 => sdata_1_tb,
        spi_clk => spi_clk_tb,
        CS0_n => CS0_n_tb);

clk_tb <= not clk_tb after 5 ns;

process
begin
    rst_tb <= '1';  -- reset the device
    wait for 10 ns;
    rst_tb <= '0';
    wait for 10 ns;
    ld_tb <= '1';
    data_in_tb <= "1010101011110000";
    SPI_RX(sdata_0_tb, spi_clk_tb, rx_rec);
    ld_tb <= '1';       -- load value into SPI device and send the data
    test_record(ind) <= rx_rec;
    wait for 1 ns;
    ind <= ind + 1;

end process;

end Behavioral;
