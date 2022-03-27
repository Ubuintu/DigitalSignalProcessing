module MER_circuit(
	input sys_clk, sam_clk_en, sym_clk_en, load, reset,
	input [1:0] SW,
	output cycle, 
	output [21:0] LFSR_out,
	output signed [17:0] TX_out, RCV_out, map_out, dec_var, map_out_ref_lvl, ref_lvl, map_out_pwr, err_acc,
	output [1:0] slice,
	output reg signed [17:0] error, MUX_out_in, MUX_out_out,
	output signed [55:0] err_square
	
);

//init to 0
//initial begin
//	LFSR_out=22'd0;
//	MUX_out_in=18'sd0;
//	map_out=18'sd0;
//end

//Variables
integer i;

//LFSR
LFSR_22 LFSR_GEN (
    .sys_clk(sys_clk), 
	 .reset(reset), 
	 .load(load), 
	 .sam_clk_en(sam_clk_en),
    .cycle(cycle),
    .out(LFSR_out)
);

//Input Mapper
mapper_in SUT_input (
	.LFSR(LFSR_out[1:0]),
//	.LFSR(counterL),
	.map_out(map_out)
);

//Upsampler
(* preserve *) reg [1:0] counter, counterL;

always @ (posedge sys_clk)
	if (reset)
		counter<=2'd0;
	else if (sam_clk_en)
		counter <= counter+2'd1;
	else
		counter <= counter;

//always @ (posedge sys_clk)
//	if (reset)
//		counterL<=2'd0;
//	else
//		counterL <= counterL+2'd1;
		
//(* keep *) reg signed [17:0] MUX_out;
		
always @ * begin
	case(counter)
		2'd1		:	MUX_out_in=0;
		2'd2		:	MUX_out_in=0;
		2'd3		:	MUX_out_in=0;
		2'd0		:	MUX_out_in=$signed(map_out);	//MF_out is pipelined @ sam_clk
	endcase
end
		

/*		cascaded TX and RCV filters	*/
PPS_filt_101 DUT_TX (
//GSM_101Mults DUT_TX (	//debug MER circuit
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.reset(reset),
	.x_in(MUX_out_in),
	.y(TX_out)
);
	
GSM_101Mults DUT_RCV (
//gs_matched_filter_mult DUT_RCV (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.reset(reset),
	.x_in(TX_out),
	.y(RCV_out)
);

// Downsample MF
(* preserve *) reg signed [17:0] MDELAY [3:0]; 

always @ (posedge sys_clk)
	if (reset) 
		MDELAY[0]<=18'sd0;
	else if (sam_clk_en)
		MDELAY[0]<=RCV_out;
	else
		MDELAY[0]<=$signed(MDELAY[0]);
	
always @ (posedge sys_clk)
	if (sam_clk_en)
		for(i=1; i<4; i=i+1)
			MDELAY[i]<=$signed(MDELAY[i-1]);

always @ (posedge sys_clk)
	if (sym_clk_en) begin
		case(SW)
			2'd1		:	MUX_out_out<=$signed(MDELAY[1]);
			2'd2		:	MUX_out_out<=$signed(MDELAY[2]);
			2'd3		:	MUX_out_out<=$signed(MDELAY[3]);
			default	:	MUX_out_out<=$signed(RCV_out);	//MF_out is pipelined @ sam_clk
		endcase
	end
	
	
//decision circuit
assign dec_var=$signed(MUX_out_out);

//Mapper_out
mapper_ref MAP_CMP (
	.map_out(map_out_ref_lvl),
	.slice(slice),
	.ref_lvl(ref_lvl)
);

slicer DECIDER (
	.dec_var(dec_var),
//	.dec_var(MUX_out),
	.ref_lvl(ref_lvl),
	.slice(slice)
);

avg_mag AVG_MAG_DV (
	.dec_var(dec_var),
//	.dec_var(MUX_out),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.clk(sys_clk),
	.reset(reset),
	.ref_lvl(ref_lvl),
	.map_out_pwr(map_out_pwr)
);

//ERROR
always @ (posedge sys_clk)
	if (reset) error <= 18'sd0;
	else if (sym_clk_en) error <= $signed(dec_var) - $signed(map_out_ref_lvl);
	else error <= error;
	
avg_err_squared_55 AVG_ER_SQR (
	.error(error),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_square(err_square)
);

avg_err AVG_ER (
	.error(error),
	.sym_clk_en(sym_clk_en),
   .clr_acc(cycle),
	.sys_clk(sys_clk),
	.reset(reset),
	.err_acc(err_acc)
);


endmodule 