-----------------------------------------------------
-- file: lab9_tb.vhd
-- author: steven bolt
-- date: 4/17/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity lab9_tb is
end lab9_tb;

architecture arch of lab9_tb is

	-- testbench signals
	signal clk_in	: std_logic := '0';
	signal reset	: std_logic := '1';
	signal write_in : std_logic := '1';
	signal addr_in	: std_logic := '1';
	signal dat_in	: std_logic_vector(15 downto 0) := x"0001";	-- initialize as x"0000" for lpf and x"0001" for hpf
	signal dat_out	: std_logic_vector(15 downto 0);
	signal sim_done : boolean := false;
	
	-- audio sample array
	type sampleArray is array (39 downto 0) of signed(15 downto 0);
	signal audioSampleArray	: sampleArray := (others => x"0000");

	component audio_filter is
	port(
		clk		: in  std_logic;
		reset_n		: in  std_logic;
		write		: in  std_logic;
		address		: in  std_logic;
		writedata	: in  std_logic_vector(15 downto 0);
		readdata	: out std_logic_vector(15 downto 0));
	end component audio_filter;

begin

	stimulus : process is
		file read_file 		: text open read_mode is "./one_cycle_200_8k.csv";
		file results_file 	: text open write_mode is "./hpf_output_waveform.csv";
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

		addr_in <= '0';	-- switch to writing to data_in register

		-- Apply the test data and put the result into an output file
		--for i in 1 to 10 loop
			for j in 0 to 39 loop
				-- Your code here...
				-- Read the data from the array and apply it to Data_In (because array is signed, cast to std_logic_vector for filter input)
				dat_in <= std_logic_vector(audioSampleArray(j));
				-- Remember to provide an enable pulse with each new sample

				-- give filter time to process
				wait for 40 ns;

				-- Write filter output to file
				writeValue := to_integer(signed(dat_out));	-- variable writeValue gets output converted to int (to_integer cant convert from std_logic_vector so a cast to signed is needed)
				write(lineOut, writeValue);			-- send int writeValue to line type lineOut
				writeline(results_file, lineOut);		-- write line to output file
				-- Your code here...
			end loop;
		--end loop;

		file_close(results_file);

		-- end simulation
		sim_done <= true;

		wait for 100 ns;

		-- last wait statement needs to be here to prevent the process
		-- sequence from restarting at the beginning
		wait;
	end process stimulus;

	-- instantiate filter as uut
	uut : component audio_filter
		port map(
		clk	  => clk_in,
		reset_n	  => reset,
		write	  => write_in,
		address	  => addr_in,
		writedata => dat_in,
		readdata  => dat_out);

	clk_in <= not clk_in after 20 ns; -- 50 MHz clock (20 ns period)

end architecture arch;
