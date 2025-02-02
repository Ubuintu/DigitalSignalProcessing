module deliverable2 #(parameter DELAY = 3)
(
			input CLOCK_50,
			input [17:0] PHYS_SW,
			input [3:0] PHYS_KEY,
			input [13:0]ADC_DA,
			input [13:0]ADC_DB,
			output reg [3:0] LEDG,
			output reg [17:0] LEDR,
			output reg[13:0]DAC_DA,
			output reg [13:0]DAC_DB,
			// output	I2C_SCLK,
			// inout		I2C_SDAT,
			output	ADC_CLK_A,
			output	ADC_CLK_B,
			output	ADC_OEB_A,
			output	ADC_OEB_B,
			// input 	ADC_OTR_A,
			// input 	ADC_OTR_B,
			output	DAC_CLK_A,
			output	DAC_CLK_B,
			output	DAC_MODE,
			output	DAC_WRT_A,
			output	DAC_WRT_B,
			output sys_clk, sam_clk_en, sym_clk_en
			// ,input 	OSC_SMA_ADC4,
			// input 	SMA_DAC4
			 );
	reg clk;

	reg [11:0] NCO_freq, phase_ref,
			           quadrature_phase_out, phase_to_ROM;
	(* noprune *) reg [11:0] phase_out, staggered_phase_out;
	reg signed [13:0] signal_to_DAC;
	reg signed [29:0] multiplier_output;
	reg [35:0] PLL_acc, quad_phase;
		
	wire dwell_pulse;
	wire [17:0] sweep_gen_freq;
	wire signed [17:0] SUT_out;
	wire signed [11:0] NCO_1_out, NCO_2_out;
	/******************************
	*	generate the clock used for sampling ADC and
	*  driving the DAC, i.e. generate the sampling clock
	*/
	always @ (posedge CLOCK_50)
	clk = ~clk;
	// end generatating sampling clock
	
	/************************
			  Set up DACs
			*/
			assign DAC_CLK_A = clk;
			assign DAC_CLK_B = clk;
			
			
			assign DAC_MODE = 1'b1; //treat DACs seperately
			
			assign DAC_WRT_A = ~clk;
			assign DAC_WRT_B = ~clk;
			
		always@ (posedge clk)// convert 1s13 format to 0u14
								//format and send it to DAC A
		DAC_DA = {~signal_to_DAC[13],
						signal_to_DAC[12:0]};		
		
				
		always@ (posedge clk) // DAC B is not used in this
					 // lab so makes it the same as DAC A
				 
			DAC_DB = {~signal_to_DAC[13],
						signal_to_DAC[12:0]} ;	
			/*  End DAC setup
			************************/
	
	/********************
	*	set up ADCs, which are not used in this lab 
	*/
	(* noprune *) reg [13:0] registered_ADC_A;
	(* noprune *) reg [13:0] registered_ADC_B;
	
	assign ADC_CLK_A = clk;
			assign ADC_CLK_B = clk;
			
			assign ADC_OEB_A = 1'b1;
			assign ADC_OEB_B = 1'b1;

			
			always@ (posedge clk)
				registered_ADC_A <= ADC_DA;
				
			always@ (posedge clk)
				registered_ADC_B <= ADC_DB;
				
			/*  End ADC setup
			************************/	
	
	
	/******************************
			Set up switches and LEDs
			*/
			always @ *
			LEDR = SW;
			always @ *
			LEDG = {dwell_pulse, KEY[2:0]};
			
			
	//end setting up switches and LEDs

	// instantiate the sweep generator	
		SweepGenerator sweep_gen_1(.clock(clk),
							  .sweep_rate_adj(3'b101),
							  .dwell_pulse(dwell_pulse),
							  .reset(~KEY[1]),
							  .lock_stop(~KEY[2]),
							  .lock_start(~KEY[3]),
							  .freq(sweep_gen_freq));
	// dwell pulse is assigned to LEDG[3] elsewhere so that it is not optimized out
	
							  
	//  make the phase accumulator for the NCOs 
	
	always @ (posedge clk)
	phase_ref = phase_ref + NCO_freq;
	
	
	
	// make data selector for phase_ref
	always @ (posedge clk)
	if (SW[0]==1'b0)
			NCO_freq = sweep_gen_freq[17:6];
	else  NCO_freq = {SW[17:14], 8'b0};

	// make the data selector for signal_to_DAC
	always @ *
	if (SW[1]==1'b0)
		signal_to_DAC = {NCO_1_out, 2'b0};
	else
	   signal_to_DAC = SUT_out[17:4];
		
	// make the phase locked loop
	always @ *
	multiplier_output = NCO_2_out * SUT_out;	

	always @ *
	quad_phase = { { 6{multiplier_output[29]} }, multiplier_output}
					  + PLL_acc;
	
	always @ (posedge clk)
	PLL_acc = quad_phase;
	
	always @ *
	quadrature_phase_out = quad_phase[35:24];
	
	always @ *
	phase_to_ROM = phase_ref + quadrature_phase_out;
	
	// end of making PLL
	
	// make the phase out, which does not to a pin
	// as its intendended destination is SignalTap
	always @ (posedge clk)
	phase_out = quadrature_phase_out + 12'b1100_0000_0000;
	
	always @ (negedge clk)
	staggered_phase_out = phase_out;
	
	// intantiate the phase-to-voltage ROM 
	// for NCOs 1 and 2
	ROM_for_12_x_12_NCO NCO_ROM_1 (
		  .address_a(phase_ref),
		  .address_b(phase_to_ROM),
		  .clock(clk),
		  .q_a(NCO_1_out),
		  .q_b(NCO_2_out));
		  
	// Instantiate the system under test
/*	system_under_test SUT_1 (.clk(clk),
	                         .SUT_in(NCO_1_out),
									 .SUT_out(SUT_out) );
									 
*/

/*--------------------------------------------------Deliverable 2--------------------------------------------------*/
/*
■ keep—Ensures that combinational signals are not removed
■ preserve—Ensures that registers are not removed
*/
//CLKEN
(* keep *) reg reset;

always @ *
	if (!KEY[0]) reset = 1'b1;
	else reset = 1'b0;

//wire sys_clk, sam_clk_en, sym_clk_en;

clk_en EN_CLK (
	.clk(CLOCK_50),
	.reset(reset),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.sym_clk_en(sym_clk_en)
);
//LFSR
(* keep *) reg load;

always @ *
	if (!KEY[1]) load = 1'b1;
	else load = 1'b0;
	
wire cycle;
wire signed [21:0] out;

LFSR_22 LFSR_GEN (
//LFSR_test LFSR_GEN (
    .sys_clk(sys_clk), 
	 .reset(reset), 
	 .load(load), 
	 .sam_clk_en(sam_clk_en),
    .cycle(cycle),
    .out(out)
);
//mapper in
wire signed [17:0] map_out, map_outQ;

mapper_in SUT_input (
	.LFSR(out[1:0]),
	.map_out(map_out)
);

mapper_in SUT_inputQ (
	.LFSR(out[3:2]),
	.map_out(map_outQ)
);
//SYSTEM UNDER TEST
(* keep *) wire signed [17:0] dec_var, errorless_decision_variable, error_actual, dec_varQ, errorless_decision_variableQ, error_actualQ;
(* keep *) reg signed [17:0] isi_power;

//20 dB
//assign isi_power = 18'sd9268;
//30 dB
//assign isi_power = 18'sd2931;
//40 dB
//assign isi_power = 18'sd927;
//55 dB
//assign isi_power = 18'sd165;

always @ *
	isi_power = SW;

DUT_for_MER_measurement DUT (
	.clk(sys_clk),
	.clk_en(sym_clk_en),
	.in_data(map_out),
	.reset(~reset),
	.isi_power(isi_power),
	.decision_variable(dec_var),
	.errorless_decision_variable(errorless_decision_variable),
	.error(error_actual)
);

DUT_for_MER_measurement DUTQ (
	.clk(sys_clk),
	.clk_en(sym_clk_en),
	.in_data(map_outQ),
	.reset(~reset),
	.isi_power(isi_power),
	.decision_variable(dec_varQ),
	.errorless_decision_variable(errorless_decision_variableQ),
	.error(error_actualQ)
);
//SLICER
wire [1:0] slice, sliceQ;
slicer DECIDER (
	.dec_var(dec_var),
	.ref_lvl(ref_lvl),
	.slice(slice)
);
slicer DECIDERQ (
	.dec_var(dec_varQ),
	.ref_lvl(ref_lvlQ),
	.slice(sliceQ)
);
//Mapper_out
wire signed [17:0] map_out_ref_lvl, map_out_ref_lvlQ;
mapper_ref MAP_CMP (
	.map_out(map_out_ref_lvl),
	.slice(slice),
	.ref_lvl(ref_lvl)
);
mapper_ref MAP_CMPQ (
	.map_out(map_out_ref_lvlQ),
	.slice(sliceQ),
	.ref_lvl(ref_lvlQ)
);
//AVG_MAG
wire signed [17:0] ref_lvl, map_out_pwr, ref_lvlQ, map_out_pwrQ;

avg_mag AVG_MAG_DV (
//avg_mag #(.ACC_WID(20), .LFSR_WID(4)) AVG_MAG_DV (
	.dec_var(dec_var),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.clk(sys_clk),
	.reset(reset),
	.ref_lvl(ref_lvl),
	.map_out_pwr(map_out_pwr)
);

avg_mag AVG_MAG_DVQ (
//avg_mag #(.ACC_WID(20), .LFSR_WID(4)) AVG_MAG_DV (
	.dec_var(dec_varQ),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.clk(sys_clk),
	.reset(reset),
	.ref_lvl(ref_lvlQ),
	.map_out_pwr(map_out_pwrQ)
);
//ERROR
(* preserve *) reg signed [17:0] error, errorQ;

always @ (posedge sys_clk)
	if (reset) error = 18'sd0;
	else if (sym_clk_en) error = dec_var - map_out_ref_lvl;
	else error = error;
always @ (posedge sys_clk)
	if (reset) errorQ = 18'sd0;
	else if (sym_clk_en) errorQ = dec_varQ - map_out_ref_lvlQ;
	else errorQ = errorQ;
	
wire signed [17:0] err_acc, err_accQ;
//wire signed [17:0] err_square;	//for original err_Sqr circuit
wire signed [55:0] err_square, err_squareQ;
	
//avg_err_squared AVG_ER_SQR (
avg_err_squared_55 AVG_ER_SQR (
	.error(error),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_square(err_square)
);
avg_err_squared_55 AVG_ER_SQRQ (
	.error(errorQ),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_square(err_squareQ)
);

avg_err AVG_ER (
	.error(error),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_acc(err_acc)
);

avg_err AVG_ERQ (
	.error(errorQ),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_acc(err_accQ)
);
// SYM COMPARE
/*
integer i;
(* noprune *) reg [1:0] LFSR_IN_Delay [DELAY-1:0];
always @ (posedge sym_clk_en)
	if (reset) begin
		for (i=0; i<DELAY; i=i+1)
			LFSR_IN_Delay[i] <= 2'b0;
	end
	else begin
		for (i=0; i< DELAY; i=i+1) 
			if (i == 0)
				LFSR_IN_Delay[i] = out[1:0];
			else
				LFSR_IN_Delay[i] = LFSR_IN_Delay[i-1];
	end
*/

(* noprune *) reg [1:0] LFSR_IN_Delay [DELAY-1:0], LFSR_IN_DelayQ [DELAY-1:0];
initial begin
	LFSR_IN_Delay[0] = 2'd0;
	LFSR_IN_Delay[1] = 2'd0;
	LFSR_IN_Delay[2] = 2'd0;
	LFSR_IN_DelayQ[0] = 2'd0;
	LFSR_IN_DelayQ[1] = 2'd0;
	LFSR_IN_DelayQ[2] = 2'd0;
end

integer i;
always @ (posedge sys_clk)
	if (sym_clk_en)
		LFSR_IN_Delay[0] = out[1:0];
		
always @ (posedge sys_clk)
	if (sym_clk_en)
		for (i=1; i<DELAY; i=i+1) 
			LFSR_IN_Delay[i] <= LFSR_IN_Delay[i-1];
	

//Q Phase
always @ (posedge sys_clk)
	if (sym_clk_en)
		LFSR_IN_DelayQ[0] <= out[3:2];
	else
		LFSR_IN_DelayQ[0] <= LFSR_IN_DelayQ[0];
always @ (posedge sys_clk)
	if (sym_clk_en)
		LFSR_IN_DelayQ[1] <= LFSR_IN_DelayQ[0];
	else
		LFSR_IN_DelayQ[1] <= LFSR_IN_DelayQ[1];
always @ (posedge sys_clk)
	if (sym_clk_en)
		LFSR_IN_DelayQ[2] <= LFSR_IN_DelayQ[1];
	else
		LFSR_IN_DelayQ[2] <= LFSR_IN_DelayQ[2];
	
(* noprune *) reg equal, equalQ;
always @ *
	if(LFSR_IN_Delay[2] == slice)
		equal = 1'b1;
	else
		equal = 1'b0;
always @ *
	if(LFSR_IN_DelayQ[2] == sliceQ)
		equalQ = 1'b1;
	else
		equalQ = 1'b0;
		
(* noprune *) reg sym_cor, sym_err, sym_corQ, sym_errQ;
always @ (posedge sys_clk)
	if (sym_clk_en)
		begin
			sym_cor <= equal;
			sym_err <= ~equal;
		end
	else
		begin
			sym_cor <= sym_cor;
			sym_err <= sym_err;
		end
		
always @ (posedge sys_clk)
	if (sym_clk_en)
		begin
			sym_corQ <= equalQ;
			sym_errQ <= ~equalQ;
		end
	else
		begin
			sym_corQ <= sym_corQ;
			sym_errQ <= sym_errQ;
		end
			
									 
// ------------------------------------------------------------------------------
// In-System Sources and Probes (ISSP) Code
//
// - instantiate ISSP cores; two cores are used:
// -- one to emulate switches and LEDs on the DE2 board (active high)
// -- one to emulate push-button keys on the DE2 board (active low)
// 
// - connect relevant signals to and from the core
//
// - note 1: push-button key outputs from ISSP will be passed through
//   a hold circuit to better simulate what happens when a button is pushed
// - note 2: core outputs will be used by the circuit only if 
//   the 'ISSP enable' bit is active (set to 1)
// -------------------------------------------------------------------------------                   

// direct connections to ISSP core
wire [49:0] issp_sw_sources;
wire [49:0] issp_probes;

// demultiplexed outputs from ISSP cores
wire [17:0] issp_sw;
wire  [3:0] issp_key;
wire        issp_en;

// outputs to remainder of circuit
reg [17:0] SW;
reg  [3:0] KEY;


// Instantiate ISSP core #1 (switch and LED emulator)
switch_led_emulator switch_led_emulator_inst (
  .source (issp_sw_sources[49:0]), // outputs from core
  .probe  (issp_probes[49:0])   // inputs to core
);

// de-multiplex output bus from ISSP
//
assign issp_en = issp_sw_sources[49];
// bits 48:22 are currently unused for this lab
assign issp_sw[17:0] = issp_sw_sources[17:0];

// combine inputs to ISSP
assign issp_probes[17:0] = LEDR[17:0];
assign issp_probes[21:18] = LEDG[3:0];
assign issp_probes[49:22] = 'b0; // set unused inputs to 0


// Instantiate ISSP core #2 (push-button key emulator)
// 4 output ports, no input ports
// (core configured to set outputs to 1 by default)

key_emulator key_emulator_inst (
  .source (issp_key[3:0])
);

// -------------------------------------------------------------
// Instantiate pulse generator circuit for each key here
// -------------------------------------------------------------

wire [3:0] issp_key_pulse;

KeyCCT	#(.PERSIST(1)) k0	(.clk(clk), .key(issp_key[0]), .key_out(issp_key_pulse[0]));
KeyCCT	#(.PERSIST(1)) k1	(.clk(clk), .key(issp_key[1]), .key_out(issp_key_pulse[1]));
KeyCCT	#(.PERSIST(1)) k2	(.clk(clk), .key(issp_key[2]), .key_out(issp_key_pulse[2]));
KeyCCT	#(.PERSIST(1)) k3	(.clk(clk), .key(issp_key[3]), .key_out(issp_key_pulse[3]));


// Only use ISSP outputs if the enable bit is set (otherwise use on-board components).
// This allows students to use the physical switches and keys if they have a board.
always @ (*)
    if(issp_en == 1'b1)
      begin
        SW[17:0] <= issp_sw[17:0];
        KEY[3:0] <= issp_key_pulse[3:0];
      end
    else
      begin
        SW[17:0] <= PHYS_SW[17:0];
        KEY[3:0] <= PHYS_KEY[3:0];
      end
	
		
endmodule	
