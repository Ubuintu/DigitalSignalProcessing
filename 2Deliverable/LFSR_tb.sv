`timescale 1ns/1ns
module LFSR_tb #(parameter WIDTH = 22);

reg clk, reset, load;
integer i;
wire signed [WIDTH-1:0] y;
wire cycle;

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
    repeat (4194303) @ (posedge clk);
    $fdisplay(file_out, $unsigned(y));
    $display("time = %0t | y = %p",$time, $unsigned(y));
    $fclose(file_out);
end

LFSR_22 DUT(
//LFSR_test DUT(
    .*,
    .out(y)
);

endmodule
