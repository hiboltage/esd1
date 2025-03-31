-- Lab 4 Top-Level
-- Created by Steven Bolt 2/18/2025

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab4 is
  port (
	CLK			: in  std_logic;
	RESET_N		: in 	std_logic;
	WRITE			: in 	std_logic;
	ADDRESS		: in 	std_logic;
	WRITEDATA 	: in 	std_logic_vector(31 downto 0);
	IRQ			: out std_logic;
	OUT_WAVE		: out std_logic);
end entity lab4;

architecture lab4Arch of lab4 is
	
	-- register signals
	signal min_count 		: unsigned(31 downto 0) := x"0000C350";	-- 50,000 counts
	signal max_count		: unsigned(31 downto 0) := x"000186A0";	-- 100,000 counts

	-- period counter signals
	signal period_count	: unsigned(31 downto 0) := x"00000000";	-- period counter
	signal period_stop	: unsigned(31 downto 0) := x"000F4240";	-- 1 million counts (20ns clock)
	
	-- angle counter signal
	signal angle_count 	: unsigned(31 downto 0) := x"0000C350";	-- angle counter (defaults to min_count because start state is SWEEP_RIGHT)

	-- state machine setup
	type sweep_states is (SWEEP_RIGHT, INT_RIGHT, SWEEP_LEFT, INT_LEFT);
	signal state : sweep_states		:= SWEEP_RIGHT;	-- initialize state machine to sweep right
	signal next_state : sweep_states := SWEEP_RIGHT;	-- initialize next state to sweep right
	
begin

	-- current state gets next state (clocked process)
	currentstate : process(CLK, RESET_N)
	begin	
		if RESET_N = '0' then
			state <= SWEEP_RIGHT;
	
		elsif rising_edge(CLK) then
			state <= next_state;
			
		end if;
		
	end process;
	
	-- determine next state (async process)
	nextstate : process(CLK)
	begin

		-- state machine logic
		case state is
			
			-- sweeping right
			when SWEEP_RIGHT =>
				if angle_count >= max_count then		-- check for end of sweep
					next_state <= INT_RIGHT;
				else
					next_state <= SWEEP_RIGHT;
				end if;
				
			-- right interrupt
			when INT_RIGHT =>
				if WRITE = '1' then
					next_state <= SWEEP_LEFT;
				else
					next_state <= INT_RIGHT;
				end if;
				
			-- sweeping left
			when SWEEP_LEFT =>
				if angle_count <= min_count then		-- check for end of sweep
					next_state <= INT_LEFT;
				else
					next_state <= SWEEP_LEFT;
				end if;
				
			-- left interrupt
			when INT_LEFT =>
				if WRITE = '1' then
					next_state <= SWEEP_RIGHT;
				else
					next_state <= INT_LEFT;
				end if;
				
			-- error if no known state
			when others =>
				report "Unknown state!";
					
		end case;
		
	end process;

	-- irq process
	interrupt : process(RESET_N, state) is
	begin
	
		if RESET_N = '0' then
			IRQ <= '0';

		elsif state = INT_RIGHT then		-- if right interrupt reached
			IRQ <= '1';						-- set irq flag
				
		elsif state = INT_LEFT then	-- if left interrupt reached
			IRQ <= '1';						-- set irq flag
			
		else
			IRQ <= '0';
				
		end if;

	end process;

	-- register process
	-- if write is high, check which address should be written to
	-- then write WRITEDATA to that address
	registers : process(CLK, RESET_N, WRITE) is
	begin
	
		-- reset to default min/max values
		if RESET_N = '0' then
			min_count <= x"0000C350";
			max_count <= x"000186A0";
			
		elsif rising_edge(CLK) then
		
			if WRITE = '1' then	-- if write enabled
			
				-- check which register address should be active and write data
				if ADDRESS = '0' then
					min_count <= unsigned(WRITEDATA);
					
				else
					max_count <= unsigned(WRITEDATA);
					
				end if;
				
			end if;
			
		end if;
		
	end process;
	
	-- period clock
	period : process(CLK, RESET_N) is
	begin
	
		-- reset count to zero
		if RESET_N = '0' then
			period_count <= x"00000000";
		
		-- every clock cycle count up until period_stop then reset
		elsif rising_edge(CLK) then
		
			if period_count >= period_stop then	-- reset counter at period_stop
				period_count <= x"00000000";
				
			else
				period_count <= period_count + x"2710";	-- increment period_count by 10,000
				
			end if;
			
		end if;
		
	end process;
	
	-- angle clock
	angle : process(CLK, RESET_N) is
	begin
	
		-- reset count to min_count
		if RESET_N = '0' then
			angle_count <= min_count;
	
		-- wait for period count to reset and then increase/decrease angle
		elsif rising_edge(CLK) then
		
			if period_count = x"00000000" then
		
				case state is
			
					when SWEEP_RIGHT =>
						if angle_count >= max_count then			-- if max angle reached
							angle_count <= max_count;				-- reset angle_count to max
						
						else
							angle_count <= angle_count + x"2710";	-- increase servo angle by 10,000
						
						end if;
				
					when SWEEP_LEFT =>
						if angle_count <= min_count then			-- if min angle reached
							angle_count <= min_count;				-- reset angle_count to minimum
					
						else
							angle_count <= angle_count - x"2710";	-- decrease servo angle by 10,000
						
						end if;
					
					when others =>							-- if not sweeping
						angle_count <= angle_count;	-- hold count at current value
					
				end case;
			
			-- if period_count hasn't been reset yet, hold angle
			else
				angle_count <= angle_count;
				
			end if;
		
		end if;
		
	end process;
	
	-- output waveform
	wave : process(CLK, RESET_N) is
	begin
		-- reset output wave
		if RESET_N = '0' then
			OUT_WAVE <= '0';
	
		elsif rising_edge(CLK) then
			
			-- if period_count is less than angle_count, then waveform is high
			if period_count < angle_count then
				OUT_WAVE <= '1';

			-- if period_count has reached angle_count, waveform goes low
			else
				OUT_WAVE <= '0';
				
			end if;
				
		end if;
		
	end process;
		
end architecture lab4Arch;