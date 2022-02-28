module pulseshaping_filter ( input sys_clk,
          input clk_ena,
			 input [2:0]coeff_sel,
		   input signed [17:0] x_in, //1s17
		   output reg signed [17:0] y //1s17
			);
			

integer i;	
reg signed [17:0]	b[15:0];				 
reg signed [17:0]	x[30:0];	
reg signed [35:0] mult_out[15:0];
reg signed [17:0] sum_level_1[15:0];
reg signed [17:0] sum_level_2[7:0];
reg signed [17:0] sum_level_3[3:0];
reg signed [17:0] sum_level_4[1:0];
reg signed [17:0] sum_level_5;


always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		x[0] = {x_in[17], x_in[17:1]}; //2s17

always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		begin
			for(i=1; i<31;i=i+1)
				x[i] <= x[i-1];
		end


always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
	begin
		for(i=0;i<=14;i=i+1)
		sum_level_1[i] = x[i]+x[30-i]; //2s17 - need room to add both coefficients togther
	end

always@ (posedge sys_clk)
	if (clk_ena == 1'b1)
		sum_level_1[15] = x[15]; //2s17


always @ *
for(i=0;i<=15; i=i+1)
	mult_out[i] = sum_level_1[i] * b[i]; //2s17 * 1s17 = 3s34


 always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		begin
			for(i=0;i<=7;i=i+1)
				sum_level_2[i] = mult_out[2*i][33:16] + mult_out[2*i+1][33:16]; //1s17 + 1s17
		end



always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		begin
			for(i=0;i<=3;i=i+1)
				sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];
		end


always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		begin
			for(i=0;i<=1;i=i+1)
				sum_level_4[i] = sum_level_3[2*i] + sum_level_3[2*i+1];
		end
		

always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		begin
			sum_level_5 = sum_level_4[0] + sum_level_4[1];
		end
		
always @ (posedge sys_clk)
	if (clk_ena == 1'b1)
		y = sum_level_5;

//==========================================================
// Filter coefficients go here
//		enter your coefficients into the case statement below
//==========================================================

always @ *

	case(coeff_sel)
		3'd0: begin  // length 9 - scaling 1
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = -18'sd6305;
			b[12] = 18'sd23347;
			b[13] = 18'sd61031;
			b[14] = 18'sd92574;
			b[15] = 18'sd104858;
		end
		3'd1: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd2: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd3: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd4: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd5: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd6: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
		3'd7: begin
			b[0] = 18'sd0;
			b[1] = 18'sd0;
			b[2] = 18'sd0;
			b[3] = 18'sd0;
			b[4] = 18'sd0;
			b[5] = 18'sd0;
			b[6] = 18'sd0;
			b[7] = 18'sd0;
			b[8] = 18'sd0;
			b[9] = 18'sd0;
			b[10] = 18'sd0;
			b[11] = 18'sd0;
			b[12] = 18'sd0;
			b[13] = 18'sd0;
			b[14] = 18'sd0;
			b[15] = 18'sd0;
		end
	endcase
	
endmodule	
	