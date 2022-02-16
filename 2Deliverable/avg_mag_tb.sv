`timescale 1ns/1ns
module avg_mag_tb #(LFSR_WID = 4);

reg clk, reset, load;
//wire signed [21:0] out;
wire signed [(LFSR_WID-1):0] out; //For testing
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


//LFSR_22 DRV_LFSR (
LFSR_test DRV_LFSR (
    .*
);

avg_mag #(.ACC_WID(20), .LFSR_WID(4)) DUT (   //4bit
//avg_mag #() DUT ( //for 22 bit LFSR
    .clr_acc(cycle),
    //.dec_var(out[17:0]),
    .dec_var( $signed({out,{(18-LFSR_WID){1'b0}}}) ),
    .clk(sys_clk),
    .*
);

endmodule

