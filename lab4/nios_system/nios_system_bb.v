
module nios_system (
	clk_clk,
	gpio_export_export,
	out_wave_export_out_wave,
	pb_export_export,
	reset_reset_n,
	sw_export_export);	

	input		clk_clk;
	output	[31:0]	gpio_export_export;
	output		out_wave_export_out_wave;
	input	[3:0]	pb_export_export;
	input		reset_reset_n;
	input	[9:0]	sw_export_export;
endmodule
