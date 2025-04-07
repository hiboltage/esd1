-----------------------------------------------------
-- file: lab6_part3.vhd
-- author: steven bolt
-- date: 4/01/2025
-----------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY lab6_part3 IS

  port (
    CLOCK_50	: in  std_logic;
	 KEY        : in  std_logic;
    LEDR       : out std_logic_vector(9 downto 0));
	
END ENTITY lab6_part3;

ARCHITECTURE part3_arch OF lab6_part3 IS

	-- nios 2 system component instantiation
	component nios_system is
		port (
			clk_clk     : in  std_logic                    := 'X'; -- clk
			key_export  : in  std_logic                    := 'X'; -- export
			leds_export : out std_logic_vector(9 downto 0)         -- export
		);
	end component nios_system;
	
BEGIN
	
	-- nios 2 component port map
	u0 : component nios_system
		port map (
			clk_clk     => CLOCK_50,     --  clk.clk
			key_export  => KEY,  --  key.export
			leds_export => LEDR(9 downto 0)  -- leds.export
		);
	
END ARCHITECTURE part3_arch;