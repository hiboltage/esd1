-----------------------------------------------------
-- file: raminfr.vhd
-- author: steven bolt
-- date: 3/25/2025
-----------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY raminfr IS
	PORT(
		clk			: IN std_logic;
		reset_n		: IN std_logic;
		write_n		: IN std_logic;
		address		: IN std_logic_vector(11 DOWNTO 0);
		writedata	: IN std_logic_vector(31 DOWNTO 0);
		readdata		: OUT std_logic_vector(31 DOWNTO 0)
	);
END ENTITY raminfr;

ARCHITECTURE rtl OF raminfr IS

	type ram_type IS array(4095 DOWNTO 0) OF std_logic_vector(31 DOWNTO 0);
	signal RAM			: ram_type;
	signal read_addr	: std_logic_vector(11 DOWNTO 0);
	
BEGIN
	
	RamBlock : process(clk)
	begin
	
		if rising_edge(clk) then
			if (reset_n = '0') then				-- if reset triggered
				read_addr <= (others => '0');	-- reset read address	
				
			elsif (write_n = '0') then							-- if write triggered
				RAM(conv_integer(address)) <= writedata;	-- write data to ram address
		
			end if;
			
			read_addr <= address;
		end if;
		
	end process RamBlock;
	
	readdata <= RAM(conv_integer(read_addr));

END ARCHITECTURE rtl;
		
		