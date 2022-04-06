module upConv(
    input signed [17:0] x_i,
    input signed [17:0] x_q,
    input sys_clk, reset,
    output reg [13:0] output_to_DAC,
    output reg signed [17:0] upConv_out
);

(* preserve *) reg [1:0] upConvCNT;
(* preserve *) reg signed [17:0] x_i_delayed, x_q_delayed;

always @ (posedge sys_clk)
    if (reset)
        upConvCNT<=2'd0;
    else
        upConvCNT<=upConvCNT+2'd1;

always @ (posedge sys_clk)
	if (reset) begin
		x_i_delayed<=18'sd0;
	end
	else begin
		x_i_delayed<=x_i;
	end

always @ (posedge sys_clk)
	if (reset) begin
		x_q_delayed<=18'sd0;
	end
	else begin
		x_q_delayed<=x_q;
	end

always @ * 
    begin
        case (upConvCNT)
            2'd0 : upConv_out = $signed(x_i_delayed);
            2'd1 : upConv_out = -$signed(x_q_delayed); 
            2'd2 : upConv_out = -$signed(x_i_delayed);
            2'd3 : upConv_out = $signed(x_q_delayed); 
        endcase
    end

always @ *
	output_to_DAC={~upConv_out[17],upConv_out[16:4]};

endmodule
