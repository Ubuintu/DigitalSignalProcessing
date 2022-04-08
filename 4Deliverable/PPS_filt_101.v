module PPS_filt_101 #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter SUMLVL=7,
    parameter LENGTH=101,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter POSSMAPPER=7,
    parameter MAPSIZE=4,
    /* 46:0 first lvl regs; (46+1):(46+1+23-1+1) 2nd lvl; numbers in array count sym regs*/
//    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
	 parameter SUMLV1=51,
	 parameter SUMLV2=26,
	 parameter SUMLV3=13,
	 parameter SUMLV4=7,
	 parameter SUMLV5=4,
	 parameter SUMLV6=2,
	 parameter SUMLV7=1
    //parameter [7:0] POSSINPUTS [(POSSMAPPER+4)-1:0]={-18'sd98303,-18'sd65536,-18'sd32768,18'sd0,18'sd32768,18'sd65536,18'sd98303,-18'sd49152,-18'sd16384,18'sd16384,18'sd49152}
)
(
    input sys_clk, sam_clk_en, reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* noprune *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV2-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_3[SUMLV3-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_4[SUMLV4-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_5[SUMLV5-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_6[SUMLV6-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_7;
(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] tol;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[MAPSIZE:0][(LENGTH-1):0];

integer i,j;
initial begin
     tol=18'sd2;
//     for (i=0; i<SUMLV1; i=i+1)
//        sum_lvl_1[i]=18'sd0;
//     for (i=0; i<SUMLV2; i=i+1)
//        sum_lvl_2[i]=18'sd0;
//     for (i=0; i<SUMLV3; i=i+1)
//        sum_lvl_3[i]=18'sd0;
//     for (i=0; i<SUMLV4; i=i+1)
//        sum_lvl_4[i]=18'sd0;
//     for (i=0; i<SUMLV5; i=i+1)
//        sum_lvl_5[i]=18'sd0;
//     for (i=0; i<SUMLV6; i=i+1)
//        sum_lvl_6[i]=18'sd0;
//     sum_lvl_7=18'sd0;
//     for (i=0; i<LENGTH; i=i+1)
//        x[i]=18'sd0;
//     y = 18'sd0;
end

//scale 1s17->2s16 for summing
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else if (sam_clk_en) begin
//        //x[0]<=$signed( {x_in[17],x_in[17:1]} );
        x[0]<=$signed(x_in);
    end
    else
        x[0]<=$signed(x[0]);

always @ (posedge sys_clk)
    if (reset) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=$signed(x[i-1]);
    end
    else begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=$signed(x[i]);
    end


//always @ (posedge clk)
always @ *
    if (reset) begin
		 for(i=0;i<LENGTH; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for(i=0; i<LENGTH; i=i+1)
				 /*For verifying taps*/
				 if( x[i] == 18'sd131008 ) begin
					  mult_out[i] = Hsys[4][i];
					  //$display("%d %d",mult_out[i],Hsys[11][i]);
				 end
				 else if ( ( x[i]>(-18'sd98303-tol) ) && ( x[i]<(-18'sd98303+tol) ) ) mult_out[i] = Hsys[0][i];
				 else if ( ( x[i]>(-18'sd32768-tol) ) && ( x[i]<(-18'sd32768+tol) ) ) mult_out[i] = Hsys[1][i];
				 else if ( ( x[i]>(18'sd32768-tol) ) && ( x[i]<(18'sd32768+tol) ) ) mult_out[i] = Hsys[2][i];
				 else if ( ( x[i]>(18'sd98303-tol) ) && ( x[i]<(18'sd98303+tol) ) ) mult_out[i] = Hsys[3][i];
				 else mult_out[i] = 18'sd0;
    end


//always @ (posedge clk)


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= 18'sd0;
    end
    else if (sam_clk_en) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= $signed(mult_out[i])+$signed(mult_out[LENGTH-1-i]);
    end

//cntr
always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] <= $signed(mult_out[SUMLV1-1]);
	else sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);

//!!! SEE D3.m for structure of filter/center tap location !!!
/*          SUMLV2              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=$signed(sum_lvl_1[2*i])+$signed(sum_lvl_1[2*i+1]);
    end
//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(sum_lvl_1[SUMLV1-1]);

/*          SUMLV3              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end

/*          SUMLV4              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV4-1; i=i+1)
            sum_lvl_4[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV4-1; i=i+1)
            sum_lvl_4[i]<=$signed(sum_lvl_3[2*i])+$signed(sum_lvl_3[2*i+1]);
    end

//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_4[SUMLV4-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_4[SUMLV4-1]<=$signed(sum_lvl_3[SUMLV3-1]);


/*          SUMLV5              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV5-1; i=i+1)
            sum_lvl_5[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV5-1; i=i+1)
            sum_lvl_5[i]<=$signed(sum_lvl_4[2*i])+$signed(sum_lvl_4[2*i+1]);
    end

//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_5[SUMLV5-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_5[SUMLV5-1]<=$signed(sum_lvl_4[SUMLV4-1]);

/*          SUMLV6              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV6; i=i+1)
            sum_lvl_6[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV6; i=i+1)
            sum_lvl_6[i]<=$signed(sum_lvl_5[2*i])+$signed(sum_lvl_5[2*i+1]);
    end



/*          SUMLV7              */
always @ (posedge sys_clk)
    if (reset) sum_lvl_7 <= 18'sd0;
    else if (sam_clk_en) sum_lvl_7 <= $signed(sum_lvl_6[0])+$signed(sum_lvl_6[1]);



//always @ (posedge sys_clk)
//    if (reset) y<= 18'sd0;
//    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
//    else if (sam_clk_en) y<=$signed(sum_lvl_7);
//    else y<=$signed(y);
	 
//integer inte=0;
always @ (posedge sys_clk)
    if (reset) y<= 18'sd0;
    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
    else if (sam_clk_en) begin
		y<=$signed(sum_lvl_7);
//		$display("time: %t | y: %d",$time,y);
//		inte<=inte+1;
    end
    else y<=$signed(y);
	 
initial begin
	Hsys[0][0] = -18'sd46;
	Hsys[1][0] = -18'sd15;
	Hsys[2][0] = 18'sd15;
	Hsys[3][0] = 18'sd46;
	Hsys[4][0] = 18'sd62;
	Hsys[0][1] = -18'sd2;
	Hsys[1][1] = -18'sd1;
	Hsys[2][1] = 18'sd1;
	Hsys[3][1] = 18'sd2;
	Hsys[4][1] = 18'sd2;
	Hsys[0][2] = 18'sd48;
	Hsys[1][2] = 18'sd16;
	Hsys[2][2] = -18'sd16;
	Hsys[3][2] = -18'sd48;
	Hsys[4][2] = -18'sd65;
	Hsys[0][3] = 18'sd117;
	Hsys[1][3] = 18'sd39;
	Hsys[2][3] = -18'sd39;
	Hsys[3][3] = -18'sd117;
	Hsys[4][3] = -18'sd156;
	Hsys[0][4] = 18'sd165;
	Hsys[1][4] = 18'sd55;
	Hsys[2][4] = -18'sd55;
	Hsys[3][4] = -18'sd165;
	Hsys[4][4] = -18'sd220;
	Hsys[0][5] = 18'sd153;
	Hsys[1][5] = 18'sd51;
	Hsys[2][5] = -18'sd51;
	Hsys[3][5] = -18'sd153;
	Hsys[4][5] = -18'sd203;
	Hsys[0][6] = 18'sd64;
	Hsys[1][6] = 18'sd21;
	Hsys[2][6] = -18'sd21;
	Hsys[3][6] = -18'sd64;
	Hsys[4][6] = -18'sd85;
	Hsys[0][7] = -18'sd71;
	Hsys[1][7] = -18'sd24;
	Hsys[2][7] = 18'sd24;
	Hsys[3][7] = 18'sd71;
	Hsys[4][7] = 18'sd95;
	Hsys[0][8] = -18'sd183;
	Hsys[1][8] = -18'sd61;
	Hsys[2][8] = 18'sd61;
	Hsys[3][8] = 18'sd183;
	Hsys[4][8] = 18'sd244;
	Hsys[0][9] = -18'sd197;
	Hsys[1][9] = -18'sd66;
	Hsys[2][9] = 18'sd66;
	Hsys[3][9] = 18'sd197;
	Hsys[4][9] = 18'sd263;
	Hsys[0][10] = -18'sd84;
	Hsys[1][10] = -18'sd28;
	Hsys[2][10] = 18'sd28;
	Hsys[3][10] = 18'sd84;
	Hsys[4][10] = 18'sd112;
	Hsys[0][11] = 18'sd112;
	Hsys[1][11] = 18'sd37;
	Hsys[2][11] = -18'sd37;
	Hsys[3][11] = -18'sd112;
	Hsys[4][11] = -18'sd149;
	Hsys[0][12] = 18'sd279;
	Hsys[1][12] = 18'sd93;
	Hsys[2][12] = -18'sd93;
	Hsys[3][12] = -18'sd279;
	Hsys[4][12] = -18'sd372;
	Hsys[0][13] = 18'sd303;
	Hsys[1][13] = 18'sd101;
	Hsys[2][13] = -18'sd101;
	Hsys[3][13] = -18'sd303;
	Hsys[4][13] = -18'sd404;
	Hsys[0][14] = 18'sd137;
	Hsys[1][14] = 18'sd46;
	Hsys[2][14] = -18'sd46;
	Hsys[3][14] = -18'sd137;
	Hsys[4][14] = -18'sd183;
	Hsys[0][15] = -18'sd150;
	Hsys[1][15] = -18'sd50;
	Hsys[2][15] = 18'sd50;
	Hsys[3][15] = 18'sd150;
	Hsys[4][15] = 18'sd201;
	Hsys[0][16] = -18'sd398;
	Hsys[1][16] = -18'sd133;
	Hsys[2][16] = 18'sd133;
	Hsys[3][16] = 18'sd398;
	Hsys[4][16] = 18'sd530;
	Hsys[0][17] = -18'sd437;
	Hsys[1][17] = -18'sd146;
	Hsys[2][17] = 18'sd146;
	Hsys[3][17] = 18'sd437;
	Hsys[4][17] = 18'sd582;
	Hsys[0][18] = -18'sd203;
	Hsys[1][18] = -18'sd68;
	Hsys[2][18] = 18'sd68;
	Hsys[3][18] = 18'sd203;
	Hsys[4][18] = 18'sd271;
	Hsys[0][19] = 18'sd203;
	Hsys[1][19] = 18'sd68;
	Hsys[2][19] = -18'sd68;
	Hsys[3][19] = -18'sd203;
	Hsys[4][19] = -18'sd270;
	Hsys[0][20] = 18'sd549;
	Hsys[1][20] = 18'sd183;
	Hsys[2][20] = -18'sd183;
	Hsys[3][20] = -18'sd549;
	Hsys[4][20] = -18'sd732;
	Hsys[0][21] = 18'sd602;
	Hsys[1][21] = 18'sd201;
	Hsys[2][21] = -18'sd201;
	Hsys[3][21] = -18'sd602;
	Hsys[4][21] = -18'sd803;
	Hsys[0][22] = 18'sd279;
	Hsys[1][22] = 18'sd93;
	Hsys[2][22] = -18'sd93;
	Hsys[3][22] = -18'sd279;
	Hsys[4][22] = -18'sd372;
	Hsys[0][23] = -18'sd275;
	Hsys[1][23] = -18'sd92;
	Hsys[2][23] = 18'sd92;
	Hsys[3][23] = 18'sd275;
	Hsys[4][23] = 18'sd367;
	Hsys[0][24] = -18'sd741;
	Hsys[1][24] = -18'sd247;
	Hsys[2][24] = 18'sd247;
	Hsys[3][24] = 18'sd741;
	Hsys[4][24] = 18'sd988;
	Hsys[0][25] = -18'sd805;
	Hsys[1][25] = -18'sd268;
	Hsys[2][25] = 18'sd268;
	Hsys[3][25] = 18'sd805;
	Hsys[4][25] = 18'sd1073;
	Hsys[0][26] = -18'sd361;
	Hsys[1][26] = -18'sd120;
	Hsys[2][26] = 18'sd120;
	Hsys[3][26] = 18'sd361;
	Hsys[4][26] = 18'sd482;
	Hsys[0][27] = 18'sd382;
	Hsys[1][27] = 18'sd127;
	Hsys[2][27] = -18'sd127;
	Hsys[3][27] = -18'sd382;
	Hsys[4][27] = -18'sd510;
	Hsys[0][28] = 18'sd993;
	Hsys[1][28] = 18'sd331;
	Hsys[2][28] = -18'sd331;
	Hsys[3][28] = -18'sd993;
	Hsys[4][28] = -18'sd1324;
	Hsys[0][29] = 18'sd1055;
	Hsys[1][29] = 18'sd352;
	Hsys[2][29] = -18'sd352;
	Hsys[3][29] = -18'sd1055;
	Hsys[4][29] = -18'sd1407;
	Hsys[0][30] = 18'sd445;
	Hsys[1][30] = 18'sd148;
	Hsys[2][30] = -18'sd148;
	Hsys[3][30] = -18'sd445;
	Hsys[4][30] = -18'sd593;
	Hsys[0][31] = -18'sd548;
	Hsys[1][31] = -18'sd183;
	Hsys[2][31] = 18'sd183;
	Hsys[3][31] = 18'sd548;
	Hsys[4][31] = 18'sd730;
	Hsys[0][32] = -18'sd1338;
	Hsys[1][32] = -18'sd446;
	Hsys[2][32] = 18'sd446;
	Hsys[3][32] = 18'sd1338;
	Hsys[4][32] = 18'sd1784;
	Hsys[0][33] = -18'sd1379;
	Hsys[1][33] = -18'sd460;
	Hsys[2][33] = 18'sd460;
	Hsys[3][33] = 18'sd1379;
	Hsys[4][33] = 18'sd1839;
	Hsys[0][34] = -18'sd524;
	Hsys[1][34] = -18'sd175;
	Hsys[2][34] = 18'sd175;
	Hsys[3][34] = 18'sd524;
	Hsys[4][34] = 18'sd698;
	Hsys[0][35] = 18'sd819;
	Hsys[1][35] = 18'sd273;
	Hsys[2][35] = -18'sd273;
	Hsys[3][35] = -18'sd819;
	Hsys[4][35] = -18'sd1092;
	Hsys[0][36] = 18'sd1851;
	Hsys[1][36] = 18'sd617;
	Hsys[2][36] = -18'sd617;
	Hsys[3][36] = -18'sd1851;
	Hsys[4][36] = -18'sd2468;
	Hsys[0][37] = 18'sd1839;
	Hsys[1][37] = 18'sd613;
	Hsys[2][37] = -18'sd613;
	Hsys[3][37] = -18'sd1839;
	Hsys[4][37] = -18'sd2452;
	Hsys[0][38] = 18'sd592;
	Hsys[1][38] = 18'sd197;
	Hsys[2][38] = -18'sd197;
	Hsys[3][38] = -18'sd592;
	Hsys[4][38] = -18'sd790;
	Hsys[0][39] = -18'sd1307;
	Hsys[1][39] = -18'sd436;
	Hsys[2][39] = 18'sd436;
	Hsys[3][39] = 18'sd1307;
	Hsys[4][39] = 18'sd1742;
	Hsys[0][40] = -18'sd2732;
	Hsys[1][40] = -18'sd911;
	Hsys[2][40] = 18'sd911;
	Hsys[3][40] = 18'sd2732;
	Hsys[4][40] = 18'sd3642;
	Hsys[0][41] = -18'sd2616;
	Hsys[1][41] = -18'sd872;
	Hsys[2][41] = 18'sd872;
	Hsys[3][41] = 18'sd2616;
	Hsys[4][41] = 18'sd3489;
	Hsys[0][42] = -18'sd646;
	Hsys[1][42] = -18'sd215;
	Hsys[2][42] = 18'sd215;
	Hsys[3][42] = 18'sd646;
	Hsys[4][42] = 18'sd861;
	Hsys[0][43] = 18'sd2371;
	Hsys[1][43] = 18'sd790;
	Hsys[2][43] = -18'sd790;
	Hsys[3][43] = -18'sd2371;
	Hsys[4][43] = -18'sd3161;
	Hsys[0][44] = 18'sd4709;
	Hsys[1][44] = 18'sd1570;
	Hsys[2][44] = -18'sd1570;
	Hsys[3][44] = -18'sd4709;
	Hsys[4][44] = -18'sd6279;
	Hsys[0][45] = 18'sd4495;
	Hsys[1][45] = 18'sd1498;
	Hsys[2][45] = -18'sd1498;
	Hsys[3][45] = -18'sd4495;
	Hsys[4][45] = -18'sd5993;
	Hsys[0][46] = 18'sd680;
	Hsys[1][46] = 18'sd227;
	Hsys[2][46] = -18'sd227;
	Hsys[3][46] = -18'sd680;
	Hsys[4][46] = -18'sd906;
	Hsys[0][47] = -18'sd6270;
	Hsys[1][47] = -18'sd2090;
	Hsys[2][47] = 18'sd2090;
	Hsys[3][47] = 18'sd6270;
	Hsys[4][47] = 18'sd8360;
	Hsys[0][48] = -18'sd14364;
	Hsys[1][48] = -18'sd4788;
	Hsys[2][48] = 18'sd4788;
	Hsys[3][48] = 18'sd14364;
	Hsys[4][48] = 18'sd19152;
	Hsys[0][49] = -18'sd20834;
	Hsys[1][49] = -18'sd6945;
	Hsys[2][49] = 18'sd6945;
	Hsys[3][49] = 18'sd20834;
	Hsys[4][49] = 18'sd27778;
	Hsys[0][50] = -18'sd23301;
	Hsys[1][50] = -18'sd7767;
	Hsys[2][50] = 18'sd7767;
	Hsys[3][50] = 18'sd23301;
	Hsys[4][50] = 18'sd31068;
	Hsys[0][51] = -18'sd20834;
	Hsys[1][51] = -18'sd6945;
	Hsys[2][51] = 18'sd6945;
	Hsys[3][51] = 18'sd20834;
	Hsys[4][51] = 18'sd27778;
	Hsys[0][52] = -18'sd14364;
	Hsys[1][52] = -18'sd4788;
	Hsys[2][52] = 18'sd4788;
	Hsys[3][52] = 18'sd14364;
	Hsys[4][52] = 18'sd19152;
	Hsys[0][53] = -18'sd6270;
	Hsys[1][53] = -18'sd2090;
	Hsys[2][53] = 18'sd2090;
	Hsys[3][53] = 18'sd6270;
	Hsys[4][53] = 18'sd8360;
	Hsys[0][54] = 18'sd680;
	Hsys[1][54] = 18'sd227;
	Hsys[2][54] = -18'sd227;
	Hsys[3][54] = -18'sd680;
	Hsys[4][54] = -18'sd906;
	Hsys[0][55] = 18'sd4495;
	Hsys[1][55] = 18'sd1498;
	Hsys[2][55] = -18'sd1498;
	Hsys[3][55] = -18'sd4495;
	Hsys[4][55] = -18'sd5993;
	Hsys[0][56] = 18'sd4709;
	Hsys[1][56] = 18'sd1570;
	Hsys[2][56] = -18'sd1570;
	Hsys[3][56] = -18'sd4709;
	Hsys[4][56] = -18'sd6279;
	Hsys[0][57] = 18'sd2371;
	Hsys[1][57] = 18'sd790;
	Hsys[2][57] = -18'sd790;
	Hsys[3][57] = -18'sd2371;
	Hsys[4][57] = -18'sd3161;
	Hsys[0][58] = -18'sd646;
	Hsys[1][58] = -18'sd215;
	Hsys[2][58] = 18'sd215;
	Hsys[3][58] = 18'sd646;
	Hsys[4][58] = 18'sd861;
	Hsys[0][59] = -18'sd2616;
	Hsys[1][59] = -18'sd872;
	Hsys[2][59] = 18'sd872;
	Hsys[3][59] = 18'sd2616;
	Hsys[4][59] = 18'sd3489;
	Hsys[0][60] = -18'sd2732;
	Hsys[1][60] = -18'sd911;
	Hsys[2][60] = 18'sd911;
	Hsys[3][60] = 18'sd2732;
	Hsys[4][60] = 18'sd3642;
	Hsys[0][61] = -18'sd1307;
	Hsys[1][61] = -18'sd436;
	Hsys[2][61] = 18'sd436;
	Hsys[3][61] = 18'sd1307;
	Hsys[4][61] = 18'sd1742;
	Hsys[0][62] = 18'sd592;
	Hsys[1][62] = 18'sd197;
	Hsys[2][62] = -18'sd197;
	Hsys[3][62] = -18'sd592;
	Hsys[4][62] = -18'sd790;
	Hsys[0][63] = 18'sd1839;
	Hsys[1][63] = 18'sd613;
	Hsys[2][63] = -18'sd613;
	Hsys[3][63] = -18'sd1839;
	Hsys[4][63] = -18'sd2452;
	Hsys[0][64] = 18'sd1851;
	Hsys[1][64] = 18'sd617;
	Hsys[2][64] = -18'sd617;
	Hsys[3][64] = -18'sd1851;
	Hsys[4][64] = -18'sd2468;
	Hsys[0][65] = 18'sd819;
	Hsys[1][65] = 18'sd273;
	Hsys[2][65] = -18'sd273;
	Hsys[3][65] = -18'sd819;
	Hsys[4][65] = -18'sd1092;
	Hsys[0][66] = -18'sd524;
	Hsys[1][66] = -18'sd175;
	Hsys[2][66] = 18'sd175;
	Hsys[3][66] = 18'sd524;
	Hsys[4][66] = 18'sd698;
	Hsys[0][67] = -18'sd1379;
	Hsys[1][67] = -18'sd460;
	Hsys[2][67] = 18'sd460;
	Hsys[3][67] = 18'sd1379;
	Hsys[4][67] = 18'sd1839;
	Hsys[0][68] = -18'sd1338;
	Hsys[1][68] = -18'sd446;
	Hsys[2][68] = 18'sd446;
	Hsys[3][68] = 18'sd1338;
	Hsys[4][68] = 18'sd1784;
	Hsys[0][69] = -18'sd548;
	Hsys[1][69] = -18'sd183;
	Hsys[2][69] = 18'sd183;
	Hsys[3][69] = 18'sd548;
	Hsys[4][69] = 18'sd730;
	Hsys[0][70] = 18'sd445;
	Hsys[1][70] = 18'sd148;
	Hsys[2][70] = -18'sd148;
	Hsys[3][70] = -18'sd445;
	Hsys[4][70] = -18'sd593;
	Hsys[0][71] = 18'sd1055;
	Hsys[1][71] = 18'sd352;
	Hsys[2][71] = -18'sd352;
	Hsys[3][71] = -18'sd1055;
	Hsys[4][71] = -18'sd1407;
	Hsys[0][72] = 18'sd993;
	Hsys[1][72] = 18'sd331;
	Hsys[2][72] = -18'sd331;
	Hsys[3][72] = -18'sd993;
	Hsys[4][72] = -18'sd1324;
	Hsys[0][73] = 18'sd382;
	Hsys[1][73] = 18'sd127;
	Hsys[2][73] = -18'sd127;
	Hsys[3][73] = -18'sd382;
	Hsys[4][73] = -18'sd510;
	Hsys[0][74] = -18'sd361;
	Hsys[1][74] = -18'sd120;
	Hsys[2][74] = 18'sd120;
	Hsys[3][74] = 18'sd361;
	Hsys[4][74] = 18'sd482;
	Hsys[0][75] = -18'sd805;
	Hsys[1][75] = -18'sd268;
	Hsys[2][75] = 18'sd268;
	Hsys[3][75] = 18'sd805;
	Hsys[4][75] = 18'sd1073;
	Hsys[0][76] = -18'sd741;
	Hsys[1][76] = -18'sd247;
	Hsys[2][76] = 18'sd247;
	Hsys[3][76] = 18'sd741;
	Hsys[4][76] = 18'sd988;
	Hsys[0][77] = -18'sd275;
	Hsys[1][77] = -18'sd92;
	Hsys[2][77] = 18'sd92;
	Hsys[3][77] = 18'sd275;
	Hsys[4][77] = 18'sd367;
	Hsys[0][78] = 18'sd279;
	Hsys[1][78] = 18'sd93;
	Hsys[2][78] = -18'sd93;
	Hsys[3][78] = -18'sd279;
	Hsys[4][78] = -18'sd372;
	Hsys[0][79] = 18'sd602;
	Hsys[1][79] = 18'sd201;
	Hsys[2][79] = -18'sd201;
	Hsys[3][79] = -18'sd602;
	Hsys[4][79] = -18'sd803;
	Hsys[0][80] = 18'sd549;
	Hsys[1][80] = 18'sd183;
	Hsys[2][80] = -18'sd183;
	Hsys[3][80] = -18'sd549;
	Hsys[4][80] = -18'sd732;
	Hsys[0][81] = 18'sd203;
	Hsys[1][81] = 18'sd68;
	Hsys[2][81] = -18'sd68;
	Hsys[3][81] = -18'sd203;
	Hsys[4][81] = -18'sd270;
	Hsys[0][82] = -18'sd203;
	Hsys[1][82] = -18'sd68;
	Hsys[2][82] = 18'sd68;
	Hsys[3][82] = 18'sd203;
	Hsys[4][82] = 18'sd271;
	Hsys[0][83] = -18'sd437;
	Hsys[1][83] = -18'sd146;
	Hsys[2][83] = 18'sd146;
	Hsys[3][83] = 18'sd437;
	Hsys[4][83] = 18'sd582;
	Hsys[0][84] = -18'sd398;
	Hsys[1][84] = -18'sd133;
	Hsys[2][84] = 18'sd133;
	Hsys[3][84] = 18'sd398;
	Hsys[4][84] = 18'sd530;
	Hsys[0][85] = -18'sd150;
	Hsys[1][85] = -18'sd50;
	Hsys[2][85] = 18'sd50;
	Hsys[3][85] = 18'sd150;
	Hsys[4][85] = 18'sd201;
	Hsys[0][86] = 18'sd137;
	Hsys[1][86] = 18'sd46;
	Hsys[2][86] = -18'sd46;
	Hsys[3][86] = -18'sd137;
	Hsys[4][86] = -18'sd183;
	Hsys[0][87] = 18'sd303;
	Hsys[1][87] = 18'sd101;
	Hsys[2][87] = -18'sd101;
	Hsys[3][87] = -18'sd303;
	Hsys[4][87] = -18'sd404;
	Hsys[0][88] = 18'sd279;
	Hsys[1][88] = 18'sd93;
	Hsys[2][88] = -18'sd93;
	Hsys[3][88] = -18'sd279;
	Hsys[4][88] = -18'sd372;
	Hsys[0][89] = 18'sd112;
	Hsys[1][89] = 18'sd37;
	Hsys[2][89] = -18'sd37;
	Hsys[3][89] = -18'sd112;
	Hsys[4][89] = -18'sd149;
	Hsys[0][90] = -18'sd84;
	Hsys[1][90] = -18'sd28;
	Hsys[2][90] = 18'sd28;
	Hsys[3][90] = 18'sd84;
	Hsys[4][90] = 18'sd112;
	Hsys[0][91] = -18'sd197;
	Hsys[1][91] = -18'sd66;
	Hsys[2][91] = 18'sd66;
	Hsys[3][91] = 18'sd197;
	Hsys[4][91] = 18'sd263;
	Hsys[0][92] = -18'sd183;
	Hsys[1][92] = -18'sd61;
	Hsys[2][92] = 18'sd61;
	Hsys[3][92] = 18'sd183;
	Hsys[4][92] = 18'sd244;
	Hsys[0][93] = -18'sd71;
	Hsys[1][93] = -18'sd24;
	Hsys[2][93] = 18'sd24;
	Hsys[3][93] = 18'sd71;
	Hsys[4][93] = 18'sd95;
	Hsys[0][94] = 18'sd64;
	Hsys[1][94] = 18'sd21;
	Hsys[2][94] = -18'sd21;
	Hsys[3][94] = -18'sd64;
	Hsys[4][94] = -18'sd85;
	Hsys[0][95] = 18'sd153;
	Hsys[1][95] = 18'sd51;
	Hsys[2][95] = -18'sd51;
	Hsys[3][95] = -18'sd153;
	Hsys[4][95] = -18'sd203;
	Hsys[0][96] = 18'sd165;
	Hsys[1][96] = 18'sd55;
	Hsys[2][96] = -18'sd55;
	Hsys[3][96] = -18'sd165;
	Hsys[4][96] = -18'sd220;
	Hsys[0][97] = 18'sd117;
	Hsys[1][97] = 18'sd39;
	Hsys[2][97] = -18'sd39;
	Hsys[3][97] = -18'sd117;
	Hsys[4][97] = -18'sd156;
	Hsys[0][98] = 18'sd48;
	Hsys[1][98] = 18'sd16;
	Hsys[2][98] = -18'sd16;
	Hsys[3][98] = -18'sd48;
	Hsys[4][98] = -18'sd65;
	Hsys[0][99] = -18'sd2;
	Hsys[1][99] = -18'sd1;
	Hsys[2][99] = 18'sd1;
	Hsys[3][99] = 18'sd2;
	Hsys[4][99] = 18'sd2;
	Hsys[0][100] = -18'sd46;
	Hsys[1][100] = -18'sd15;
	Hsys[2][100] = 18'sd15;
	Hsys[3][100] = 18'sd46;
	Hsys[4][100] = 18'sd62;
end

endmodule 
