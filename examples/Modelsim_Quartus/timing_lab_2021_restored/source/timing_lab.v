module timing_lab ( input CLOCK_50,
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
  

//=============================================================				
//					DECLARATIONS
//           for ADC and DACs				

	   (* noprune *)reg [13:0] registered_ADC_A;
		(* noprune *)reg [13:0] registered_ADC_B;
							
//************************
//				  Set up DACs
					
					assign DAC_CLK_A = sys_clk;
					assign DAC_CLK_B = sys_clk;
					
					
					assign DAC_MODE = 1'b1; //treat DACs seperately
					
					assign DAC_WRT_A = ~sys_clk;
					assign DAC_WRT_B = ~sys_clk;
					
					always@ (posedge sys_clk)
					DAC_DA = {~sig_DAC[13], sig_DAC[12:0]};
						
					always@ (posedge sys_clk)// make DAC B echo DAC A
					DAC_DB = {~sig_DAC[13], sig_DAC[12:0]};	
	
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
						
//  End ADC setup
//=================================================




//==============================================================================
// QAM - Transmitter
//==============================================================================

wire 							sys_clk, sam_clk_ena, sym_clk_ena;
wire 	signed 	[17:0] 	sig_tx;
wire 				[3:0] 	lfsr_out;
wire 	signed 	[17:0] 	mapped_I, mapped_Q, I_pulse_out, Q_pulse_out;
reg 	signed 	[17:0] 	I_up4, Q_up4;
wire 				[1:0] 	I_sym, Q_sym;
reg 	signed 	[13:0]	sig_DAC;


//====================================================
//create I and Q data
//by using an LFSR
//
//		Note: LFSR is to be run at the sampling rate of
//          the SRRC pulse shaping filters, not the
//          symbol rate. The idea here is to reduce
//          potential correlation between the I and Q
//          data.
//          This concept will be discussed further in
//          EE 465, or ask your lab instruction to
//          explain if you are interested.
//====================================================

LFSR lfsr_channel( 	.clk(sam_clk_ena),
			.load_data(~KEY[3]), //reset LFSR
			.q(lfsr_out));

assign I_sym = lfsr_out[1:0];
assign Q_sym = lfsr_out[3:2];

//====================================================
//Instantiate your mappers here
//====================================================

mapper map_I(.symbol(I_sym),
				 .value(mapped_I));
				 
mapper map_Q(.symbol(Q_sym),
				 .value(mapped_Q));

//====================================================
//Up-sample mapper values prior to sending to SRRC
//pulse-shaping filters
//
//Note: Upsample by zero-stuffing. sym_clk_ena happens
//      once every 4 sam_clk_ena pulses so we use the
//      actual mapper output on a sym_clk_ena pulses
//      and zeros for other 3 sam_clk_ena pulses.
//====================================================
				 
always@ *
	if(sym_clk_ena == 1'b1)
		I_up4 <= mapped_I;
	else
		I_up4 <= 18'sd0;
		
always@ *
	if(sym_clk_ena == 1'b1)
		Q_up4 <= mapped_Q;
	else
		Q_up4 <= 18'sd0;
		

//====================================================
//Instantiate SRRC filters
//====================================================

pulseshaping_filter pulse_I456(.sys_clk(sys_clk),
									.clk_ena(sam_clk_ena),
									.coeff_sel(SW[17:16]),
									.x_in(I_up4),
									.y(I_pulse_out)   );
									

pulseshaping_filter pulse_Q456(.sys_clk(sys_clk),
									.clk_ena(sam_clk_ena),
									.coeff_sel(SW[17:16]),
									.x_in(Q_up4),
									.y(Q_pulse_out)   );

//pulseshaping_filter_no_pipelining pulse_I456(.sys_clk(sys_clk),
//									.clk_ena(sam_clk_ena),
//									.coeff_sel(SW[17:16]),
//									.x_in(I_up4),
//									.y(I_pulse_out)   );
									

//pulseshaping_filter_no_pipelining pulse_Q456(.sys_clk(sys_clk),
//									.clk_ena(sam_clk_ena),
//									.coeff_sel(SW[17:16]),
//									.x_in(Q_up4),
//									.y(Q_pulse_out)   );

//===================================================
//Send output to filters to Transmitter circuit
//
// Note: This circuit produces the clock signals to
//       be used. Also, this circuit takes the output
//       of the SRRC pulse-shaping filters and upsam-
//       ples it by a factor of 4, anti-alises the
//       upsampled data and upconverts the signal to
//       1/4*sys_clk Hz. (25/4 = 6.25 MHz)
//===================================================

EE456_QAM_Transmitter mainSig(	.clock_50(CLOCK_50),
											.sys_clk(sys_clk),
											.sam_clk_ena(sam_clk_ena),
											.sym_clk_ena(sym_clk_ena),
											.filter_in_I(I_pulse_out),
											.filter_in_Q(Q_pulse_out),
											.reset(~KEY[3]),
											.sig_out(sig_tx));

//transmitt signal to DAC.
always@ (posedge sys_clk)
	sig_DAC <= sig_tx[17:4];
	
						
//====================================================
// Show user that switches and buttons are working
//====================================================

always@ *
	LEDR[17:0] = SW[17:0];
	
always@ *
	LEDG[3:0] = ~KEY[3:0];

	
endmodule
