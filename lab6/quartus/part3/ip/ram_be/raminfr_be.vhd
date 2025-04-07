-----------------------------------------------------
-- file: raminfr_be.vhd
-- author: steven bolt
-- date: 4/01/2025
-----------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY raminfr_be IS
	PORT(
		clk					: IN std_logic;
		reset_n				: IN std_logic;
		writebyteenable_n	: IN std_logic_vector(3 DOWNTO 0);	-- RAM lanes | each lane is a byte, so to write 32-bit data, need to call writebyteenable_n(3:0)
		address				: IN std_logic_vector(11 DOWNTO 0);
		writedata			: IN std_logic_vector(31 DOWNTO 0);
		readdata				: OUT std_logic_vector(31 DOWNTO 0)
	);
END ENTITY raminfr_be;

ARCHITECTURE rtl OF raminfr_be IS

	-- these are the 4 independent 4Kx8 RAM channels (4k is 4096 bits)
	type ram_channel_type IS array(4095 DOWNTO 0) OF std_logic_vector(7 DOWNTO 0);
	signal RAM_0		: ram_channel_type;
	signal RAM_1		: ram_channel_type;
	signal RAM_2		: ram_channel_type;
	signal RAM_3		: ram_channel_type;
	
	-- this is the final 32-bit write
	type ram_type is array(4095 downto 0) of std_logic_vector(32 downto 0);
	signal RAM			: ram_type;
	
	-- this is the 
	signal read_addr	: std_logic_vector(11 DOWNTO 0);
	
BEGIN

	-- we have declared 4 independent 4Kx8 RAM arrays, the 32-bit array should be assembled as such
	
	-- 			RAM_3 | RAM_2 | RAM_1 | RAM_0
	
	-- and then written to the memory location as a 32-bit word
	
	-- split the 32-bit writedata input into 4 and then reassemble ?
	
	-- for efficiency's sake, probably not the best idea to rewrite the entire address every time,
	-- so we probably only want to write if a channel is enabled
	-- however, this creates an issue with having more frequent smaller writes to memory
	
	-- i'm probably just gonna rewrite the entire address
	
	-- now this creates a problem with overwriting existing data in byte locations that were not enabled
	
	-- to fix this i'd need to bitmask this somehow, like i can't just write zeros to bytes that weren't enabled
	
	RamBlock : process(clk)
	begin
	
		if rising_edge(clk) then
			if (reset_n = '0') then				-- if reset triggered
				read_addr <= (others => '0');	-- reset read address	
				
			elsif (writebyteenable_n(0) = '0') then						-- if write to ram_0 triggered
				RAM(conv_integer(address)) <= writedata(7 downto 0);	-- write last 8 bytes of data to ram address
				
			elsif (writebyteenable_n(1) = '0') then										-- if write to ram_1 triggered
				RAM(conv_integer(address + x"0001")) <= writedata(15 downto 8);	-- write next 8 bytes of data to ram address offset by 1 byte
				
			elsif (writebyteenable_n(2) = '0') then										-- if write to ram_2 triggered
				RAM(conv_integer(address + x"0002")) <= writedata(23 downto 16);	-- write next 8 bytes of data to ram address offset by 2 bytes
				
			elsif (writebyteenable_n(3) = '0') then										-- if write to ram_3 triggered
				RAM(conv_integer(address + x"0003")) <= writedata(31 downto 24);	-- write first 8 bytes of data to ram address offset by 3 bytes
		
			end if;
			
			read_addr <= address;	-- get read address
		end if;
		
	end process RamBlock;
	
	readdata <= RAM(conv_integer(read_addr));		-- write data out

END ARCHITECTURE rtl;