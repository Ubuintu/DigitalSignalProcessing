`timescale 1ns/1ps
module tb_filter;

reg clk, reset;

reg signed [17:0] x_in;
wire signed [17:0] y;

localparam PERIOD = 10;
localparam RESET_DELAY = 2;
localparam RESET_LENGTH = 21;

// Clock generation
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
    #(RESET_DELAY);
    reset = 1;
    #(RESET_LENGTH * PERIOD);
    reset = 0;
end



always @ (posedge clk)
    if(reset)
        begin
        x_in <= 18'sb0;
        end
    else
        x_in <= x_in + 18'sd1;
        

sine_filt DUT (
    .clk(clk),
    .x_in(x_in),
    .y(y)

    //.*
);

endmodule
