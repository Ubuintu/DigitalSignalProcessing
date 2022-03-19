`timescale 1ns/1ps
module deliverable2_testbench();
wire sys_clk, sam_clk_en, sym_clk_en;

reg clk_50;

localparam PERIOD=20; 
localparam RSTDELAY=2; 
localparam RSTLEN=2; 

initial begin
    clk_50=0;
    forever begin
    #(PERIOD/2);
    clk_50=~clk_50;
    end
end

deliverable2 MER_circuit (
	.CLOCK_50(clk_50),
	.sys_clk(sys_clk),
	.sym_clk_en(sym_clk_en),
	.sam_clk_en(sam_clk_en)
);

endmodule
