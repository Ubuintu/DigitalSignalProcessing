`timescale 1ns/1ns
module avg_err_tb #(LFSR_WID = 4);

reg clk, reset, load;
wire signed [(LFSR_WID-1):0] LFSR_out; 
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
    .out(LFSR_out),
    .*
);

endmodule
