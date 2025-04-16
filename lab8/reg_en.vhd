-----------------------------------------------------
-- file: reg_en.vhd
-- author: steven bolt
-- date: 4/11/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- this is a pipelining register to delay a value by a single clock cycle
entity reg_en is
	port(
		clock				: in  std_logic;
		reset_n			: in  std_logic;
		filter_enable	: in  std_logic;
		filter_in		: in  std_logic_vector(15 downto 0);
		filter_out		: out std_logic_vector(15 downto 0));	
end entity reg_en;

architecture behavioral of reg_en is

begin
	
	shift : process(clock, reset_n)
	begin
	
		if (reset_n = '0') then
			filter_out <= (others => '0');
	
		elsif rising_edge(clock) then
		
			if (filter_enable = '1') then		-- on clock if filter enabled, move data
				filter_out <= filter_in;
			end if;
			
		end if;
		
	end process;
	
end architecture behavioral;
		