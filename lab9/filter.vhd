-----------------------------------------------------
-- file:    filter.vhd
-- author:  steven bolt
-- date:    4/17/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.filter_coefficients.all;

entity filter is
   port(
      clk       	: in  std_logic;
      reset_n   	: in  std_logic;
      filter_en  	: in  std_logic;
		filter_sel 	: in  std_logic;	-- 0 for lpf, 1 for hpf
		address		: in  std_logic;	-- 0 for data_in, 1 for switch
      data_in 		: in  std_logic_vector(15 downto 0);
      data_out		: out std_logic_vector(15 downto 0));
end filter;

architecture behavioral of filter is
   
   -- bus signals
   type bus_type is array(16 downto 0) of std_logic_vector(15 downto 0);
   signal bus_in  : bus_type := (others => (others => '0'));   -- top bus for register I/O and multiplier input
   
   type bus_add_type is array(16 downto 0) of std_logic_vector(31 downto 0);
   signal bus_add : bus_add_type := (others => (others => '0'));  -- bottom bus for adders
	
	signal coeffs : coeff_array := (others => (others => '0'));  -- coefficient bus for current filter coefficients
   
   -- coefficient selection component
	component coeff is
		port(
			reset_n		 : in  std_logic;
			filter_type  : in  std_logic;
			coefficients : out coeff_array);
	end component coeff;
	
   -- multiplier component
   component mult is
      port(
         dataa    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         datab    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
         result   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
   end component mult;
   
   -- register component
   component reg_en is
      port(
      clock          : in  std_logic;
      reset_n        : in  std_logic;
      filter_enable  : in  std_logic;
      filter_in      : in  std_logic_vector(15 downto 0);
      filter_out     : out std_logic_vector(15 downto 0));  
   end component reg_en;
   
begin
	
	bus_in(0) <= data_in;	-- send data_in to first register

   data_out <= bus_add(16)(30 downto 15) + bus_add(15)(30 downto 15) + bus_add(14)(30 downto 15) + bus_add(13)(30 downto 15) + 
					bus_add(12)(30 downto 15) + bus_add(11)(30 downto 15) + bus_add(10)(30 downto 15) + bus_add(9)(30 downto 15) + 
					bus_add(8)(30 downto 15) + bus_add(7)(30 downto 15) + bus_add(6)(30 downto 15) + bus_add(5)(30 downto 15) + 
					bus_add(4)(30 downto 15) + bus_add(3)(30 downto 15) + bus_add(2)(30 downto 15) + bus_add(1)(30 downto 15) + 
					bus_add(0)(30 downto 15);

---------------------------------------------------------------------------
------------- filter generation and routing -------------------------------
---------------------------------------------------------------------------

   -- generate 17 multipliers
   gen_mult:
   for n in 0 to 16 generate
      mult_n : mult port map (
         dataa  => bus_in(n),	 	-- input signal
         datab  => coeffs(n), 	-- multiply by coefficient
         result => bus_add(n) 	-- send mult result to add bus
      );
   end generate gen_mult;

   -- generate 16 registers
   gen_reg:
   for n in 0 to 15 generate
      reg_n : reg_en port map (
         clock          => clk,
         reset_n        => reset_n,
         filter_enable  => filter_en,     -- enable register shift
         filter_in      => bus_in(n),     -- input signal
         filter_out     => bus_in(n + 1)  -- output signal to multiplier/next reg
      );
   end generate gen_reg;
	
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

	-- coefficient selector component
	select_coeff : coeff
		port map(
			reset_n		 	=> reset_n,
			filter_type  	=> filter_sel,
			coefficients 	=> coeffs
		);
		

end architecture behavioral;