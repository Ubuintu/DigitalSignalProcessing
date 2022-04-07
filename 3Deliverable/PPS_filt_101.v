//module PPS_filt_101 #(
////Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
//    parameter WIDTH=18,
//    parameter SUMLVL=7,
//    parameter LENGTH=101,
//    //Matlab: N-sum(tapsPerlvl);
//    parameter OFFSET=2,
//    parameter POSSMAPPER=7,
//    parameter MAPSIZE=4,
//    /* 46:0 first lvl regs; (46+1):(46+1+23-1+1) 2nd lvl; numbers in array count sym regs*/
////    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
//	 parameter SUMLV1=51,
//	 parameter SUMLV2=26,
//	 parameter SUMLV3=13,
//	 parameter SUMLV4=7,
//	 parameter SUMLV5=4,
//	 parameter SUMLV6=2,
//	 parameter SUMLV7=1
//    //parameter [7:0] POSSINPUTS [(POSSMAPPER+4)-1:0]={-18'sd98303,-18'sd65536,-18'sd32768,18'sd0,18'sd32768,18'sd65536,18'sd98303,-18'sd49152,-18'sd16384,18'sd16384,18'sd49152}
//)
//(
//    input sys_clk, sam_clk_en, reset,
//    input signed [WIDTH-1:0] x_in,
//    output reg signed [WIDTH-1:0] y
//);
//
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV2-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_3[SUMLV3-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_4[SUMLV4-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_5[SUMLV5-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_6[SUMLV6-1:0];
//(* noprune *) reg signed [WIDTH-1:0] sum_lvl_7;
//(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1):0];
//(* noprune *) reg signed [WIDTH-1:0] tol;
//(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
//(* noprune *) reg signed [WIDTH-1:0] Hsys[MAPSIZE:0][(LENGTH-1):0];
//
//integer i,j;
//initial begin
//     tol=18'sd10;
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
////     for (i=0; i<SUMLV1; i=i+1)
////        mult_out[i]=18'sd0;
//     for (i=0; i<LENGTH; i=i+1)
//        x[i]=18'sd0;
//     y = 18'sd0;
//end
//
////scale 1s17->2s16 for summing
//always @ (posedge sys_clk)
//    if (reset) 
//        x[0]<=18'sd0;
//    else if (sam_clk_en) begin
//        //x[0]<=$signed( {x_in[17],x_in[17:1]} );
//        x[0]<=$signed(x_in);
//    end
//    else
//        x[0]<=$signed(x[0]);
//
//always @ (posedge sys_clk)
//    if (reset) begin
//        for(i=1; i<LENGTH; i=i+1)
//            x[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for(i=1; i<LENGTH; i=i+1)
//            x[i]<=$signed(x[i-1]);
//    end
//    else begin
//        for(i=1; i<LENGTH; i=i+1)
//            x[i]<=$signed(x[i]);
//    end
//
//
////always @ (posedge clk)
//always @ *
//    if (reset) begin
//		 for(i=0;i<LENGTH; i=i+1)
//		 //should be 2s34 (2s16*0s18)
//			  mult_out[i] = 18'sd0;
//    end
//    else begin
//        for(i=0; i<LENGTH; i=i+1)
//				 /*For verifying taps*/
//				 if( x[i] == 18'sd131008 ) begin
//					  mult_out[i] = Hsys[4][i];
//					  //$display("%d %d",mult_out[i],Hsys[11][i]);
//				 end
//				 else if ( ( x[i]>(-18'sd98303-tol) ) && ( x[i]<(-18'sd98303+tol) ) ) mult_out[i] = Hsys[0][i];
//				 else if ( ( x[i]>(-18'sd32768-tol) ) && ( x[i]<(-18'sd32768+tol) ) ) mult_out[i] = Hsys[1][i];
//				 else if ( ( x[i]>(18'sd32768-tol) ) && ( x[i]<(18'sd32768+tol) ) ) mult_out[i] = Hsys[2][i];
//				 else if ( ( x[i]>(18'sd98303-tol) ) && ( x[i]<(18'sd98303+tol) ) ) mult_out[i] = Hsys[3][i];
//				 else mult_out[i] = 18'sd0;
//    end
//
//
////always @ (posedge clk)
//
//
////1s17 + 1s17 will cause overflow for sum_lvl_1[i]
//always @ (posedge sys_clk)
//    if (reset) begin
//		 for(i=0;i<SUMLV1-1;i=i+1)
//			  sum_lvl_1[i] <= 18'sd0;
//    end
//    else if (sam_clk_en) begin
//		 for(i=0;i<SUMLV1-1;i=i+1)
//			  sum_lvl_1[i] <= $signed(mult_out[i])+$signed(mult_out[LENGTH-1-i]);
//    end
//
////cntr
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
//	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] <= $signed(mult_out[SUMLV1-1]);
//	else sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);
//
////!!! SEE D3.m for structure of filter/center tap location !!!
///*          SUMLV2              */
//always @ (posedge sys_clk)
//    if (reset) begin
//        for (i=0; i<SUMLV2-1; i=i+1)
//            sum_lvl_2[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for (i=0; i<SUMLV2-1; i=i+1)
//            sum_lvl_2[i]<=$signed(sum_lvl_1[2*i])+$signed(sum_lvl_1[2*i+1]);
//    end
////for center
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
//    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(sum_lvl_1[SUMLV1-1]);
//
///*          SUMLV3              */
//always @ (posedge sys_clk)
//    if (reset) begin
//        for (i=0; i<SUMLV3; i=i+1)
//            sum_lvl_3[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for (i=0; i<SUMLV3; i=i+1)
//            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
//    end
//
///*          SUMLV4              */
//always @ (posedge sys_clk)
//    if (reset) begin
//        for (i=0; i<SUMLV4-1; i=i+1)
//            sum_lvl_4[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for (i=0; i<SUMLV4-1; i=i+1)
//            sum_lvl_4[i]<=$signed(sum_lvl_3[2*i])+$signed(sum_lvl_3[2*i+1]);
//    end
//
////for center
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_4[SUMLV4-1] <= 18'sd0;
//    else if (sam_clk_en) sum_lvl_4[SUMLV4-1]<=$signed(sum_lvl_3[SUMLV3-1]);
//
//
///*          SUMLV5              */
//always @ (posedge sys_clk)
//    if (reset) begin
//        for (i=0; i<SUMLV5-1; i=i+1)
//            sum_lvl_5[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for (i=0; i<SUMLV5-1; i=i+1)
//            sum_lvl_5[i]<=$signed(sum_lvl_4[2*i])+$signed(sum_lvl_4[2*i+1]);
//    end
//
////for center
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_5[SUMLV5-1] <= 18'sd0;
//    else if (sam_clk_en) sum_lvl_5[SUMLV5-1]<=$signed(sum_lvl_4[SUMLV4-1]);
//
///*          SUMLV6              */
//always @ (posedge sys_clk)
//    if (reset) begin
//        for (i=0; i<SUMLV6; i=i+1)
//            sum_lvl_6[i]<=18'sd0;
//    end
//    else if (sam_clk_en) begin
//        for (i=0; i<SUMLV6; i=i+1)
//            sum_lvl_6[i]<=$signed(sum_lvl_5[2*i])+$signed(sum_lvl_5[2*i+1]);
//    end
//
//
//
///*          SUMLV7              */
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_7 <= 18'sd0;
//    else if (sam_clk_en) sum_lvl_7 <= $signed(sum_lvl_6[0])+$signed(sum_lvl_6[1]);
//
//
//
////always @ (posedge sys_clk)
////    if (reset) y<= 18'sd0;
////    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
////    else if (sam_clk_en) y<=$signed(sum_lvl_7);
////    else y<=$signed(y);
//	 
////integer inte=0;
//always @ (posedge sys_clk)
//    if (reset) y<= 18'sd0;
//    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
//    else if (sam_clk_en) begin
//		y<=$signed(sum_lvl_7);
////		$display("time: %t | y: %d",$time,y);
////		inte<=inte+1;
//    end
//    else y<=$signed(y);
//
///*
////more pwr BUT lower OB1
//initial begin
//	Hsys[0][0] = -18'sd100;
//	Hsys[1][0] = -18'sd33;
//	Hsys[2][0] = 18'sd33;
//	Hsys[3][0] = 18'sd100;
//	Hsys[4][0] = 18'sd134;
//	Hsys[0][1] = -18'sd4;
//	Hsys[1][1] = -18'sd1;
//	Hsys[2][1] = 18'sd1;
//	Hsys[3][1] = 18'sd4;
//	Hsys[4][1] = 18'sd5;
//	Hsys[0][2] = 18'sd105;
//	Hsys[1][2] = 18'sd35;
//	Hsys[2][2] = -18'sd35;
//	Hsys[3][2] = -18'sd105;
//	Hsys[4][2] = -18'sd140;
//	Hsys[0][3] = 18'sd254;
//	Hsys[1][3] = 18'sd85;
//	Hsys[2][3] = -18'sd85;
//	Hsys[3][3] = -18'sd254;
//	Hsys[4][3] = -18'sd338;
//	Hsys[0][4] = 18'sd359;
//	Hsys[1][4] = 18'sd120;
//	Hsys[2][4] = -18'sd120;
//	Hsys[3][4] = -18'sd359;
//	Hsys[4][4] = -18'sd478;
//	Hsys[0][5] = 18'sd332;
//	Hsys[1][5] = 18'sd111;
//	Hsys[2][5] = -18'sd111;
//	Hsys[3][5] = -18'sd332;
//	Hsys[4][5] = -18'sd442;
//	Hsys[0][6] = 18'sd139;
//	Hsys[1][6] = 18'sd46;
//	Hsys[2][6] = -18'sd46;
//	Hsys[3][6] = -18'sd139;
//	Hsys[4][6] = -18'sd185;
//	Hsys[0][7] = -18'sd154;
//	Hsys[1][7] = -18'sd51;
//	Hsys[2][7] = 18'sd51;
//	Hsys[3][7] = 18'sd154;
//	Hsys[4][7] = 18'sd206;
//	Hsys[0][8] = -18'sd397;
//	Hsys[1][8] = -18'sd132;
//	Hsys[2][8] = 18'sd132;
//	Hsys[3][8] = 18'sd397;
//	Hsys[4][8] = 18'sd530;
//	Hsys[0][9] = -18'sd428;
//	Hsys[1][9] = -18'sd143;
//	Hsys[2][9] = 18'sd143;
//	Hsys[3][9] = 18'sd428;
//	Hsys[4][9] = 18'sd571;
//	Hsys[0][10] = -18'sd182;
//	Hsys[1][10] = -18'sd61;
//	Hsys[2][10] = 18'sd61;
//	Hsys[3][10] = 18'sd182;
//	Hsys[4][10] = 18'sd242;
//	Hsys[0][11] = 18'sd242;
//	Hsys[1][11] = 18'sd81;
//	Hsys[2][11] = -18'sd81;
//	Hsys[3][11] = -18'sd242;
//	Hsys[4][11] = -18'sd323;
//	Hsys[0][12] = 18'sd607;
//	Hsys[1][12] = 18'sd202;
//	Hsys[2][12] = -18'sd202;
//	Hsys[3][12] = -18'sd607;
//	Hsys[4][12] = -18'sd809;
//	Hsys[0][13] = 18'sd659;
//	Hsys[1][13] = 18'sd220;
//	Hsys[2][13] = -18'sd220;
//	Hsys[3][13] = -18'sd659;
//	Hsys[4][13] = -18'sd878;
//	Hsys[0][14] = 18'sd298;
//	Hsys[1][14] = 18'sd99;
//	Hsys[2][14] = -18'sd99;
//	Hsys[3][14] = -18'sd298;
//	Hsys[4][14] = -18'sd397;
//	Hsys[0][15] = -18'sd327;
//	Hsys[1][15] = -18'sd109;
//	Hsys[2][15] = 18'sd109;
//	Hsys[3][15] = 18'sd327;
//	Hsys[4][15] = 18'sd436;
//	Hsys[0][16] = -18'sd865;
//	Hsys[1][16] = -18'sd288;
//	Hsys[2][16] = 18'sd288;
//	Hsys[3][16] = 18'sd865;
//	Hsys[4][16] = 18'sd1153;
//	Hsys[0][17] = -18'sd949;
//	Hsys[1][17] = -18'sd316;
//	Hsys[2][17] = 18'sd316;
//	Hsys[3][17] = 18'sd949;
//	Hsys[4][17] = 18'sd1266;
//	Hsys[0][18] = -18'sd441;
//	Hsys[1][18] = -18'sd147;
//	Hsys[2][18] = 18'sd147;
//	Hsys[3][18] = 18'sd441;
//	Hsys[4][18] = 18'sd588;
//	Hsys[0][19] = 18'sd440;
//	Hsys[1][19] = 18'sd147;
//	Hsys[2][19] = -18'sd147;
//	Hsys[3][19] = -18'sd440;
//	Hsys[4][19] = -18'sd587;
//	Hsys[0][20] = 18'sd1193;
//	Hsys[1][20] = 18'sd398;
//	Hsys[2][20] = -18'sd398;
//	Hsys[3][20] = -18'sd1193;
//	Hsys[4][20] = -18'sd1591;
//	Hsys[0][21] = 18'sd1309;
//	Hsys[1][21] = 18'sd436;
//	Hsys[2][21] = -18'sd436;
//	Hsys[3][21] = -18'sd1309;
//	Hsys[4][21] = -18'sd1746;
//	Hsys[0][22] = 18'sd607;
//	Hsys[1][22] = 18'sd202;
//	Hsys[2][22] = -18'sd202;
//	Hsys[3][22] = -18'sd607;
//	Hsys[4][22] = -18'sd809;
//	Hsys[0][23] = -18'sd599;
//	Hsys[1][23] = -18'sd200;
//	Hsys[2][23] = 18'sd200;
//	Hsys[3][23] = 18'sd599;
//	Hsys[4][23] = 18'sd798;
//	Hsys[0][24] = -18'sd1612;
//	Hsys[1][24] = -18'sd537;
//	Hsys[2][24] = 18'sd537;
//	Hsys[3][24] = 18'sd1612;
//	Hsys[4][24] = 18'sd2149;
//	Hsys[0][25] = -18'sd1749;
//	Hsys[1][25] = -18'sd583;
//	Hsys[2][25] = 18'sd583;
//	Hsys[3][25] = 18'sd1749;
//	Hsys[4][25] = 18'sd2333;
//	Hsys[0][26] = -18'sd785;
//	Hsys[1][26] = -18'sd262;
//	Hsys[2][26] = 18'sd262;
//	Hsys[3][26] = 18'sd785;
//	Hsys[4][26] = 18'sd1047;
//	Hsys[0][27] = 18'sd831;
//	Hsys[1][27] = 18'sd277;
//	Hsys[2][27] = -18'sd277;
//	Hsys[3][27] = -18'sd831;
//	Hsys[4][27] = -18'sd1109;
//	Hsys[0][28] = 18'sd2158;
//	Hsys[1][28] = 18'sd719;
//	Hsys[2][28] = -18'sd719;
//	Hsys[3][28] = -18'sd2158;
//	Hsys[4][28] = -18'sd2878;
//	Hsys[0][29] = 18'sd2294;
//	Hsys[1][29] = 18'sd765;
//	Hsys[2][29] = -18'sd765;
//	Hsys[3][29] = -18'sd2294;
//	Hsys[4][29] = -18'sd3059;
//	Hsys[0][30] = 18'sd966;
//	Hsys[1][30] = 18'sd322;
//	Hsys[2][30] = -18'sd322;
//	Hsys[3][30] = -18'sd966;
//	Hsys[4][30] = -18'sd1289;
//	Hsys[0][31] = -18'sd1191;
//	Hsys[1][31] = -18'sd397;
//	Hsys[2][31] = 18'sd397;
//	Hsys[3][31] = 18'sd1191;
//	Hsys[4][31] = 18'sd1588;
//	Hsys[0][32] = -18'sd2908;
//	Hsys[1][32] = -18'sd969;
//	Hsys[2][32] = 18'sd969;
//	Hsys[3][32] = 18'sd2908;
//	Hsys[4][32] = 18'sd3878;
//	Hsys[0][33] = -18'sd2998;
//	Hsys[1][33] = -18'sd999;
//	Hsys[2][33] = 18'sd999;
//	Hsys[3][33] = 18'sd2998;
//	Hsys[4][33] = 18'sd3997;
//	Hsys[0][34] = -18'sd1138;
//	Hsys[1][34] = -18'sd379;
//	Hsys[2][34] = 18'sd379;
//	Hsys[3][34] = 18'sd1138;
//	Hsys[4][34] = 18'sd1518;
//	Hsys[0][35] = 18'sd1780;
//	Hsys[1][35] = 18'sd593;
//	Hsys[2][35] = -18'sd593;
//	Hsys[3][35] = -18'sd1780;
//	Hsys[4][35] = -18'sd2373;
//	Hsys[0][36] = 18'sd4024;
//	Hsys[1][36] = 18'sd1341;
//	Hsys[2][36] = -18'sd1341;
//	Hsys[3][36] = -18'sd4024;
//	Hsys[4][36] = -18'sd5366;
//	Hsys[0][37] = 18'sd3997;
//	Hsys[1][37] = 18'sd1332;
//	Hsys[2][37] = -18'sd1332;
//	Hsys[3][37] = -18'sd3997;
//	Hsys[4][37] = -18'sd5329;
//	Hsys[0][38] = 18'sd1288;
//	Hsys[1][38] = 18'sd429;
//	Hsys[2][38] = -18'sd429;
//	Hsys[3][38] = -18'sd1288;
//	Hsys[4][38] = -18'sd1717;
//	Hsys[0][39] = -18'sd2841;
//	Hsys[1][39] = -18'sd947;
//	Hsys[2][39] = 18'sd947;
//	Hsys[3][39] = 18'sd2841;
//	Hsys[4][39] = 18'sd3788;
//	Hsys[0][40] = -18'sd5938;
//	Hsys[1][40] = -18'sd1979;
//	Hsys[2][40] = 18'sd1979;
//	Hsys[3][40] = 18'sd5938;
//	Hsys[4][40] = 18'sd7918;
//	Hsys[0][41] = -18'sd5688;
//	Hsys[1][41] = -18'sd1896;
//	Hsys[2][41] = 18'sd1896;
//	Hsys[3][41] = 18'sd5688;
//	Hsys[4][41] = 18'sd7584;
//	Hsys[0][42] = -18'sd1404;
//	Hsys[1][42] = -18'sd468;
//	Hsys[2][42] = 18'sd468;
//	Hsys[3][42] = 18'sd1404;
//	Hsys[4][42] = 18'sd1872;
//	Hsys[0][43] = 18'sd5154;
//	Hsys[1][43] = 18'sd1718;
//	Hsys[2][43] = -18'sd1718;
//	Hsys[3][43] = -18'sd5154;
//	Hsys[4][43] = -18'sd6872;
//	Hsys[0][44] = 18'sd10238;
//	Hsys[1][44] = 18'sd3413;
//	Hsys[2][44] = -18'sd3413;
//	Hsys[3][44] = -18'sd10238;
//	Hsys[4][44] = -18'sd13651;
//	Hsys[0][45] = 18'sd9772;
//	Hsys[1][45] = 18'sd3257;
//	Hsys[2][45] = -18'sd3257;
//	Hsys[3][45] = -18'sd9772;
//	Hsys[4][45] = -18'sd13029;
//	Hsys[0][46] = 18'sd1477;
//	Hsys[1][46] = 18'sd492;
//	Hsys[2][46] = -18'sd492;
//	Hsys[3][46] = -18'sd1477;
//	Hsys[4][46] = -18'sd1970;
//	Hsys[0][47] = -18'sd13630;
//	Hsys[1][47] = -18'sd4543;
//	Hsys[2][47] = 18'sd4543;
//	Hsys[3][47] = 18'sd13630;
//	Hsys[4][47] = 18'sd18174;
//	Hsys[0][48] = -18'sd31226;
//	Hsys[1][48] = -18'sd10409;
//	Hsys[2][48] = 18'sd10409;
//	Hsys[3][48] = 18'sd31226;
//	Hsys[4][48] = 18'sd41636;
//	Hsys[0][49] = -18'sd45290;
//	Hsys[1][49] = -18'sd15097;
//	Hsys[2][49] = 18'sd15097;
//	Hsys[3][49] = 18'sd45290;
//	Hsys[4][49] = 18'sd60388;
//	Hsys[0][50] = -18'sd50653;
//	Hsys[1][50] = -18'sd16884;
//	Hsys[2][50] = 18'sd16884;
//	Hsys[3][50] = 18'sd50653;
//	Hsys[4][50] = 18'sd67540;
//	Hsys[0][51] = -18'sd45290;
//	Hsys[1][51] = -18'sd15097;
//	Hsys[2][51] = 18'sd15097;
//	Hsys[3][51] = 18'sd45290;
//	Hsys[4][51] = 18'sd60388;
//	Hsys[0][52] = -18'sd31226;
//	Hsys[1][52] = -18'sd10409;
//	Hsys[2][52] = 18'sd10409;
//	Hsys[3][52] = 18'sd31226;
//	Hsys[4][52] = 18'sd41636;
//	Hsys[0][53] = -18'sd13630;
//	Hsys[1][53] = -18'sd4543;
//	Hsys[2][53] = 18'sd4543;
//	Hsys[3][53] = 18'sd13630;
//	Hsys[4][53] = 18'sd18174;
//	Hsys[0][54] = 18'sd1477;
//	Hsys[1][54] = 18'sd492;
//	Hsys[2][54] = -18'sd492;
//	Hsys[3][54] = -18'sd1477;
//	Hsys[4][54] = -18'sd1970;
//	Hsys[0][55] = 18'sd9772;
//	Hsys[1][55] = 18'sd3257;
//	Hsys[2][55] = -18'sd3257;
//	Hsys[3][55] = -18'sd9772;
//	Hsys[4][55] = -18'sd13029;
//	Hsys[0][56] = 18'sd10238;
//	Hsys[1][56] = 18'sd3413;
//	Hsys[2][56] = -18'sd3413;
//	Hsys[3][56] = -18'sd10238;
//	Hsys[4][56] = -18'sd13651;
//	Hsys[0][57] = 18'sd5154;
//	Hsys[1][57] = 18'sd1718;
//	Hsys[2][57] = -18'sd1718;
//	Hsys[3][57] = -18'sd5154;
//	Hsys[4][57] = -18'sd6872;
//	Hsys[0][58] = -18'sd1404;
//	Hsys[1][58] = -18'sd468;
//	Hsys[2][58] = 18'sd468;
//	Hsys[3][58] = 18'sd1404;
//	Hsys[4][58] = 18'sd1872;
//	Hsys[0][59] = -18'sd5688;
//	Hsys[1][59] = -18'sd1896;
//	Hsys[2][59] = 18'sd1896;
//	Hsys[3][59] = 18'sd5688;
//	Hsys[4][59] = 18'sd7584;
//	Hsys[0][60] = -18'sd5938;
//	Hsys[1][60] = -18'sd1979;
//	Hsys[2][60] = 18'sd1979;
//	Hsys[3][60] = 18'sd5938;
//	Hsys[4][60] = 18'sd7918;
//	Hsys[0][61] = -18'sd2841;
//	Hsys[1][61] = -18'sd947;
//	Hsys[2][61] = 18'sd947;
//	Hsys[3][61] = 18'sd2841;
//	Hsys[4][61] = 18'sd3788;
//	Hsys[0][62] = 18'sd1288;
//	Hsys[1][62] = 18'sd429;
//	Hsys[2][62] = -18'sd429;
//	Hsys[3][62] = -18'sd1288;
//	Hsys[4][62] = -18'sd1717;
//	Hsys[0][63] = 18'sd3997;
//	Hsys[1][63] = 18'sd1332;
//	Hsys[2][63] = -18'sd1332;
//	Hsys[3][63] = -18'sd3997;
//	Hsys[4][63] = -18'sd5329;
//	Hsys[0][64] = 18'sd4024;
//	Hsys[1][64] = 18'sd1341;
//	Hsys[2][64] = -18'sd1341;
//	Hsys[3][64] = -18'sd4024;
//	Hsys[4][64] = -18'sd5366;
//	Hsys[0][65] = 18'sd1780;
//	Hsys[1][65] = 18'sd593;
//	Hsys[2][65] = -18'sd593;
//	Hsys[3][65] = -18'sd1780;
//	Hsys[4][65] = -18'sd2373;
//	Hsys[0][66] = -18'sd1138;
//	Hsys[1][66] = -18'sd379;
//	Hsys[2][66] = 18'sd379;
//	Hsys[3][66] = 18'sd1138;
//	Hsys[4][66] = 18'sd1518;
//	Hsys[0][67] = -18'sd2998;
//	Hsys[1][67] = -18'sd999;
//	Hsys[2][67] = 18'sd999;
//	Hsys[3][67] = 18'sd2998;
//	Hsys[4][67] = 18'sd3997;
//	Hsys[0][68] = -18'sd2908;
//	Hsys[1][68] = -18'sd969;
//	Hsys[2][68] = 18'sd969;
//	Hsys[3][68] = 18'sd2908;
//	Hsys[4][68] = 18'sd3878;
//	Hsys[0][69] = -18'sd1191;
//	Hsys[1][69] = -18'sd397;
//	Hsys[2][69] = 18'sd397;
//	Hsys[3][69] = 18'sd1191;
//	Hsys[4][69] = 18'sd1588;
//	Hsys[0][70] = 18'sd966;
//	Hsys[1][70] = 18'sd322;
//	Hsys[2][70] = -18'sd322;
//	Hsys[3][70] = -18'sd966;
//	Hsys[4][70] = -18'sd1289;
//	Hsys[0][71] = 18'sd2294;
//	Hsys[1][71] = 18'sd765;
//	Hsys[2][71] = -18'sd765;
//	Hsys[3][71] = -18'sd2294;
//	Hsys[4][71] = -18'sd3059;
//	Hsys[0][72] = 18'sd2158;
//	Hsys[1][72] = 18'sd719;
//	Hsys[2][72] = -18'sd719;
//	Hsys[3][72] = -18'sd2158;
//	Hsys[4][72] = -18'sd2878;
//	Hsys[0][73] = 18'sd831;
//	Hsys[1][73] = 18'sd277;
//	Hsys[2][73] = -18'sd277;
//	Hsys[3][73] = -18'sd831;
//	Hsys[4][73] = -18'sd1109;
//	Hsys[0][74] = -18'sd785;
//	Hsys[1][74] = -18'sd262;
//	Hsys[2][74] = 18'sd262;
//	Hsys[3][74] = 18'sd785;
//	Hsys[4][74] = 18'sd1047;
//	Hsys[0][75] = -18'sd1749;
//	Hsys[1][75] = -18'sd583;
//	Hsys[2][75] = 18'sd583;
//	Hsys[3][75] = 18'sd1749;
//	Hsys[4][75] = 18'sd2333;
//	Hsys[0][76] = -18'sd1612;
//	Hsys[1][76] = -18'sd537;
//	Hsys[2][76] = 18'sd537;
//	Hsys[3][76] = 18'sd1612;
//	Hsys[4][76] = 18'sd2149;
//	Hsys[0][77] = -18'sd599;
//	Hsys[1][77] = -18'sd200;
//	Hsys[2][77] = 18'sd200;
//	Hsys[3][77] = 18'sd599;
//	Hsys[4][77] = 18'sd798;
//	Hsys[0][78] = 18'sd607;
//	Hsys[1][78] = 18'sd202;
//	Hsys[2][78] = -18'sd202;
//	Hsys[3][78] = -18'sd607;
//	Hsys[4][78] = -18'sd809;
//	Hsys[0][79] = 18'sd1309;
//	Hsys[1][79] = 18'sd436;
//	Hsys[2][79] = -18'sd436;
//	Hsys[3][79] = -18'sd1309;
//	Hsys[4][79] = -18'sd1746;
//	Hsys[0][80] = 18'sd1193;
//	Hsys[1][80] = 18'sd398;
//	Hsys[2][80] = -18'sd398;
//	Hsys[3][80] = -18'sd1193;
//	Hsys[4][80] = -18'sd1591;
//	Hsys[0][81] = 18'sd440;
//	Hsys[1][81] = 18'sd147;
//	Hsys[2][81] = -18'sd147;
//	Hsys[3][81] = -18'sd440;
//	Hsys[4][81] = -18'sd587;
//	Hsys[0][82] = -18'sd441;
//	Hsys[1][82] = -18'sd147;
//	Hsys[2][82] = 18'sd147;
//	Hsys[3][82] = 18'sd441;
//	Hsys[4][82] = 18'sd588;
//	Hsys[0][83] = -18'sd949;
//	Hsys[1][83] = -18'sd316;
//	Hsys[2][83] = 18'sd316;
//	Hsys[3][83] = 18'sd949;
//	Hsys[4][83] = 18'sd1266;
//	Hsys[0][84] = -18'sd865;
//	Hsys[1][84] = -18'sd288;
//	Hsys[2][84] = 18'sd288;
//	Hsys[3][84] = 18'sd865;
//	Hsys[4][84] = 18'sd1153;
//	Hsys[0][85] = -18'sd327;
//	Hsys[1][85] = -18'sd109;
//	Hsys[2][85] = 18'sd109;
//	Hsys[3][85] = 18'sd327;
//	Hsys[4][85] = 18'sd436;
//	Hsys[0][86] = 18'sd298;
//	Hsys[1][86] = 18'sd99;
//	Hsys[2][86] = -18'sd99;
//	Hsys[3][86] = -18'sd298;
//	Hsys[4][86] = -18'sd397;
//	Hsys[0][87] = 18'sd659;
//	Hsys[1][87] = 18'sd220;
//	Hsys[2][87] = -18'sd220;
//	Hsys[3][87] = -18'sd659;
//	Hsys[4][87] = -18'sd878;
//	Hsys[0][88] = 18'sd607;
//	Hsys[1][88] = 18'sd202;
//	Hsys[2][88] = -18'sd202;
//	Hsys[3][88] = -18'sd607;
//	Hsys[4][88] = -18'sd809;
//	Hsys[0][89] = 18'sd242;
//	Hsys[1][89] = 18'sd81;
//	Hsys[2][89] = -18'sd81;
//	Hsys[3][89] = -18'sd242;
//	Hsys[4][89] = -18'sd323;
//	Hsys[0][90] = -18'sd182;
//	Hsys[1][90] = -18'sd61;
//	Hsys[2][90] = 18'sd61;
//	Hsys[3][90] = 18'sd182;
//	Hsys[4][90] = 18'sd242;
//	Hsys[0][91] = -18'sd428;
//	Hsys[1][91] = -18'sd143;
//	Hsys[2][91] = 18'sd143;
//	Hsys[3][91] = 18'sd428;
//	Hsys[4][91] = 18'sd571;
//	Hsys[0][92] = -18'sd397;
//	Hsys[1][92] = -18'sd132;
//	Hsys[2][92] = 18'sd132;
//	Hsys[3][92] = 18'sd397;
//	Hsys[4][92] = 18'sd530;
//	Hsys[0][93] = -18'sd154;
//	Hsys[1][93] = -18'sd51;
//	Hsys[2][93] = 18'sd51;
//	Hsys[3][93] = 18'sd154;
//	Hsys[4][93] = 18'sd206;
//	Hsys[0][94] = 18'sd139;
//	Hsys[1][94] = 18'sd46;
//	Hsys[2][94] = -18'sd46;
//	Hsys[3][94] = -18'sd139;
//	Hsys[4][94] = -18'sd185;
//	Hsys[0][95] = 18'sd332;
//	Hsys[1][95] = 18'sd111;
//	Hsys[2][95] = -18'sd111;
//	Hsys[3][95] = -18'sd332;
//	Hsys[4][95] = -18'sd442;
//	Hsys[0][96] = 18'sd359;
//	Hsys[1][96] = 18'sd120;
//	Hsys[2][96] = -18'sd120;
//	Hsys[3][96] = -18'sd359;
//	Hsys[4][96] = -18'sd478;
//	Hsys[0][97] = 18'sd254;
//	Hsys[1][97] = 18'sd85;
//	Hsys[2][97] = -18'sd85;
//	Hsys[3][97] = -18'sd254;
//	Hsys[4][97] = -18'sd338;
//	Hsys[0][98] = 18'sd105;
//	Hsys[1][98] = 18'sd35;
//	Hsys[2][98] = -18'sd35;
//	Hsys[3][98] = -18'sd105;
//	Hsys[4][98] = -18'sd140;
//	Hsys[0][99] = -18'sd4;
//	Hsys[1][99] = -18'sd1;
//	Hsys[2][99] = 18'sd1;
//	Hsys[3][99] = 18'sd4;
//	Hsys[4][99] = 18'sd5;
//	Hsys[0][100] = -18'sd100;
//	Hsys[1][100] = -18'sd33;
//	Hsys[2][100] = 18'sd33;
//	Hsys[3][100] = 18'sd100;
//	Hsys[4][100] = 18'sd134;
//end
//*/
//
///*
////better OB1
//initial begin
//	Hsys[0][0] = -18'sd97;
//	Hsys[1][0] = -18'sd32;
//	Hsys[2][0] = 18'sd32;
//	Hsys[3][0] = 18'sd97;
//	Hsys[4][0] = 18'sd130;
//	Hsys[0][1] = -18'sd4;
//	Hsys[1][1] = -18'sd1;
//	Hsys[2][1] = 18'sd1;
//	Hsys[3][1] = 18'sd4;
//	Hsys[4][1] = 18'sd5;
//	Hsys[0][2] = 18'sd102;
//	Hsys[1][2] = 18'sd34;
//	Hsys[2][2] = -18'sd34;
//	Hsys[3][2] = -18'sd102;
//	Hsys[4][2] = -18'sd136;
//	Hsys[0][3] = 18'sd246;
//	Hsys[1][3] = 18'sd82;
//	Hsys[2][3] = -18'sd82;
//	Hsys[3][3] = -18'sd246;
//	Hsys[4][3] = -18'sd328;
//	Hsys[0][4] = 18'sd348;
//	Hsys[1][4] = 18'sd116;
//	Hsys[2][4] = -18'sd116;
//	Hsys[3][4] = -18'sd348;
//	Hsys[4][4] = -18'sd464;
//	Hsys[0][5] = 18'sd322;
//	Hsys[1][5] = 18'sd107;
//	Hsys[2][5] = -18'sd107;
//	Hsys[3][5] = -18'sd322;
//	Hsys[4][5] = -18'sd429;
//	Hsys[0][6] = 18'sd135;
//	Hsys[1][6] = 18'sd45;
//	Hsys[2][6] = -18'sd45;
//	Hsys[3][6] = -18'sd135;
//	Hsys[4][6] = -18'sd180;
//	Hsys[0][7] = -18'sd150;
//	Hsys[1][7] = -18'sd50;
//	Hsys[2][7] = 18'sd50;
//	Hsys[3][7] = 18'sd150;
//	Hsys[4][7] = 18'sd200;
//	Hsys[0][8] = -18'sd385;
//	Hsys[1][8] = -18'sd128;
//	Hsys[2][8] = 18'sd128;
//	Hsys[3][8] = 18'sd385;
//	Hsys[4][8] = 18'sd514;
//	Hsys[0][9] = -18'sd415;
//	Hsys[1][9] = -18'sd138;
//	Hsys[2][9] = 18'sd138;
//	Hsys[3][9] = 18'sd415;
//	Hsys[4][9] = 18'sd554;
//	Hsys[0][10] = -18'sd176;
//	Hsys[1][10] = -18'sd59;
//	Hsys[2][10] = 18'sd59;
//	Hsys[3][10] = 18'sd176;
//	Hsys[4][10] = 18'sd235;
//	Hsys[0][11] = 18'sd235;
//	Hsys[1][11] = 18'sd78;
//	Hsys[2][11] = -18'sd78;
//	Hsys[3][11] = -18'sd235;
//	Hsys[4][11] = -18'sd314;
//	Hsys[0][12] = 18'sd589;
//	Hsys[1][12] = 18'sd196;
//	Hsys[2][12] = -18'sd196;
//	Hsys[3][12] = -18'sd589;
//	Hsys[4][12] = -18'sd785;
//	Hsys[0][13] = 18'sd639;
//	Hsys[1][13] = 18'sd213;
//	Hsys[2][13] = -18'sd213;
//	Hsys[3][13] = -18'sd639;
//	Hsys[4][13] = -18'sd852;
//	Hsys[0][14] = 18'sd289;
//	Hsys[1][14] = 18'sd96;
//	Hsys[2][14] = -18'sd96;
//	Hsys[3][14] = -18'sd289;
//	Hsys[4][14] = -18'sd386;
//	Hsys[0][15] = -18'sd317;
//	Hsys[1][15] = -18'sd106;
//	Hsys[2][15] = 18'sd106;
//	Hsys[3][15] = 18'sd317;
//	Hsys[4][15] = 18'sd423;
//	Hsys[0][16] = -18'sd839;
//	Hsys[1][16] = -18'sd280;
//	Hsys[2][16] = 18'sd280;
//	Hsys[3][16] = 18'sd839;
//	Hsys[4][16] = 18'sd1119;
//	Hsys[0][17] = -18'sd921;
//	Hsys[1][17] = -18'sd307;
//	Hsys[2][17] = 18'sd307;
//	Hsys[3][17] = 18'sd921;
//	Hsys[4][17] = 18'sd1228;
//	Hsys[0][18] = -18'sd428;
//	Hsys[1][18] = -18'sd143;
//	Hsys[2][18] = 18'sd143;
//	Hsys[3][18] = 18'sd428;
//	Hsys[4][18] = 18'sd571;
//	Hsys[0][19] = 18'sd427;
//	Hsys[1][19] = 18'sd142;
//	Hsys[2][19] = -18'sd142;
//	Hsys[3][19] = -18'sd427;
//	Hsys[4][19] = -18'sd570;
//	Hsys[0][20] = 18'sd1158;
//	Hsys[1][20] = 18'sd386;
//	Hsys[2][20] = -18'sd386;
//	Hsys[3][20] = -18'sd1158;
//	Hsys[4][20] = -18'sd1543;
//	Hsys[0][21] = 18'sd1270;
//	Hsys[1][21] = 18'sd423;
//	Hsys[2][21] = -18'sd423;
//	Hsys[3][21] = -18'sd1270;
//	Hsys[4][21] = -18'sd1694;
//	Hsys[0][22] = 18'sd589;
//	Hsys[1][22] = 18'sd196;
//	Hsys[2][22] = -18'sd196;
//	Hsys[3][22] = -18'sd589;
//	Hsys[4][22] = -18'sd785;
//	Hsys[0][23] = -18'sd581;
//	Hsys[1][23] = -18'sd194;
//	Hsys[2][23] = 18'sd194;
//	Hsys[3][23] = 18'sd581;
//	Hsys[4][23] = 18'sd774;
//	Hsys[0][24] = -18'sd1564;
//	Hsys[1][24] = -18'sd521;
//	Hsys[2][24] = 18'sd521;
//	Hsys[3][24] = 18'sd1564;
//	Hsys[4][24] = 18'sd2085;
//	Hsys[0][25] = -18'sd1698;
//	Hsys[1][25] = -18'sd566;
//	Hsys[2][25] = 18'sd566;
//	Hsys[3][25] = 18'sd1698;
//	Hsys[4][25] = 18'sd2263;
//	Hsys[0][26] = -18'sd762;
//	Hsys[1][26] = -18'sd254;
//	Hsys[2][26] = 18'sd254;
//	Hsys[3][26] = 18'sd762;
//	Hsys[4][26] = 18'sd1016;
//	Hsys[0][27] = 18'sd807;
//	Hsys[1][27] = 18'sd269;
//	Hsys[2][27] = -18'sd269;
//	Hsys[3][27] = -18'sd807;
//	Hsys[4][27] = -18'sd1076;
//	Hsys[0][28] = 18'sd2094;
//	Hsys[1][28] = 18'sd698;
//	Hsys[2][28] = -18'sd698;
//	Hsys[3][28] = -18'sd2094;
//	Hsys[4][28] = -18'sd2793;
//	Hsys[0][29] = 18'sd2226;
//	Hsys[1][29] = 18'sd742;
//	Hsys[2][29] = -18'sd742;
//	Hsys[3][29] = -18'sd2226;
//	Hsys[4][29] = -18'sd2968;
//	Hsys[0][30] = 18'sd938;
//	Hsys[1][30] = 18'sd313;
//	Hsys[2][30] = -18'sd313;
//	Hsys[3][30] = -18'sd938;
//	Hsys[4][30] = -18'sd1250;
//	Hsys[0][31] = -18'sd1156;
//	Hsys[1][31] = -18'sd385;
//	Hsys[2][31] = 18'sd385;
//	Hsys[3][31] = 18'sd1156;
//	Hsys[4][31] = 18'sd1541;
//	Hsys[0][32] = -18'sd2822;
//	Hsys[1][32] = -18'sd941;
//	Hsys[2][32] = 18'sd941;
//	Hsys[3][32] = 18'sd2822;
//	Hsys[4][32] = 18'sd3763;
//	Hsys[0][33] = -18'sd2909;
//	Hsys[1][33] = -18'sd970;
//	Hsys[2][33] = 18'sd970;
//	Hsys[3][33] = 18'sd2909;
//	Hsys[4][33] = 18'sd3879;
//	Hsys[0][34] = -18'sd1104;
//	Hsys[1][34] = -18'sd368;
//	Hsys[2][34] = 18'sd368;
//	Hsys[3][34] = 18'sd1104;
//	Hsys[4][34] = 18'sd1473;
//	Hsys[0][35] = 18'sd1727;
//	Hsys[1][35] = 18'sd576;
//	Hsys[2][35] = -18'sd576;
//	Hsys[3][35] = -18'sd1727;
//	Hsys[4][35] = -18'sd2303;
//	Hsys[0][36] = 18'sd3905;
//	Hsys[1][36] = 18'sd1302;
//	Hsys[2][36] = -18'sd1302;
//	Hsys[3][36] = -18'sd3905;
//	Hsys[4][36] = -18'sd5207;
//	Hsys[0][37] = 18'sd3878;
//	Hsys[1][37] = 18'sd1293;
//	Hsys[2][37] = -18'sd1293;
//	Hsys[3][37] = -18'sd3878;
//	Hsys[4][37] = -18'sd5171;
//	Hsys[0][38] = 18'sd1250;
//	Hsys[1][38] = 18'sd417;
//	Hsys[2][38] = -18'sd417;
//	Hsys[3][38] = -18'sd1250;
//	Hsys[4][38] = -18'sd1666;
//	Hsys[0][39] = -18'sd2756;
//	Hsys[1][39] = -18'sd919;
//	Hsys[2][39] = 18'sd919;
//	Hsys[3][39] = 18'sd2756;
//	Hsys[4][39] = 18'sd3675;
//	Hsys[0][40] = -18'sd5762;
//	Hsys[1][40] = -18'sd1921;
//	Hsys[2][40] = 18'sd1921;
//	Hsys[3][40] = 18'sd5762;
//	Hsys[4][40] = 18'sd7683;
//	Hsys[0][41] = -18'sd5519;
//	Hsys[1][41] = -18'sd1840;
//	Hsys[2][41] = 18'sd1840;
//	Hsys[3][41] = 18'sd5519;
//	Hsys[4][41] = 18'sd7359;
//	Hsys[0][42] = -18'sd1362;
//	Hsys[1][42] = -18'sd454;
//	Hsys[2][42] = 18'sd454;
//	Hsys[3][42] = 18'sd1362;
//	Hsys[4][42] = 18'sd1817;
//	Hsys[0][43] = 18'sd5001;
//	Hsys[1][43] = 18'sd1667;
//	Hsys[2][43] = -18'sd1667;
//	Hsys[3][43] = -18'sd5001;
//	Hsys[4][43] = -18'sd6668;
//	Hsys[0][44] = 18'sd9934;
//	Hsys[1][44] = 18'sd3311;
//	Hsys[2][44] = -18'sd3311;
//	Hsys[3][44] = -18'sd9934;
//	Hsys[4][44] = -18'sd13246;
//	Hsys[0][45] = 18'sd9482;
//	Hsys[1][45] = 18'sd3161;
//	Hsys[2][45] = -18'sd3161;
//	Hsys[3][45] = -18'sd9482;
//	Hsys[4][45] = -18'sd12643;
//	Hsys[0][46] = 18'sd1434;
//	Hsys[1][46] = 18'sd478;
//	Hsys[2][46] = -18'sd478;
//	Hsys[3][46] = -18'sd1434;
//	Hsys[4][46] = -18'sd1911;
//	Hsys[0][47] = -18'sd13225;
//	Hsys[1][47] = -18'sd4408;
//	Hsys[2][47] = 18'sd4408;
//	Hsys[3][47] = 18'sd13225;
//	Hsys[4][47] = 18'sd17635;
//	Hsys[0][48] = -18'sd30300;
//	Hsys[1][48] = -18'sd10100;
//	Hsys[2][48] = 18'sd10100;
//	Hsys[3][48] = 18'sd30300;
//	Hsys[4][48] = 18'sd40401;
//	Hsys[0][49] = -18'sd43946;
//	Hsys[1][49] = -18'sd14649;
//	Hsys[2][49] = 18'sd14649;
//	Hsys[3][49] = 18'sd43946;
//	Hsys[4][49] = 18'sd58597;
//	Hsys[0][50] = -18'sd49151;
//	Hsys[1][50] = -18'sd16384;
//	Hsys[2][50] = 18'sd16384;
//	Hsys[3][50] = 18'sd49151;
//	Hsys[4][50] = 18'sd65536;
//	Hsys[0][51] = -18'sd43946;
//	Hsys[1][51] = -18'sd14649;
//	Hsys[2][51] = 18'sd14649;
//	Hsys[3][51] = 18'sd43946;
//	Hsys[4][51] = 18'sd58597;
//	Hsys[0][52] = -18'sd30300;
//	Hsys[1][52] = -18'sd10100;
//	Hsys[2][52] = 18'sd10100;
//	Hsys[3][52] = 18'sd30300;
//	Hsys[4][52] = 18'sd40401;
//	Hsys[0][53] = -18'sd13225;
//	Hsys[1][53] = -18'sd4408;
//	Hsys[2][53] = 18'sd4408;
//	Hsys[3][53] = 18'sd13225;
//	Hsys[4][53] = 18'sd17635;
//	Hsys[0][54] = 18'sd1434;
//	Hsys[1][54] = 18'sd478;
//	Hsys[2][54] = -18'sd478;
//	Hsys[3][54] = -18'sd1434;
//	Hsys[4][54] = -18'sd1911;
//	Hsys[0][55] = 18'sd9482;
//	Hsys[1][55] = 18'sd3161;
//	Hsys[2][55] = -18'sd3161;
//	Hsys[3][55] = -18'sd9482;
//	Hsys[4][55] = -18'sd12643;
//	Hsys[0][56] = 18'sd9934;
//	Hsys[1][56] = 18'sd3311;
//	Hsys[2][56] = -18'sd3311;
//	Hsys[3][56] = -18'sd9934;
//	Hsys[4][56] = -18'sd13246;
//	Hsys[0][57] = 18'sd5001;
//	Hsys[1][57] = 18'sd1667;
//	Hsys[2][57] = -18'sd1667;
//	Hsys[3][57] = -18'sd5001;
//	Hsys[4][57] = -18'sd6668;
//	Hsys[0][58] = -18'sd1362;
//	Hsys[1][58] = -18'sd454;
//	Hsys[2][58] = 18'sd454;
//	Hsys[3][58] = 18'sd1362;
//	Hsys[4][58] = 18'sd1817;
//	Hsys[0][59] = -18'sd5519;
//	Hsys[1][59] = -18'sd1840;
//	Hsys[2][59] = 18'sd1840;
//	Hsys[3][59] = 18'sd5519;
//	Hsys[4][59] = 18'sd7359;
//	Hsys[0][60] = -18'sd5762;
//	Hsys[1][60] = -18'sd1921;
//	Hsys[2][60] = 18'sd1921;
//	Hsys[3][60] = 18'sd5762;
//	Hsys[4][60] = 18'sd7683;
//	Hsys[0][61] = -18'sd2756;
//	Hsys[1][61] = -18'sd919;
//	Hsys[2][61] = 18'sd919;
//	Hsys[3][61] = 18'sd2756;
//	Hsys[4][61] = 18'sd3675;
//	Hsys[0][62] = 18'sd1250;
//	Hsys[1][62] = 18'sd417;
//	Hsys[2][62] = -18'sd417;
//	Hsys[3][62] = -18'sd1250;
//	Hsys[4][62] = -18'sd1666;
//	Hsys[0][63] = 18'sd3878;
//	Hsys[1][63] = 18'sd1293;
//	Hsys[2][63] = -18'sd1293;
//	Hsys[3][63] = -18'sd3878;
//	Hsys[4][63] = -18'sd5171;
//	Hsys[0][64] = 18'sd3905;
//	Hsys[1][64] = 18'sd1302;
//	Hsys[2][64] = -18'sd1302;
//	Hsys[3][64] = -18'sd3905;
//	Hsys[4][64] = -18'sd5207;
//	Hsys[0][65] = 18'sd1727;
//	Hsys[1][65] = 18'sd576;
//	Hsys[2][65] = -18'sd576;
//	Hsys[3][65] = -18'sd1727;
//	Hsys[4][65] = -18'sd2303;
//	Hsys[0][66] = -18'sd1104;
//	Hsys[1][66] = -18'sd368;
//	Hsys[2][66] = 18'sd368;
//	Hsys[3][66] = 18'sd1104;
//	Hsys[4][66] = 18'sd1473;
//	Hsys[0][67] = -18'sd2909;
//	Hsys[1][67] = -18'sd970;
//	Hsys[2][67] = 18'sd970;
//	Hsys[3][67] = 18'sd2909;
//	Hsys[4][67] = 18'sd3879;
//	Hsys[0][68] = -18'sd2822;
//	Hsys[1][68] = -18'sd941;
//	Hsys[2][68] = 18'sd941;
//	Hsys[3][68] = 18'sd2822;
//	Hsys[4][68] = 18'sd3763;
//	Hsys[0][69] = -18'sd1156;
//	Hsys[1][69] = -18'sd385;
//	Hsys[2][69] = 18'sd385;
//	Hsys[3][69] = 18'sd1156;
//	Hsys[4][69] = 18'sd1541;
//	Hsys[0][70] = 18'sd938;
//	Hsys[1][70] = 18'sd313;
//	Hsys[2][70] = -18'sd313;
//	Hsys[3][70] = -18'sd938;
//	Hsys[4][70] = -18'sd1250;
//	Hsys[0][71] = 18'sd2226;
//	Hsys[1][71] = 18'sd742;
//	Hsys[2][71] = -18'sd742;
//	Hsys[3][71] = -18'sd2226;
//	Hsys[4][71] = -18'sd2968;
//	Hsys[0][72] = 18'sd2094;
//	Hsys[1][72] = 18'sd698;
//	Hsys[2][72] = -18'sd698;
//	Hsys[3][72] = -18'sd2094;
//	Hsys[4][72] = -18'sd2793;
//	Hsys[0][73] = 18'sd807;
//	Hsys[1][73] = 18'sd269;
//	Hsys[2][73] = -18'sd269;
//	Hsys[3][73] = -18'sd807;
//	Hsys[4][73] = -18'sd1076;
//	Hsys[0][74] = -18'sd762;
//	Hsys[1][74] = -18'sd254;
//	Hsys[2][74] = 18'sd254;
//	Hsys[3][74] = 18'sd762;
//	Hsys[4][74] = 18'sd1016;
//	Hsys[0][75] = -18'sd1698;
//	Hsys[1][75] = -18'sd566;
//	Hsys[2][75] = 18'sd566;
//	Hsys[3][75] = 18'sd1698;
//	Hsys[4][75] = 18'sd2263;
//	Hsys[0][76] = -18'sd1564;
//	Hsys[1][76] = -18'sd521;
//	Hsys[2][76] = 18'sd521;
//	Hsys[3][76] = 18'sd1564;
//	Hsys[4][76] = 18'sd2085;
//	Hsys[0][77] = -18'sd581;
//	Hsys[1][77] = -18'sd194;
//	Hsys[2][77] = 18'sd194;
//	Hsys[3][77] = 18'sd581;
//	Hsys[4][77] = 18'sd774;
//	Hsys[0][78] = 18'sd589;
//	Hsys[1][78] = 18'sd196;
//	Hsys[2][78] = -18'sd196;
//	Hsys[3][78] = -18'sd589;
//	Hsys[4][78] = -18'sd785;
//	Hsys[0][79] = 18'sd1270;
//	Hsys[1][79] = 18'sd423;
//	Hsys[2][79] = -18'sd423;
//	Hsys[3][79] = -18'sd1270;
//	Hsys[4][79] = -18'sd1694;
//	Hsys[0][80] = 18'sd1158;
//	Hsys[1][80] = 18'sd386;
//	Hsys[2][80] = -18'sd386;
//	Hsys[3][80] = -18'sd1158;
//	Hsys[4][80] = -18'sd1543;
//	Hsys[0][81] = 18'sd427;
//	Hsys[1][81] = 18'sd142;
//	Hsys[2][81] = -18'sd142;
//	Hsys[3][81] = -18'sd427;
//	Hsys[4][81] = -18'sd570;
//	Hsys[0][82] = -18'sd428;
//	Hsys[1][82] = -18'sd143;
//	Hsys[2][82] = 18'sd143;
//	Hsys[3][82] = 18'sd428;
//	Hsys[4][82] = 18'sd571;
//	Hsys[0][83] = -18'sd921;
//	Hsys[1][83] = -18'sd307;
//	Hsys[2][83] = 18'sd307;
//	Hsys[3][83] = 18'sd921;
//	Hsys[4][83] = 18'sd1228;
//	Hsys[0][84] = -18'sd839;
//	Hsys[1][84] = -18'sd280;
//	Hsys[2][84] = 18'sd280;
//	Hsys[3][84] = 18'sd839;
//	Hsys[4][84] = 18'sd1119;
//	Hsys[0][85] = -18'sd317;
//	Hsys[1][85] = -18'sd106;
//	Hsys[2][85] = 18'sd106;
//	Hsys[3][85] = 18'sd317;
//	Hsys[4][85] = 18'sd423;
//	Hsys[0][86] = 18'sd289;
//	Hsys[1][86] = 18'sd96;
//	Hsys[2][86] = -18'sd96;
//	Hsys[3][86] = -18'sd289;
//	Hsys[4][86] = -18'sd386;
//	Hsys[0][87] = 18'sd639;
//	Hsys[1][87] = 18'sd213;
//	Hsys[2][87] = -18'sd213;
//	Hsys[3][87] = -18'sd639;
//	Hsys[4][87] = -18'sd852;
//	Hsys[0][88] = 18'sd589;
//	Hsys[1][88] = 18'sd196;
//	Hsys[2][88] = -18'sd196;
//	Hsys[3][88] = -18'sd589;
//	Hsys[4][88] = -18'sd785;
//	Hsys[0][89] = 18'sd235;
//	Hsys[1][89] = 18'sd78;
//	Hsys[2][89] = -18'sd78;
//	Hsys[3][89] = -18'sd235;
//	Hsys[4][89] = -18'sd314;
//	Hsys[0][90] = -18'sd176;
//	Hsys[1][90] = -18'sd59;
//	Hsys[2][90] = 18'sd59;
//	Hsys[3][90] = 18'sd176;
//	Hsys[4][90] = 18'sd235;
//	Hsys[0][91] = -18'sd415;
//	Hsys[1][91] = -18'sd138;
//	Hsys[2][91] = 18'sd138;
//	Hsys[3][91] = 18'sd415;
//	Hsys[4][91] = 18'sd554;
//	Hsys[0][92] = -18'sd385;
//	Hsys[1][92] = -18'sd128;
//	Hsys[2][92] = 18'sd128;
//	Hsys[3][92] = 18'sd385;
//	Hsys[4][92] = 18'sd514;
//	Hsys[0][93] = -18'sd150;
//	Hsys[1][93] = -18'sd50;
//	Hsys[2][93] = 18'sd50;
//	Hsys[3][93] = 18'sd150;
//	Hsys[4][93] = 18'sd200;
//	Hsys[0][94] = 18'sd135;
//	Hsys[1][94] = 18'sd45;
//	Hsys[2][94] = -18'sd45;
//	Hsys[3][94] = -18'sd135;
//	Hsys[4][94] = -18'sd180;
//	Hsys[0][95] = 18'sd322;
//	Hsys[1][95] = 18'sd107;
//	Hsys[2][95] = -18'sd107;
//	Hsys[3][95] = -18'sd322;
//	Hsys[4][95] = -18'sd429;
//	Hsys[0][96] = 18'sd348;
//	Hsys[1][96] = 18'sd116;
//	Hsys[2][96] = -18'sd116;
//	Hsys[3][96] = -18'sd348;
//	Hsys[4][96] = -18'sd464;
//	Hsys[0][97] = 18'sd246;
//	Hsys[1][97] = 18'sd82;
//	Hsys[2][97] = -18'sd82;
//	Hsys[3][97] = -18'sd246;
//	Hsys[4][97] = -18'sd328;
//	Hsys[0][98] = 18'sd102;
//	Hsys[1][98] = 18'sd34;
//	Hsys[2][98] = -18'sd34;
//	Hsys[3][98] = -18'sd102;
//	Hsys[4][98] = -18'sd136;
//	Hsys[0][99] = -18'sd4;
//	Hsys[1][99] = -18'sd1;
//	Hsys[2][99] = 18'sd1;
//	Hsys[3][99] = 18'sd4;
//	Hsys[4][99] = 18'sd5;
//	Hsys[0][100] = -18'sd97;
//	Hsys[1][100] = -18'sd32;
//	Hsys[2][100] = 18'sd32;
//	Hsys[3][100] = 18'sd97;
//	Hsys[4][100] = 18'sd130;
//end
//*/
//
//initial begin
//	Hsys[0][0] = -18'sd107;
//	Hsys[1][0] = -18'sd36;
//	Hsys[2][0] = 18'sd36;
//	Hsys[3][0] = 18'sd107;
//	Hsys[4][0] = 18'sd142;
//	Hsys[0][1] = -18'sd4;
//	Hsys[1][1] = -18'sd1;
//	Hsys[2][1] = 18'sd1;
//	Hsys[3][1] = 18'sd4;
//	Hsys[4][1] = 18'sd5;
//	Hsys[0][2] = 18'sd112;
//	Hsys[1][2] = 18'sd37;
//	Hsys[2][2] = -18'sd37;
//	Hsys[3][2] = -18'sd112;
//	Hsys[4][2] = -18'sd149;
//	Hsys[0][3] = 18'sd270;
//	Hsys[1][3] = 18'sd90;
//	Hsys[2][3] = -18'sd90;
//	Hsys[3][3] = -18'sd270;
//	Hsys[4][3] = -18'sd360;
//	Hsys[0][4] = 18'sd382;
//	Hsys[1][4] = 18'sd127;
//	Hsys[2][4] = -18'sd127;
//	Hsys[3][4] = -18'sd382;
//	Hsys[4][4] = -18'sd509;
//	Hsys[0][5] = 18'sd353;
//	Hsys[1][5] = 18'sd118;
//	Hsys[2][5] = -18'sd118;
//	Hsys[3][5] = -18'sd353;
//	Hsys[4][5] = -18'sd470;
//	Hsys[0][6] = 18'sd148;
//	Hsys[1][6] = 18'sd49;
//	Hsys[2][6] = -18'sd49;
//	Hsys[3][6] = -18'sd148;
//	Hsys[4][6] = -18'sd197;
//	Hsys[0][7] = -18'sd164;
//	Hsys[1][7] = -18'sd55;
//	Hsys[2][7] = 18'sd55;
//	Hsys[3][7] = 18'sd164;
//	Hsys[4][7] = 18'sd219;
//	Hsys[0][8] = -18'sd422;
//	Hsys[1][8] = -18'sd141;
//	Hsys[2][8] = 18'sd141;
//	Hsys[3][8] = 18'sd422;
//	Hsys[4][8] = 18'sd563;
//	Hsys[0][9] = -18'sd455;
//	Hsys[1][9] = -18'sd152;
//	Hsys[2][9] = 18'sd152;
//	Hsys[3][9] = 18'sd455;
//	Hsys[4][9] = 18'sd607;
//	Hsys[0][10] = -18'sd193;
//	Hsys[1][10] = -18'sd64;
//	Hsys[2][10] = 18'sd64;
//	Hsys[3][10] = 18'sd193;
//	Hsys[4][10] = 18'sd258;
//	Hsys[0][11] = 18'sd258;
//	Hsys[1][11] = 18'sd86;
//	Hsys[2][11] = -18'sd86;
//	Hsys[3][11] = -18'sd258;
//	Hsys[4][11] = -18'sd344;
//	Hsys[0][12] = 18'sd645;
//	Hsys[1][12] = 18'sd215;
//	Hsys[2][12] = -18'sd215;
//	Hsys[3][12] = -18'sd645;
//	Hsys[4][12] = -18'sd860;
//	Hsys[0][13] = 18'sd701;
//	Hsys[1][13] = 18'sd234;
//	Hsys[2][13] = -18'sd234;
//	Hsys[3][13] = -18'sd701;
//	Hsys[4][13] = -18'sd934;
//	Hsys[0][14] = 18'sd317;
//	Hsys[1][14] = 18'sd106;
//	Hsys[2][14] = -18'sd106;
//	Hsys[3][14] = -18'sd317;
//	Hsys[4][14] = -18'sd423;
//	Hsys[0][15] = -18'sd348;
//	Hsys[1][15] = -18'sd116;
//	Hsys[2][15] = 18'sd116;
//	Hsys[3][15] = 18'sd348;
//	Hsys[4][15] = 18'sd464;
//	Hsys[0][16] = -18'sd919;
//	Hsys[1][16] = -18'sd306;
//	Hsys[2][16] = 18'sd306;
//	Hsys[3][16] = 18'sd919;
//	Hsys[4][16] = 18'sd1226;
//	Hsys[0][17] = -18'sd1010;
//	Hsys[1][17] = -18'sd337;
//	Hsys[2][17] = 18'sd337;
//	Hsys[3][17] = 18'sd1010;
//	Hsys[4][17] = 18'sd1346;
//	Hsys[0][18] = -18'sd469;
//	Hsys[1][18] = -18'sd156;
//	Hsys[2][18] = 18'sd156;
//	Hsys[3][18] = 18'sd469;
//	Hsys[4][18] = 18'sd625;
//	Hsys[0][19] = 18'sd468;
//	Hsys[1][19] = 18'sd156;
//	Hsys[2][19] = -18'sd156;
//	Hsys[3][19] = -18'sd468;
//	Hsys[4][19] = -18'sd624;
//	Hsys[0][20] = 18'sd1269;
//	Hsys[1][20] = 18'sd423;
//	Hsys[2][20] = -18'sd423;
//	Hsys[3][20] = -18'sd1269;
//	Hsys[4][20] = -18'sd1692;
//	Hsys[0][21] = 18'sd1392;
//	Hsys[1][21] = 18'sd464;
//	Hsys[2][21] = -18'sd464;
//	Hsys[3][21] = -18'sd1392;
//	Hsys[4][21] = -18'sd1856;
//	Hsys[0][22] = 18'sd645;
//	Hsys[1][22] = 18'sd215;
//	Hsys[2][22] = -18'sd215;
//	Hsys[3][22] = -18'sd645;
//	Hsys[4][22] = -18'sd860;
//	Hsys[0][23] = -18'sd637;
//	Hsys[1][23] = -18'sd212;
//	Hsys[2][23] = 18'sd212;
//	Hsys[3][23] = 18'sd637;
//	Hsys[4][23] = 18'sd849;
//	Hsys[0][24] = -18'sd1714;
//	Hsys[1][24] = -18'sd571;
//	Hsys[2][24] = 18'sd571;
//	Hsys[3][24] = 18'sd1714;
//	Hsys[4][24] = 18'sd2285;
//	Hsys[0][25] = -18'sd1860;
//	Hsys[1][25] = -18'sd620;
//	Hsys[2][25] = 18'sd620;
//	Hsys[3][25] = 18'sd1860;
//	Hsys[4][25] = 18'sd2481;
//	Hsys[0][26] = -18'sd835;
//	Hsys[1][26] = -18'sd278;
//	Hsys[2][26] = 18'sd278;
//	Hsys[3][26] = 18'sd835;
//	Hsys[4][26] = 18'sd1114;
//	Hsys[0][27] = 18'sd884;
//	Hsys[1][27] = 18'sd295;
//	Hsys[2][27] = -18'sd295;
//	Hsys[3][27] = -18'sd884;
//	Hsys[4][27] = -18'sd1179;
//	Hsys[0][28] = 18'sd2295;
//	Hsys[1][28] = 18'sd765;
//	Hsys[2][28] = -18'sd765;
//	Hsys[3][28] = -18'sd2295;
//	Hsys[4][28] = -18'sd3060;
//	Hsys[0][29] = 18'sd2439;
//	Hsys[1][29] = 18'sd813;
//	Hsys[2][29] = -18'sd813;
//	Hsys[3][29] = -18'sd2439;
//	Hsys[4][29] = -18'sd3253;
//	Hsys[0][30] = 18'sd1028;
//	Hsys[1][30] = 18'sd343;
//	Hsys[2][30] = -18'sd343;
//	Hsys[3][30] = -18'sd1028;
//	Hsys[4][30] = -18'sd1370;
//	Hsys[0][31] = -18'sd1267;
//	Hsys[1][31] = -18'sd422;
//	Hsys[2][31] = 18'sd422;
//	Hsys[3][31] = 18'sd1267;
//	Hsys[4][31] = 18'sd1689;
//	Hsys[0][32] = -18'sd3093;
//	Hsys[1][32] = -18'sd1031;
//	Hsys[2][32] = 18'sd1031;
//	Hsys[3][32] = 18'sd3093;
//	Hsys[4][32] = 18'sd4123;
//	Hsys[0][33] = -18'sd3188;
//	Hsys[1][33] = -18'sd1063;
//	Hsys[2][33] = 18'sd1063;
//	Hsys[3][33] = 18'sd3188;
//	Hsys[4][33] = 18'sd4251;
//	Hsys[0][34] = -18'sd1210;
//	Hsys[1][34] = -18'sd403;
//	Hsys[2][34] = 18'sd403;
//	Hsys[3][34] = 18'sd1210;
//	Hsys[4][34] = 18'sd1614;
//	Hsys[0][35] = 18'sd1893;
//	Hsys[1][35] = 18'sd631;
//	Hsys[2][35] = -18'sd631;
//	Hsys[3][35] = -18'sd1893;
//	Hsys[4][35] = -18'sd2524;
//	Hsys[0][36] = 18'sd4280;
//	Hsys[1][36] = 18'sd1427;
//	Hsys[2][36] = -18'sd1427;
//	Hsys[3][36] = -18'sd4280;
//	Hsys[4][36] = -18'sd5706;
//	Hsys[0][37] = 18'sd4250;
//	Hsys[1][37] = 18'sd1417;
//	Hsys[2][37] = -18'sd1417;
//	Hsys[3][37] = -18'sd4250;
//	Hsys[4][37] = -18'sd5667;
//	Hsys[0][38] = 18'sd1369;
//	Hsys[1][38] = 18'sd456;
//	Hsys[2][38] = -18'sd456;
//	Hsys[3][38] = -18'sd1369;
//	Hsys[4][38] = -18'sd1826;
//	Hsys[0][39] = -18'sd3021;
//	Hsys[1][39] = -18'sd1007;
//	Hsys[2][39] = 18'sd1007;
//	Hsys[3][39] = 18'sd3021;
//	Hsys[4][39] = 18'sd4028;
//	Hsys[0][40] = -18'sd6315;
//	Hsys[1][40] = -18'sd2105;
//	Hsys[2][40] = 18'sd2105;
//	Hsys[3][40] = 18'sd6315;
//	Hsys[4][40] = 18'sd8420;
//	Hsys[0][41] = -18'sd6049;
//	Hsys[1][41] = -18'sd2016;
//	Hsys[2][41] = 18'sd2016;
//	Hsys[3][41] = 18'sd6049;
//	Hsys[4][41] = 18'sd8065;
//	Hsys[0][42] = -18'sd1493;
//	Hsys[1][42] = -18'sd498;
//	Hsys[2][42] = 18'sd498;
//	Hsys[3][42] = 18'sd1493;
//	Hsys[4][42] = 18'sd1991;
//	Hsys[0][43] = 18'sd5481;
//	Hsys[1][43] = 18'sd1827;
//	Hsys[2][43] = -18'sd1827;
//	Hsys[3][43] = -18'sd5481;
//	Hsys[4][43] = -18'sd7308;
//	Hsys[0][44] = 18'sd10887;
//	Hsys[1][44] = 18'sd3629;
//	Hsys[2][44] = -18'sd3629;
//	Hsys[3][44] = -18'sd10887;
//	Hsys[4][44] = -18'sd14516;
//	Hsys[0][45] = 18'sd10391;
//	Hsys[1][45] = 18'sd3464;
//	Hsys[2][45] = -18'sd3464;
//	Hsys[3][45] = -18'sd10391;
//	Hsys[4][45] = -18'sd13855;
//	Hsys[0][46] = 18'sd1571;
//	Hsys[1][46] = 18'sd524;
//	Hsys[2][46] = -18'sd524;
//	Hsys[3][46] = -18'sd1571;
//	Hsys[4][46] = -18'sd2095;
//	Hsys[0][47] = -18'sd14494;
//	Hsys[1][47] = -18'sd4831;
//	Hsys[2][47] = 18'sd4831;
//	Hsys[3][47] = 18'sd14494;
//	Hsys[4][47] = 18'sd19326;
//	Hsys[0][48] = -18'sd33206;
//	Hsys[1][48] = -18'sd11069;
//	Hsys[2][48] = 18'sd11069;
//	Hsys[3][48] = 18'sd33206;
//	Hsys[4][48] = 18'sd44277;
//	Hsys[0][49] = -18'sd48162;
//	Hsys[1][49] = -18'sd16054;
//	Hsys[2][49] = 18'sd16054;
//	Hsys[3][49] = 18'sd48162;
//	Hsys[4][49] = 18'sd64218;
//	Hsys[0][50] = -18'sd53866;
//	Hsys[1][50] = -18'sd17955;
//	Hsys[2][50] = 18'sd17955;
//	Hsys[3][50] = 18'sd53866;
//	Hsys[4][50] = 18'sd71823;
//	Hsys[0][51] = -18'sd48162;
//	Hsys[1][51] = -18'sd16054;
//	Hsys[2][51] = 18'sd16054;
//	Hsys[3][51] = 18'sd48162;
//	Hsys[4][51] = 18'sd64218;
//	Hsys[0][52] = -18'sd33206;
//	Hsys[1][52] = -18'sd11069;
//	Hsys[2][52] = 18'sd11069;
//	Hsys[3][52] = 18'sd33206;
//	Hsys[4][52] = 18'sd44277;
//	Hsys[0][53] = -18'sd14494;
//	Hsys[1][53] = -18'sd4831;
//	Hsys[2][53] = 18'sd4831;
//	Hsys[3][53] = 18'sd14494;
//	Hsys[4][53] = 18'sd19326;
//	Hsys[0][54] = 18'sd1571;
//	Hsys[1][54] = 18'sd524;
//	Hsys[2][54] = -18'sd524;
//	Hsys[3][54] = -18'sd1571;
//	Hsys[4][54] = -18'sd2095;
//	Hsys[0][55] = 18'sd10391;
//	Hsys[1][55] = 18'sd3464;
//	Hsys[2][55] = -18'sd3464;
//	Hsys[3][55] = -18'sd10391;
//	Hsys[4][55] = -18'sd13855;
//	Hsys[0][56] = 18'sd10887;
//	Hsys[1][56] = 18'sd3629;
//	Hsys[2][56] = -18'sd3629;
//	Hsys[3][56] = -18'sd10887;
//	Hsys[4][56] = -18'sd14516;
//	Hsys[0][57] = 18'sd5481;
//	Hsys[1][57] = 18'sd1827;
//	Hsys[2][57] = -18'sd1827;
//	Hsys[3][57] = -18'sd5481;
//	Hsys[4][57] = -18'sd7308;
//	Hsys[0][58] = -18'sd1493;
//	Hsys[1][58] = -18'sd498;
//	Hsys[2][58] = 18'sd498;
//	Hsys[3][58] = 18'sd1493;
//	Hsys[4][58] = 18'sd1991;
//	Hsys[0][59] = -18'sd6049;
//	Hsys[1][59] = -18'sd2016;
//	Hsys[2][59] = 18'sd2016;
//	Hsys[3][59] = 18'sd6049;
//	Hsys[4][59] = 18'sd8065;
//	Hsys[0][60] = -18'sd6315;
//	Hsys[1][60] = -18'sd2105;
//	Hsys[2][60] = 18'sd2105;
//	Hsys[3][60] = 18'sd6315;
//	Hsys[4][60] = 18'sd8420;
//	Hsys[0][61] = -18'sd3021;
//	Hsys[1][61] = -18'sd1007;
//	Hsys[2][61] = 18'sd1007;
//	Hsys[3][61] = 18'sd3021;
//	Hsys[4][61] = 18'sd4028;
//	Hsys[0][62] = 18'sd1369;
//	Hsys[1][62] = 18'sd456;
//	Hsys[2][62] = -18'sd456;
//	Hsys[3][62] = -18'sd1369;
//	Hsys[4][62] = -18'sd1826;
//	Hsys[0][63] = 18'sd4250;
//	Hsys[1][63] = 18'sd1417;
//	Hsys[2][63] = -18'sd1417;
//	Hsys[3][63] = -18'sd4250;
//	Hsys[4][63] = -18'sd5667;
//	Hsys[0][64] = 18'sd4280;
//	Hsys[1][64] = 18'sd1427;
//	Hsys[2][64] = -18'sd1427;
//	Hsys[3][64] = -18'sd4280;
//	Hsys[4][64] = -18'sd5706;
//	Hsys[0][65] = 18'sd1893;
//	Hsys[1][65] = 18'sd631;
//	Hsys[2][65] = -18'sd631;
//	Hsys[3][65] = -18'sd1893;
//	Hsys[4][65] = -18'sd2524;
//	Hsys[0][66] = -18'sd1210;
//	Hsys[1][66] = -18'sd403;
//	Hsys[2][66] = 18'sd403;
//	Hsys[3][66] = 18'sd1210;
//	Hsys[4][66] = 18'sd1614;
//	Hsys[0][67] = -18'sd3188;
//	Hsys[1][67] = -18'sd1063;
//	Hsys[2][67] = 18'sd1063;
//	Hsys[3][67] = 18'sd3188;
//	Hsys[4][67] = 18'sd4251;
//	Hsys[0][68] = -18'sd3093;
//	Hsys[1][68] = -18'sd1031;
//	Hsys[2][68] = 18'sd1031;
//	Hsys[3][68] = 18'sd3093;
//	Hsys[4][68] = 18'sd4123;
//	Hsys[0][69] = -18'sd1267;
//	Hsys[1][69] = -18'sd422;
//	Hsys[2][69] = 18'sd422;
//	Hsys[3][69] = 18'sd1267;
//	Hsys[4][69] = 18'sd1689;
//	Hsys[0][70] = 18'sd1028;
//	Hsys[1][70] = 18'sd343;
//	Hsys[2][70] = -18'sd343;
//	Hsys[3][70] = -18'sd1028;
//	Hsys[4][70] = -18'sd1370;
//	Hsys[0][71] = 18'sd2439;
//	Hsys[1][71] = 18'sd813;
//	Hsys[2][71] = -18'sd813;
//	Hsys[3][71] = -18'sd2439;
//	Hsys[4][71] = -18'sd3253;
//	Hsys[0][72] = 18'sd2295;
//	Hsys[1][72] = 18'sd765;
//	Hsys[2][72] = -18'sd765;
//	Hsys[3][72] = -18'sd2295;
//	Hsys[4][72] = -18'sd3060;
//	Hsys[0][73] = 18'sd884;
//	Hsys[1][73] = 18'sd295;
//	Hsys[2][73] = -18'sd295;
//	Hsys[3][73] = -18'sd884;
//	Hsys[4][73] = -18'sd1179;
//	Hsys[0][74] = -18'sd835;
//	Hsys[1][74] = -18'sd278;
//	Hsys[2][74] = 18'sd278;
//	Hsys[3][74] = 18'sd835;
//	Hsys[4][74] = 18'sd1114;
//	Hsys[0][75] = -18'sd1860;
//	Hsys[1][75] = -18'sd620;
//	Hsys[2][75] = 18'sd620;
//	Hsys[3][75] = 18'sd1860;
//	Hsys[4][75] = 18'sd2481;
//	Hsys[0][76] = -18'sd1714;
//	Hsys[1][76] = -18'sd571;
//	Hsys[2][76] = 18'sd571;
//	Hsys[3][76] = 18'sd1714;
//	Hsys[4][76] = 18'sd2285;
//	Hsys[0][77] = -18'sd637;
//	Hsys[1][77] = -18'sd212;
//	Hsys[2][77] = 18'sd212;
//	Hsys[3][77] = 18'sd637;
//	Hsys[4][77] = 18'sd849;
//	Hsys[0][78] = 18'sd645;
//	Hsys[1][78] = 18'sd215;
//	Hsys[2][78] = -18'sd215;
//	Hsys[3][78] = -18'sd645;
//	Hsys[4][78] = -18'sd860;
//	Hsys[0][79] = 18'sd1392;
//	Hsys[1][79] = 18'sd464;
//	Hsys[2][79] = -18'sd464;
//	Hsys[3][79] = -18'sd1392;
//	Hsys[4][79] = -18'sd1856;
//	Hsys[0][80] = 18'sd1269;
//	Hsys[1][80] = 18'sd423;
//	Hsys[2][80] = -18'sd423;
//	Hsys[3][80] = -18'sd1269;
//	Hsys[4][80] = -18'sd1692;
//	Hsys[0][81] = 18'sd468;
//	Hsys[1][81] = 18'sd156;
//	Hsys[2][81] = -18'sd156;
//	Hsys[3][81] = -18'sd468;
//	Hsys[4][81] = -18'sd624;
//	Hsys[0][82] = -18'sd469;
//	Hsys[1][82] = -18'sd156;
//	Hsys[2][82] = 18'sd156;
//	Hsys[3][82] = 18'sd469;
//	Hsys[4][82] = 18'sd625;
//	Hsys[0][83] = -18'sd1010;
//	Hsys[1][83] = -18'sd337;
//	Hsys[2][83] = 18'sd337;
//	Hsys[3][83] = 18'sd1010;
//	Hsys[4][83] = 18'sd1346;
//	Hsys[0][84] = -18'sd919;
//	Hsys[1][84] = -18'sd306;
//	Hsys[2][84] = 18'sd306;
//	Hsys[3][84] = 18'sd919;
//	Hsys[4][84] = 18'sd1226;
//	Hsys[0][85] = -18'sd348;
//	Hsys[1][85] = -18'sd116;
//	Hsys[2][85] = 18'sd116;
//	Hsys[3][85] = 18'sd348;
//	Hsys[4][85] = 18'sd464;
//	Hsys[0][86] = 18'sd317;
//	Hsys[1][86] = 18'sd106;
//	Hsys[2][86] = -18'sd106;
//	Hsys[3][86] = -18'sd317;
//	Hsys[4][86] = -18'sd423;
//	Hsys[0][87] = 18'sd701;
//	Hsys[1][87] = 18'sd234;
//	Hsys[2][87] = -18'sd234;
//	Hsys[3][87] = -18'sd701;
//	Hsys[4][87] = -18'sd934;
//	Hsys[0][88] = 18'sd645;
//	Hsys[1][88] = 18'sd215;
//	Hsys[2][88] = -18'sd215;
//	Hsys[3][88] = -18'sd645;
//	Hsys[4][88] = -18'sd860;
//	Hsys[0][89] = 18'sd258;
//	Hsys[1][89] = 18'sd86;
//	Hsys[2][89] = -18'sd86;
//	Hsys[3][89] = -18'sd258;
//	Hsys[4][89] = -18'sd344;
//	Hsys[0][90] = -18'sd193;
//	Hsys[1][90] = -18'sd64;
//	Hsys[2][90] = 18'sd64;
//	Hsys[3][90] = 18'sd193;
//	Hsys[4][90] = 18'sd258;
//	Hsys[0][91] = -18'sd455;
//	Hsys[1][91] = -18'sd152;
//	Hsys[2][91] = 18'sd152;
//	Hsys[3][91] = 18'sd455;
//	Hsys[4][91] = 18'sd607;
//	Hsys[0][92] = -18'sd422;
//	Hsys[1][92] = -18'sd141;
//	Hsys[2][92] = 18'sd141;
//	Hsys[3][92] = 18'sd422;
//	Hsys[4][92] = 18'sd563;
//	Hsys[0][93] = -18'sd164;
//	Hsys[1][93] = -18'sd55;
//	Hsys[2][93] = 18'sd55;
//	Hsys[3][93] = 18'sd164;
//	Hsys[4][93] = 18'sd219;
//	Hsys[0][94] = 18'sd148;
//	Hsys[1][94] = 18'sd49;
//	Hsys[2][94] = -18'sd49;
//	Hsys[3][94] = -18'sd148;
//	Hsys[4][94] = -18'sd197;
//	Hsys[0][95] = 18'sd353;
//	Hsys[1][95] = 18'sd118;
//	Hsys[2][95] = -18'sd118;
//	Hsys[3][95] = -18'sd353;
//	Hsys[4][95] = -18'sd470;
//	Hsys[0][96] = 18'sd382;
//	Hsys[1][96] = 18'sd127;
//	Hsys[2][96] = -18'sd127;
//	Hsys[3][96] = -18'sd382;
//	Hsys[4][96] = -18'sd509;
//	Hsys[0][97] = 18'sd270;
//	Hsys[1][97] = 18'sd90;
//	Hsys[2][97] = -18'sd90;
//	Hsys[3][97] = -18'sd270;
//	Hsys[4][97] = -18'sd360;
//	Hsys[0][98] = 18'sd112;
//	Hsys[1][98] = 18'sd37;
//	Hsys[2][98] = -18'sd37;
//	Hsys[3][98] = -18'sd112;
//	Hsys[4][98] = -18'sd149;
//	Hsys[0][99] = -18'sd4;
//	Hsys[1][99] = -18'sd1;
//	Hsys[2][99] = 18'sd1;
//	Hsys[3][99] = 18'sd4;
//	Hsys[4][99] = 18'sd5;
//	Hsys[0][100] = -18'sd107;
//	Hsys[1][100] = -18'sd36;
//	Hsys[2][100] = 18'sd36;
//	Hsys[3][100] = 18'sd107;
//	Hsys[4][100] = 18'sd142;
//end

//endmodule 

module PPS_filt_101 #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter SUMLVL=7,
    parameter LENGTH=121,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter POSSMAPPER=7,
    parameter MAPSIZE=4,
    /* 46:0 first lvl regs; (46+1):(46+1+23-1+1) 2nd lvl; numbers in array count sym regs*/
//    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
	 parameter SUMLV1=61,
	 parameter SUMLV2=31,
	 parameter SUMLV3=16,
	 parameter SUMLV4=8,
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
     for (i=0; i<SUMLV1; i=i+1)
        sum_lvl_1[i]=18'sd0;
     for (i=0; i<SUMLV2; i=i+1)
        sum_lvl_2[i]=18'sd0;
     for (i=0; i<SUMLV3; i=i+1)
        sum_lvl_3[i]=18'sd0;
     for (i=0; i<SUMLV4; i=i+1)
        sum_lvl_4[i]=18'sd0;
     for (i=0; i<SUMLV5; i=i+1)
        sum_lvl_5[i]=18'sd0;
     for (i=0; i<SUMLV6; i=i+1)
        sum_lvl_6[i]=18'sd0;
     sum_lvl_7=18'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
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
        for (i=0; i<SUMLV3-1; i=i+1)
            sum_lvl_3[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV3-1; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end
	 
//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_3[SUMLV3-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_3[SUMLV3-1]<=$signed(sum_lvl_2[SUMLV2-1]);

/*          SUMLV4              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV4; i=i+1)
            sum_lvl_4[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV4; i=i+1)
            sum_lvl_4[i]<=$signed(sum_lvl_3[2*i])+$signed(sum_lvl_3[2*i+1]);
    end



/*          SUMLV5              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_5[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_5[i]<=$signed(sum_lvl_4[2*i])+$signed(sum_lvl_4[2*i+1]);
    end


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
	Hsys[0][0] = 18'sd44;
	Hsys[1][0] = 18'sd15;
	Hsys[2][0] = -18'sd15;
	Hsys[3][0] = -18'sd44;
	Hsys[4][0] = -18'sd59;
	Hsys[0][1] = 18'sd1;
	Hsys[1][1] = 18'sd0;
	Hsys[2][1] = 18'sd0;
	Hsys[3][1] = -18'sd1;
	Hsys[4][1] = -18'sd2;
	Hsys[0][2] = -18'sd16;
	Hsys[1][2] = -18'sd5;
	Hsys[2][2] = 18'sd5;
	Hsys[3][2] = 18'sd16;
	Hsys[4][2] = 18'sd22;
	Hsys[0][3] = -18'sd33;
	Hsys[1][3] = -18'sd11;
	Hsys[2][3] = 18'sd11;
	Hsys[3][3] = 18'sd33;
	Hsys[4][3] = 18'sd44;
	Hsys[0][4] = -18'sd33;
	Hsys[1][4] = -18'sd11;
	Hsys[2][4] = 18'sd11;
	Hsys[3][4] = 18'sd33;
	Hsys[4][4] = 18'sd45;
	Hsys[0][5] = -18'sd11;
	Hsys[1][5] = -18'sd4;
	Hsys[2][5] = 18'sd4;
	Hsys[3][5] = 18'sd11;
	Hsys[4][5] = 18'sd14;
	Hsys[0][6] = 18'sd27;
	Hsys[1][6] = 18'sd9;
	Hsys[2][6] = -18'sd9;
	Hsys[3][6] = -18'sd27;
	Hsys[4][6] = -18'sd36;
	Hsys[0][7] = 18'sd56;
	Hsys[1][7] = 18'sd19;
	Hsys[2][7] = -18'sd19;
	Hsys[3][7] = -18'sd56;
	Hsys[4][7] = -18'sd75;
	Hsys[0][8] = 18'sd53;
	Hsys[1][8] = 18'sd18;
	Hsys[2][8] = -18'sd18;
	Hsys[3][8] = -18'sd53;
	Hsys[4][8] = -18'sd71;
	Hsys[0][9] = 18'sd10;
	Hsys[1][9] = 18'sd3;
	Hsys[2][9] = -18'sd3;
	Hsys[3][9] = -18'sd10;
	Hsys[4][9] = -18'sd14;
	Hsys[0][10] = -18'sd52;
	Hsys[1][10] = -18'sd17;
	Hsys[2][10] = 18'sd17;
	Hsys[3][10] = 18'sd52;
	Hsys[4][10] = 18'sd70;
	Hsys[0][11] = -18'sd96;
	Hsys[1][11] = -18'sd32;
	Hsys[2][11] = 18'sd32;
	Hsys[3][11] = 18'sd96;
	Hsys[4][11] = 18'sd127;
	Hsys[0][12] = -18'sd83;
	Hsys[1][12] = -18'sd28;
	Hsys[2][12] = 18'sd28;
	Hsys[3][12] = 18'sd83;
	Hsys[4][12] = 18'sd111;
	Hsys[0][13] = -18'sd10;
	Hsys[1][13] = -18'sd3;
	Hsys[2][13] = 18'sd3;
	Hsys[3][13] = 18'sd10;
	Hsys[4][13] = 18'sd13;
	Hsys[0][14] = 18'sd88;
	Hsys[1][14] = 18'sd29;
	Hsys[2][14] = -18'sd29;
	Hsys[3][14] = -18'sd88;
	Hsys[4][14] = -18'sd117;
	Hsys[0][15] = 18'sd147;
	Hsys[1][15] = 18'sd49;
	Hsys[2][15] = -18'sd49;
	Hsys[3][15] = -18'sd147;
	Hsys[4][15] = -18'sd196;
	Hsys[0][16] = 18'sd118;
	Hsys[1][16] = 18'sd39;
	Hsys[2][16] = -18'sd39;
	Hsys[3][16] = -18'sd118;
	Hsys[4][16] = -18'sd157;
	Hsys[0][17] = 18'sd1;
	Hsys[1][17] = 18'sd0;
	Hsys[2][17] = 18'sd0;
	Hsys[3][17] = -18'sd1;
	Hsys[4][17] = -18'sd1;
	Hsys[0][18] = -18'sd143;
	Hsys[1][18] = -18'sd48;
	Hsys[2][18] = 18'sd48;
	Hsys[3][18] = 18'sd143;
	Hsys[4][18] = 18'sd190;
	Hsys[0][19] = -18'sd219;
	Hsys[1][19] = -18'sd73;
	Hsys[2][19] = 18'sd73;
	Hsys[3][19] = 18'sd219;
	Hsys[4][19] = 18'sd292;
	Hsys[0][20] = -18'sd163;
	Hsys[1][20] = -18'sd54;
	Hsys[2][20] = 18'sd54;
	Hsys[3][20] = 18'sd163;
	Hsys[4][20] = 18'sd217;
	Hsys[0][21] = 18'sd15;
	Hsys[1][21] = 18'sd5;
	Hsys[2][21] = -18'sd5;
	Hsys[3][21] = -18'sd15;
	Hsys[4][21] = -18'sd20;
	Hsys[0][22] = 18'sd217;
	Hsys[1][22] = 18'sd72;
	Hsys[2][22] = -18'sd72;
	Hsys[3][22] = -18'sd217;
	Hsys[4][22] = -18'sd290;
	Hsys[0][23] = 18'sd310;
	Hsys[1][23] = 18'sd103;
	Hsys[2][23] = -18'sd103;
	Hsys[3][23] = -18'sd310;
	Hsys[4][23] = -18'sd414;
	Hsys[0][24] = 18'sd212;
	Hsys[1][24] = 18'sd71;
	Hsys[2][24] = -18'sd71;
	Hsys[3][24] = -18'sd212;
	Hsys[4][24] = -18'sd282;
	Hsys[0][25] = -18'sd48;
	Hsys[1][25] = -18'sd16;
	Hsys[2][25] = 18'sd16;
	Hsys[3][25] = 18'sd48;
	Hsys[4][25] = 18'sd64;
	Hsys[0][26] = -18'sd323;
	Hsys[1][26] = -18'sd108;
	Hsys[2][26] = 18'sd108;
	Hsys[3][26] = 18'sd323;
	Hsys[4][26] = 18'sd430;
	Hsys[0][27] = -18'sd430;
	Hsys[1][27] = -18'sd143;
	Hsys[2][27] = 18'sd143;
	Hsys[3][27] = 18'sd430;
	Hsys[4][27] = 18'sd573;
	Hsys[0][28] = -18'sd269;
	Hsys[1][28] = -18'sd90;
	Hsys[2][28] = 18'sd90;
	Hsys[3][28] = 18'sd269;
	Hsys[4][28] = 18'sd358;
	Hsys[0][29] = 18'sd100;
	Hsys[1][29] = 18'sd33;
	Hsys[2][29] = -18'sd33;
	Hsys[3][29] = -18'sd100;
	Hsys[4][29] = -18'sd133;
	Hsys[0][30] = 18'sd463;
	Hsys[1][30] = 18'sd154;
	Hsys[2][30] = -18'sd154;
	Hsys[3][30] = -18'sd463;
	Hsys[4][30] = -18'sd618;
	Hsys[0][31] = 18'sd578;
	Hsys[1][31] = 18'sd193;
	Hsys[2][31] = -18'sd193;
	Hsys[3][31] = -18'sd578;
	Hsys[4][31] = -18'sd771;
	Hsys[0][32] = 18'sd327;
	Hsys[1][32] = 18'sd109;
	Hsys[2][32] = -18'sd109;
	Hsys[3][32] = -18'sd327;
	Hsys[4][32] = -18'sd436;
	Hsys[0][33] = -18'sd184;
	Hsys[1][33] = -18'sd61;
	Hsys[2][33] = 18'sd61;
	Hsys[3][33] = 18'sd184;
	Hsys[4][33] = 18'sd245;
	Hsys[0][34] = -18'sd656;
	Hsys[1][34] = -18'sd219;
	Hsys[2][34] = 18'sd219;
	Hsys[3][34] = 18'sd656;
	Hsys[4][34] = 18'sd874;
	Hsys[0][35] = -18'sd768;
	Hsys[1][35] = -18'sd256;
	Hsys[2][35] = 18'sd256;
	Hsys[3][35] = 18'sd768;
	Hsys[4][35] = 18'sd1024;
	Hsys[0][36] = -18'sd388;
	Hsys[1][36] = -18'sd129;
	Hsys[2][36] = 18'sd129;
	Hsys[3][36] = 18'sd388;
	Hsys[4][36] = 18'sd517;
	Hsys[0][37] = 18'sd311;
	Hsys[1][37] = 18'sd104;
	Hsys[2][37] = -18'sd104;
	Hsys[3][37] = -18'sd311;
	Hsys[4][37] = -18'sd415;
	Hsys[0][38] = 18'sd916;
	Hsys[1][38] = 18'sd305;
	Hsys[2][38] = -18'sd305;
	Hsys[3][38] = -18'sd916;
	Hsys[4][38] = -18'sd1222;
	Hsys[0][39] = 18'sd1009;
	Hsys[1][39] = 18'sd336;
	Hsys[2][39] = -18'sd336;
	Hsys[3][39] = -18'sd1009;
	Hsys[4][39] = -18'sd1346;
	Hsys[0][40] = 18'sd445;
	Hsys[1][40] = 18'sd148;
	Hsys[2][40] = -18'sd148;
	Hsys[3][40] = -18'sd445;
	Hsys[4][40] = -18'sd593;
	Hsys[0][41] = -18'sd510;
	Hsys[1][41] = -18'sd170;
	Hsys[2][41] = 18'sd170;
	Hsys[3][41] = 18'sd510;
	Hsys[4][41] = 18'sd680;
	Hsys[0][42] = -18'sd1286;
	Hsys[1][42] = -18'sd429;
	Hsys[2][42] = 18'sd429;
	Hsys[3][42] = 18'sd1286;
	Hsys[4][42] = 18'sd1715;
	Hsys[0][43] = -18'sd1336;
	Hsys[1][43] = -18'sd445;
	Hsys[2][43] = 18'sd445;
	Hsys[3][43] = 18'sd1336;
	Hsys[4][43] = 18'sd1781;
	Hsys[0][44] = -18'sd499;
	Hsys[1][44] = -18'sd166;
	Hsys[2][44] = 18'sd166;
	Hsys[3][44] = 18'sd499;
	Hsys[4][44] = 18'sd666;
	Hsys[0][45] = 18'sd825;
	Hsys[1][45] = 18'sd275;
	Hsys[2][45] = -18'sd275;
	Hsys[3][45] = -18'sd825;
	Hsys[4][45] = -18'sd1100;
	Hsys[0][46] = 18'sd1842;
	Hsys[1][46] = 18'sd614;
	Hsys[2][46] = -18'sd614;
	Hsys[3][46] = -18'sd1842;
	Hsys[4][46] = -18'sd2456;
	Hsys[0][47] = 18'sd1812;
	Hsys[1][47] = 18'sd604;
	Hsys[2][47] = -18'sd604;
	Hsys[3][47] = -18'sd1812;
	Hsys[4][47] = -18'sd2416;
	Hsys[0][48] = 18'sd543;
	Hsys[1][48] = 18'sd181;
	Hsys[2][48] = -18'sd181;
	Hsys[3][48] = -18'sd543;
	Hsys[4][48] = -18'sd724;
	Hsys[0][49] = -18'sd1374;
	Hsys[1][49] = -18'sd458;
	Hsys[2][49] = 18'sd458;
	Hsys[3][49] = 18'sd1374;
	Hsys[4][49] = 18'sd1832;
	Hsys[0][50] = -18'sd2795;
	Hsys[1][50] = -18'sd932;
	Hsys[2][50] = 18'sd932;
	Hsys[3][50] = 18'sd2795;
	Hsys[4][50] = 18'sd3727;
	Hsys[0][51] = -18'sd2634;
	Hsys[1][51] = -18'sd878;
	Hsys[2][51] = 18'sd878;
	Hsys[3][51] = 18'sd2634;
	Hsys[4][51] = 18'sd3513;
	Hsys[0][52] = -18'sd579;
	Hsys[1][52] = -18'sd193;
	Hsys[2][52] = 18'sd193;
	Hsys[3][52] = 18'sd579;
	Hsys[4][52] = 18'sd772;
	Hsys[0][53] = 18'sd2531;
	Hsys[1][53] = 18'sd844;
	Hsys[2][53] = -18'sd844;
	Hsys[3][53] = -18'sd2531;
	Hsys[4][53] = -18'sd3374;
	Hsys[0][54] = 18'sd4910;
	Hsys[1][54] = 18'sd1637;
	Hsys[2][54] = -18'sd1637;
	Hsys[3][54] = -18'sd4910;
	Hsys[4][54] = -18'sd6547;
	Hsys[0][55] = 18'sd4626;
	Hsys[1][55] = 18'sd1542;
	Hsys[2][55] = -18'sd1542;
	Hsys[3][55] = -18'sd4626;
	Hsys[4][55] = -18'sd6168;
	Hsys[0][56] = 18'sd599;
	Hsys[1][56] = 18'sd200;
	Hsys[2][56] = -18'sd200;
	Hsys[3][56] = -18'sd599;
	Hsys[4][56] = -18'sd799;
	Hsys[0][57] = -18'sd6675;
	Hsys[1][57] = -18'sd2225;
	Hsys[2][57] = 18'sd2225;
	Hsys[3][57] = 18'sd6675;
	Hsys[4][57] = 18'sd8901;
	Hsys[0][58] = -18'sd15126;
	Hsys[1][58] = -18'sd5042;
	Hsys[2][58] = 18'sd5042;
	Hsys[3][58] = 18'sd15126;
	Hsys[4][58] = 18'sd20169;
	Hsys[0][59] = -18'sd21874;
	Hsys[1][59] = -18'sd7291;
	Hsys[2][59] = 18'sd7291;
	Hsys[3][59] = 18'sd21874;
	Hsys[4][59] = 18'sd29165;
	Hsys[0][60] = -18'sd24446;
	Hsys[1][60] = -18'sd8149;
	Hsys[2][60] = 18'sd8149;
	Hsys[3][60] = 18'sd24446;
	Hsys[4][60] = 18'sd32595;
	Hsys[0][61] = -18'sd21874;
	Hsys[1][61] = -18'sd7291;
	Hsys[2][61] = 18'sd7291;
	Hsys[3][61] = 18'sd21874;
	Hsys[4][61] = 18'sd29165;
	Hsys[0][62] = -18'sd15126;
	Hsys[1][62] = -18'sd5042;
	Hsys[2][62] = 18'sd5042;
	Hsys[3][62] = 18'sd15126;
	Hsys[4][62] = 18'sd20169;
	Hsys[0][63] = -18'sd6675;
	Hsys[1][63] = -18'sd2225;
	Hsys[2][63] = 18'sd2225;
	Hsys[3][63] = 18'sd6675;
	Hsys[4][63] = 18'sd8901;
	Hsys[0][64] = 18'sd599;
	Hsys[1][64] = 18'sd200;
	Hsys[2][64] = -18'sd200;
	Hsys[3][64] = -18'sd599;
	Hsys[4][64] = -18'sd799;
	Hsys[0][65] = 18'sd4626;
	Hsys[1][65] = 18'sd1542;
	Hsys[2][65] = -18'sd1542;
	Hsys[3][65] = -18'sd4626;
	Hsys[4][65] = -18'sd6168;
	Hsys[0][66] = 18'sd4910;
	Hsys[1][66] = 18'sd1637;
	Hsys[2][66] = -18'sd1637;
	Hsys[3][66] = -18'sd4910;
	Hsys[4][66] = -18'sd6547;
	Hsys[0][67] = 18'sd2531;
	Hsys[1][67] = 18'sd844;
	Hsys[2][67] = -18'sd844;
	Hsys[3][67] = -18'sd2531;
	Hsys[4][67] = -18'sd3374;
	Hsys[0][68] = -18'sd579;
	Hsys[1][68] = -18'sd193;
	Hsys[2][68] = 18'sd193;
	Hsys[3][68] = 18'sd579;
	Hsys[4][68] = 18'sd772;
	Hsys[0][69] = -18'sd2634;
	Hsys[1][69] = -18'sd878;
	Hsys[2][69] = 18'sd878;
	Hsys[3][69] = 18'sd2634;
	Hsys[4][69] = 18'sd3513;
	Hsys[0][70] = -18'sd2795;
	Hsys[1][70] = -18'sd932;
	Hsys[2][70] = 18'sd932;
	Hsys[3][70] = 18'sd2795;
	Hsys[4][70] = 18'sd3727;
	Hsys[0][71] = -18'sd1374;
	Hsys[1][71] = -18'sd458;
	Hsys[2][71] = 18'sd458;
	Hsys[3][71] = 18'sd1374;
	Hsys[4][71] = 18'sd1832;
	Hsys[0][72] = 18'sd543;
	Hsys[1][72] = 18'sd181;
	Hsys[2][72] = -18'sd181;
	Hsys[3][72] = -18'sd543;
	Hsys[4][72] = -18'sd724;
	Hsys[0][73] = 18'sd1812;
	Hsys[1][73] = 18'sd604;
	Hsys[2][73] = -18'sd604;
	Hsys[3][73] = -18'sd1812;
	Hsys[4][73] = -18'sd2416;
	Hsys[0][74] = 18'sd1842;
	Hsys[1][74] = 18'sd614;
	Hsys[2][74] = -18'sd614;
	Hsys[3][74] = -18'sd1842;
	Hsys[4][74] = -18'sd2456;
	Hsys[0][75] = 18'sd825;
	Hsys[1][75] = 18'sd275;
	Hsys[2][75] = -18'sd275;
	Hsys[3][75] = -18'sd825;
	Hsys[4][75] = -18'sd1100;
	Hsys[0][76] = -18'sd499;
	Hsys[1][76] = -18'sd166;
	Hsys[2][76] = 18'sd166;
	Hsys[3][76] = 18'sd499;
	Hsys[4][76] = 18'sd666;
	Hsys[0][77] = -18'sd1336;
	Hsys[1][77] = -18'sd445;
	Hsys[2][77] = 18'sd445;
	Hsys[3][77] = 18'sd1336;
	Hsys[4][77] = 18'sd1781;
	Hsys[0][78] = -18'sd1286;
	Hsys[1][78] = -18'sd429;
	Hsys[2][78] = 18'sd429;
	Hsys[3][78] = 18'sd1286;
	Hsys[4][78] = 18'sd1715;
	Hsys[0][79] = -18'sd510;
	Hsys[1][79] = -18'sd170;
	Hsys[2][79] = 18'sd170;
	Hsys[3][79] = 18'sd510;
	Hsys[4][79] = 18'sd680;
	Hsys[0][80] = 18'sd445;
	Hsys[1][80] = 18'sd148;
	Hsys[2][80] = -18'sd148;
	Hsys[3][80] = -18'sd445;
	Hsys[4][80] = -18'sd593;
	Hsys[0][81] = 18'sd1009;
	Hsys[1][81] = 18'sd336;
	Hsys[2][81] = -18'sd336;
	Hsys[3][81] = -18'sd1009;
	Hsys[4][81] = -18'sd1346;
	Hsys[0][82] = 18'sd916;
	Hsys[1][82] = 18'sd305;
	Hsys[2][82] = -18'sd305;
	Hsys[3][82] = -18'sd916;
	Hsys[4][82] = -18'sd1222;
	Hsys[0][83] = 18'sd311;
	Hsys[1][83] = 18'sd104;
	Hsys[2][83] = -18'sd104;
	Hsys[3][83] = -18'sd311;
	Hsys[4][83] = -18'sd415;
	Hsys[0][84] = -18'sd388;
	Hsys[1][84] = -18'sd129;
	Hsys[2][84] = 18'sd129;
	Hsys[3][84] = 18'sd388;
	Hsys[4][84] = 18'sd517;
	Hsys[0][85] = -18'sd768;
	Hsys[1][85] = -18'sd256;
	Hsys[2][85] = 18'sd256;
	Hsys[3][85] = 18'sd768;
	Hsys[4][85] = 18'sd1024;
	Hsys[0][86] = -18'sd656;
	Hsys[1][86] = -18'sd219;
	Hsys[2][86] = 18'sd219;
	Hsys[3][86] = 18'sd656;
	Hsys[4][86] = 18'sd874;
	Hsys[0][87] = -18'sd184;
	Hsys[1][87] = -18'sd61;
	Hsys[2][87] = 18'sd61;
	Hsys[3][87] = 18'sd184;
	Hsys[4][87] = 18'sd245;
	Hsys[0][88] = 18'sd327;
	Hsys[1][88] = 18'sd109;
	Hsys[2][88] = -18'sd109;
	Hsys[3][88] = -18'sd327;
	Hsys[4][88] = -18'sd436;
	Hsys[0][89] = 18'sd578;
	Hsys[1][89] = 18'sd193;
	Hsys[2][89] = -18'sd193;
	Hsys[3][89] = -18'sd578;
	Hsys[4][89] = -18'sd771;
	Hsys[0][90] = 18'sd463;
	Hsys[1][90] = 18'sd154;
	Hsys[2][90] = -18'sd154;
	Hsys[3][90] = -18'sd463;
	Hsys[4][90] = -18'sd618;
	Hsys[0][91] = 18'sd100;
	Hsys[1][91] = 18'sd33;
	Hsys[2][91] = -18'sd33;
	Hsys[3][91] = -18'sd100;
	Hsys[4][91] = -18'sd133;
	Hsys[0][92] = -18'sd269;
	Hsys[1][92] = -18'sd90;
	Hsys[2][92] = 18'sd90;
	Hsys[3][92] = 18'sd269;
	Hsys[4][92] = 18'sd358;
	Hsys[0][93] = -18'sd430;
	Hsys[1][93] = -18'sd143;
	Hsys[2][93] = 18'sd143;
	Hsys[3][93] = 18'sd430;
	Hsys[4][93] = 18'sd573;
	Hsys[0][94] = -18'sd323;
	Hsys[1][94] = -18'sd108;
	Hsys[2][94] = 18'sd108;
	Hsys[3][94] = 18'sd323;
	Hsys[4][94] = 18'sd430;
	Hsys[0][95] = -18'sd48;
	Hsys[1][95] = -18'sd16;
	Hsys[2][95] = 18'sd16;
	Hsys[3][95] = 18'sd48;
	Hsys[4][95] = 18'sd64;
	Hsys[0][96] = 18'sd212;
	Hsys[1][96] = 18'sd71;
	Hsys[2][96] = -18'sd71;
	Hsys[3][96] = -18'sd212;
	Hsys[4][96] = -18'sd282;
	Hsys[0][97] = 18'sd310;
	Hsys[1][97] = 18'sd103;
	Hsys[2][97] = -18'sd103;
	Hsys[3][97] = -18'sd310;
	Hsys[4][97] = -18'sd414;
	Hsys[0][98] = 18'sd217;
	Hsys[1][98] = 18'sd72;
	Hsys[2][98] = -18'sd72;
	Hsys[3][98] = -18'sd217;
	Hsys[4][98] = -18'sd290;
	Hsys[0][99] = 18'sd15;
	Hsys[1][99] = 18'sd5;
	Hsys[2][99] = -18'sd5;
	Hsys[3][99] = -18'sd15;
	Hsys[4][99] = -18'sd20;
	Hsys[0][100] = -18'sd163;
	Hsys[1][100] = -18'sd54;
	Hsys[2][100] = 18'sd54;
	Hsys[3][100] = 18'sd163;
	Hsys[4][100] = 18'sd217;
	Hsys[0][101] = -18'sd219;
	Hsys[1][101] = -18'sd73;
	Hsys[2][101] = 18'sd73;
	Hsys[3][101] = 18'sd219;
	Hsys[4][101] = 18'sd292;
	Hsys[0][102] = -18'sd143;
	Hsys[1][102] = -18'sd48;
	Hsys[2][102] = 18'sd48;
	Hsys[3][102] = 18'sd143;
	Hsys[4][102] = 18'sd190;
	Hsys[0][103] = 18'sd1;
	Hsys[1][103] = 18'sd0;
	Hsys[2][103] = 18'sd0;
	Hsys[3][103] = -18'sd1;
	Hsys[4][103] = -18'sd1;
	Hsys[0][104] = 18'sd118;
	Hsys[1][104] = 18'sd39;
	Hsys[2][104] = -18'sd39;
	Hsys[3][104] = -18'sd118;
	Hsys[4][104] = -18'sd157;
	Hsys[0][105] = 18'sd147;
	Hsys[1][105] = 18'sd49;
	Hsys[2][105] = -18'sd49;
	Hsys[3][105] = -18'sd147;
	Hsys[4][105] = -18'sd196;
	Hsys[0][106] = 18'sd88;
	Hsys[1][106] = 18'sd29;
	Hsys[2][106] = -18'sd29;
	Hsys[3][106] = -18'sd88;
	Hsys[4][106] = -18'sd117;
	Hsys[0][107] = -18'sd10;
	Hsys[1][107] = -18'sd3;
	Hsys[2][107] = 18'sd3;
	Hsys[3][107] = 18'sd10;
	Hsys[4][107] = 18'sd13;
	Hsys[0][108] = -18'sd83;
	Hsys[1][108] = -18'sd28;
	Hsys[2][108] = 18'sd28;
	Hsys[3][108] = 18'sd83;
	Hsys[4][108] = 18'sd111;
	Hsys[0][109] = -18'sd96;
	Hsys[1][109] = -18'sd32;
	Hsys[2][109] = 18'sd32;
	Hsys[3][109] = 18'sd96;
	Hsys[4][109] = 18'sd127;
	Hsys[0][110] = -18'sd52;
	Hsys[1][110] = -18'sd17;
	Hsys[2][110] = 18'sd17;
	Hsys[3][110] = 18'sd52;
	Hsys[4][110] = 18'sd70;
	Hsys[0][111] = 18'sd10;
	Hsys[1][111] = 18'sd3;
	Hsys[2][111] = -18'sd3;
	Hsys[3][111] = -18'sd10;
	Hsys[4][111] = -18'sd14;
	Hsys[0][112] = 18'sd53;
	Hsys[1][112] = 18'sd18;
	Hsys[2][112] = -18'sd18;
	Hsys[3][112] = -18'sd53;
	Hsys[4][112] = -18'sd71;
	Hsys[0][113] = 18'sd56;
	Hsys[1][113] = 18'sd19;
	Hsys[2][113] = -18'sd19;
	Hsys[3][113] = -18'sd56;
	Hsys[4][113] = -18'sd75;
	Hsys[0][114] = 18'sd27;
	Hsys[1][114] = 18'sd9;
	Hsys[2][114] = -18'sd9;
	Hsys[3][114] = -18'sd27;
	Hsys[4][114] = -18'sd36;
	Hsys[0][115] = -18'sd11;
	Hsys[1][115] = -18'sd4;
	Hsys[2][115] = 18'sd4;
	Hsys[3][115] = 18'sd11;
	Hsys[4][115] = 18'sd14;
	Hsys[0][116] = -18'sd33;
	Hsys[1][116] = -18'sd11;
	Hsys[2][116] = 18'sd11;
	Hsys[3][116] = 18'sd33;
	Hsys[4][116] = 18'sd45;
	Hsys[0][117] = -18'sd33;
	Hsys[1][117] = -18'sd11;
	Hsys[2][117] = 18'sd11;
	Hsys[3][117] = 18'sd33;
	Hsys[4][117] = 18'sd44;
	Hsys[0][118] = -18'sd16;
	Hsys[1][118] = -18'sd5;
	Hsys[2][118] = 18'sd5;
	Hsys[3][118] = 18'sd16;
	Hsys[4][118] = 18'sd22;
	Hsys[0][119] = 18'sd1;
	Hsys[1][119] = 18'sd0;
	Hsys[2][119] = 18'sd0;
	Hsys[3][119] = -18'sd1;
	Hsys[4][119] = -18'sd2;
	Hsys[0][120] = 18'sd44;
	Hsys[1][120] = 18'sd15;
	Hsys[2][120] = -18'sd15;
	Hsys[3][120] = -18'sd44;
	Hsys[4][120] = -18'sd59;
end

endmodule 