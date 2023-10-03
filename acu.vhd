----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2023 12:19:40 PM
-- Design Name: 
-- Module Name: acu - Behavioral
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

entity acu is
  Port (Q : out std_logic_vector(7 downto 0);
        clk,ce,rst : in std_logic;
        D : in std_logic_vector(7 downto 0));
end acu;

architecture Behavioral of acu is
    signal Q_s : std_logic_vector(7 downto 0);
begin
    process(clk)
    begin
    
    if rising_edge(clk) then
        if (rst = '1') then
            Q_s <= "00000000";
        elsif ce = '1' then
            Q_s <= D;
        else
            Q_s <= Q_s;
        end if;
    end if;
    Q <= Q_s;
    end process;

end Behavioral;
