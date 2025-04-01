-- Lab 4 Testbench
-- Created by Steven Bolt 2/20/2025
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab4_part2 is
	port (
		CLOCK_50		: in 	std_logic;
		LEDR			: out std_logic_vector(9 downto 0);
		GPIO_0		: out std_logic_vector(35 downto 0));	-- declare gpio_0 signals
end entity lab4_part2;

architecture lab4_part2_arch of lab4_part2 is

	-- signal declarations
	signal reset_in		: std_logic := '1';
	signal write_in		: std_logic := '1';
	signal addr_in 		: std_logic := '0';
	signal wrtdata_in		: std_logic_vector(31 downto 0) := x"0000C350";	-- 50,000 counts (min angle)
	
	-- servo controller component
	component lab4 is
		port (
			clk			: in  std_logic;
			reset_n		: in 	std_logic;
			write			: in 	std_logic;
			address		: in 	std_logic;
			writedata 	: in 	std_logic_vector(31 downto 0);
			irq			: out std_logic;
			out_wave		: out std_logic);
	end component lab4;
	
begin

	-- link controller component
	controller : component lab4
		port map (
			clk			=> CLOCK_50,
			reset_n		=> reset_in,
			write			=> write_in,
			address		=> addr_in,
			writedata	=> wrtdata_in,
			irq 			=> LEDR(0),
			out_wave		=> GPIO_0(2)
		);
		
end architecture lab4_part2_arch;