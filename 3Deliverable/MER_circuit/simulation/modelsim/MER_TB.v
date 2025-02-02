`timescale 1ns/1ps
module MER_TB();
reg clk_50, reset, load, a_reset;
reg [1:0] SW;
wire sys_clk, sam_clk_en, sym_clk_en, cycle;
wire [21:0] LFSR_out;
wire signed [17:0] TX_out, RCV_out, map_out, dec_var, map_out_ref_lvl, ref_lvl, map_out_pwr, err_acc, error, MUX_out_in, MUX_out_out;
wire [1:0] slice;
wire signed [55:0] err_square;

localparam PERIOD=20; 
localparam RSTDELAY=2; 
localparam RSTLEN=2; 

initial begin
    clk_50=0;
    forever begin
    #(PERIOD/2);
    clk_50=~clk_50;
    end
end

initial begin
    reset=0;
    a_reset=1;
    //LFSR_out=22'd0;
    //map_out=18'sd0;
    //MUX_out_in=18'sd0;
    SW=2'd1;
    //file_in=$fopen("impulse_response.txt","r");
    //file_in=$fopen("D3_ASK_in.txt","r");
    #(RSTDELAY*PERIOD);
    reset=1;
    a_reset=0;
    load=1;
    #(RSTLEN*RSTLEN*10*PERIOD);
    reset=0;
    load=0;
end

clk_en EN_CLK( .clk(clk_50), .reset(a_reset), .sys_clk(sys_clk), .sam_clk_en(sam_clk_en), .sym_clk_en(sym_clk_en) );

MER_circuit MEAS_DUT (
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.sym_clk_en(sym_clk_en),
	.load(load),
	.reset(reset),
	.SW(SW),
	.cycle(cycle),
	.LFSR_out(LFSR_out),
	.TX_out(TX_out),
	.RCV_out(RCV_out),
	.map_out(map_out),
	.dec_var(dec_var),
	.map_out_ref_lvl(map_out_ref_lvl),
	.ref_lvl(ref_lvl),
	.map_out_pwr(map_out_pwr),
	.err_acc(err_acc),
	.slice(slice),
	.error(error),
	.MUX_out_in(MUX_out_in),
	.MUX_out_out(MUX_out_out),
	.err_square(err_square)
);

endmodule