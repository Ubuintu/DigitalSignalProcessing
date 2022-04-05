module upConv(
    input signed [17:0] x_i,
    input signed [17:0] x_q,
    input sys_clk, reset,
    output reg [14:0] output_to_DAC,
    output reg signed [17:0] upConv_out
);

(* preserve *) reg [1:0] upConvCNT;

always @ (posedge sys_clk)
    if (reset)
        upConvCNT<=2'd0;
    else
        upConvCNT<=upConvCNT+2'd1;


always @ * 
    if (reset)
        upConv_out=18'sd0;
    else begin
        case (upConvCNT)
            2'd0 : upConv_out = $signed(x_i);
            2'd1 : upConv_out = -$signed(x_q); 
            2'd2 : upConv_out = -$signed(x_i);
            2'd3 : upConv_out = $signed(x_q); 
        endcase
    end

always @ *
    if (reset)
		  output_to_DAC=14'd0;
	 else
        output_to_DAC={~upConv_out[17],upConv_out[16:4]};

endmodule
