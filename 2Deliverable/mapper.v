module mapper_in (
    input [1:0] LFSR,
    output reg signed [17:0] map_out
    );

always @ (LFSR) begin
    case(LFSR)
        2'b00   : map_out = -18'sd131072;
        2'b01   : map_out = -18'sd43691;
        2'b11   : map_out = 18'sd43691;
        2'b10   : map_out = 18'sd131071;
    endcase
end


endmodule


module mapper_ref (
    input [1:0] slicer,
    input reg signed [17:0] ref_lvl,
    output reg signed [17:0] map_out
    );

(* noprune *) wire signed [17:0] b;

//ref_lvl is 2s16 -> b is 1s17
assign b = ref_lvl >>> 2;

always @ (LFSR) begin
    case(LFSR)
        2'b00   : map_out = -18'sd131072;
        2'b01   : map_out = -18'sd43691;
        2'b11   : map_out = 18'sd43691;
        2'b10   : map_out = 18'sd131071;
    endcase
end


endmodule
