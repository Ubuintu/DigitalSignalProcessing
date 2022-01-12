module pulse_shaping_filter (
          input clk,
		   input signed [17:0] x_in,
		   output reg signed [17:0] y   );
integer i;

//---------------------------------------------
// Comment these lines of code before you begin
//	always@*
//	y <= x_in;
// Endo of line to comment
//---------------------------------------------

	
/*			3.1.12			*/
//(* noprune *) reg signed [17:0] add1, xD, xD1, xD2, xD3, xD4, xD5, xD6, xD7;
//always @ *
//	add1 = x_in + xD;
//	
////first delay is an acc
//always @ (posedge clk)
//	xD = add1;
//	
////Chain of delays
//always @ (posedge clk)
//	xD1 = xD;
//always @ (posedge clk)
//	xD2 = xD1;
//always @ (posedge clk)
//	xD3 = xD2;
//always @ (posedge clk)
//	xD4 = xD3;
//always @ (posedge clk)
//	xD5 = xD4;
//always @ (posedge clk)
//	xD6 = xD5;
//always @ (posedge clk)
//	xD7 = xD6;
//	
////final adder
//always @ (posedge clk)
//	y = add1 - xD7;
	
/*				3.1.19			*/
integer j;		
//b is a 1d vector with 16 elements, each element is 18 bits wide
reg signed [17:0]	b[3:0];				 
reg signed [17:0]	x[7:0];	
reg signed [35:0] mult_out[3:0];
reg signed [17:0] sum_level_1[3:0];
reg signed [17:0] sum_level_2[1:0];
reg signed [17:0] sum_level_3;


always @ (posedge clk)
	x[0] = { x_in[17], x_in[17:1]};	// sign extend input to 2s16
//	x[0] = x_in;	//leave input as 1s17?

//This is a chain of 8 delayed registers one after the other as seen in Lab 2 from EE461
always @ (posedge clk)
	begin
		for(j=1; j<8;j=j+1)
			x[j] <= x[j-1];
	end

//This is where the registers with common coefficiencts are summed together | EE461 Lab 2 p.6 
always @ *
	for(j=0;j<=3;j=j+1)
		sum_level_1[j] = x[j]+x[7-j];


//Multiple the registers with the same coeff w/their respective coeff | EE461 Lab 2 p.6  
always @ *
	//4.1.10b
//always @ (posedge clk)
	for(j=0;j<=3; j=j+1)
		mult_out[j] = sum_level_1[j] * b[j];

////Sum the first adder row of registers; output of multipliers are trimmed from 3s33 -> 2s16 | EE461 Lab 2 p.7
always @ *
	for(j=0;j<=1;j=j+1)
		sum_level_2[j] = mult_out[2*j][33:18] + mult_out[2*j+1][33:18];

//Sum the last adder row of registers to get y[n] | EE461 Lab 2 p.7
always @ *
	sum_level_3 = sum_level_2[0] + sum_level_2[1];

always @ (posedge clk)
	y = sum_level_3;

// These are the coefficients; should be found via matlab
always @ *
   begin
   b[0] =  18'sd   39909;
   b[1] =  18'sd   113652;
   b[2] =  18'sd   170092;
   b[3] =  18'sd	 200638;
   end


endmodule
