module PPS_filt #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter SUMLVL=7,
    parameter LENGTH=93,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter POSSMAPPER=7,
    parameter MAPSIZE=4,
    /* 46:0 first lvl regs; (46+1):(46+1+23-1+1) 2nd lvl; numbers in array count sym regs*/
//    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
	 parameter SUMLV1=47,
	 parameter SUMLV2=24,
	 parameter SUMLV3=12,
	 parameter SUMLV4=6,
	 parameter SUMLV5=3,
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
     tol=18'sd5;
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
     for (i=0; i<SUMLV1; i=i+1)
        mult_out[i]=18'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
end

//scale 1s17->2s16 for summing
always @ (posedge sys_clk)
    if (reset) 
        x[0]=18'sd0;
    else if (sam_clk_en) begin
        //x[0]<=$signed( {x_in[17],x_in[17:1]} );
        x[0]<=$signed(x_in );
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
            x[i]=$signed(x[i]);
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
				 if( x[i] == 18'sd131071 ) begin
					  mult_out[i] = Hsys[4][i];
					  //$display("%d %d",mult_out[i],Hsys[11][i]);
				 end
				 else if ( ( x[i]>(-18'sd98303-tol) ) && ( x[i]<(-18'sd98303+tol) ) ) mult_out[i] = Hsys[0][i];
				 else if ( ( x[i]>(-18'sd65536-tol) ) && ( x[i]<(-18'sd65536+tol) ) ) mult_out[i] = Hsys[1][i];
				 else if ( ( x[i]>(18'sd32768-tol) ) && ( x[i]<(18'sd32768+tol) ) ) mult_out[i] = Hsys[2][i];
				 else if ( ( x[i]>(18'sd98303-tol) ) && ( x[i]<(18'sd98303+tol) ) ) mult_out[i] = Hsys[3][i];
				 else mult_out[i] = 18'sd0;
    end


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] = 18'sd0;
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
            sum_lvl_2[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=$signed(sum_lvl_1[2*i])+$signed(sum_lvl_1[2*i+1]);
    end

always @ (posedge sys_clk)
    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(sum_lvl_1[SUMLV1-1]);

/*          SUMLV3              */

always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end

/*          SUMLV4              */

always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV4; i=i+1)
            sum_lvl_4[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV4; i=i+1)
            sum_lvl_4[i]<=$signed(sum_lvl_3[2*i])+$signed(sum_lvl_3[2*i+1]);
    end

/*          SUMLV5              */

always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_5[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_5[i]<=$signed(sum_lvl_4[2*i])+$signed(sum_lvl_4[2*i+1]);
    end

/*          SUMLV6              */

always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV6; i=i+1)
            sum_lvl_6[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV6; i=i+1)
            if (i==SUMLV6-1)
                sum_lvl_6[i]<=$signed(sum_lvl_5[SUMLV5-1]);
            else
                sum_lvl_6[i]<=$signed(sum_lvl_5[2*i])+$signed(sum_lvl_5[2*i+1]);
    end


/*          SUMLV7              */
always @ (posedge sys_clk)
    if (reset) sum_lvl_7 = 18'sd0;
    else if (sam_clk_en) sum_lvl_7 <= $signed(sum_lvl_6[0])+$signed(sum_lvl_6[1]);



always @ (posedge sys_clk)
    if (reset) y<= 18'sd0;
    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
    else if (sam_clk_en) y<=$signed(sum_lvl_7);
    else y<=$signed(y);

