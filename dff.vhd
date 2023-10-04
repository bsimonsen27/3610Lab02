----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/19/2023 03:12:42 PM
-- Design Name: 
-- Module Name: dff - Behavioral
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

entity dff is
  Port (Q : out std_logic_vector (7 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        en : in std_logic;
        S : in std_logic_vector (7 downto 0) );
end dff;

architecture Behavioral of dff is
-- SIGNAL DECLARATION
signal D : std_logic_vector (7 downto 0);
signal q_s : std_logic_vector (7 downto 0);

begin
D <= S when en = '1' else q_s;
process(clk)
begin
    if(falling_edge(clk)) then
        if(reset = '1') then
            Q <= "00000000";
         else 
            q_s <= D;
         end if;
     end if;
end process;
Q <= q_s;

end Behavioral;
