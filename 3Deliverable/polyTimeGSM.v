module pp_MUX #(
    //width of registers
    parameter WID = 18,
    //# binary bits for counter
    parameter CNT = 2,
    parameter NUMCOEFF = 4;
)
(
    input [CNT-1:0] counter,
    input [WID-1:0] Hsys1,
    input [WID-1:0] Hsys2,
    input [WID-1:0] Hsys3,
    input [WID-1:0] Hsys4,
    output reg [WID-1:0] pp_H_out
);

always @ (counter)
    case(counter)
        2'd0    : pp_H_out<=Hsys1;
        2'd1    : pp_H_out<=Hsys2;
        2'd2    : pp_H_out<=Hsys3;
        2'd3    : pp_H_out<=Hsys4;
    endcase
end

endmodule


module GSM_PPT #(
    parameter WIDTH=18,
    parameter LENGTH=101,