module GSPS_filt #(
    parameter WIDTH=18,
    parameter SUM1WID=11,
    parameter SUM2WID=6,
    parameter SUM3WID=3,
    parameter SUM4WID=1
)
(
    input sys_clk, sam_clk_en, sym_clk_en, reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);


endmodule

