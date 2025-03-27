-----------------------------------------------------
-- file: lab6_part1.vhd
-- author: steven bolt
-- date: 3/25/2025
-----------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY lab6_part1 IS

  port (
    CLOCK_50	: in  std_logic;
	 KEY        : in  std_logic;
    LEDS       : out std_logic_vector(7 downto 0));
	
END ENTITY lab6_part1;

ARCHITECTURE part1_arch OF lab6_part1 IS

	-- nios 2 system component instantiation
	component nios_system is
		port (
			clk_clk            : in  std_logic                    := 'X'; -- clk
			key1_export_export : in  std_logic                    := 'X'; -- export
			leds_export_export : out std_logic_vector(7 downto 0)         -- export
		);
	end component nios_system;
	
BEGIN
	
	-- nios 2 component port map
	u0 : component nios_system
		port map (
			clk_clk            => CLOCK_50,	--         clk.clk
			key1_export_export => KEY, 		-- key1_export.export
			leds_export_export => LEDS  		-- leds_export.export
		);
	
END ARCHITECTURE part1_arch;