
module nios_system (
	clk_clk,
	hex0_export,
	leds_export,
	reset_reset_n,
	switches_export,
	pushbuttons_export);	

	input		clk_clk;
	output	[6:0]	hex0_export;
	output	[7:0]	leds_export;
	input		reset_reset_n;
	input	[7:0]	switches_export;
	input	[3:0]	pushbuttons_export;
endmodule
