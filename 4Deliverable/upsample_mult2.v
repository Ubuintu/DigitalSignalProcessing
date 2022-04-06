module upsample_mult2 (
	input reset, sam_clk_en, sym_clk_en, sys_clk, tw_clk_en, clk_50,
	input signed[17:0] x_in,
	output reg signed[17:0] y
	);
	
integer i;
(* noprune *)reg signed [17:0]	b[3:0];		 
(* noprune *)reg signed [17:0]	x[6:0];	
(* noprune *)reg signed [17:0] sum_level_1[3:0];
(* noprune *)reg signed [35:0] mult_out[3:0];
(* noprune *)reg signed [17:0] sum_level_2[1:0];
(* noprune *)reg signed [17:0] sum_level_3, x_up; 
(* noprune *)reg up_counter;

//initial begin
//up_counter = 1'b0;
//x_up = 18'sd0;
//sum_level_2[0] = 18'sd0;
//sum_level_2[1] = 18'sd0;
//sum_level_3 = 18'sd0;
//end

// up counter changes on 25 MHz clk
always @ (posedge sys_clk)
		if (reset)
			up_counter <= 1'd0;
		else 
			up_counter <= ~up_counter;


always @ (posedge sys_clk)
	if (reset)
		x_up = 18'sd0;
	else if (up_counter == 1'd0)
		x_up = 18'sd0;
	else if (up_counter == 1'd1)
		x_up = x_in;
	else 
		x_up = x_up;


always @ (posedge sys_clk)
	if (reset)
		x[0] <= 18'sd0;
	else
	x[0] <= x_up;
	//	x[0] <= $signed({ x_up[17], x_up[17:1]});

// chain of 105 registers to cycle through x_in at each sample clk
always @ (posedge sys_clk)
	if (reset == 1'b1)
	begin
		for(i=1; i<7; i = i+1)
			x[i] <= 18'sd0;
	end
	else
//	else
	begin
		for(i=1; i<7; i = i+1)
			x[i] <= x[i-1];
	end

	
//sum the registers with common coefficients
always @ (posedge sys_clk)
	if (reset)
		begin
		for(i=0;i<=2;i=i+1)
			sum_level_1[i] <= 18'sd0;
		end
	else
		begin
		for(i=0;i<=2;i=i+1)
			sum_level_1[i] <= x[i] + x[6-i];
		end
	
//center reg
always @ (posedge sys_clk)
	if (reset)
		sum_level_1[3] <= 18'sd0;
	else
		sum_level_1[3] <= x[3];

	
// multiply inputs by coeff
always @ *
	for (i = 0; i <= 3; i = i + 1)	
		mult_out[i] = sum_level_1[i] * b[i];
	
// sums
always @ *
begin
	sum_level_2[0] = $signed(mult_out[0][34:17]) + $signed(mult_out[1][34:17]);
	sum_level_2[1] = $signed(mult_out[3][34:17]) + $signed(mult_out[2][34:17]);
//	sum_level_2[0] = $signed(mult_out[0][33:16]) + $signed(mult_out[1][33:16]);
//	sum_level_2[1] = $signed(mult_out[3][33:16]) + $signed(mult_out[2][33:16]);
end

always @ *
	sum_level_3 = sum_level_2[0] + sum_level_2[1];

	
// output y
always @ (posedge sys_clk)
	if (reset)
		y <= 18'sd0;
	else
		y <= sum_level_3;

//----------------------------------------------------------------
// Coefficients from MATLAB
//----------------------------------------------------------------
initial
begin
b[0] = -18'sd4744;
b[1] = 18'sd0;
b[2] = 18'sd37451;
b[3] = 18'sd65536;
end
endmodule 
