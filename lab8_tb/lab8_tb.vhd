-----------------------------------------------------
-- file: lab8_tb.vhd
-- author: steven bolt
-- date: 4/14/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity lab8_tb is
end lab8_tb;

architecture arch of lab8_tb is

	-- testbench signals
	signal clk_in	: std_logic := '0';
	signal reset	: std_logic := '0';
	signal flt_en	: std_logic := '1';
	signal dat_in	: std_logic_vector(15 downto 0) := (others => '0');
	signal dat_out	: std_logic_vector(15 downto 0);
	signal sim_done : boolean := false;
	
	-- audio sample array
	type sampleArray is array (39 downto 0) of signed(15 downto 0);
	signal audioSampleArray	: sampleArray := (others => x"0000");

	-- low pass filter
	component low_pass_filter is
		port(
			clk		: in  std_logic;
			reset_n	 	: in  std_logic;
			filter_en 	: in  std_logic;
			data_in 	: in  std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0));
	end component low_pass_filter;

	-- high pass filter
	component high_pass_filter is
		port(
			clk		: in  std_logic;
			reset_n	 	: in  std_logic;
			filter_en 	: in  std_logic;
			data_in 	: in  std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0));
	end component high_pass_filter;

begin

	stimulus : process is
		file read_file 		: text open read_mode is "./one_cycle_200_8k.csv";
		file results_file 	: text open write_mode is "./lpf_output_waveform_long.csv";
		variable lineIn 	: line;
		variable lineOut 	: line;
		variable readValue 	: integer;
		variable writeValue 	: integer;
	begin
		wait for 100 ns;
		reset <= '1';

		-- Read data from file into an array
		for i in 0 to 39 loop
			readline(read_file, lineIn);			 -- read line into lineIn
			read(lineIn, readValue);			 -- read int from lineIn into readValue
			audioSampleArray(i) <= to_signed(readValue, 16); -- store 16-bit signed value in array
			wait for 50 ns;
		end loop;

		file_close(read_file);

		wait for 10 ns;

		-- Apply the test data and put the result into an output file
		for i in 1 to 10 loop
			for j in 0 to 39 loop
				-- Your code here...
				-- Read the data from the array and apply it to Data_In (because array is signed, cast to std_logic_vector for filter input)
				dat_in <= std_logic_vector(audioSampleArray(j));

				-- Remember to provide an enable pulse with each new sample
				--flt_en <= '1';
				wait for 20 ns;
				--flt_en <= '0';
				wait for 20 ns;

				-- Write filter output to file
				writeValue := to_integer(unsigned(dat_out));	-- variable writeValue gets output converted to int (to_integer cant convert from std_logic_vector so a cast to signed is needed)
				write(lineOut, writeValue);			-- send int writeValue to line type lineOut
				writeline(results_file, lineOut);		-- write line to output file
				-- Your code here...
			end loop;
		end loop;

		file_close(results_file);

		-- end simulation
		sim_done <= true;

		wait for 100 ns;

		-- last wait statement needs to be here to prevent the process
		-- sequence from restarting at the beginning
		wait;
	end process stimulus;

	-- instantiate filter as uut
	uut : component low_pass_filter
		port map(
			clk		=> clk_in,
			reset_n	 	=> reset,
			filter_en 	=> flt_en,
			data_in 	=> dat_in,
			data_out	=> dat_out);

	clk_in <= not clk_in after 20 ns; -- 50 MHz clock (20 ns period)

end architecture arch;