module filter_design(
						   input clock_50,
							input [17:0]SW,
							input [3:0] KEY,
							input [13:0]ADC_DA,
						   input [13:0]ADC_DB,
							output reg [3:0] LEDG,
							output reg [17:0] LEDR,
							output reg[13:0]DAC_DA,
							output reg [13:0]DAC_DB,
							output	ADC_CLK_A,
							output	ADC_CLK_B,
							output	ADC_OEB_A,
							output	ADC_OEB_B,
							output	DAC_CLK_A,
							output	DAC_CLK_B,
							output	DAC_MODE,
							output	DAC_WRT_A,
							output	DAC_WRT_B
							);
			  


//**************************************************				
//					DECLARATIONS					
					
		(* keep *) wire signed [13:0]	sin_out;

					
		reg [4:0] NCO_freq;	// unsigned fraction with units cycles/sample	
					
										
	   (* noprune *)reg [13:0] registered_ADC_A;
		(* noprune *)reg [13:0] registered_ADC_B;
					

									
	//*****************************
	//			Set up switches and LEDs
	
					always @ *
					LEDR = SW;
					always @ *
					LEDG = KEY;
					
	// end setting up switches and LEDs
	// ***************************
							
	//************************
	//				  Set up DACs
					
					assign DAC_CLK_A = sys_clk;
					assign DAC_CLK_B = sys_clk;
					
					
					assign DAC_MODE = 1'b1; //treat DACs seperately
					
					assign DAC_WRT_A = ~sys_clk;
					assign DAC_WRT_B = ~sys_clk;
					
					always@ (posedge sys_clk)// make DAC A echo ADC A
					DAC_DA = registered_ADC_A[13:0];
						
						
		always@ (posedge sys_clk) 
		 /* connect the output multiplexer,  which is called
		    output_mux, to the regisgter (i.e. D-flip flops)
			 that drive the pins for DAC B. 
		    In the process convert the signed output of
			 the NCO to an unsigned number, which is required
			 by DAC B, by inverting the sign bit. */
							
			DAC_DB = DAC_out;
//  End DAC setup
//************************	
					
// ************************
//		 Setup ADCs
					
					assign ADC_CLK_A = sys_clk;
					assign ADC_CLK_B = sys_clk;
					
					assign ADC_OEB_A = 1'b1;
					assign ADC_OEB_B = 1'b1;

					
					always@ (posedge sys_clk)
						registered_ADC_A <= ADC_DA;
						
					always@ (posedge sys_clk)
						registered_ADC_B <= ADC_DB;
						

wire sys_clk, sam_clk, sam_clk_ena, sym_clk_ena, sym_clk, q1;
					

wire signed [17:0]srrc_out, srrc_input;
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
			  
//ee465_gold_standard_srrc filly(
//			.sys_clk(sys_clk), //system clock, your design may not use this
//			.sam_clk(sam_clk_ena), //sampling clock
//			.sig_in(srrc_input), //4-ASK input value 1s17
//			.sig_out(srrc_out) //output of SRRC filter 1s17
//			);

PPS_filt_BAD DUT (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.x_in(srrc_input),
	.y(srrc_out)
	);
	


endmodule
