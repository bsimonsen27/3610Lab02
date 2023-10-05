----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2023 02:10:20 PM
-- Design Name: 
-- Module Name: testbench - Behavioral
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

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
  
  component RX is
generic ( baud_rate_p : in integer := 115200;
	      clk_f_p : in integer := 100e6); -- Using _p to indicate it's a parameter
	port (clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		sdata : in std_logic;	-- serial data in
		pdata : out std_logic_vector(7 downto 0);	-- parallel data out
		ready : out std_logic);	-- ready strobe, active high
end component;

component Tx is
    generic ( baud_rate_p : in integer := 115200;
	         clk_f_p : in integer := 100e6); -- Using _p to indicate it's a parameter
    port ( clk : in std_logic;	-- clock input
		reset : in std_logic;	-- reset, active high
		pdata : in std_logic_vector(7 downto 0); -- parallel data in
		load : in std_logic;	-- load signal, active high
		busy : out std_logic; 	-- busy indicator
		sdata : out std_logic);	-- serial data out

end component;

  signal clk_tb : std_logic := '0';
  signal reset_tb : std_logic := '1';
  signal pdata_tb : std_logic_vector(7 downto 0);
  signal ready_tb : std_logic := '0';
  signal busy_tb : std_logic;
  signal sdata_out_tb : std_logic;
  signal sdata_in_tb : std_logic;

  constant BIT_PERIOD : TIME := 40 ns;

  procedure TX_BITS(
    data : in std_logic_vector(7 downto 0);
    signal tx_serial : out std_logic
  ) is
  begin
    tx_serial <= '0';
    wait for BIT_PERIOD;
    for ii in 0 to 7 loop
      tx_serial <= data(ii);
      wait for BIT_PERIOD;
    end loop;
    tx_serial <= '1';
    wait for BIT_PERIOD;
  end TX_BITS;

begin
  R1: RX port map(
    clk => clk_tb,
    reset => reset_tb,
    sdata => sdata_in_tb,
    pdata => pdata_tb,
    ready => ready_tb
  );

  T1: Tx port map(
    clk => clk_tb, 
    reset => reset_tb,
    sdata => sdata_out_tb,
    pdata => pdata_tb,
    load => ready_tb,
    busy => busy_tb
  );


  clk_tb <= not clk_tb after 5 ns;

  process
  begin    
    wait for 13 ns;
    reset_tb <= '1';    -- reset devices
    sdata_in_tb <= '1';
    wait for 5 ns;
    reset_tb <= '0'; 
    wait until rising_edge(clk_tb);
    
    -- Call TX_BITS inside the Receiver to send data
    TX_BITS(X"56", sdata_in_tb);
    wait for 120 ns;
    TX_BITS(X"70", sdata_in_tb);
    wait for 120 ns;
--    sdata_in_tb <= '0';   -- start bit
--    wait for 40 ns;
    
    wait;
  end process;
end Behavioral;
