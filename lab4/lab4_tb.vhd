
-- Lab 4 Testbench
-- Created by Steven Bolt 2/20/2025
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab4_tb is
end entity lab4_tb;

architecture lab4_tbArch of lab4_tb is

	-- inputs
	signal clk_in		: std_logic := '1';
	signal reset_in		: std_logic := '1';
	signal write_in		: std_logic := '1';
	signal addr_in 		: std_logic := '0';
	signal wrtdata_in	: std_logic_vector(31 downto 0) := x"0000EA60";
	--outputs
	signal irq_out		: std_logic;
	signal wave_out		: std_logic;
	
	component lab4 is
		port (
			CLK		: in  std_logic;
			RESET_N		: in  std_logic;
			WRITE		: in  std_logic;
			ADDRESS		: in  std_logic;
			WRITEDATA 	: in  std_logic_vector(31 downto 0);
			IRQ		: out std_logic;
			OUT_WAVE	: out std_logic);
	end component lab4;
	
begin

	uut : lab4
		port map (
			CLK => clk_in,
			RESET_N => reset_in,
			WRITE => write_in,
			ADDRESS => addr_in,
			WRITEDATA => wrtdata_in,
			IRQ => irq_out,
			OUT_WAVE => wave_out
		);

	clk_in <= not clk_in after 10 ns;	-- clock period of 20ns (50 MHz)
		
end architecture lab4_tbArch;