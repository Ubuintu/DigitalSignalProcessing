module MER_circuit(
	input clock_50,
	input [17:0]SW,
	input [3:0] KEY,
	output signed [17:0] srrc_out, srrc_input, err_acc,
	output signed [55:0] err_square,
	output [21:0] counter,
	output cycle, sys_clk, sam_clk_ena, sym_clk_ena
	);
	
	
//wire sys_clk, sam_clk, sam_clk_ena, sym_clk_ena, sym_clk, q1;
integer i,j;
					


wire [13:0] DAC_out;

 EE465_filter_test SRRC_test(
						   .clock_50(clock_50),
							.reset(~KEY[3]),
							.output_from_filter_1s17(srrc_out),
							.filter_input_scale(SW[2:0]),
							.input_to_filter_1s17(srrc_input),
							//.lfsr_value(),
							.symbol_clk_ena(sym_clk_ena),
							.sample_clk_ena(sam_clk_ena),
							.system_clk(sys_clk),
							.output_to_DAC(DAC_out)
							);
							
(* preserve *) reg [21:0] counterR;
(* preserve *) reg cycleR;

//Wait for DUT to be driven with 2^20 symbols
always @ (posedge sys_clk)
	if (~KEY[3] || counter > 22'd4194303)
		counterR<=22'd0;
	else if (sam_clk_ena)
		counterR <= counterR+22'd1;
	else
		counterR <= counterR;
		
always @ (posedge sys_clk)
	if (~KEY[3]) 
		cycleR <= 1'b0;
	else if (sam_clk_ena & counter >= 22'd4194303)
		cycleR<=1'b1;
	else
		cycleR<=1'b0;
		
assign cycle=cycleR;
assign counter=counterR;

endmodule 