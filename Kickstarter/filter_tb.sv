module filter_tb;
`timeunit 1ns;

reg clk, reset;

reg [17:0] in;
wire [17:0] out;

localparam PERIOD = 10;
localparam RESET_DELAY = 2;

// Clock generation
intial
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
clocking filt_cb @(posedge clk);
    output in;
    input out;
endclocking

//Apply test stimulus
initial begin
    reset = 1;
    x_in = 18'd0;
    ##1;
    reset = 0;
    ##1 filt_cb = 18'H1FFFF;
    ##1 filt_cb = 18'H0;
    ##1 filt_cb = 18'H1FFFF;
    ##1 filt_cb = 18'H0;
    ##1 filt_cb = 18'H1FFFF;
    ##1 filt_cb = 18'H0;
end

endprogram

sine_filt DUT (.*);

endmodule
