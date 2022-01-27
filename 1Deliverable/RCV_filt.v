module RCV_filt (
          input clk, reset,
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
//coeff is 0s18
reg signed [17:0]	b[10:0];	
//input is 1s17			 
reg signed [17:0]	x[20:0];	
(* noprune *) reg signed [35:0] mult_out[10:0];
(* noprune *) reg signed [17:0] sum_level_1[10:0];
(* noprune *) reg signed [17:0] sum_level_2[5:0];
(* noprune *) reg signed [17:0] sum_level_3[2:0];
(* noprune *) reg signed [17:0] sum_level_4;


//sign extend input to prevent overflow in sum_level_1
//always @ (posedge clk)    //for quartus
always @ *  //for modelSim
    if (reset) begin
			x[0] = 18'sd0;
    end
    else begin
	    x[0] = $signed( {x_in[17], x_in[17:1]} ); 
    end

//x_in[i] is 2s16
always @ (posedge clk)
    if (reset) begin
        for(i=1; i<21;i=i+1)
            x[i] <= 18'sd0;
    end
    else begin
        for(i=1; i<21;i=i+1)
            x[i] <= $signed( x[i-1] ); 
    end


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ *
    if (reset) begin
		 for(i=0;i<=9;i=i+1)
			  sum_level_1[i] = 18'sd0;
    end
    else begin
		 for(i=0;i<=9;i=i+1)
			  sum_level_1[i] = $signed(x[i])+$signed(x[20-i]);
    end

always @ *
    if (reset) sum_level_1[10] = 18'sd0;
	 else sum_level_1[10] = $signed(x[10]);


// always @ (posedge clk)
always @ *
    if (reset) begin
		 for(i=0;i<=10; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 35'sd0;
    end
    else begin
		 for(i=0;i<=10; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = $signed(sum_level_1[i]) * $signed(b[i]);
    end

//coeffs are 0s17, x[i] is 2s16
always @ *
    if (reset) begin
		 for(i=0;i<=4;i=i+1)
			  sum_level_2[i] = 18'sd0;
    end
    else begin
		 for(i=0;i<=4;i=i+1)
			  sum_level_2[i] = $signed( mult_out[2*i][34:17] ) + $signed( mult_out[2*i+1][34:17] );
    end

always @ *
    if (reset) sum_level_2[5] = 18'sd0;
	 else sum_level_2[5] = $signed(mult_out[10][34:17]);
    
always @ *
    if (reset) begin
		 for(i=0;i<=2;i=i+1)
			  sum_level_3[i] = 18'sd0;
    end
    else begin
		 for(i=0;i<=2;i=i+1)
			  sum_level_3[i] = $signed(sum_level_2[2*i]) + $signed(sum_level_2[2*i+1]);
    end
			
always @ *
    if (reset) sum_level_4 = 18'sd0;
	 else sum_level_4 = $signed(sum_level_3[0]) + $signed(sum_level_3[1]) + $signed(sum_level_3[2]);
    

always @ (posedge clk)
    if (reset) y = 18'sd0;
	 else y = $signed(sum_level_4);

	
//always @ *	//<- Don't use this especially in modelsim
initial
   begin

	b[0] = 18'sd2817;
	b[1] = 18'sd4060;
	b[2] = 18'sd2289;
	b[3] = -18'sd2373;
	b[4] = -18'sd7348;
	b[5] = -18'sd8574;
	b[6] = -18'sd2772;
	b[7] = 18'sd10263;
	b[8] = 18'sd26830;
	b[9] = 18'sd40696;
	b[10] = 18'sd46096;

   end

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

