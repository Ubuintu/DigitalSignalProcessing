module approx_brick_wall_filt (
          input clk,
			 input [4:2] SW,
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

always @ (posedge clk)
	begin
		for(i=1; i<31;i=i+1)
			x[i] <= x[i-1];
	end


always @ *
	for(i=0;i<=14;i=i+1)
		sum_level_1[i] = x[i]+x[30-i];

always @ *
	sum_level_1[15] = x[15];

// **** See lab 4's verilog files on structure ****
always @ (posedge clk)		//this was originally commented out, not sure if i should use it or not??
//always @ *
	for(i=0;i<=15; i=i+1)
		mult_out[i] = sum_level_1[i] * b[i];


always @ *
	for(i=0;i<=7;i=i+1)
		sum_level_2[i] = mult_out[2*i][34:17] + mult_out[2*i+1][34:17];



always @ *
	for(i=0;i<=3;i=i+1)
		sum_level_3[i] = sum_level_2[2*i] + sum_level_2[2*i+1];
			


always @ *
	for(i=0;i<=1;i=i+1)
		sum_level_4[i] = sum_level_3[2*i] + sum_level_3[2*i+1];


always @ *
	sum_level_5 = sum_level_4[0] + sum_level_4[1];

always @ (posedge clk)
y = sum_level_5;


//Lab 5
always @ *
	case(SW[4:2])
	
//Hann
   3'H0: begin
		b[0] =  18'sd   0;
		b[1] =  -18'sd   59;
		b[2] =  -18'sd   178;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   804;
		b[5] =   18'sd	  1891;
		b[6] =   18'sd   2053;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   4220;
		b[9] =  -18'sd   8252;
		b[10] = -18'sd   8023;
		b[11] =  18'sd		  0;
		b[12] =  18'sd  16127;
		b[13] =  18'sd  36187;
		b[14] =  18'sd  52904;
		b[15]=   18'sd  59411;
		end
		
//Kaiser equivalent of a Hann window
	3'H1: begin
		b[0] =  -18'sd   356;
		b[1] =  -18'sd   831;
		b[2] =  -18'sd   889;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   1757;
		b[5] =   18'sd	  3338;
		b[6] =   18'sd   3110;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   5235;
		b[9] =  -18'sd   9584;
		b[10] = -18'sd   8861;
		b[11] =  18'sd		  0;
		b[12] =  18'sd  16678;
		b[13] =  18'sd  36721;
		b[14] =  18'sd  53096;
		b[15]=   18'sd  59411;
		end

//Hamming
	3'H2: begin
		b[0] =  -18'sd   285;
		b[1] =  -18'sd   487;
		b[2] =  -18'sd   493;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   1129;
		b[5] =   18'sd	  2345;
		b[6] =   18'sd  2364;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   4494;
		b[9] =  -18'sd   8600;
		b[10] = -18'sd   8237;
		b[11] =  18'sd		  0;
		b[12] =  18'sd   16263;
		b[13] =  18'sd  36318;
		b[14] =  18'sd  52951;
		b[15]=   18'sd  59411;
		end
		
//Kaiser equivalent of a Hamming window
	3'H3: begin
		b[0] =  -18'sd   148;
		b[1] =  -18'sd   431;
		b[2] =  -18'sd   532;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   1267;
		b[5] =   18'sd	  2574;
		b[6] =   18'sd   2537;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   4655;
		b[9] =  -18'sd  8805;
		b[10] = -18'sd  8362;
		b[11] =  18'sd		  0;
		b[12] =  18'sd  16339;
		b[13] =  18'sd  36390;
		b[14] =  18'sd  52976;
		b[15]=   18'sd  59411;
		end

//Blackman
	3'H4: begin
		b[0] =  -18'sd   0;
		b[1] =  -18'sd   22;
		b[2] =  -18'sd   69;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   375;
		b[5] =   18'sd	  983;
		b[6] =   18'sd  1193;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   3011;
		b[9] =  -18'sd   6427;
		b[10] = -18'sd   6740;
		b[11] =  18'sd		  0;
		b[12] =  18'sd   15141;
		b[13] =  18'sd  35186;
		b[14] =  18'sd  52534;
		b[15]=   18'sd  59411;
		end
		
//Kaiser equivalent of a Blackman window
	3'H5: begin
		b[0] =  -18'sd   20;
		b[1] =  -18'sd   104;
		b[2] =  -18'sd   175;
		b[3] =   18'sd		  0;
		b[4] =   18'sd   626;
		b[5] =   18'sd	  1470;
		b[6] =   18'sd   1634;
		b[7] =   18'sd		  0;
		b[8] =  -18'sd   3612;
		b[9] =  -18'sd   7331;
		b[10] = -18'sd   7375;
		b[11] =  18'sd		  0;
		b[12] =  18'sd  15631;
		b[13] =  18'sd  35684;
		b[14] =  18'sd  52718;
		b[15]=   18'sd  59411;
		end

//Rectangular
	3'H6: begin
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
		
//Kaiser window for pre-lab design filter
	3'H7: begin
		b[0] =  18'sd   0;
		b[1] =  18'sd   518;
		b[2] =  18'sd   1343;
		b[3] =   18'sd		1569;
		b[4] =   18'sd  0;
		b[5] =   -18'sd	3603;
		b[6] =   -18'sd   7352;
		b[7] =   -18'sd		  7408;
		b[8] =  18'sd   0;
		b[9] =  18'sd  15673;
		b[10] = 18'sd  35732;
		b[11] =  18'sd		52737;
		b[12] =  18'sd  59411;
		b[13] =  18'sd  52737;
		b[14] =  18'sd  35732;
		b[15]=   18'sd  15673;
		end
		
endcase

/* for debugging
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
	