-----------------------------------------------------
-- file:    audio_filter.vhd
-- author:  steven bolt
-- date:    4/17/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity audio_filter is
	port(
		clk			: in  std_logic;
		reset_n		: in  std_logic;
		write			: in  std_logic;
		address		: in  std_logic;
		writedata	: in  std_logic_vector(15 downto 0);
		readdata		: out std_logic_vector(15 downto 0));
end entity audio_filter;

architecture filter_arch of audio_filter is

	-- register signals
	signal reg_data   : std_logic_vector(15 downto 0);
	signal reg_switch : std_logic;

	-- modified lab 8 filter component
	component filter is
		port(
			clk        : in  std_logic;
			reset_n    : in  std_logic;
			filter_en  : in  std_logic;
			filter_sel : in  std_logic;
			data_in    : in  std_logic_vector(15 downto 0);
			data_out   : out std_logic_vector(15 downto 0));
	end component;

begin

	-- register process
	-- address determines which location should be written to
	
	-- 0 writes to the modified filter's data_in port
	-- 1 writes to the modified filter's filter_sel port
	
	-- filter_sel is used to select which set of coefficients should be used (low-pass or high-pass)
	registers : process(clk, reset_n, write)
	begin
		if (reset_n = '0') then			-- reset reg_data and switch registers
			reg_data <= (others => '0');
			reg_switch <= '0';
		
		elsif (address = '0') then		-- if address 0, write to reg_data register
			reg_data <= writedata;
			
		elsif (address = '1') then		-- if address 1, write to reg_switch register
			reg_switch <= writedata(0);
			
		end if;
	end process registers;

	-- link to filter component
	f1 : filter
		port map(
			clk        => clk,
			reset_n    => reset_n,
			filter_en  => write,
			filter_sel => reg_switch,
			data_in    => reg_data,
			data_out   => readdata
		);

end architecture filter_arch;