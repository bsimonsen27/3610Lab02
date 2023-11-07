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
	   --sdata_1 : out std_logic;	-- serial data out 2
	   spi_clk : out std_logic;		-- clk out to SPI devices
	   CS0_n : out std_logic);	-- chip select 1, active low

end component;

component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

type test_array_type is array (0 to 3) of std_logic_vector(15 downto 0);
signal test_record : test_array_type;
signal ind : integer :=0;
signal rx_rec : std_logic_vector(15 downto 0);

signal reset_TB, sdata_TB, load_TB, CS0_n_TB, spi_clk_TB: std_logic := '1';
signal data_in_TB : std_logic_vector(15 downto 0);
signal addra_TB : STD_LOGIC_VECTOR(13 DOWNTO 0);
signal clk_TB :std_logic := '0';
 
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

UUT: SPI_master
Port map ( clk => clk_TB,
            reset => reset_TB,
            load => load_TB,
            data_in  => data_in_TB,
            sdata_0  => sdata_TB,
            --sdata_1 : 
            spi_clk  => spi_clk_TB,
            CS0_n => CS0_n_TB); 
        
C2: blk_mem_gen_0 
PORT MAP (clka => clk_tb,
          addra => addra_TB, 
          douta => data_in_TB ); 
                          

clk_TB <= not clk_TB after 5 ns;
process
begin
    wait for 13 ns;
    reset_TB <= '1';
    wait for 15 ns;
    reset_TB <= '0';
    load_TB <= '1';
    for ii in 0 to 10000 loop
        wait until CS0_n_tb = '1';
        ind <= ii;
        addra_tb <= std_logic_vector(TO_UNSIGNED(ind, addra_tb'length));
        load_TB <= '1';
        wait for 15ns;
        load_TB <= '0';
        
    end loop;
--    SPI_RX(sdata_TB, spi_clk_TB, rx_rec);
--    test_record(ind) <= rx_rec;
--    wait for 1 ns;
--    ind <= ind + 1;
    
--    wait for 1 us;
    
--    load_TB <= '1';
--    data_in_TB <= X"5A5A";
--    wait for 15 ns;
--    load_TB <= '0';
    
--    SPI_RX(sdata_TB, spi_clk_TB, rx_rec);
--    test_record(ind) <= rx_rec;
--    wait for 1 ns;
--    ind <= ind + 1;
    
    wait;
    
end process;


end Behavioral;
