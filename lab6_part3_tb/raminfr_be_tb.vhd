-----------------------------------------------------
-- file: raminfr_be_tb.vhd
-- author: steven bolt
-- date: 4/01/2025
-----------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity raminfr_be_tb is
end entity raminfr_be_tb;

architecture be_tb_arch of raminfr_be_tb is

	-- testbench signals
	signal clk_in	  : std_logic := '0';
	signal rst_in     : std_logic := '1';
	signal wrt_in	  : std_logic_vector(3 downto 0) := b"1100";
	signal addr_in    : std_logic_vector(11 downto 0) := x"000";
	signal wrtdata_in : std_logic_vector(31 downto 0) := x"12345678";
	signal rddata_out : std_logic_vector(31 downto 0);

	-- byte-enabled inferred ram component declaration
	component raminfr_be is
		port(
			clk			: in std_logic;
			reset_n			: in std_logic;
			writebyteenable_n	: in std_logic_vector(3 DOWNTO 0);
			address			: in std_logic_vector(11 DOWNTO 0);
			writedata		: in std_logic_vector(31 DOWNTO 0);
			readdata		: out std_logic_vector(31 DOWNTO 0));
	end component raminfr_be;

begin

	-- uut instantiation
	uut : component raminfr_be
		port map(
			clk => clk_in,
			reset_n => rst_in,
			writebyteenable_n => wrt_in,
			address => addr_in,
			writedata => wrtdata_in,
			readdata => rddata_out);

	clk_in <= not clk_in after 20 ns; -- 50 MHz clock (20 ns period)

end architecture be_tb_arch;