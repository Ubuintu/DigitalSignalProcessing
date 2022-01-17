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

integer file_in;

initial begin
    reset = 0;
    x_in = 0;
    
    //for 1s17 sine input
    file_in = $fopen("input_sine.txt","r");
    
    //for worse case input
    //file_in = $fopen("input_worst.txt","r");
    
    //impulse response
    //file_in = $fopen("input_ir.txt","r");
    
    #(RESET_DELAY);
    reset = 1;
    #(RESET_LENGTH * PERIOD);
    reset = 0;
end


/*
always @ (posedge clk)
    if(reset)
        begin
        x_in <= 18'sb0;
        end
    else
        x_in <= x_in + 18'sd1;
*/        

always @ (posedge clk)
    if(reset)
        begin
            x_in <= 18'sb0;
        end
    else
        $fscanf(file_in,"%d\n",x_in);


sine_filt DUT (
    .clk(clk),
    .reset(reset),
    .x_in(x_in),
    .y(y)

    //.*
);


endmodule
