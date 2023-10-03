----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/05/2023 01:12:00 PM
-- Design Name: 
-- Module Name: Counter - Behavioral
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



entity Counter is
    Port (ld_val: in unsigned(7 downto 0);
    en, ld, rst, clk: in std_logic;
    clk_o: out std_logic);
end Counter;

architecture Behavioral of Counter is
    signal cnt: unsigned(7 downto 0);
begin
process(clk,rst)
begin
    if rst = '0' then
        cnt <= ld_val;
    elsif rising_edge(clk) then
        if ld = '1' then
            cnt <=ld_val;
        end if;
    elsif en = '1' then
        if cnt = 0 then
            clk_o <= '1';
        else
            cnt <= cnt - 1;
        end if;
    end if;
    
end process;

end Behavioral;
