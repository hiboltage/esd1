library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab3 is
  port (
    CLOCK_50   : in  std_logic;
	 KEY         : in  std_logic_vector(3 downto 0);
    SW    		 : in  std_logic_vector(7 downto 0);
	 HEX0        : out std_logic_vector(6 downto 0);
	 LEDR			 : out std_logic_vector(7 downto 0));
end entity lab3;

architecture lab3Arch of lab3 is

	-- signal declarations
	signal reset_n : std_logic;
	signal key0_d1 : std_logic;
	signal key0_d2 : std_logic;
	signal key0_d3 : std_logic;

	-- nios 2 component
	component nios_system is
		port (
			clk_clk            : in  std_logic                    := 'X';             -- clk
			hex0_export        : out std_logic_vector(6 downto 0);                    -- export
			leds_export        : out std_logic_vector(7 downto 0);                    -- export
			pushbuttons_export : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			reset_reset_n      : in  std_logic                    := 'X';             -- reset_n
			switches_export    : in  std_logic_vector(7 downto 0) := (others => 'X')  -- export
		);
	end component nios_system;
	
begin

	----- synchronize the reset
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
			clk_clk            => CLOCK_50,            --         clk.clk
			hex0_export        => HEX0,        --        hex0.export
			leds_export        => LEDR,        --        leds.export
			pushbuttons_export => KEY, -- pushbuttons.export
			reset_reset_n      => reset_n,      --       reset.reset_n
			switches_export    => SW     --    switches.export
		);
		
end architecture lab3Arch;