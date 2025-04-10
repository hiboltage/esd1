-- TimeQuest demo top-level
-- Created by Steven Bolt 4/9/2025

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity timequest_demo is

	port (
		clock		: in  std_logic;
		A			: in  std_logic_vector(15 downto 0);
		B			: in  std_logic_vector(15 downto 0);
		Result	: out std_logic_vector(15 downto 0));
		
end entity timequest_demo;

architecture behavioral of timequest_demo is

	signal q1 : unsigned(15 downto 0);
	signal q2 : unsigned(15 downto 0);
	signal q3 : unsigned(15 downto 0);

begin

	flipflops : process(clock)
	begin
	
		if rising_edge(clock) then
			q1 <= unsigned(A);
			q2 <= unsigned(B);
			Result <= std_logic_vector(q3);
		end if;
		
	end process;
	
	addition : process(q1, q2)
	begin
		q3 <= q1 + q2;
	end process;

end architecture behavioral;