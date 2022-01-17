module sine_filt (
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
always @ (posedge clk)
    if (reset) begin
        for (i=0; i<=20; i=i+1)
            x[i] = 18'sd0;
	for (i=0; i<=10; i=i+1)
	    mult_out[i] = 36'sd0;
	for (i=0; i<=10; i=i+1)
	    sum_level_1[i] = 18'sd0;
	for (i=0; i<=5; i=i+1)
	    sum_level_2[i] = 18'sd0;
	for (i=0; i<=2; i=i+1)
	    sum_level_3[i] = 18'sd0;
	sum_level_4 = 18'sd0;
    end
    else begin
	    x[0] = $signed( {x_in[17], x_in[17:1]} ); 
    end

//x_in[i] is 2s16
always @ (posedge clk)
    begin
        for(i=1; i<21;i=i+1)
            x[i] <= $signed( x[i-1] );
    end


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ *
    for(i=0;i<=9;i=i+1)
        sum_level_1[i] = $signed(x[i])+$signed(x[20-i]);

always @ *
    sum_level_1[10] = $signed(x[10]);


// always @ (posedge clk)
always @ *
    for(i=0;i<=10; i=i+1)
	 //should be 2s34 (2s16*0s18)
        mult_out[i] = $signed(sum_level_1[i]) * $signed(b[i]);


//Try sum_level_2 to 1s17 since mult_out will never be close to 1 from b[i]
always @ *
    for(i=0;i<=4;i=i+1)
        sum_level_2[i] = $signed( mult_out[2*i][34:17] ) + $signed( mult_out[2*i+1][34:17] );

always @ *
    sum_level_2[5] = $signed(mult_out[10][34:17]);


always @ *
    for(i=0;i<=2;i=i+1)
        sum_level_3[i] = $signed(sum_level_2[2*i]) + $signed(sum_level_2[2*i+1]);
			
always @ *
    sum_level_4 = $signed(sum_level_3[0]) + $signed(sum_level_3[1]) + $signed(sum_level_3[2]);

always @ (posedge clk)
    y = $signed(sum_level_4);

	
//always @ *
initial
   begin
		b[0] = 18'sd4091;
		b[1] = 18'sd5895;
		b[2] = 18'sd3323;
		b[3] = -18'sd3445;
		b[4] = -18'sd10669;
		b[5] = -18'sd12449;
		b[6] = -18'sd4024;
		b[7] = 18'sd14901;
		b[8] = 18'sd38953;
		b[9] = 18'sd59086;
		b[10] = 18'sd66926;
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

