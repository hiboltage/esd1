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
		filter_enable	: in  std_logic;
		filter_in		: in  std_logic_vector(15 downto 0);
		filter_out		: out std_logic_vector(15 downto 0));	
end entity reg_en;

architecture behavioral of reg_en is

begin
	
	shift : process(filter_enable)
	begin
	
		if rising_edge(filter_enable) then
			filter_out <= filter_in;
		end if;
		
	end process;
	
end architecture behavioral;
		