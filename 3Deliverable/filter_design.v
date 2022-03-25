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
integer i,j;
					

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

/* keep for combinational; preserve for registers; noprune for fan out*/
(* preserve *) reg [21:0] counter;
(* preserve *) reg cycle;
	
wire signed [17:0] err_acc;
//wire signed [17:0] err_square;	//for original err_Sqr circuit
wire signed [55:0] err_square;

//output of matched DS filter
(* keep *) wire signed [17:0] dec_var;

//Wait for DUT to be driven with 2^20 symbols
always @ (posedge sys_clk)
	if (~KEY[3] || counter > 22'd4194303)
		counter<=22'd0;
	else if (sam_clk_ena)
		counter <= counter+22'd1;
	else
		counter <= counter;
		
always @ (posedge sys_clk)
	if (~KEY[3]) 
		cycle <= 1'b0;
	else if (sam_clk_ena & counter >= 22'd4194303)
		cycle<=1'b1;
	else
		cycle<=1'b0;
	
//PPS_filt DUT_TX (
PPS_filt_101 DUT_TX (
//GSM_101Mults DUT_TX (	//debug MER circuit
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.x_in(srrc_input),
	.y(srrc_out)
	);

(* keep *) wire signed [17:0] MF_out;

//GSM
//GSM_noMult (
GSM_101Mults DUT_RCV (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.x_in(srrc_out),
	.y(MF_out)
);

//delay outputs for MUX @ sample clk. output of MF should come out w/e AND then needs to be sample by sam_clk & sym_clk sequentially
(* preserve *) reg signed [17:0] MDELAY [3:0]; 

always @ (posedge sys_clk)
	if (~KEY[3]) 
		MDELAY[0]<=18'sd0;
	else if (sam_clk_ena)
		MDELAY[0]<=MF_out;
	else
		MDELAY[0]<=$signed(MDELAY[0]);
	
		
always @ (posedge sys_clk)
	if (sam_clk_ena)
		for(i=1; i<4; i=i+1)
			MDELAY[i]<=$signed(MDELAY[i-1]);

//MUX for cor symbol
(* preserve *) reg signed [17:0] MUX_out;

always @ (posedge sys_clk)
	if (sym_clk_ena) begin
		case(SW[17:16])
			2'd1		:	MUX_out<=$signed(MDELAY[1]);
			2'd2		:	MUX_out<=$signed(MDELAY[2]);
			2'd3		:	MUX_out<=$signed(MDELAY[3]);
			default	:	MUX_out<=$signed(MF_out);	//MF_out is pipelined @ sam_clk
		endcase
	end
	
assign dec_var=$signed(MUX_out);
	
	
//SLICER
wire [1:0] slice;
slicer DECIDER (
//	.dec_var(dec_var),
	.dec_var(MUX_out),
	.ref_lvl(ref_lvl),
	.slice(slice)
);

//Mapper_out
wire signed [17:0] map_out_ref_lvl;
mapper_ref MAP_CMP (
	.map_out(map_out_ref_lvl),
	.slice(slice),
	.ref_lvl(ref_lvl)
);
//AVG_MAG
wire signed [17:0] ref_lvl, map_out_pwr;

avg_mag AVG_MAG_DV (
//	.dec_var(dec_var),
	.dec_var(MUX_out),
	.sym_clk_en(sym_clk_ena),
   .clr_acc(cycle),
	.clk(sys_clk),
	.reset(~KEY[3]),
	.ref_lvl(ref_lvl),
	.map_out_pwr(map_out_pwr)
);

//ERROR
(* preserve *) reg signed [17:0] error;

always @ (posedge sys_clk)
	if (~KEY[3]) error <= 18'sd0;
	else if (sym_clk_ena) error <= $signed(dec_var) - $signed(map_out_ref_lvl);
	else error <= error;
	
avg_err_squared_55 AVG_ER_SQR (
	.error(error),
	.sym_clk_en(sym_clk_ena),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(~KEY[3]),
	.err_square(err_square)
);

avg_err AVG_ER (
	.error(error),
	.sym_clk_en(sym_clk_ena),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(~KEY[3]),
	.err_acc(err_acc)
);


endmodule
