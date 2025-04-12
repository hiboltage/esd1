-----------------------------------------------------
-- file: lab6_part5.vhd
-- author: steven bolt
-- date: 4/11/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lab6_part5 is

  port (
    CLOCK_50	: in  std_logic;
	 KEY        : in  std_logic_vector(3 downto 0);
    LEDR       : out std_logic_vector(7 downto 0));
	
end entity lab6_part5;

architecture part5_arch of lab6_part5 is

	-- nios 2 system component instantiation
	component nios_system is
		port (
			clk_clk     : in  std_logic                    := 'X'; -- clk
			key1_export : in  std_logic                    := 'X'; -- export
			leds_export : out std_logic_vector(7 downto 0)         -- export
		);
	end component nios_system;
	
begin
	
	-- nios 2 component port map
	u0 : component nios_system
		port map (
			clk_clk     => CLOCK_50,     --  clk.clk
			key1_export => KEY(1), -- key1.export
			leds_export => LEDR  -- leds.export
		);


end architecture part5_arch;