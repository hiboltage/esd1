-----------------------------------------------------
-- file: low_pass_filter.vhd
-- author: steven bolt
-- date: 4/10/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity low_pass_filter is
	port(
		clk		 : in  std_logic;
		reset_n	 : in  std_logic;
		filter_en : in  std_logic;
		data_in 	 : in  std_logic_vector(15 downto 0);
		data_out	 : out std_logic_vector(15 downto 0));
end low_pass_filter;

architecture behavioral of low_pass_filter is

	-- build coefficient array
	constant type coeff_type is array(16 downto 0) of std_logic_vector(15 downto 0);
	signal S		: coeff_type;
	
begin
	
	S(0) <= x"";	-- 0.0025
	S(1) <= x"";	-- 0.0057
	S(2) <= x"";	-- 0.0147
	S(3) <= x"";