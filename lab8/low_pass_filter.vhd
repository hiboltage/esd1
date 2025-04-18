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

	-- coefficient array
	type coeff_type is array(16 downto 0) of std_logic_vector(15 downto 0);
	signal S			: coeff_type;
	
	-- bus signals
	type bus_type is array(16 downto 0) of std_logic_vector(15 downto 0);
	signal bus_in	: bus_type := (others => (others => '0'));	-- top bus for register I/O and multiplier input
	
	type bus_add_type is array(16 downto 0) of std_logic_vector(31 downto 0);
	signal bus_add	: bus_add_type := (others => (others => '0'));	-- bottom bus for adders
	
	
	-- multiplier component
	component mult is
		port(
			dataa		: IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
			datab		: IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	end component mult;
	
	-- register component
	component reg_en is
		port(
		clock				: in  std_logic;
		reset_n			: in  std_logic;
		filter_enable	: in  std_logic;
		filter_in		: in  std_logic_vector(15 downto 0);
		filter_out		: out std_logic_vector(15 downto 0));	
	end component reg_en;
	
begin
	
	-- build coefficient array (MAKE CONSTANTS ??)
	S(0)  <= x"0051";	-- 0.0025
	S(1)  <= x"00BA";	-- 0.0057
	S(2)  <= x"01E1";	-- 0.0147
	S(3)  <= x"0408";	-- 0.0315
	S(4)  <= x"071A"; -- 0.0555
	S(5)  <= x"0AAC"; -- 0.0834
	S(6)  <= x"0E11"; -- 0.1099
	S(7)  <= x"107F"; -- 0.1289
	S(8)  <= x"1161"; -- 0.1358
	S(9)  <= x"107F"; -- 0.1289
	S(10) <= x"0E11"; -- 0.1099
	S(11) <= x"0AAC"; -- 0.0834
	S(12) <= x"071A"; -- 0.0555
	S(13) <= x"0408"; -- 0.0315
	S(14) <= x"01E1"; -- 0.0147
	S(15) <= x"00BA"; -- 0.0057
	S(16) <= x"0051"; -- 0.0025
	
	-- generate 17 multipliers
	gen_mult:
	for n in 0 to 16 generate
		mult_n : mult port map (
			dataa	 => bus_in(n),	-- input signal
			datab	 => S(n),		-- multiply by coefficient
			result => bus_add(n)	-- send mult result to add bus
		);
	end generate gen_mult;

	-- generate 16 registers
	gen_reg:
	for n in 0 to 15 generate
		reg_n : reg_en port map (
			clock 			=> clk,
			reset_n			=> reset_n,
			filter_enable	=> filter_en,		-- enable register shift
			filter_in		=> bus_in(n),		-- input signal
			filter_out		=> bus_in(n + 1)	-- output signal to multiplier/next reg
		);
	end generate gen_reg;
	
	bus_in(0) <= data_in;

	data_out <= bus_add(16)(30 downto 15) + bus_add(15)(30 downto 15) + bus_add(14)(30 downto 15) + bus_add(13)(30 downto 15) + bus_add(12)(30 downto 15) + bus_add(11)(30 downto 15) + bus_add(10)(30 downto 15) + bus_add(9)(30 downto 15) + bus_add(8)(30 downto 15) + bus_add(7)(30 downto 15) + bus_add(6)(30 downto 15) + bus_add(5)(30 downto 15) + bus_add(4)(30 downto 15) + bus_add(3)(30 downto 15) + bus_add(2)(30 downto 15) + bus_add(1)(30 downto 15) + bus_add(0)(30 downto 15);

end architecture behavioral;