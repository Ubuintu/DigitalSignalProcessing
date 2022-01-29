module TX_filt_MF (
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
integer i,j;	
//coeff is 0s18
//b array is 18 bits wide with 8 rows and 11 columns
reg signed [17:0]	b[7:0][10:0];	
//input is 1s17			 
reg signed [17:0]	x[20:0];	
(* noprune *) reg signed [17:0] mult_out[10:0];
(* noprune *) reg signed [17:0] sum_level_1[10:0];
(* noprune *) reg signed [17:0] sum_level_2[5:0];
(* noprune *) reg signed [17:0] sum_level_3[2:0];
(* noprune *) reg signed [17:0] sum_level_4, tol;

//tolerance of 10% of center coeff i.e. h(11)*0.1*2^17
initial begin
    tol = 18'sd5;
end


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
            x[i] = 18'sd0;
    end
    else begin
        for(i=1; i<21;i=i+1)
            x[i] = $signed( x[i-1] ); 
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


always @ (posedge clk)
//always @ *
    if (reset) begin
		 for(i=0;i<=10; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for(i=0; i<=10; i=i+1)
            //if( sum_level_1[i] == 18'sd0 ) mult_out[i] = 18'sd0;
            /* Given that FS input scaled down to 65535 */
            if( sum_level_1[i] == 18'sd65535 ) mult_out[i] = b[7][i];
            else if ( ( sum_level_1[i]>(-18'sd131072-tol) ) && ( sum_level_1[i]<(-18'sd131072+tol) ) ) mult_out[i] = b[0][i];
            else if ( ( sum_level_1[i]>(-18'sd87381-tol) ) && ( sum_level_1[i]<(-18'sd87381+tol) ) ) mult_out[i] = b[1][i];
            else if ( ( sum_level_1[i]>(-18'sd43690-tol) ) && ( sum_level_1[i]<(-18'sd43690+tol) ) ) mult_out[i] = b[2][i];
            else if ( ( sum_level_1[i]>(18'sd0-tol) ) && ( sum_level_1[i]<(18'sd0+tol) ) ) mult_out[i] = b[3][i];
            else if ( ( sum_level_1[i]>(18'sd43690-tol) ) && ( sum_level_1[i]<(18'sd43690+tol) ) ) mult_out[i] = b[4][i];
            else if ( ( sum_level_1[i]>(18'sd87381-tol) ) && ( sum_level_1[i]<(18'sd87381+tol) ) ) mult_out[i] = b[5][i];
            else if ( ( sum_level_1[i]>(18'sd131072-tol) ) && ( sum_level_1[i]<(18'sd131072+tol) ) ) mult_out[i] = b[6][i];
            /* Old else statement */
            //else mult_out[i] = b[7][i];
            /* Default all none intended values to 0 */
            else mult_out[i] = 18'sd0;
    end

//coeffs are 0s17, x[i] is 2s16
always @ *
    if (reset) begin
		 for(i=0;i<=4;i=i+1)
			  sum_level_2[i] = 18'sd0;
    end
    else begin
		 for(i=0;i<=4;i=i+1)
			  sum_level_2[i] = $signed( mult_out[2*i] ) + $signed( mult_out[2*i+1] );
    end

always @ *
    if (reset) sum_level_2[5] = 18'sd0;
	 else sum_level_2[5] = $signed(mult_out[10]);
    
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
	b[0][0] = -18'sd1194;
	b[1][0] = -18'sd796;
	b[2][0] = -18'sd398;
	b[4][0] = 18'sd398;
	b[5][0] = 18'sd796;
	b[6][0] = 18'sd1194;
	b[7][0] = 18'sd597;
	b[0][1] = -18'sd2452;
	b[1][1] = -18'sd1635;
	b[2][1] = -18'sd817;
	b[4][1] = 18'sd817;
	b[5][1] = 18'sd1635;
	b[6][1] = 18'sd2452;
	b[7][1] = 18'sd1226;
	b[0][2] = -18'sd1658;
	b[1][2] = -18'sd1105;
	b[2][2] = -18'sd553;
	b[4][2] = 18'sd553;
	b[5][2] = 18'sd1105;
	b[6][2] = 18'sd1658;
	b[7][2] = 18'sd829;
	b[0][3] = 18'sd3142;
	b[1][3] = 18'sd2095;
	b[2][3] = 18'sd1047;
	b[4][3] = -18'sd1047;
	b[5][3] = -18'sd2095;
	b[6][3] = -18'sd3142;
	b[7][3] = -18'sd1571;
	b[0][4] = 18'sd10432;
	b[1][4] = 18'sd6955;
	b[2][4] = 18'sd3477;
	b[4][4] = -18'sd3477;
	b[5][4] = -18'sd6955;
	b[6][4] = -18'sd10432;
	b[7][4] = -18'sd5216;
	b[0][5] = 18'sd13698;
	b[1][5] = 18'sd9132;
	b[2][5] = 18'sd4566;
	b[4][5] = -18'sd4566;
	b[5][5] = -18'sd9132;
	b[6][5] = -18'sd13698;
	b[7][5] = -18'sd6849;
	b[0][6] = 18'sd4326;
	b[1][6] = 18'sd2884;
	b[2][6] = 18'sd1442;
	b[4][6] = -18'sd1442;
	b[5][6] = -18'sd2884;
	b[6][6] = -18'sd4326;
	b[7][6] = -18'sd2163;
	b[0][7] = -18'sd21804;
	b[1][7] = -18'sd14536;
	b[2][7] = -18'sd7268;
	b[4][7] = 18'sd7268;
	b[5][7] = 18'sd14536;
	b[6][7] = 18'sd21804;
	b[7][7] = 18'sd10902;
	b[0][8] = -18'sd58858;
	b[1][8] = -18'sd39238;
	b[2][8] = -18'sd19619;
	b[4][8] = 18'sd19619;
	b[5][8] = 18'sd39238;
	b[6][8] = 18'sd58858;
	b[7][8] = 18'sd29429;
	b[0][9] = -18'sd91953;
	b[1][9] = -18'sd61302;
	b[2][9] = -18'sd30651;
	b[4][9] = 18'sd30651;
	b[5][9] = 18'sd61302;
	b[6][9] = 18'sd91953;
	b[7][9] = 18'sd45977;
	b[0][10] = -18'sd105245;
	b[1][10] = -18'sd70163;
	b[2][10] = -18'sd35082;
	b[4][10] = 18'sd35082;
	b[5][10] = 18'sd70163;
	b[6][10] = 18'sd105245;
	b[7][10] = 18'sd52623;
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
