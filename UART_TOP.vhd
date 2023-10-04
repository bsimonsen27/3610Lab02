----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2023 05:54:08 PM
-- Design Name: 
-- Module Name: UART_TOP - Behavioral
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

entity UART_TOP is
Port (clk_t, rst, sdata : in std_logic;
        LED_out : out std_logic_vector(7 downto 0);
        idle_s : out std_logic_vector(1 downto 0));
end UART_TOP;

architecture Behavioral of UART_TOP is

component UART_RX is
  generic (
    g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;

component UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;

---------------- SIGNAL DECLARATION ----------------------
signal pdata_s : std_logic_vector(7 downto 0);
signal rdy_s, n_clk : std_logic;
signal busy_s : std_logic;
signal sdata_out : std_logic;

begin
n_clk <= not clk_t;

R1 : UART_RX port map(i_Clk => n_clk,
                    i_RX_Serial => sdata,
                    o_RX_DV => rdy_s,
                    o_RX_Byte => pdata_s);

end Behavioral;
