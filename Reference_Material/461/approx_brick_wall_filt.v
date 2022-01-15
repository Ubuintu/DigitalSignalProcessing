module approx_brick_wall_filt (
          input clk,
		   input signed [17:0] x_in,
		   output reg signed [17:0] y   );
			
/*
reg signed [17:0] b0, b1, b2, b3, b4, b5, b6, b7,
                  b8, b9, b10, b11, b12, b13, b14, b15;
reg signed [17:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9,
                  x10, x11, x12, x13, x14, x15, x16, x17,
						x18, x19, 
						X20, X21, X2, X2, X2, X2, X2, 
						X2, X2, X2, 
*/
integer i;	
//b is a 1d vector with 16 elements, each element is 18 bits wide
reg signed [17:0]	b[15:0];				 
reg signed [17:0]	x[30:0];	
reg signed [35:0] mult_out[15:0];
reg signed [17:0] sum_level_1[15:0];
reg signed [17:0] sum_level_2[7:0];
reg signed [17:0] sum_level_3[3:0];
reg signed [17:0] sum_level_4[1:0];
reg signed [17:0] sum_level_5;


always @ (posedge clk)
	x[0] = { x_in[17], x_in[17:1]}; // sign extend input
//	x[0] = { {2{x_in[17]}}, x_in[17:1]}; // 4.1.9 sign extend input since dbled coeffs changes gain to 3s15

//This is a chain of 31 registers one after the other as seen on p.3 of the lab
always @ (posedge clk)
	begin
		for(i=1; i<31;i=i+1)
			x[i] <= x[i-1];
	end

//This is where the registers with common coefficiencts are summed together | p.6 
always @ *
	for(i=0;i<=14;i=i+1)
		sum_level_1[i] = x[i]+x[30-i];

//Since the total number of registers is odd, this is the center reg | p.6
always @ *
	sum_level_1[15] = x[15];


//Multiple the registers with the same coeff w/their respective coeff | p.6 
always @ *
	//4.1.10b
//always @ (posedge clk)
	for(i=0;i<=15; i=i+1)
		mult_out[i] = sum_level_1[i] * b[i];

////Sum the first adder row of registers; output of multipliers are trimmed from 3s33 -> 2s16 | p.7
always @ *
	for(i=0;i<=7;i=i+1)
//		sum_level_2[i] = mult_out[2*i][34:17] + mult_out[2*i+1][34:17];
//Another way to do 4.1.9; leave input as 2s16, coeff 1s17 -> 3s33 -> trim y to 3s15
		sum_level_2[i] = mult_out[2*i][35:18] + mult_out[2*i+1][35:18];


//Sum the second adder row of registers | p.7
always @ *
	for(i=0;i<=3;i=i+1)
		sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];
			

//Sum the third adder row of registers | p.7
always @ *
	for(i=0;i<=1;i=i+1)
		sum_level_4[i] = sum_level_3[2*i] + sum_level_3[2*i+1];

//Sum the last adder row of registers to get y[n] | p.7
always @ *
	sum_level_5 = sum_level_4[0] + sum_level_4[1];

always @ (posedge clk)
	y = sum_level_5;

// These are the coefficients; should be found via matlab
always @ *
   begin
   b[0] =  -18'sd   3566;
   b[1] =  -18'sd   5403;
   b[2] =  -18'sd   4114;
   b[3] =   18'sd		  0;
   b[4] =   18'sd   4863;
   b[5] =   18'sd	  7564;
   b[6] =   18'sd   5943;
   b[7] =   18'sd		  0;
   b[8] =  -18'sd   7641;
   b[9] =  -18'sd  12607;
   b[10] = -18'sd  10698;
   b[11] =  18'sd		  0;
   b[12] =  18'sd  17829;
   b[13] =  18'sd  37822;
   b[14] =  18'sd  53488;
   b[15]=   18'sd  59411;
   end

//// 4.1.9 dbl coeffs
//always @ *
//   begin
//   b[0] =  -18'sd   7132;
//   b[1] =  -18'sd  10806;
//   b[2] =  -18'sd   8229;
//   b[3] =   18'sd		  0;
//   b[4] =   18'sd   9725;
//   b[5] =   18'sd	  15129;
//   b[6] =   18'sd   11886;
//   b[7] =   18'sd		  0;
//   b[8] =  -18'sd   15282;
//   b[9] =  -18'sd   25215;
//   b[10] = -18'sd  21395;
//   b[11] =  18'sd		  0;
//   b[12] =  18'sd  35659;
//   b[13] =  18'sd  75644;
//   b[14] =  18'sd  106977;
//   b[15]=   18'sd  118821;
//   end

/* for debugging LITERALLY DOESNT WORK
always@ *
	for (i=0; i<=15; i=i+1)
		if (i==15) % center coefficient
			b[i] = 18'sd 131071; % almost 1 i.e. 1-2^(17)
	else b[i] =18'sd0; % other than center coefficient
*/

/* for debugging
always@ *
	for (i=0; i<=15; i=i+1)
		b[i] =18'sd 8192; % value of 1/16
*/
endmodule	
	