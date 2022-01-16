module filter_tb;

reg clk, reset;

reg [17:0] x_in;
wire [17:0] y;

localparam PERIOD = 10;
localparam RESET_DELAY = 2;

// Clock generation
initial
begin
    clk = 0;
    forever begin
    #(PERIOD/2);
    clk=~clk;
    end
end

//Test program
program test_filter;
//clocking outputs are DUT inputs; clocking inputs are DUT outputs
default clocking filt_cb @(posedge clk);
    //default input #1step output#2;
    output x_in;
    input y;
endclocking

//Apply test stimulus
initial begin
    reset = 1;
    filt_cb.x_in <= 18'd0;
    ##1;
    reset = 0;
    ##5;
    ##1 filt_cb.x_in <= 18'H1FFFF;
    ##1 filt_cb.x_in <= 18'H0;
    ##1 filt_cb.x_in <= 18'H1FFFF;
    ##1 filt_cb.x_in <= 18'H0;
    ##1 filt_cb.x_in <= 18'H1FFFF;
    ##1 filt_cb.x_in <= 18'H0;
end

endprogram

sine_filt DUT (
//    .clk(clk),
//    .x_in(x_in),
//    .y(y)

    .*
);

endmodule
