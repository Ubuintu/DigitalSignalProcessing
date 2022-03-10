module GSPS_filt #(
    parameter WIDTH=18,
    parameter SUMLVL=6,
    parameter LENGTH=93,
    parameter POSSMAPPER=7,
    parameter integer SUMLVLWID [SUMLVL-1:0]={46,23,11,5,2,1}
)
(
    input sys_clk, sam_clk_en, sym_clk_en, reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);


endmodule

