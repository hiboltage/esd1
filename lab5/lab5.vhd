-- Lab 5 Top-Level
-- Created by Steven Bolt 4/9/2025

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab5 is

	port (
		CLOCK_50		: in  std_logic;								-- board clock
		SW				: in  std_logic_vector(7 downto 0);		-- switches
		KEY			: in  std_logic_vector(3 downto 0);		-- pushbuttons
		HEX0			: out std_logic_vector(6 downto 0);		-- hex displays
		HEX1			: out std_logic_vector(6 downto 0);
		HEX2			: out std_logic_vector(6 downto 0);
		HEX3			: out std_logic_vector(6 downto 0);
		HEX4			: out std_logic_vector(6 downto 0);
		HEX5			: out std_logic_vector(6 downto 0);
		GPIO_0		: out std_logic_vector(35 downto 0));	-- gpio_0 pins
		
end entity lab5;

architecture lab5_arch of lab5 is

	component nios_system is
		port (
			clk_clk                       : in  std_logic                    := 'X';             -- clk
			hex0_export                   : out std_logic_vector(6 downto 0);                    -- export
			hex1_export                   : out std_logic_vector(6 downto 0);                    -- export
			hex2_export                   : out std_logic_vector(6 downto 0);                    -- export
			hex3_export                   : out std_logic_vector(6 downto 0);                    -- export
			hex4_export                   : out std_logic_vector(6 downto 0);                    -- export
			hex5_export                   : out std_logic_vector(6 downto 0);                    -- export
			pushbuttons_export            : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			reset_reset_n                 : in  std_logic                    := 'X';             -- reset_n
			switches_export               : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
			out_wave_writeresponsevalid_n : out std_logic                                        -- writeresponsevalid_n
		);
	end component nios_system;
		
	-- pushbutton signal declarations
	signal reset_n : std_logic;
	signal key0_d1 : std_logic;
	signal key0_d2 : std_logic;
	signal key0_d3 : std_logic;
	
begin

	-- synchronize the reset
	synchReset_proc : process (CLOCK_50) begin
	 if (rising_edge(CLOCK_50)) then
		key0_d1 <= KEY(0);
		key0_d2 <= key0_d1;
		key0_d3 <= key0_d2;
	 end if;
	end process synchReset_proc;
	reset_n <= key0_d3;
	
	-- nios system port map
	u0 : component nios_system
	port map (
		clk_clk                       => CLOCK_50,               --         clk.clk
		hex0_export                   => HEX0,                   --        hex0.export
		hex1_export                   => HEX1,                   --        hex1.export
		hex2_export                   => HEX2,                   --        hex2.export
		hex3_export                   => HEX3,                   --        hex3.export
		hex4_export                   => HEX4,                   --        hex4.export
		hex5_export                   => HEX5,                   --        hex5.export
		pushbuttons_export            => KEY,            			-- pushbuttons.export
		reset_reset_n                 => reset_n,                --       reset.reset_n
		switches_export               => SW,               		--    switches.export
		out_wave_writeresponsevalid_n => GPIO_0(2)  --    out_wave.writeresponsevalid_n
	);

end architecture lab5_arch;