`timescale 1ns/1ns
module avg_mag_tb;

reg clk, reset, load;
//wire signed [21:0] out;
wire signed [3:0] out; //For testing
wire cycle, sys_clk, sam_clk_en, sym_clk_en;
wire signed [17:0] ref_lvl, map_out_pwr;

localparam PERIOD = 10;
localparam RESET_DELAY = 2;
localparam RESET_LENGTH = 21;

// Clock generation initial
initial
begin
    clk = 0;
    forever begin
    #(PERIOD/2);
    clk=~clk;
    end
end

initial begin
   reset = 0;
   load = 0;
   #(RESET_DELAY);
   reset = ~reset;
   #(RESET_DELAY * PERIOD );
   reset = ~reset;
   load = ~load;
   //time load w/sam_clk
   repeat(4)@(posedge clk);
   load = ~load;
end

clk_en timing (
    .*
);


//LFSR_22 drv (
LFSR_test DRV_LFSR (
    .clk(sam_clk_en),
    .*
);

avg_mag #(.ACC_WID(20), .LFSR_WID(4)) DUT (
    .clr_acc(cycle),
    //.dec_var(out[17:0]),
    .dec_var( $signed({out,{14{1'b0}}}) ),
    .clk(sys_clk),
    .*
);

endmodule

