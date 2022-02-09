`timescale 1ns/1ps
module LFSR_tb;

reg clk, reset, load;
integer i;
wire signed [21:0] y;

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

integer file_out;


initial begin
    reset = 0;
    load = 0;
    file_out = $fopen("outLFSR.txt","w");
    #(RESET_DELAY);
    reset = ~reset;
    #(RESET_LENGTH * PERIOD);
    reset = ~reset;
    load = ~load;
    @(posedge clk);
    load = ~load;
    @(posedge clk);
    $fdisplay(file_out, $unsigned(y));
    $display("time = %0t | y = %p",$time, $unsigned(y));
    repeat (20) @ (posedge clk);
    $fdisplay(file_out, $unsigned(y));
    $display("time = %0t | y = %p",$time, $unsigned(y));
    $fclose(file_out);
end

LFSR_22 DUT(
    .*,
    .out(y)
);

endmodule
