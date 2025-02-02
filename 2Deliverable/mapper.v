module mapper_in (
    input [1:0] LFSR,
    output reg signed [17:0] map_out
    );

always @ (LFSR) begin
    case(LFSR)
        2'b00   : map_out = -18'sd98304;
        2'b01   : map_out = -18'sd32768;
        2'b11   : map_out = 18'sd32768;
        2'b10   : map_out = 18'sd98304;
    endcase
end


endmodule


module mapper_ref (
    input [1:0] slice,
    input signed [17:0] ref_lvl,
    output reg signed [17:0] map_out
    );


//ref_lvl = 2b (1s17); LS by 1 bit is division by 2 
(* keep *) reg signed [17:0] b;
(* keep *) reg signed [35:0] mult_out;

always @ *
    b = $signed(ref_lvl >>> 1);
	 
//3*2^15
always @ *
    mult_out = b * 18'sd98304;

always @ * begin
    case(slice)
        2'b00   : map_out = -$signed(mult_out[32:15]);
        2'b01   : map_out = -$signed(b);
        2'b11   : map_out = b;
        2'b10   : map_out = $signed(mult_out[32:15]);
    endcase
end


endmodule
