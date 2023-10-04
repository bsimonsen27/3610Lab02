----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2023 09:17:33 AM
-- Design Name: 
-- Module Name: UART_Rx_Top - Behavioral
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

entity UART_Rx_Top is
  Port (clk_t, rst, sdata : in std_logic;
        LED_out : out std_logic_vector(7 downto 0);
        sdata_out : out std_logic);
        --idle_s : out std_logic_vector(1 downto 0));
end UART_Rx_Top;

architecture Behavioral of UART_Rx_Top is
   
component Receiver is
    Port ( clk : in std_logic; -- clock input
        reset : in std_logic; -- reset, active high
        sdata : in std_logic; -- serial data in
        pdata : out std_logic_vector(7 downto 0); -- parallel data out
        ready : out std_logic);
end component;

component acu is
  Port (Q : out std_logic_vector(7 downto 0);
        clk,ce,rst : in std_logic;
        D : in std_logic_vector(7 downto 0));
end component;

--component Transmitter is
--port ( clk : in std_logic; -- clock input
--        reset : in std_logic; -- reset, active high
--        pdata : in std_logic_vector(7 downto 0); -- parallel data in
--        load : in std_logic; -- load signal, active high
--        busy : out std_logic; -- busy indicator
--        sdata : out std_logic); -- serial data out
--end component;

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

signal pdata_s : std_logic_vector(7 downto 0);
signal rdy_s, n_clk : std_logic;
signal busy_s : std_logic;
--signal sdata_out : std_logic;
begin
n_clk <= not clk_t;
R1 : Receiver port map( clk => clk_t, 
                        reset => rst, 
                        ready => rdy_s, 
                        sdata => sdata, 
                        pdata => pdata_s);
D  : acu port map(clk => n_clk,
                  rst => rst,
                  ce => rdy_s,
                  D => pdata_s,
                  Q => LED_out);
--T1 : Transmitter port map(clk => clk_t,
--                          reset => rst,
--                          pdata => pdata_s,
--                          load => rdy_s,
--                          busy => busy_s,
--                          sdata => sdata_out);

T2 : TX port map(clk => clk_t,
                 reset => rst,
                 pdata => pdata_s,
                 load => rdy_s,
                 busy => busy_s,
                 sdata => sdata_out);

end Behavioral;