initial begin
	Hsys[0][0] = -18'sd9;
	Hsys[1][0] = -18'sd3;
	Hsys[2][0] = 18'sd3;
	Hsys[3][0] = 18'sd9;
	Hsys[4][0] = 18'sd23;
	Hsys[0][1] = -18'sd1;
	Hsys[1][1] = 18'sd0;
	Hsys[2][1] = 18'sd0;
	Hsys[3][1] = 18'sd1;
	Hsys[4][1] = 18'sd4;
	Hsys[0][2] = 18'sd9;
	Hsys[1][2] = 18'sd3;
	Hsys[2][2] = -18'sd3;
	Hsys[3][2] = -18'sd9;
	Hsys[4][2] = -18'sd25;
	Hsys[0][3] = 18'sd26;
	Hsys[1][3] = 18'sd9;
	Hsys[2][3] = -18'sd9;
	Hsys[3][3] = -18'sd26;
	Hsys[4][3] = -18'sd69;
	Hsys[0][4] = 18'sd39;
	Hsys[1][4] = 18'sd13;
	Hsys[2][4] = -18'sd13;
	Hsys[3][4] = -18'sd39;
	Hsys[4][4] = -18'sd103;
	Hsys[0][5] = 18'sd37;
	Hsys[1][5] = 18'sd12;
	Hsys[2][5] = -18'sd12;
	Hsys[3][5] = -18'sd37;
	Hsys[4][5] = -18'sd97;
	Hsys[0][6] = 18'sd13;
	Hsys[1][6] = 18'sd4;
	Hsys[2][6] = -18'sd4;
	Hsys[3][6] = -18'sd13;
	Hsys[4][6] = -18'sd36;
	Hsys[0][7] = -18'sd24;
	Hsys[1][7] = -18'sd8;
	Hsys[2][7] = 18'sd8;
	Hsys[3][7] = 18'sd24;
	Hsys[4][7] = 18'sd65;
	Hsys[0][8] = -18'sd57;
	Hsys[1][8] = -18'sd19;
	Hsys[2][8] = 18'sd19;
	Hsys[3][8] = 18'sd57;
	Hsys[4][8] = 18'sd153;
	Hsys[0][9] = -18'sd62;
	Hsys[1][9] = -18'sd21;
	Hsys[2][9] = 18'sd21;
	Hsys[3][9] = 18'sd62;
	Hsys[4][9] = 18'sd165;
	Hsys[0][10] = -18'sd25;
	Hsys[1][10] = -18'sd8;
	Hsys[2][10] = 18'sd8;
	Hsys[3][10] = 18'sd25;
	Hsys[4][10] = 18'sd67;
	Hsys[0][11] = 18'sd41;
	Hsys[1][11] = 18'sd14;
	Hsys[2][11] = -18'sd14;
	Hsys[3][11] = -18'sd41;
	Hsys[4][11] = -18'sd108;
	Hsys[0][12] = 18'sd99;
	Hsys[1][12] = 18'sd33;
	Hsys[2][12] = -18'sd33;
	Hsys[3][12] = -18'sd99;
	Hsys[4][12] = -18'sd265;
	Hsys[0][13] = 18'sd109;
	Hsys[1][13] = 18'sd36;
	Hsys[2][13] = -18'sd36;
	Hsys[3][13] = -18'sd109;
	Hsys[4][13] = -18'sd292;
	Hsys[0][14] = 18'sd49;
	Hsys[1][14] = 18'sd16;
	Hsys[2][14] = -18'sd16;
	Hsys[3][14] = -18'sd49;
	Hsys[4][14] = -18'sd131;
	Hsys[0][15] = -18'sd60;
	Hsys[1][15] = -18'sd20;
	Hsys[2][15] = 18'sd20;
	Hsys[3][15] = 18'sd60;
	Hsys[4][15] = 18'sd160;
	Hsys[0][16] = -18'sd158;
	Hsys[1][16] = -18'sd53;
	Hsys[2][16] = 18'sd53;
	Hsys[3][16] = 18'sd158;
	Hsys[4][16] = 18'sd421;
	Hsys[0][17] = -18'sd176;
	Hsys[1][17] = -18'sd59;
	Hsys[2][17] = 18'sd59;
	Hsys[3][17] = 18'sd176;
	Hsys[4][17] = 18'sd470;
	Hsys[0][18] = -18'sd83;
	Hsys[1][18] = -18'sd28;
	Hsys[2][18] = 18'sd28;
	Hsys[3][18] = 18'sd83;
	Hsys[4][18] = 18'sd222;
	Hsys[0][19] = 18'sd86;
	Hsys[1][19] = 18'sd29;
	Hsys[2][19] = -18'sd29;
	Hsys[3][19] = -18'sd86;
	Hsys[4][19] = -18'sd230;
	Hsys[0][20] = 18'sd238;
	Hsys[1][20] = 18'sd79;
	Hsys[2][20] = -18'sd79;
	Hsys[3][20] = -18'sd238;
	Hsys[4][20] = -18'sd634;
	Hsys[0][21] = 18'sd266;
	Hsys[1][21] = 18'sd89;
	Hsys[2][21] = -18'sd89;
	Hsys[3][21] = -18'sd266;
	Hsys[4][21] = -18'sd710;
	Hsys[0][22] = 18'sd127;
	Hsys[1][22] = 18'sd42;
	Hsys[2][22] = -18'sd42;
	Hsys[3][22] = -18'sd127;
	Hsys[4][22] = -18'sd339;
	Hsys[0][23] = -18'sd124;
	Hsys[1][23] = -18'sd41;
	Hsys[2][23] = 18'sd41;
	Hsys[3][23] = 18'sd124;
	Hsys[4][23] = 18'sd330;
	Hsys[0][24] = -18'sd344;
	Hsys[1][24] = -18'sd115;
	Hsys[2][24] = 18'sd115;
	Hsys[3][24] = 18'sd344;
	Hsys[4][24] = 18'sd918;
	Hsys[0][25] = -18'sd383;
	Hsys[1][25] = -18'sd128;
	Hsys[2][25] = 18'sd128;
	Hsys[3][25] = 18'sd383;
	Hsys[4][25] = 18'sd1021;
	Hsys[0][26] = -18'sd179;
	Hsys[1][26] = -18'sd60;
	Hsys[2][26] = 18'sd60;
	Hsys[3][26] = 18'sd179;
	Hsys[4][26] = 18'sd478;
	Hsys[0][27] = 18'sd180;
	Hsys[1][27] = 18'sd60;
	Hsys[2][27] = -18'sd60;
	Hsys[3][27] = -18'sd180;
	Hsys[4][27] = -18'sd479;
	Hsys[0][28] = 18'sd487;
	Hsys[1][28] = 18'sd162;
	Hsys[2][28] = -18'sd162;
	Hsys[3][28] = -18'sd487;
	Hsys[4][28] = -18'sd1299;
	Hsys[0][29] = 18'sd532;
	Hsys[1][29] = 18'sd177;
	Hsys[2][29] = -18'sd177;
	Hsys[3][29] = -18'sd532;
	Hsys[4][29] = -18'sd1418;
	Hsys[0][30] = 18'sd236;
	Hsys[1][30] = 18'sd79;
	Hsys[2][30] = -18'sd79;
	Hsys[3][30] = -18'sd236;
	Hsys[4][30] = -18'sd629;
	Hsys[0][31] = -18'sd268;
	Hsys[1][31] = -18'sd89;
	Hsys[2][31] = 18'sd89;
	Hsys[3][31] = 18'sd268;
	Hsys[4][31] = 18'sd714;
	Hsys[0][32] = -18'sd685;
	Hsys[1][32] = -18'sd228;
	Hsys[2][32] = 18'sd228;
	Hsys[3][32] = 18'sd685;
	Hsys[4][32] = 18'sd1827;
	Hsys[0][33] = -18'sd726;
	Hsys[1][33] = -18'sd242;
	Hsys[2][33] = 18'sd242;
	Hsys[3][33] = 18'sd726;
	Hsys[4][33] = 18'sd1936;
	Hsys[0][34] = -18'sd293;
	Hsys[1][34] = -18'sd98;
	Hsys[2][34] = 18'sd98;
	Hsys[3][34] = 18'sd293;
	Hsys[4][34] = 18'sd782;
	Hsys[0][35] = 18'sd414;
	Hsys[1][35] = 18'sd138;
	Hsys[2][35] = -18'sd138;
	Hsys[3][35] = -18'sd414;
	Hsys[4][35] = -18'sd1105;
	Hsys[0][36] = 18'sd979;
	Hsys[1][36] = 18'sd326;
	Hsys[2][36] = -18'sd326;
	Hsys[3][36] = -18'sd979;
	Hsys[4][36] = -18'sd2612;
	Hsys[0][37] = 18'sd998;
	Hsys[1][37] = 18'sd333;
	Hsys[2][37] = -18'sd333;
	Hsys[3][37] = -18'sd998;
	Hsys[4][37] = -18'sd2661;
	Hsys[0][38] = 18'sd346;
	Hsys[1][38] = 18'sd115;
	Hsys[2][38] = -18'sd115;
	Hsys[3][38] = -18'sd346;
	Hsys[4][38] = -18'sd922;
	Hsys[0][39] = -18'sd682;
	Hsys[1][39] = -18'sd227;
	Hsys[2][39] = 18'sd227;
	Hsys[3][39] = 18'sd682;
	Hsys[4][39] = 18'sd1820;
	Hsys[0][40] = -18'sd1478;
	Hsys[1][40] = -18'sd493;
	Hsys[2][40] = 18'sd493;
	Hsys[3][40] = 18'sd1478;
	Hsys[4][40] = 18'sd3943;
	Hsys[0][41] = -18'sd1446;
	Hsys[1][41] = -18'sd482;
	Hsys[2][41] = 18'sd482;
	Hsys[3][41] = 18'sd1446;
	Hsys[4][41] = 18'sd3857;
	Hsys[0][42] = -18'sd388;
	Hsys[1][42] = -18'sd129;
	Hsys[2][42] = 18'sd129;
	Hsys[3][42] = 18'sd388;
	Hsys[4][42] = 18'sd1035;
	Hsys[0][43] = 18'sd1272;
	Hsys[1][43] = 18'sd424;
	Hsys[2][43] = -18'sd424;
	Hsys[3][43] = -18'sd1272;
	Hsys[4][43] = -18'sd3392;
	Hsys[0][44] = 18'sd2586;
	Hsys[1][44] = 18'sd862;
	Hsys[2][44] = -18'sd862;
	Hsys[3][44] = -18'sd2586;
	Hsys[4][44] = -18'sd6897;
	Hsys[0][45] = 18'sd2503;
	Hsys[1][45] = 18'sd834;
	Hsys[2][45] = -18'sd834;
	Hsys[3][45] = -18'sd2503;
	Hsys[4][45] = -18'sd6673;
	Hsys[0][46] = 18'sd415;
	Hsys[1][46] = 18'sd138;
	Hsys[2][46] = -18'sd138;
	Hsys[3][46] = -18'sd415;
	Hsys[4][46] = -18'sd1107;
	Hsys[0][47] = -18'sd3435;
	Hsys[1][47] = -18'sd1145;
	Hsys[2][47] = 18'sd1145;
	Hsys[3][47] = 18'sd3435;
	Hsys[4][47] = 18'sd9160;
	Hsys[0][48] = -18'sd7945;
	Hsys[1][48] = -18'sd2648;
	Hsys[2][48] = 18'sd2648;
	Hsys[3][48] = 18'sd7945;
	Hsys[4][48] = 18'sd21186;
	Hsys[0][49] = -18'sd11560;
	Hsys[1][49] = -18'sd3853;
	Hsys[2][49] = 18'sd3853;
	Hsys[3][49] = 18'sd11560;
	Hsys[4][49] = 18'sd30827;
	Hsys[0][50] = -18'sd12941;
	Hsys[1][50] = -18'sd4314;
	Hsys[2][50] = 18'sd4314;
	Hsys[3][50] = 18'sd12941;
	Hsys[4][50] = 18'sd34509;
	Hsys[0][51] = -18'sd11560;
	Hsys[1][51] = -18'sd3853;
	Hsys[2][51] = 18'sd3853;
	Hsys[3][51] = 18'sd11560;
	Hsys[4][51] = 18'sd30827;
	Hsys[0][52] = -18'sd7945;
	Hsys[1][52] = -18'sd2648;
	Hsys[2][52] = 18'sd2648;
	Hsys[3][52] = 18'sd7945;
	Hsys[4][52] = 18'sd21186;
	Hsys[0][53] = -18'sd3435;
	Hsys[1][53] = -18'sd1145;
	Hsys[2][53] = 18'sd1145;
	Hsys[3][53] = 18'sd3435;
	Hsys[4][53] = 18'sd9160;
	Hsys[0][54] = 18'sd415;
	Hsys[1][54] = 18'sd138;
	Hsys[2][54] = -18'sd138;
	Hsys[3][54] = -18'sd415;
	Hsys[4][54] = -18'sd1107;
	Hsys[0][55] = 18'sd2503;
	Hsys[1][55] = 18'sd834;
	Hsys[2][55] = -18'sd834;
	Hsys[3][55] = -18'sd2503;
	Hsys[4][55] = -18'sd6673;
	Hsys[0][56] = 18'sd2586;
	Hsys[1][56] = 18'sd862;
	Hsys[2][56] = -18'sd862;
	Hsys[3][56] = -18'sd2586;
	Hsys[4][56] = -18'sd6897;
	Hsys[0][57] = 18'sd1272;
	Hsys[1][57] = 18'sd424;
	Hsys[2][57] = -18'sd424;
	Hsys[3][57] = -18'sd1272;
	Hsys[4][57] = -18'sd3392;
	Hsys[0][58] = -18'sd388;
	Hsys[1][58] = -18'sd129;
	Hsys[2][58] = 18'sd129;
	Hsys[3][58] = 18'sd388;
	Hsys[4][58] = 18'sd1035;
	Hsys[0][59] = -18'sd1446;
	Hsys[1][59] = -18'sd482;
	Hsys[2][59] = 18'sd482;
	Hsys[3][59] = 18'sd1446;
	Hsys[4][59] = 18'sd3857;
	Hsys[0][60] = -18'sd1478;
	Hsys[1][60] = -18'sd493;
	Hsys[2][60] = 18'sd493;
	Hsys[3][60] = 18'sd1478;
	Hsys[4][60] = 18'sd3943;
	Hsys[0][61] = -18'sd682;
	Hsys[1][61] = -18'sd227;
	Hsys[2][61] = 18'sd227;
	Hsys[3][61] = 18'sd682;
	Hsys[4][61] = 18'sd1820;
	Hsys[0][62] = 18'sd346;
	Hsys[1][62] = 18'sd115;
	Hsys[2][62] = -18'sd115;
	Hsys[3][62] = -18'sd346;
	Hsys[4][62] = -18'sd922;
	Hsys[0][63] = 18'sd998;
	Hsys[1][63] = 18'sd333;
	Hsys[2][63] = -18'sd333;
	Hsys[3][63] = -18'sd998;
	Hsys[4][63] = -18'sd2661;
	Hsys[0][64] = 18'sd979;
	Hsys[1][64] = 18'sd326;
	Hsys[2][64] = -18'sd326;
	Hsys[3][64] = -18'sd979;
	Hsys[4][64] = -18'sd2612;
	Hsys[0][65] = 18'sd414;
	Hsys[1][65] = 18'sd138;
	Hsys[2][65] = -18'sd138;
	Hsys[3][65] = -18'sd414;
	Hsys[4][65] = -18'sd1105;
	Hsys[0][66] = -18'sd293;
	Hsys[1][66] = -18'sd98;
	Hsys[2][66] = 18'sd98;
	Hsys[3][66] = 18'sd293;
	Hsys[4][66] = 18'sd782;
	Hsys[0][67] = -18'sd726;
	Hsys[1][67] = -18'sd242;
	Hsys[2][67] = 18'sd242;
	Hsys[3][67] = 18'sd726;
	Hsys[4][67] = 18'sd1936;
	Hsys[0][68] = -18'sd685;
	Hsys[1][68] = -18'sd228;
	Hsys[2][68] = 18'sd228;
	Hsys[3][68] = 18'sd685;
	Hsys[4][68] = 18'sd1827;
	Hsys[0][69] = -18'sd268;
	Hsys[1][69] = -18'sd89;
	Hsys[2][69] = 18'sd89;
	Hsys[3][69] = 18'sd268;
	Hsys[4][69] = 18'sd714;
	Hsys[0][70] = 18'sd236;
	Hsys[1][70] = 18'sd79;
	Hsys[2][70] = -18'sd79;
	Hsys[3][70] = -18'sd236;
	Hsys[4][70] = -18'sd629;
	Hsys[0][71] = 18'sd532;
	Hsys[1][71] = 18'sd177;
	Hsys[2][71] = -18'sd177;
	Hsys[3][71] = -18'sd532;
	Hsys[4][71] = -18'sd1418;
	Hsys[0][72] = 18'sd487;
	Hsys[1][72] = 18'sd162;
	Hsys[2][72] = -18'sd162;
	Hsys[3][72] = -18'sd487;
	Hsys[4][72] = -18'sd1299;
	Hsys[0][73] = 18'sd180;
	Hsys[1][73] = 18'sd60;
	Hsys[2][73] = -18'sd60;
	Hsys[3][73] = -18'sd180;
	Hsys[4][73] = -18'sd479;
	Hsys[0][74] = -18'sd179;
	Hsys[1][74] = -18'sd60;
	Hsys[2][74] = 18'sd60;
	Hsys[3][74] = 18'sd179;
	Hsys[4][74] = 18'sd478;
	Hsys[0][75] = -18'sd383;
	Hsys[1][75] = -18'sd128;
	Hsys[2][75] = 18'sd128;
	Hsys[3][75] = 18'sd383;
	Hsys[4][75] = 18'sd1021;
	Hsys[0][76] = -18'sd344;
	Hsys[1][76] = -18'sd115;
	Hsys[2][76] = 18'sd115;
	Hsys[3][76] = 18'sd344;
	Hsys[4][76] = 18'sd918;
	Hsys[0][77] = -18'sd124;
	Hsys[1][77] = -18'sd41;
	Hsys[2][77] = 18'sd41;
	Hsys[3][77] = 18'sd124;
	Hsys[4][77] = 18'sd330;
	Hsys[0][78] = 18'sd127;
	Hsys[1][78] = 18'sd42;
	Hsys[2][78] = -18'sd42;
	Hsys[3][78] = -18'sd127;
	Hsys[4][78] = -18'sd339;
	Hsys[0][79] = 18'sd266;
	Hsys[1][79] = 18'sd89;
	Hsys[2][79] = -18'sd89;
	Hsys[3][79] = -18'sd266;
	Hsys[4][79] = -18'sd710;
	Hsys[0][80] = 18'sd238;
	Hsys[1][80] = 18'sd79;
	Hsys[2][80] = -18'sd79;
	Hsys[3][80] = -18'sd238;
	Hsys[4][80] = -18'sd634;
	Hsys[0][81] = 18'sd86;
	Hsys[1][81] = 18'sd29;
	Hsys[2][81] = -18'sd29;
	Hsys[3][81] = -18'sd86;
	Hsys[4][81] = -18'sd230;
	Hsys[0][82] = -18'sd83;
	Hsys[1][82] = -18'sd28;
	Hsys[2][82] = 18'sd28;
	Hsys[3][82] = 18'sd83;
	Hsys[4][82] = 18'sd222;
	Hsys[0][83] = -18'sd176;
	Hsys[1][83] = -18'sd59;
	Hsys[2][83] = 18'sd59;
	Hsys[3][83] = 18'sd176;
	Hsys[4][83] = 18'sd470;
	Hsys[0][84] = -18'sd158;
	Hsys[1][84] = -18'sd53;
	Hsys[2][84] = 18'sd53;
	Hsys[3][84] = 18'sd158;
	Hsys[4][84] = 18'sd421;
	Hsys[0][85] = -18'sd60;
	Hsys[1][85] = -18'sd20;
	Hsys[2][85] = 18'sd20;
	Hsys[3][85] = 18'sd60;
	Hsys[4][85] = 18'sd160;
	Hsys[0][86] = 18'sd49;
	Hsys[1][86] = 18'sd16;
	Hsys[2][86] = -18'sd16;
	Hsys[3][86] = -18'sd49;
	Hsys[4][86] = -18'sd131;
	Hsys[0][87] = 18'sd109;
	Hsys[1][87] = 18'sd36;
	Hsys[2][87] = -18'sd36;
	Hsys[3][87] = -18'sd109;
	Hsys[4][87] = -18'sd292;
	Hsys[0][88] = 18'sd99;
	Hsys[1][88] = 18'sd33;
	Hsys[2][88] = -18'sd33;
	Hsys[3][88] = -18'sd99;
	Hsys[4][88] = -18'sd265;
	Hsys[0][89] = 18'sd41;
	Hsys[1][89] = 18'sd14;
	Hsys[2][89] = -18'sd14;
	Hsys[3][89] = -18'sd41;
	Hsys[4][89] = -18'sd108;
	Hsys[0][90] = -18'sd25;
	Hsys[1][90] = -18'sd8;
	Hsys[2][90] = 18'sd8;
	Hsys[3][90] = 18'sd25;
	Hsys[4][90] = 18'sd67;
	Hsys[0][91] = -18'sd62;
	Hsys[1][91] = -18'sd21;
	Hsys[2][91] = 18'sd21;
	Hsys[3][91] = 18'sd62;
	Hsys[4][91] = 18'sd165;
	Hsys[0][92] = -18'sd57;
	Hsys[1][92] = -18'sd19;
	Hsys[2][92] = 18'sd19;
	Hsys[3][92] = 18'sd57;
	Hsys[4][92] = 18'sd153;
	Hsys[0][93] = -18'sd24;
	Hsys[1][93] = -18'sd8;
	Hsys[2][93] = 18'sd8;
	Hsys[3][93] = 18'sd24;
	Hsys[4][93] = 18'sd65;
	Hsys[0][94] = 18'sd13;
	Hsys[1][94] = 18'sd4;
	Hsys[2][94] = -18'sd4;
	Hsys[3][94] = -18'sd13;
	Hsys[4][94] = -18'sd36;
	Hsys[0][95] = 18'sd37;
	Hsys[1][95] = 18'sd12;
	Hsys[2][95] = -18'sd12;
	Hsys[3][95] = -18'sd37;
	Hsys[4][95] = -18'sd97;
	Hsys[0][96] = 18'sd39;
	Hsys[1][96] = 18'sd13;
	Hsys[2][96] = -18'sd13;
	Hsys[3][96] = -18'sd39;
	Hsys[4][96] = -18'sd103;
	Hsys[0][97] = 18'sd26;
	Hsys[1][97] = 18'sd9;
	Hsys[2][97] = -18'sd9;
	Hsys[3][97] = -18'sd26;
	Hsys[4][97] = -18'sd69;
	Hsys[0][98] = 18'sd9;
	Hsys[1][98] = 18'sd3;
	Hsys[2][98] = -18'sd3;
	Hsys[3][98] = -18'sd9;
	Hsys[4][98] = -18'sd25;
	Hsys[0][99] = -18'sd1;
	Hsys[1][99] = 18'sd0;
	Hsys[2][99] = 18'sd0;
	Hsys[3][99] = 18'sd1;
	Hsys[4][99] = 18'sd4;
	Hsys[0][100] = -18'sd9;
	Hsys[1][100] = -18'sd3;
	Hsys[2][100] = 18'sd3;
	Hsys[3][100] = 18'sd9;
	Hsys[4][100] = 18'sd23;
end

endmodule 
