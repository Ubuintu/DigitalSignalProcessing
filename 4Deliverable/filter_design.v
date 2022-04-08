module filter_design #(
	parameter DELAY=5
)
(
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
						

wire sys_clk, sam_clk, sam_clk_ena, sym_clk_ena, sym_clk, q1, sys_clk2_en;
integer i,j;
					

wire signed [17:0] srrc_out, srrc_outQ;
//wire signed [17:0] srrc_input;
reg [13:0] DAC_out;

////Try Rory's LFSR
// EE465_filter_test SRRC_test(
//						   .clock_50(clock_50),
//							.reset(~KEY[3]),
////							.output_from_filter_1s17(srrc_out),
////							.filter_input_scale(SW[2:0]),
////							.input_to_filter_1s17(srrc_input),
//							.lfsr_value(),
//							.symbol_clk_ena(sym_clk_ena),
//							.sample_clk_ena(sam_clk_ena),
//							.system_clk(sys_clk),
////							.output_to_DAC(DAC_out)
//							);

						
clk_en EN_clk (
	.clk(clock_50),
	.reset(~KEY[3]),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.sym_clk_en(sym_clk_ena),
	.sys_clk2_en(sys_clk2_en)
	);
			  
//ee465_gold_standard_srrc filly(
//			.sys_clk(sys_clk), //system clock, your design may not use this
//			.sam_clk(sam_clk_ena), //sampling clock
//			.sig_in(srrc_input), //4-ASK input value 1s17
//			.sig_out(srrc_out) //output of SRRC filter 1s17
//			);

/* keep for combinational; preserve for registers; noprune for fan out*/
(* preserve *) reg [21:0] counter;
	
wire signed [17:0] err_acc;
//wire signed [17:0] err_square;	//for original err_Sqr circuit
wire signed [55:0] err_square;

//output of matched DS filter
(* keep *) wire signed [17:0] dec_var;
(* keep *) wire signed [21:0] out;
(* keep *) wire signed [22:0] outQ;
(* preserve *) wire cycle;

/*------------LFSR------------*/
(* keep *) reg load;

always @ *
	if (!KEY[1]) load = 1'b1;
	else load = 1'b0;
	
	
LFSR_22 LFSR_GEN (
    .sys_clk(sys_clk), 
	 .reset(~KEY[3]), 
	 .load(load), 
	 .sam_clk_en(sam_clk_ena),
    .cycle(cycle),
    .out(out)
);

//Try Rory's LFSR
// EE465_filter_test SRRC_test(
//						   .clock_50(clock_50),
//							.reset(~KEY[3]),
////							.output_from_filter_1s17(srrc_out),
////							.filter_input_scale(SW[2:0]),
////							.input_to_filter_1s17(srrc_input),
//							.lfsr_value(out[1:0])
//							//,
////							.symbol_clk_ena(sym_clk_ena),
////							.sample_clk_ena(sam_clk_ena),
////							.system_clk(sys_clk),
////							.output_to_DAC(DAC_out)
//							);

//LFSR test (
//	.clk(sys_clk),
//	.load_data(load),
//	.q(outQ[13:0])
//	);
	
LFSR_23 LFSR_GENQ (
    .sys_clk(sys_clk), 
	 .reset(~KEY[3]), 
	 .load(load), 
	 .sam_clk_en(sam_clk_ena),
    .cycle(cycle),
    .out(outQ)
);

//Try Rory's LFSR
// EE465_filter_test SRRC_testQ(
//						   .clock_50(clock_50),
//							.reset(~KEY[3]),
////							.output_from_filter_1s17(srrc_out),
////							.filter_input_scale(SW[2:0]),
////							.input_to_filter_1s17(srrc_input),
//							.lfsr_value(outQ[1:0])
//							//,
////							.symbol_clk_ena(sym_clk_ena),
////							.sample_clk_ena(sam_clk_ena),
////							.system_clk(sys_clk),
////							.output_to_DAC(DAC_out)
//							);

wire signed [17:0] map_out, map_outQ;
mapper_in SUT_input (
	.LFSR(out[1:0]),
	.map_out(map_out)
);

mapper_in SUT_inputQ (
	.LFSR(outQ[1:0]),
	.map_out(map_outQ)
);

(* preserve *) reg [1:0] samCnt;

//upsample LFSR by 4
always @ (posedge sys_clk)
	if (~KEY[3])
		samCnt<=2'd0;
	else
		samCnt<=samCnt+2'd1;
		
//Make sure to uncomment srrc wires above
(* keep *) reg signed [17:0] srrc_input, srrc_inputQ;

always @ * begin
	case(samCnt)
		2'd0 : srrc_input=$signed(map_out);
		default : srrc_input=18'sd0;
	endcase
end

always @ * begin
	case(samCnt)
		2'd0 : srrc_inputQ=$signed(map_outQ);
		default : srrc_inputQ=18'sd0;
	endcase
end

PPS_filt_101 DUT_TX (
//PPS_filt_121 DUT_TX (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.x_in(srrc_input),
	.y(srrc_out)
	);

PPS_filt_101 DUT_TXQ (
//PPS_filt_121 DUT_TXQ (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.x_in(srrc_inputQ),
	.y(srrc_outQ)
	);

/*------------Upsample b4 1st LPF | 12.5 MHz------------*/
(* preserve *) reg halfSysCnt;

always @ (posedge sys_clk)
	if (~KEY[3])
		halfSysCnt<=1'd0;
	else if (sys_clk2_en)
		halfSysCnt<=~halfSysCnt;
		
(* keep *) reg signed [17:0] UpSam1, UpSam1Q;

always @ * begin
	case (halfSysCnt)
		1'd0 : UpSam1=$signed(srrc_out);
		default : UpSam1=18'sd0;
	endcase
end

always @ * begin
	case (halfSysCnt)
		1'd0 : UpSam1Q=$signed(srrc_outQ);
		default : UpSam1Q=18'sd0;
	endcase
end
		
/*------------First halfband LPF | 12.5 MHz------------*/
wire signed [17:0] halfOut1;

halfband_1st_sym HB1 (
//halfband_1st_sym_copy HB1 (
	.x_in(UpSam1),
	.y(halfOut1),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);
/*------------First halfband LPFQ | 12.5 MHz------------*/
wire signed [17:0] halfOut1Q;

halfband_1st_sym HB1Q (
//halfband_1st_sym_copy HB1Q (
	.x_in(UpSam1Q),
	.y(halfOut1Q),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);
	
/*------------Upsample b4 2nd LPF | 25 MHz------------*/
(* preserve *) reg SysCnt;

always @ (posedge sys_clk)
	if (~KEY[3])
		SysCnt<=1'd0;
	else 
		SysCnt<=SysCnt+1'd1;
		
		
(* keep *) reg signed [17:0] UpSam2, UpSam2Q;

always @ * begin
	case (SysCnt)
		1'd1 : UpSam2=$signed(halfOut1);
		default : UpSam2=18'sd0;
	endcase
end

always @ * begin
	case (SysCnt)
		1'd1 : UpSam2Q=$signed(halfOut1Q);
		default : UpSam2Q=18'sd0;
	endcase
end
		
/*------------Second halfband LPF | 25 MHz------------*/
wire signed [17:0] halfOut2;

halfband_2nd_sym HB2 (
	.x_in(UpSam2),
	.y(halfOut2),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);
		
/*------------Second halfband LPFQ | 25 MHz------------*/
wire signed [17:0] halfOut2Q;

halfband_2nd_sym HB2Q (
	.x_in(UpSam2Q),
	.y(halfOut2Q),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);


/*------------Upconverter | 25 MHz------------*/
wire signed [17:0] test_point_1;
wire signed [13:0] test_point_1_DAC;
upConv convUp (
	.x_i(halfOut1),
	.x_q(halfOut1Q),
	.sys_clk(sys_clk),
	.reset(~KEY[3]),
	.output_to_DAC(test_point_1_DAC),
	.upConv_out(test_point_1)
	);

//halfOut_dn_I_1; I_out
	
always @ *
	case(SW[17:16])
//		2'd0: DAC_out={~halfOut1[17],halfOut1[16:4]};
		2'd0: DAC_out={~halfOut_dn_I_1[17],halfOut_dn_I_1[16:4]};	//output of first halfband
		2'd1: DAC_out=test_point_1_DAC;
//		2'd2: DAC_out={~halfOut2[17],halfOut2[16:4]};
		2'd2: DAC_out={~I_out[17],I_out[16:4]};	//I channel output of downconverter
		2'd3: DAC_out=test_point_2_DAC;
	endcase


/*------------Channel | 25 MHz------------*/

(* preserve *) reg signed [17:0] pipeline;
(* keep *) reg signed [17:0] mult_mux;

always @ (posedge sys_clk)
	pipeline <= test_point_1;

always @ * begin
	case (SW[1:0])
			2'd1		:	mult_mux=18'sd8192;
			2'd2		:	mult_mux=18'sd16384;
			2'd3		:	mult_mux=18'sd32768;
			default	:	mult_mux=18'sd130171;	//MF_out is pipelined @ sam_clk
		endcase
	end
	
(* keep *) wire signed [35:0] mult_out;

assign mult_out=$signed(mult_mux)*$signed(pipeline);

wire signed [17:0] noise;

awgn_generator AWGN(
  .clk(sys_clk),
  .clk_en(1'd1),
  .reset_n(~KEY[3]),  //active LOW reset
  .awgn_out(noise)
);

reg signed [17:0] noise_ctrl;

always @ *
	case(SW[4])
		2'd0: noise_ctrl=18'sd0;
		default: noise_ctrl=$signed(noise);
	endcase
	
(* preserve *) reg signed [17:0] test_point_2;
(* keep *) wire [13:0] test_point_2_DAC;

always @ (posedge sys_clk)
	test_point_2 <= $signed(mult_out[34:17])+$signed(noise_ctrl);
	
assign test_point_2_DAC={~test_point_2[17],test_point_2[16:4]};
	
/*------------RCV | 25 MHz | Channel has 2 delays @ sys_clk------------*/
/*------------downconverter------------*/
(* keep *) wire [13:0] output_to_DAC_I, output_to_DAC_Q;
(* keep *) wire signed [17:0] I_out, Q_out;

dnConv convDn (
	.tp2(test_point_2),
	.sys_clk(sys_clk),
	//currently circuit is usin SW: 4, 2-0, & 17-16
	.SW(SW[15:14]),
	.output_to_DAC_I(output_to_DAC_I),
	.output_to_DAC_Q(output_to_DAC_Q),
	.I_out(I_out),
	.Q_out(Q_out)
);

(* preserve *) reg signed [17:0] I_pipe, Q_pipe;

//still 25 MHz
always @ (posedge sys_clk)
	I_pipe <= $signed(I_out);
	
always @ (posedge sys_clk)
	Q_pipe <= $signed(Q_out);

/*------------halfband filt 1 for I------------*/
wire signed [17:0] halfOut_dn_I_1, halfOut_dn_Q_1;

halfband_2nd_sym HB_dn_I_1 (
	.x_in(I_pipe),
	.y(halfOut_dn_I_1),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);

/*------------dn sample for I_1------------*/
(* preserve *) reg signed [17:0] dnSam_I_1;

//sample output @ sampling rate 2x slower
always @ (posedge sys_clk)
	if (sys_clk2_en)
		dnSam_I_1 <= halfOut_dn_I_1;
		
/*------------halfband filt 2 for I------------*/
wire signed [17:0] halfOut_dn_I_2;

halfband_1st_sym HB_dn_I_2 (
//halfband_1st_sym_copy HB1Q (
	.x_in(dnSam_I_1),
	.y(halfOut_dn_I_2),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_ena),
	.reset(~KEY[3]),
	.clk(clock_50),
	.sys_clk2_en(sys_clk2_en)
	);

/*------------dn sample for I_2------------*/
(* preserve *) reg signed [17:0] dnSam_I_2;

//sample output @ sampling rate 2x slower
always @ (posedge sys_clk)
	if (sam_clk_ena)
		dnSam_I_2 <= halfOut_dn_I_2;

/*

(* keep *) wire signed [17:0] MF_out;
//GSM
//GSM_101Mults DUT_RCV (
GSM_TS DUT_RCV (
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
*/

endmodule
