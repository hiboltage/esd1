-- Lab 4 Testbench
-- Created by Steven Bolt 2/20/2025
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab4_tb is
end entity lab4_tb;

architecture lab4_tbArch of lab4_tb is

	signal clk_in			: std_logic := '0';
	signal write_in		: std_logic := '0';
	signal addr_in 		: std_logic := '0';
	signal wrtdata_in		: std_logic_vector(31 downto 0) := x"00000000";
	
	component controller is
		port (
			CLK		   : in  std_logic;
			WRITE			: in 	std_logic;
			ADDRESS		: in 	std_logic;
			WRITEDATA 	: in 	std_logic_vector(31 downto 0);
			IRQ			: out std_logic;
			OUT_WAVE		: out std_logic);
	end component controller;
	
begin
	
	clk_in <= not clk_in after 10 ns;	-- clock period of 20ns

	controller_instance : component controller
		port map (
			CLK => clk_in,
			WRITE => write_in,
			ADDRESS => addr_in,
			WRITEDATA => wrtdata_in,
			IRQ => irq_out,
			OUT_WAVE => wave_out
		);
		
end architecture lab4_tbArch;