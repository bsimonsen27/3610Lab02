----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2023 10:00:45 PM
-- Design Name: 
-- Module Name: SPI_TOP - Behavioral
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

entity SPI_TOP is
  Port (sw : in std_logic_vector(5 downto 0);
      clk : in std_logic; -- clock input
      reset : in std_logic; -- reset, active high
      load : in std_logic; -- notification to send data
      sdata_top : out std_logic; -- serial data out 1
      --sdata_1 : out std_logic; -- serial data out 2 (connect if extra DAC is needed)
      spi_clk_top : out std_logic; -- clk out to SPI devices
      CS0_top : out std_logic );
end SPI_TOP;

architecture Behavioral of SPI_TOP is
signal input_data: std_logic_vector(15 downto 0);
signal input_addr: std_logic_vector(16 downto 0);
signal count : integer :=0 ;
signal ena_s : std_logic; 
signal CS_BUFF : std_logic;
signal nclk : std_logic;
    
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


begin

C1: spi_master port map( clk => clk,
                         reset =>reset,
                         load =>load,
                         data_in=> input_data,
                         sdata_0 => sdata_top,
                         spi_clk => spi_clk_top,
                         CS0_n => CS_BUFF);
                         
C2: blk_mem_gen_0 PORT MAP (
                            clka => clk,
                            addra => input_addr,
                            douta => input_data
                          );

    count <= count;
    input_data <= input_data;
    input_addr <= std_logic_vector(TO_UNSIGNED(count, input_addr'length));
    nclk <= NOT clk;
    CS0_top <= CS_BUFF;
    process(clk)
   
    begin
        if reset = '1' then
            count <= 0;
        elsif rising_edge(clk) then
            if CS_BUFF = '1' then
                count <= count + 1;
                if count = 10000 then
                    count <= 0;
                end if; 
            elsif CS_BUFF = '1' then
                count <= count; 
            else
                count <= count;
            end if;
        end if;
         
    
    end process; 

end Behavioral;
