module filter_tb;

reg clk, reset;

reg [17:0] in;
wire [17:0] out;

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
    default input #1step output#2;
    output in;
    input out;
endclocking

//Apply test stimulus
initial begin
    reset = 1;
    filt_cb.in <= 18'd0;
    ##1;
    reset = 0;
    ##1 filt_cb.in <= 18'H1FFFF;
    ##1 filt_cb.in <= 18'H0;
    ##1 filt_cb.in <= 18'H1FFFF;
    ##1 filt_cb.in <= 18'H0;
    ##1 filt_cb.in <= 18'H1FFFF;
    ##1 filt_cb.in <= 18'H0;
end

endprogram

sine_filt DUT (.*, .x_in(in), .y(out));

endmodule
