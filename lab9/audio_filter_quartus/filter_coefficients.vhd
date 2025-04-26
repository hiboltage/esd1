-----------------------------------------------------
-- file:    filter_coefficients.vhd
-- author: 	steven bolt
-- date:    4/17/2025
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- package for filter coefficient array type
package filter_coefficients is
	type coeff_array is array(16 downto 0) of std_logic_vector(15 downto 0);
end package;

package body filter_coefficients is
end package body;