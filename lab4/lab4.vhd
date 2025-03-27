-- Lab 4 Top-Level
-- Created by Steven Bolt 2/18/2025

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lab4 is
  port (
	CLK			: in  std_logic;
	KEY			: in 	std_logic;
	WRITE			: in 	std_logic;
	ADDRESS		: in 	std_logic;
	WRITEDATA 	: in 	std_logic_vector(31 downto 0);
	IRQ			: out std_logic;
	OUT_WAVE		: out std_logic);
end entity lab4;

architecture lab4Arch of lab4 is

	-- nios 2 component
	entity nios_system is
		port (
			clk_clk                  : in  std_logic                     := '0';             --             clk.clk
			gpio_export_export       : out std_logic_vector(31 downto 0);                    --     gpio_export.export
			out_wave_export_out_wave : out std_logic;                                        -- out_wave_export.out_wave
			pb_export_export         : in  std_logic_vector(3 downto 0)  := (others => '0'); --       pb_export.export
			reset_reset_n            : in  std_logic                     := '0';             --           reset.reset_n
			sw_export_export         : in  std_logic_vector(9 downto 0)  := (others => '0')  --       sw_export.export
		);
	end entity nios_system;
	
	-- reset signals
	signal reset_n : std_logic;
	signal key0_d1 : std_logic;
	signal key0_d2 : std_logic;
	signal key0_d3 : std_logic;
	
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

	----- synchronize the reset
	synchReset_proc : process (CLOCK_50) begin
	 if (rising_edge(CLOCK_50)) then
		key0_d1 <= KEY(0);
		key0_d2 <= key0_d1;
		key0_d3 <= key0_d2;
	 end if;
	end process synchReset_proc;
	reset_n <= key0_d3;

	-- current state gets next state (clocked process)
	currentstate : process(CLK, reset_n)
	begin	
		if reset_n = '0' then
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
	interrupt : process(reset_n, state) is
	begin
	
		if reset_n = '0' then
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
	registers : process(CLK, reset_n, WRITE) is
	begin
	
		-- reset to default min/max values
		if reset_n = '0' then
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
	period : process(CLK, reset_n) is
	begin
	
		-- reset count to zero
		if reset_n = '0' then
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
	angle : process(CLK, reset_n) is
	begin
	
		-- reset count to min_count
		if reset_n = '0' then
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
	wave : process(CLK, reset_n) is
	begin
		-- reset output wave
		if reset_n = '0' then
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
	
	-- nios 2 component
	servo_controller_inst_0 : component nios_system
		port map (
			clk             => CLOCK_50,  	--            clock.clk
			reset_n         => reset_n,   	--            reset.reset_n
			write           => WRITE,      	--   avalon_slave_0.write
			address         => ADDRESS(0), 	--                 .address
			writedata       => WRITEDATA,  	--                 .writedata
			out_wave_export => OUT_WAVE, 		--      conduit_end.out_wave
			irq             => IRQ				-- interrupt_sender.irq
		);
		
end architecture lab4Arch;