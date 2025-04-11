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
	signal RAM_0		: ram_channel_type	:= (others => (others => '0'));
	signal RAM_1		: ram_channel_type	:= (others => (others => '0'));
	signal RAM_2		: ram_channel_type	:= (others => (others => '0'));
	signal RAM_3		: ram_channel_type	:= (others => (others => '0'));
	
	-- this is the address to write at
	signal read_addr	: std_logic_vector(11 DOWNTO 0);
	
BEGIN

	-- we have declared 4 independent 4Kx8 RAM arrays, the 32-bit array should be assembled as such
	
	-- 			RAM_3 | RAM_2 | RAM_1 | RAM_0
	
	RamBlock : process(clk)
	begin
	
		if rising_edge(clk) then
			if (reset_n = '0') then				-- if reset triggered
				read_addr <= (others => '0');	-- reset read address
			end if;
				
			if (writebyteenable_n(0) = '0') then											-- if write to ram_0 triggered
				RAM_0(conv_integer(address + x"000")) <= writedata(7 downto 0);	-- write last 8 bytes of data to ram address (conv_integer to index into array)
			end if;
				
			if (writebyteenable_n(1) = '0') then											-- if write to ram_1 triggered
				RAM_1(conv_integer(address + x"001")) <= writedata(15 downto 8);	-- write next 8 bytes of data to ram address offset by 1 byte
			end if;
				
			if (writebyteenable_n(2) = '0') then											-- if write to ram_2 triggered
				RAM_2(conv_integer(address + x"002")) <= writedata(23 downto 16);	-- write next 8 bytes of data to ram address offset by 2 bytes
			end if;
				
			if (writebyteenable_n(3) = '0') then											-- if write to ram_3 triggered
				RAM_3(conv_integer(address + x"003")) <= writedata(31 downto 24);	-- write first 8 bytes of data to ram address offset by 3 bytes
			end if;
			
			read_addr <= address;	-- get read address
		end if;
		
	end process RamBlock;
	
	readdata <= RAM_3(conv_integer(read_addr + x"003")) & RAM_2(conv_integer(read_addr + x"002")) & RAM_1(conv_integer(read_addr + x"001")) & RAM_0(conv_integer(read_addr));	-- write ram block

END ARCHITECTURE rtl;