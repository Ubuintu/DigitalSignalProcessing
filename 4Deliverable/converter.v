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

/*------------Downconverter------------*/
module dnConv #(
    parameter DELAY=3
)
(
    input signed [17:0] tp2,
    input sys_clk, reset,
    input [1:0] SW,
    output reg [13:0] output_to_DAC_I, output_to_DAC_Q,
    output reg signed [17:0] I_out,Q_out
);

(* preserve *) reg [1:0] dnConvCNT;
(* preserve *) reg signed [17:0] x_i, x_q;
(* noprune *) reg signed [17:0] tp2_delay [DELAY-1:0];
integer i;

always @ (posedge sys_clk)
    if (reset)
        dnConvCNT<=2'd0;
    else
        dnConvCNT<=dnConvCNT+2'd1;

always @ (posedge sys_clk)
    for (i=0; i<DELAY; i=i+1)
        if (i==0)
            tp2_delay[i]<=tp2;
        else
            tp2_delay[i]<=tp2_delay[i-1];

reg signed [17:0] tp2_timed;
always @ *
    case (SW)
        2'd0: tp2_timed=tp2;
        2'd1: tp2_timed=tp2_delay[0];
        2'd2: tp2_timed=tp2_delay[1];
        2'd3: tp2_timed=tp2_delay[2];
    endcase

always @ *
	if (reset) begin
		x_i<=18'sd0;
	end
	else begin
		x_i<=tp2_timed;
	end

always @ *
	if (reset) begin
		x_q<=18'sd0;
	end
	else begin
		x_q<=tp2_timed;
	end

always @ * 
    begin
        case (dnConvCNT)
            2'd0 : I_out = $signed(x_i);
            2'd1 : I_out = 18'sd0; 
            2'd2 : I_out = -$signed(x_i);
            2'd3 : I_out = 18'sd0; 
        endcase
    end

always @ * 
    begin
        case (dnConvCNT)
            2'd0 : Q_out = 18'sd0;
            2'd1 : Q_out = -$signed(x_q);
            2'd2 : Q_out = 18'sd0;
            2'd3 : Q_out = $signed(x_q);
        endcase
    end

always @ *
	output_to_DAC_I={~I_out[17],I_out[16:4]};

always @ *
	output_to_DAC_Q={~Q_out[17],Q_out[16:4]};

endmodule
