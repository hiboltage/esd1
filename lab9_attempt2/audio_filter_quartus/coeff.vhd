-----------------------------------------------------
-- file:    coeff.vhd
-- author:  steven bolt
-- date:    4/17/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.filter_coefficients.all;

entity coeff is
   port(
		reset_n		 : in  std_logic;
		filter_type  : in  std_logic;
		coefficients : out coeff_array);
end entity coeff;

architecture behavioral of coeff is

   -- coefficient arrays
   constant lpf_coeff : coeff_array := (
		x"0051", x"00BA", x"01E1", x"0408",
      x"071A", x"0AAC", x"0E11", x"107F",
		x"1161", x"107F", x"0E11", x"0AAC",
		x"071A", x"0408", x"01E1", x"00BA", 
		x"0051"
	);
                                             
   constant hpf_coeff : coeff_array := (
		x"003E", x"FF9B", x"FE9F", x"0000",
		x"0535", x"05B2", x"F5AC", x"DAB7",
      x"4C91", x"DAB7", x"F5AC", x"05D2",
      x"0535", x"0000", x"FE9F", x"FF9B",
      x"003E"
	);

begin

	-- mux for selecting filter type
	mux : process(filter_type, reset_n)
	begin
	
		if (reset_n = '0') then				-- reset output
			coefficients <= (others => (others => '0'));
			
		elsif (filter_type = '0') then	-- low pass filter selected
			coefficients <= lpf_coeff;
			
		elsif (filter_type ='1') then	-- high pass filter selected
			coefficients <= hpf_coeff;
			
		end if;
	
	end process;

end architecture behavioral;