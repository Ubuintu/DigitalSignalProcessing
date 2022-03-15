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
(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
(* noprune *) reg signed [WIDTH-1:0] tol;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[MAPSIZE+POSSMAPPER:0][(LENGTH-1)/2:0];

integer i,j;
initial begin
     tol=18'sd10;
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
        x[0]<=$signed( {x_in[17],x_in[17:1]} );
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


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] = 18'sd0;
    end
    else if (sam_clk_en) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] = $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] = 18'sd0;
	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] = $signed(x[SUMLV1-1]);
	else sum_lvl_1[SUMLV1-1] = $signed(sum_lvl_1[SUMLV1-1]);


//always @ (posedge clk)
always @ *
    if (reset) begin
		 for(i=0;i<SUMLV1; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for(i=0; i<SUMLV1; i=i+1)
            if( i<SUMLV1-2 ) begin 
                /*For verifying taps*/
                if( sum_lvl_1[i] == 18'sd65500 ) begin
                    mult_out[i] <= Hsys[11][i];
                    //$display("%d %d",mult_out[i],Hsys[11][i]);
                end
                else if ( ( sum_lvl_1[i]>(-18'sd98303-tol) ) && ( sum_lvl_1[i]<(-18'sd98303+tol) ) ) mult_out[i] <= Hsys[0][i];
                else if ( ( sum_lvl_1[i]>(-18'sd65536-tol) ) && ( sum_lvl_1[i]<(-18'sd65536+tol) ) ) mult_out[i] <= Hsys[1][i];
                else if ( ( sum_lvl_1[i]>(-18'sd32768-tol) ) && ( sum_lvl_1[i]<(-18'sd32768+tol) ) ) mult_out[i] <= Hsys[2][i];
                else if ( ( sum_lvl_1[i]>(18'sd0-tol) ) && ( sum_lvl_1[i]<(18'sd0+tol) ) ) mult_out[i] <= Hsys[3][i];
                else if ( ( sum_lvl_1[i]>(18'sd32768-tol) ) && ( sum_lvl_1[i]<(18'sd32768+tol) ) ) mult_out[i] <= Hsys[4][i];
                else if ( ( sum_lvl_1[i]>(18'sd65536-tol) ) && ( sum_lvl_1[i]<(18'sd65536+tol) ) ) mult_out[i] <= Hsys[5][i];
                else if ( ( sum_lvl_1[i]>(18'sd98303-tol) ) && ( sum_lvl_1[i]<(18'sd98303+tol) ) ) mult_out[i] <= Hsys[6][i];
                else mult_out[i] = 18'sd0;
                end
            else begin
                /*For verifying taps*/
                if( sum_lvl_1[i] == 18'sd65500 ) mult_out[i] <= Hsys[11][i];
                else if ( ( sum_lvl_1[i]>(-18'sd49152-tol) ) && ( sum_lvl_1[i]<(-18'sd49152+tol) ) ) mult_out[i] <= Hsys[7][i];
                else if ( ( sum_lvl_1[i]>(-18'sd16384-tol) ) && ( sum_lvl_1[i]<(-18'sd16384+tol) ) ) mult_out[i] <= Hsys[8][i];
                else if ( ( sum_lvl_1[i]>(18'sd16384-tol) ) && ( sum_lvl_1[i]<(18'sd16384+tol) ) ) mult_out[i] <= Hsys[9][i];
                else if ( ( sum_lvl_1[i]>(18'sd49152-tol) ) && ( sum_lvl_1[i]<(18'sd49152+tol) ) ) mult_out[i] <= Hsys[10][i];
                else mult_out[i] <= 18'sd0;
            end
    end
//!!! SEE D3.m for structure of filter/center tap location !!!
/*          SUMLV2              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=$signed(mult_out[2*i])+$signed(mult_out[2*i+1]);
    end

always @ (posedge sys_clk)
    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1]);

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
	Hsys[0][0] = 18'sd33;
	Hsys[1][0] = 18'sd22;
	Hsys[2][0] = 18'sd11;
	Hsys[3][0] = 18'sd0;
	Hsys[4][0] = -18'sd11;
	Hsys[5][0] = -18'sd22;
	Hsys[6][0] = -18'sd33;
	Hsys[7][0] = 18'sd17;
	Hsys[8][0] = 18'sd6;
	Hsys[9][0] = -18'sd6;
	Hsys[10][0] = -18'sd17;
	Hsys[11][0] = -18'sd44;
	Hsys[0][1] = 18'sd10;
	Hsys[1][1] = 18'sd7;
	Hsys[2][1] = 18'sd3;
	Hsys[3][1] = 18'sd0;
	Hsys[4][1] = -18'sd3;
	Hsys[5][1] = -18'sd7;
	Hsys[6][1] = -18'sd10;
	Hsys[7][1] = 18'sd5;
	Hsys[8][1] = 18'sd2;
	Hsys[9][1] = -18'sd2;
	Hsys[10][1] = -18'sd5;
	Hsys[11][1] = -18'sd13;
	Hsys[0][2] = -18'sd27;
	Hsys[1][2] = -18'sd18;
	Hsys[2][2] = -18'sd9;
	Hsys[3][2] = 18'sd0;
	Hsys[4][2] = 18'sd9;
	Hsys[5][2] = 18'sd18;
	Hsys[6][2] = 18'sd27;
	Hsys[7][2] = -18'sd14;
	Hsys[8][2] = -18'sd5;
	Hsys[9][2] = 18'sd5;
	Hsys[10][2] = 18'sd14;
	Hsys[11][2] = 18'sd36;
	Hsys[0][3] = -18'sd85;
	Hsys[1][3] = -18'sd57;
	Hsys[2][3] = -18'sd28;
	Hsys[3][3] = 18'sd0;
	Hsys[4][3] = 18'sd28;
	Hsys[5][3] = 18'sd57;
	Hsys[6][3] = 18'sd85;
	Hsys[7][3] = -18'sd42;
	Hsys[8][3] = -18'sd14;
	Hsys[9][3] = 18'sd14;
	Hsys[10][3] = 18'sd42;
	Hsys[11][3] = 18'sd113;
	Hsys[0][4] = -18'sd132;
	Hsys[1][4] = -18'sd88;
	Hsys[2][4] = -18'sd44;
	Hsys[3][4] = 18'sd0;
	Hsys[4][4] = 18'sd44;
	Hsys[5][4] = 18'sd88;
	Hsys[6][4] = 18'sd132;
	Hsys[7][4] = -18'sd66;
	Hsys[8][4] = -18'sd22;
	Hsys[9][4] = 18'sd22;
	Hsys[10][4] = 18'sd66;
	Hsys[11][4] = 18'sd176;
	Hsys[0][5] = -18'sd128;
	Hsys[1][5] = -18'sd86;
	Hsys[2][5] = -18'sd43;
	Hsys[3][5] = 18'sd0;
	Hsys[4][5] = 18'sd43;
	Hsys[5][5] = 18'sd86;
	Hsys[6][5] = 18'sd128;
	Hsys[7][5] = -18'sd64;
	Hsys[8][5] = -18'sd21;
	Hsys[9][5] = 18'sd21;
	Hsys[10][5] = 18'sd64;
	Hsys[11][5] = 18'sd171;
	Hsys[0][6] = -18'sd53;
	Hsys[1][6] = -18'sd35;
	Hsys[2][6] = -18'sd18;
	Hsys[3][6] = 18'sd0;
	Hsys[4][6] = 18'sd18;
	Hsys[5][6] = 18'sd35;
	Hsys[6][6] = 18'sd53;
	Hsys[7][6] = -18'sd26;
	Hsys[8][6] = -18'sd9;
	Hsys[9][6] = 18'sd9;
	Hsys[10][6] = 18'sd26;
	Hsys[11][6] = 18'sd70;
	Hsys[0][7] = 18'sd74;
	Hsys[1][7] = 18'sd50;
	Hsys[2][7] = 18'sd25;
	Hsys[3][7] = 18'sd0;
	Hsys[4][7] = -18'sd25;
	Hsys[5][7] = -18'sd50;
	Hsys[6][7] = -18'sd74;
	Hsys[7][7] = 18'sd37;
	Hsys[8][7] = 18'sd12;
	Hsys[9][7] = -18'sd12;
	Hsys[10][7] = -18'sd37;
	Hsys[11][7] = -18'sd99;
	Hsys[0][8] = 18'sd187;
	Hsys[1][8] = 18'sd124;
	Hsys[2][8] = 18'sd62;
	Hsys[3][8] = 18'sd0;
	Hsys[4][8] = -18'sd62;
	Hsys[5][8] = -18'sd124;
	Hsys[6][8] = -18'sd187;
	Hsys[7][8] = 18'sd93;
	Hsys[8][8] = 18'sd31;
	Hsys[9][8] = -18'sd31;
	Hsys[10][8] = -18'sd93;
	Hsys[11][8] = -18'sd249;
	Hsys[0][9] = 18'sd206;
	Hsys[1][9] = 18'sd137;
	Hsys[2][9] = 18'sd69;
	Hsys[3][9] = 18'sd0;
	Hsys[4][9] = -18'sd69;
	Hsys[5][9] = -18'sd137;
	Hsys[6][9] = -18'sd206;
	Hsys[7][9] = 18'sd103;
	Hsys[8][9] = 18'sd34;
	Hsys[9][9] = -18'sd34;
	Hsys[10][9] = -18'sd103;
	Hsys[11][9] = -18'sd274;
	Hsys[0][10] = 18'sd91;
	Hsys[1][10] = 18'sd61;
	Hsys[2][10] = 18'sd30;
	Hsys[3][10] = 18'sd0;
	Hsys[4][10] = -18'sd30;
	Hsys[5][10] = -18'sd61;
	Hsys[6][10] = -18'sd91;
	Hsys[7][10] = 18'sd45;
	Hsys[8][10] = 18'sd15;
	Hsys[9][10] = -18'sd15;
	Hsys[10][10] = -18'sd45;
	Hsys[11][10] = -18'sd121;
	Hsys[0][11] = -18'sd119;
	Hsys[1][11] = -18'sd80;
	Hsys[2][11] = -18'sd40;
	Hsys[3][11] = 18'sd0;
	Hsys[4][11] = 18'sd40;
	Hsys[5][11] = 18'sd80;
	Hsys[6][11] = 18'sd119;
	Hsys[7][11] = -18'sd60;
	Hsys[8][11] = -18'sd20;
	Hsys[9][11] = 18'sd20;
	Hsys[10][11] = 18'sd60;
	Hsys[11][11] = 18'sd159;
	Hsys[0][12] = -18'sd310;
	Hsys[1][12] = -18'sd206;
	Hsys[2][12] = -18'sd103;
	Hsys[3][12] = 18'sd0;
	Hsys[4][12] = 18'sd103;
	Hsys[5][12] = 18'sd206;
	Hsys[6][12] = 18'sd310;
	Hsys[7][12] = -18'sd155;
	Hsys[8][12] = -18'sd52;
	Hsys[9][12] = 18'sd52;
	Hsys[10][12] = 18'sd155;
	Hsys[11][12] = 18'sd413;
	Hsys[0][13] = -18'sd346;
	Hsys[1][13] = -18'sd231;
	Hsys[2][13] = -18'sd115;
	Hsys[3][13] = 18'sd0;
	Hsys[4][13] = 18'sd115;
	Hsys[5][13] = 18'sd231;
	Hsys[6][13] = 18'sd346;
	Hsys[7][13] = -18'sd173;
	Hsys[8][13] = -18'sd58;
	Hsys[9][13] = 18'sd58;
	Hsys[10][13] = 18'sd173;
	Hsys[11][13] = 18'sd462;
	Hsys[0][14] = -18'sd164;
	Hsys[1][14] = -18'sd109;
	Hsys[2][14] = -18'sd55;
	Hsys[3][14] = 18'sd0;
	Hsys[4][14] = 18'sd55;
	Hsys[5][14] = 18'sd109;
	Hsys[6][14] = 18'sd164;
	Hsys[7][14] = -18'sd82;
	Hsys[8][14] = -18'sd27;
	Hsys[9][14] = 18'sd27;
	Hsys[10][14] = 18'sd82;
	Hsys[11][14] = 18'sd219;
	Hsys[0][15] = 18'sd171;
	Hsys[1][15] = 18'sd114;
	Hsys[2][15] = 18'sd57;
	Hsys[3][15] = 18'sd0;
	Hsys[4][15] = -18'sd57;
	Hsys[5][15] = -18'sd114;
	Hsys[6][15] = -18'sd171;
	Hsys[7][15] = 18'sd85;
	Hsys[8][15] = 18'sd28;
	Hsys[9][15] = -18'sd28;
	Hsys[10][15] = -18'sd85;
	Hsys[11][15] = -18'sd227;
	Hsys[0][16] = 18'sd472;
	Hsys[1][16] = 18'sd315;
	Hsys[2][16] = 18'sd157;
	Hsys[3][16] = 18'sd0;
	Hsys[4][16] = -18'sd157;
	Hsys[5][16] = -18'sd315;
	Hsys[6][16] = -18'sd472;
	Hsys[7][16] = 18'sd236;
	Hsys[8][16] = 18'sd79;
	Hsys[9][16] = -18'sd79;
	Hsys[10][16] = -18'sd236;
	Hsys[11][16] = -18'sd630;
	Hsys[0][17] = 18'sd533;
	Hsys[1][17] = 18'sd355;
	Hsys[2][17] = 18'sd178;
	Hsys[3][17] = 18'sd0;
	Hsys[4][17] = -18'sd178;
	Hsys[5][17] = -18'sd355;
	Hsys[6][17] = -18'sd533;
	Hsys[7][17] = 18'sd267;
	Hsys[8][17] = 18'sd89;
	Hsys[9][17] = -18'sd89;
	Hsys[10][17] = -18'sd267;
	Hsys[11][17] = -18'sd711;
	Hsys[0][18] = 18'sd259;
	Hsys[1][18] = 18'sd172;
	Hsys[2][18] = 18'sd86;
	Hsys[3][18] = 18'sd0;
	Hsys[4][18] = -18'sd86;
	Hsys[5][18] = -18'sd172;
	Hsys[6][18] = -18'sd259;
	Hsys[7][18] = 18'sd129;
	Hsys[8][18] = 18'sd43;
	Hsys[9][18] = -18'sd43;
	Hsys[10][18] = -18'sd129;
	Hsys[11][18] = -18'sd345;
	Hsys[0][19] = -18'sd243;
	Hsys[1][19] = -18'sd162;
	Hsys[2][19] = -18'sd81;
	Hsys[3][19] = 18'sd0;
	Hsys[4][19] = 18'sd81;
	Hsys[5][19] = 18'sd162;
	Hsys[6][19] = 18'sd243;
	Hsys[7][19] = -18'sd121;
	Hsys[8][19] = -18'sd40;
	Hsys[9][19] = 18'sd40;
	Hsys[10][19] = 18'sd121;
	Hsys[11][19] = 18'sd324;
	Hsys[0][20] = -18'sd689;
	Hsys[1][20] = -18'sd459;
	Hsys[2][20] = -18'sd230;
	Hsys[3][20] = 18'sd0;
	Hsys[4][20] = 18'sd230;
	Hsys[5][20] = 18'sd459;
	Hsys[6][20] = 18'sd689;
	Hsys[7][20] = -18'sd344;
	Hsys[8][20] = -18'sd115;
	Hsys[9][20] = 18'sd115;
	Hsys[10][20] = 18'sd344;
	Hsys[11][20] = 18'sd918;
	Hsys[0][21] = -18'sd774;
	Hsys[1][21] = -18'sd516;
	Hsys[2][21] = -18'sd258;
	Hsys[3][21] = 18'sd0;
	Hsys[4][21] = 18'sd258;
	Hsys[5][21] = 18'sd516;
	Hsys[6][21] = 18'sd774;
	Hsys[7][21] = -18'sd387;
	Hsys[8][21] = -18'sd129;
	Hsys[9][21] = 18'sd129;
	Hsys[10][21] = 18'sd387;
	Hsys[11][21] = 18'sd1032;
	Hsys[0][22] = -18'sd371;
	Hsys[1][22] = -18'sd247;
	Hsys[2][22] = -18'sd124;
	Hsys[3][22] = 18'sd0;
	Hsys[4][22] = 18'sd124;
	Hsys[5][22] = 18'sd247;
	Hsys[6][22] = 18'sd371;
	Hsys[7][22] = -18'sd185;
	Hsys[8][22] = -18'sd62;
	Hsys[9][22] = 18'sd62;
	Hsys[10][22] = 18'sd185;
	Hsys[11][22] = 18'sd495;
	Hsys[0][23] = 18'sd350;
	Hsys[1][23] = 18'sd234;
	Hsys[2][23] = 18'sd117;
	Hsys[3][23] = 18'sd0;
	Hsys[4][23] = -18'sd117;
	Hsys[5][23] = -18'sd234;
	Hsys[6][23] = -18'sd350;
	Hsys[7][23] = 18'sd175;
	Hsys[8][23] = 18'sd58;
	Hsys[9][23] = -18'sd58;
	Hsys[10][23] = -18'sd175;
	Hsys[11][23] = -18'sd467;
	Hsys[0][24] = 18'sd977;
	Hsys[1][24] = 18'sd651;
	Hsys[2][24] = 18'sd326;
	Hsys[3][24] = 18'sd0;
	Hsys[4][24] = -18'sd326;
	Hsys[5][24] = -18'sd651;
	Hsys[6][24] = -18'sd977;
	Hsys[7][24] = 18'sd489;
	Hsys[8][24] = 18'sd163;
	Hsys[9][24] = -18'sd163;
	Hsys[10][24] = -18'sd489;
	Hsys[11][24] = -18'sd1303;
	Hsys[0][25] = 18'sd1080;
	Hsys[1][25] = 18'sd720;
	Hsys[2][25] = 18'sd360;
	Hsys[3][25] = 18'sd0;
	Hsys[4][25] = -18'sd360;
	Hsys[5][25] = -18'sd720;
	Hsys[6][25] = -18'sd1080;
	Hsys[7][25] = 18'sd540;
	Hsys[8][25] = 18'sd180;
	Hsys[9][25] = -18'sd180;
	Hsys[10][25] = -18'sd540;
	Hsys[11][25] = -18'sd1439;
	Hsys[0][26] = 18'sd494;
	Hsys[1][26] = 18'sd329;
	Hsys[2][26] = 18'sd165;
	Hsys[3][26] = 18'sd0;
	Hsys[4][26] = -18'sd165;
	Hsys[5][26] = -18'sd329;
	Hsys[6][26] = -18'sd494;
	Hsys[7][26] = 18'sd247;
	Hsys[8][26] = 18'sd82;
	Hsys[9][26] = -18'sd82;
	Hsys[10][26] = -18'sd247;
	Hsys[11][26] = -18'sd658;
	Hsys[0][27] = -18'sd521;
	Hsys[1][27] = -18'sd347;
	Hsys[2][27] = -18'sd174;
	Hsys[3][27] = 18'sd0;
	Hsys[4][27] = 18'sd174;
	Hsys[5][27] = 18'sd347;
	Hsys[6][27] = 18'sd521;
	Hsys[7][27] = -18'sd260;
	Hsys[8][27] = -18'sd87;
	Hsys[9][27] = 18'sd87;
	Hsys[10][27] = 18'sd260;
	Hsys[11][27] = 18'sd694;
	Hsys[0][28] = -18'sd1374;
	Hsys[1][28] = -18'sd916;
	Hsys[2][28] = -18'sd458;
	Hsys[3][28] = 18'sd0;
	Hsys[4][28] = 18'sd458;
	Hsys[5][28] = 18'sd916;
	Hsys[6][28] = 18'sd1374;
	Hsys[7][28] = -18'sd687;
	Hsys[8][28] = -18'sd229;
	Hsys[9][28] = 18'sd229;
	Hsys[10][28] = 18'sd687;
	Hsys[11][28] = 18'sd1832;
	Hsys[0][29] = -18'sd1474;
	Hsys[1][29] = -18'sd983;
	Hsys[2][29] = -18'sd491;
	Hsys[3][29] = 18'sd0;
	Hsys[4][29] = 18'sd491;
	Hsys[5][29] = 18'sd983;
	Hsys[6][29] = 18'sd1474;
	Hsys[7][29] = -18'sd737;
	Hsys[8][29] = -18'sd246;
	Hsys[9][29] = 18'sd246;
	Hsys[10][29] = 18'sd737;
	Hsys[11][29] = 18'sd1966;
	Hsys[0][30] = -18'sd617;
	Hsys[1][30] = -18'sd411;
	Hsys[2][30] = -18'sd206;
	Hsys[3][30] = 18'sd0;
	Hsys[4][30] = 18'sd206;
	Hsys[5][30] = 18'sd411;
	Hsys[6][30] = 18'sd617;
	Hsys[7][30] = -18'sd308;
	Hsys[8][30] = -18'sd103;
	Hsys[9][30] = 18'sd103;
	Hsys[10][30] = 18'sd308;
	Hsys[11][30] = 18'sd823;
	Hsys[0][31] = 18'sd808;
	Hsys[1][31] = 18'sd539;
	Hsys[2][31] = 18'sd269;
	Hsys[3][31] = 18'sd0;
	Hsys[4][31] = -18'sd269;
	Hsys[5][31] = -18'sd539;
	Hsys[6][31] = -18'sd808;
	Hsys[7][31] = 18'sd404;
	Hsys[8][31] = 18'sd135;
	Hsys[9][31] = -18'sd135;
	Hsys[10][31] = -18'sd404;
	Hsys[11][31] = -18'sd1078;
	Hsys[0][32] = 18'sd1962;
	Hsys[1][32] = 18'sd1308;
	Hsys[2][32] = 18'sd654;
	Hsys[3][32] = 18'sd0;
	Hsys[4][32] = -18'sd654;
	Hsys[5][32] = -18'sd1308;
	Hsys[6][32] = -18'sd1962;
	Hsys[7][32] = 18'sd981;
	Hsys[8][32] = 18'sd327;
	Hsys[9][32] = -18'sd327;
	Hsys[10][32] = -18'sd981;
	Hsys[11][32] = -18'sd2616;
	Hsys[0][33] = 18'sd2023;
	Hsys[1][33] = 18'sd1349;
	Hsys[2][33] = 18'sd674;
	Hsys[3][33] = 18'sd0;
	Hsys[4][33] = -18'sd674;
	Hsys[5][33] = -18'sd1349;
	Hsys[6][33] = -18'sd2023;
	Hsys[7][33] = 18'sd1012;
	Hsys[8][33] = 18'sd337;
	Hsys[9][33] = -18'sd337;
	Hsys[10][33] = -18'sd1012;
	Hsys[11][33] = -18'sd2698;
	Hsys[0][34] = 18'sd729;
	Hsys[1][34] = 18'sd486;
	Hsys[2][34] = 18'sd243;
	Hsys[3][34] = 18'sd0;
	Hsys[4][34] = -18'sd243;
	Hsys[5][34] = -18'sd486;
	Hsys[6][34] = -18'sd729;
	Hsys[7][34] = 18'sd365;
	Hsys[8][34] = 18'sd122;
	Hsys[9][34] = -18'sd122;
	Hsys[10][34] = -18'sd365;
	Hsys[11][34] = -18'sd973;
	Hsys[0][35] = -18'sd1338;
	Hsys[1][35] = -18'sd892;
	Hsys[2][35] = -18'sd446;
	Hsys[3][35] = 18'sd0;
	Hsys[4][35] = 18'sd446;
	Hsys[5][35] = 18'sd892;
	Hsys[6][35] = 18'sd1338;
	Hsys[7][35] = -18'sd669;
	Hsys[8][35] = -18'sd223;
	Hsys[9][35] = 18'sd223;
	Hsys[10][35] = 18'sd669;
	Hsys[11][35] = 18'sd1785;
	Hsys[0][36] = -18'sd2959;
	Hsys[1][36] = -18'sd1972;
	Hsys[2][36] = -18'sd986;
	Hsys[3][36] = 18'sd0;
	Hsys[4][36] = 18'sd986;
	Hsys[5][36] = 18'sd1972;
	Hsys[6][36] = 18'sd2959;
	Hsys[7][36] = -18'sd1479;
	Hsys[8][36] = -18'sd493;
	Hsys[9][36] = 18'sd493;
	Hsys[10][36] = 18'sd1479;
	Hsys[11][36] = 18'sd3945;
	Hsys[0][37] = -18'sd2923;
	Hsys[1][37] = -18'sd1949;
	Hsys[2][37] = -18'sd974;
	Hsys[3][37] = 18'sd0;
	Hsys[4][37] = 18'sd974;
	Hsys[5][37] = 18'sd1949;
	Hsys[6][37] = 18'sd2923;
	Hsys[7][37] = -18'sd1462;
	Hsys[8][37] = -18'sd487;
	Hsys[9][37] = 18'sd487;
	Hsys[10][37] = 18'sd1462;
	Hsys[11][37] = 18'sd3898;
	Hsys[0][38] = -18'sd820;
	Hsys[1][38] = -18'sd546;
	Hsys[2][38] = -18'sd273;
	Hsys[3][38] = 18'sd0;
	Hsys[4][38] = 18'sd273;
	Hsys[5][38] = 18'sd546;
	Hsys[6][38] = 18'sd820;
	Hsys[7][38] = -18'sd410;
	Hsys[8][38] = -18'sd137;
	Hsys[9][38] = 18'sd137;
	Hsys[10][38] = 18'sd410;
	Hsys[11][38] = 18'sd1093;
	Hsys[0][39] = 18'sd2512;
	Hsys[1][39] = 18'sd1675;
	Hsys[2][39] = 18'sd837;
	Hsys[3][39] = 18'sd0;
	Hsys[4][39] = -18'sd837;
	Hsys[5][39] = -18'sd1675;
	Hsys[6][39] = -18'sd2512;
	Hsys[7][39] = 18'sd1256;
	Hsys[8][39] = 18'sd419;
	Hsys[9][39] = -18'sd419;
	Hsys[10][39] = -18'sd1256;
	Hsys[11][39] = -18'sd3349;
	Hsys[0][40] = 18'sd5170;
	Hsys[1][40] = 18'sd3447;
	Hsys[2][40] = 18'sd1723;
	Hsys[3][40] = 18'sd0;
	Hsys[4][40] = -18'sd1723;
	Hsys[5][40] = -18'sd3447;
	Hsys[6][40] = -18'sd5170;
	Hsys[7][40] = 18'sd2585;
	Hsys[8][40] = 18'sd862;
	Hsys[9][40] = -18'sd862;
	Hsys[10][40] = -18'sd2585;
	Hsys[11][40] = -18'sd6894;
	Hsys[0][41] = 18'sd5035;
	Hsys[1][41] = 18'sd3357;
	Hsys[2][41] = 18'sd1678;
	Hsys[3][41] = 18'sd0;
	Hsys[4][41] = -18'sd1678;
	Hsys[5][41] = -18'sd3357;
	Hsys[6][41] = -18'sd5035;
	Hsys[7][41] = 18'sd2518;
	Hsys[8][41] = 18'sd839;
	Hsys[9][41] = -18'sd839;
	Hsys[10][41] = -18'sd2518;
	Hsys[11][41] = -18'sd6714;
	Hsys[0][42] = 18'sd878;
	Hsys[1][42] = 18'sd585;
	Hsys[2][42] = 18'sd293;
	Hsys[3][42] = 18'sd0;
	Hsys[4][42] = -18'sd293;
	Hsys[5][42] = -18'sd585;
	Hsys[6][42] = -18'sd878;
	Hsys[7][42] = 18'sd439;
	Hsys[8][42] = 18'sd146;
	Hsys[9][42] = -18'sd146;
	Hsys[10][42] = -18'sd439;
	Hsys[11][42] = -18'sd1171;
	Hsys[0][43] = -18'sd6828;
	Hsys[1][43] = -18'sd4552;
	Hsys[2][43] = -18'sd2276;
	Hsys[3][43] = 18'sd0;
	Hsys[4][43] = 18'sd2276;
	Hsys[5][43] = 18'sd4552;
	Hsys[6][43] = 18'sd6828;
	Hsys[7][43] = -18'sd3414;
	Hsys[8][43] = -18'sd1138;
	Hsys[9][43] = 18'sd1138;
	Hsys[10][43] = 18'sd3414;
	Hsys[11][43] = 18'sd9104;
	Hsys[0][44] = -18'sd15872;
	Hsys[1][44] = -18'sd10581;
	Hsys[2][44] = -18'sd5291;
	Hsys[3][44] = 18'sd0;
	Hsys[4][44] = 18'sd5291;
	Hsys[5][44] = 18'sd10581;
	Hsys[6][44] = 18'sd15872;
	Hsys[7][44] = -18'sd7936;
	Hsys[8][44] = -18'sd2645;
	Hsys[9][44] = 18'sd2645;
	Hsys[10][44] = 18'sd7936;
	Hsys[11][44] = 18'sd21163;
	Hsys[0][45] = -18'sd23128;
	Hsys[1][45] = -18'sd15419;
	Hsys[2][45] = -18'sd7709;
	Hsys[3][45] = 18'sd0;
	Hsys[4][45] = 18'sd7709;
	Hsys[5][45] = 18'sd15419;
	Hsys[6][45] = 18'sd23128;
	Hsys[7][45] = -18'sd11564;
	Hsys[8][45] = -18'sd3855;
	Hsys[9][45] = 18'sd3855;
	Hsys[10][45] = 18'sd11564;
	Hsys[11][45] = 18'sd30838;
	Hsys[0][46] = -18'sd25901;
	Hsys[1][46] = -18'sd17267;
	Hsys[2][46] = -18'sd8634;
	Hsys[3][46] = 18'sd0;
	Hsys[4][46] = 18'sd8634;
	Hsys[5][46] = 18'sd17267;
	Hsys[6][46] = 18'sd25901;
	Hsys[7][46] = -18'sd12950;
	Hsys[8][46] = -18'sd4317;
	Hsys[9][46] = 18'sd4317;
	Hsys[10][46] = 18'sd12950;
	Hsys[11][46] = 18'sd34535;
end


endmodule

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
(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
(* noprune *) reg signed [WIDTH-1:0] tol;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[MAPSIZE+POSSMAPPER:0][(LENGTH-1)/2:0];

integer i,j;
initial begin
     tol=18'sd10;
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
        x[0]<=$signed( {x_in[17],x_in[17:1]} );
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


//1s17 + 1s17 will cause overflow for sum_lvl_1[i]
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] = 18'sd0;
    end
    else if (sam_clk_en) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] = $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] = 18'sd0;
	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] = $signed(x[SUMLV1-1]);
	else sum_lvl_1[SUMLV1-1] = $signed(sum_lvl_1[SUMLV1-1]);


//always @ (posedge clk)
always @ *
    if (reset) begin
		 for(i=0;i<SUMLV1; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for(i=0; i<SUMLV1; i=i+1)
            if( i<SUMLV1-2 ) begin 
                /*For verifying taps*/
                if( sum_lvl_1[i] == 18'sd65500 ) begin
                    mult_out[i] <= Hsys[11][i];
                    //$display("%d %d",mult_out[i],Hsys[11][i]);
                end
                else if ( ( sum_lvl_1[i]>(-18'sd98303-tol) ) && ( sum_lvl_1[i]<(-18'sd98303+tol) ) ) mult_out[i] <= Hsys[0][i];
                else if ( ( sum_lvl_1[i]>(-18'sd65536-tol) ) && ( sum_lvl_1[i]<(-18'sd65536+tol) ) ) mult_out[i] <= Hsys[1][i];
                else if ( ( sum_lvl_1[i]>(-18'sd32768-tol) ) && ( sum_lvl_1[i]<(-18'sd32768+tol) ) ) mult_out[i] <= Hsys[2][i];
                else if ( ( sum_lvl_1[i]>(18'sd0-tol) ) && ( sum_lvl_1[i]<(18'sd0+tol) ) ) mult_out[i] <= Hsys[3][i];
                else if ( ( sum_lvl_1[i]>(18'sd32768-tol) ) && ( sum_lvl_1[i]<(18'sd32768+tol) ) ) mult_out[i] <= Hsys[4][i];
                else if ( ( sum_lvl_1[i]>(18'sd65536-tol) ) && ( sum_lvl_1[i]<(18'sd65536+tol) ) ) mult_out[i] <= Hsys[5][i];
                else if ( ( sum_lvl_1[i]>(18'sd98303-tol) ) && ( sum_lvl_1[i]<(18'sd98303+tol) ) ) mult_out[i] <= Hsys[6][i];
                else mult_out[i] = 18'sd0;
                end
            else begin
                /*For verifying taps*/
                if( sum_lvl_1[i] == 18'sd65500 ) mult_out[i] <= Hsys[11][i];
                else if ( ( sum_lvl_1[i]>(-18'sd49152-tol) ) && ( sum_lvl_1[i]<(-18'sd49152+tol) ) ) mult_out[i] <= Hsys[7][i];
                else if ( ( sum_lvl_1[i]>(-18'sd16384-tol) ) && ( sum_lvl_1[i]<(-18'sd16384+tol) ) ) mult_out[i] <= Hsys[8][i];
                else if ( ( sum_lvl_1[i]>(18'sd16384-tol) ) && ( sum_lvl_1[i]<(18'sd16384+tol) ) ) mult_out[i] <= Hsys[9][i];
                else if ( ( sum_lvl_1[i]>(18'sd49152-tol) ) && ( sum_lvl_1[i]<(18'sd49152+tol) ) ) mult_out[i] <= Hsys[10][i];
                else mult_out[i] <= 18'sd0;
            end
    end
//!!! SEE D3.m for structure of filter/center tap location !!!
/*          SUMLV2              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=$signed(mult_out[2*i])+$signed(mult_out[2*i+1]);
    end
//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1]);

/*          SUMLV3              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3-1; i=i+1)
            sum_lvl_3[i]=18'sd0;
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
        for (i=0; i<SUMLV4-1; i=i+1)
            sum_lvl_4[i]=18'sd0;
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
            sum_lvl_5[i]=18'sd0;
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
            sum_lvl_6[i]=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV6; i=i+1)
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
	Hsys[0][0] = -18'sd67;
	Hsys[1][0] = -18'sd45;
	Hsys[2][0] = -18'sd22;
	Hsys[3][0] = 18'sd0;
	Hsys[4][0] = 18'sd22;
	Hsys[5][0] = 18'sd45;
	Hsys[6][0] = 18'sd67;
	Hsys[7][0] = -18'sd34;
	Hsys[8][0] = -18'sd11;
	Hsys[9][0] = 18'sd11;
	Hsys[10][0] = 18'sd34;
	Hsys[11][0] = 18'sd22;
	Hsys[0][1] = -18'sd10;
	Hsys[1][1] = -18'sd7;
	Hsys[2][1] = -18'sd3;
	Hsys[3][1] = 18'sd0;
	Hsys[4][1] = 18'sd3;
	Hsys[5][1] = 18'sd7;
	Hsys[6][1] = 18'sd10;
	Hsys[7][1] = -18'sd5;
	Hsys[8][1] = -18'sd2;
	Hsys[9][1] = 18'sd2;
	Hsys[10][1] = 18'sd5;
	Hsys[11][1] = 18'sd3;
	Hsys[0][2] = 18'sd72;
	Hsys[1][2] = 18'sd48;
	Hsys[2][2] = 18'sd24;
	Hsys[3][2] = 18'sd0;
	Hsys[4][2] = -18'sd24;
	Hsys[5][2] = -18'sd48;
	Hsys[6][2] = -18'sd72;
	Hsys[7][2] = 18'sd36;
	Hsys[8][2] = 18'sd12;
	Hsys[9][2] = -18'sd12;
	Hsys[10][2] = -18'sd36;
	Hsys[11][2] = -18'sd24;
	Hsys[0][3] = 18'sd197;
	Hsys[1][3] = 18'sd131;
	Hsys[2][3] = 18'sd66;
	Hsys[3][3] = 18'sd0;
	Hsys[4][3] = -18'sd66;
	Hsys[5][3] = -18'sd131;
	Hsys[6][3] = -18'sd197;
	Hsys[7][3] = 18'sd98;
	Hsys[8][3] = 18'sd33;
	Hsys[9][3] = -18'sd33;
	Hsys[10][3] = -18'sd98;
	Hsys[11][3] = -18'sd66;
	Hsys[0][4] = 18'sd296;
	Hsys[1][4] = 18'sd197;
	Hsys[2][4] = 18'sd99;
	Hsys[3][4] = 18'sd0;
	Hsys[4][4] = -18'sd99;
	Hsys[5][4] = -18'sd197;
	Hsys[6][4] = -18'sd296;
	Hsys[7][4] = 18'sd148;
	Hsys[8][4] = 18'sd49;
	Hsys[9][4] = -18'sd49;
	Hsys[10][4] = -18'sd148;
	Hsys[11][4] = -18'sd99;
	Hsys[0][5] = 18'sd283;
	Hsys[1][5] = 18'sd189;
	Hsys[2][5] = 18'sd94;
	Hsys[3][5] = 18'sd0;
	Hsys[4][5] = -18'sd94;
	Hsys[5][5] = -18'sd189;
	Hsys[6][5] = -18'sd283;
	Hsys[7][5] = 18'sd142;
	Hsys[8][5] = 18'sd47;
	Hsys[9][5] = -18'sd47;
	Hsys[10][5] = -18'sd142;
	Hsys[11][5] = -18'sd94;
	Hsys[0][6] = 18'sd110;
	Hsys[1][6] = 18'sd74;
	Hsys[2][6] = 18'sd37;
	Hsys[3][6] = 18'sd0;
	Hsys[4][6] = -18'sd37;
	Hsys[5][6] = -18'sd74;
	Hsys[6][6] = -18'sd110;
	Hsys[7][6] = 18'sd55;
	Hsys[8][6] = 18'sd18;
	Hsys[9][6] = -18'sd18;
	Hsys[10][6] = -18'sd55;
	Hsys[11][6] = -18'sd37;
	Hsys[0][7] = -18'sd177;
	Hsys[1][7] = -18'sd118;
	Hsys[2][7] = -18'sd59;
	Hsys[3][7] = 18'sd0;
	Hsys[4][7] = 18'sd59;
	Hsys[5][7] = 18'sd118;
	Hsys[6][7] = 18'sd177;
	Hsys[7][7] = -18'sd88;
	Hsys[8][7] = -18'sd29;
	Hsys[9][7] = 18'sd29;
	Hsys[10][7] = 18'sd88;
	Hsys[11][7] = 18'sd59;
	Hsys[0][8] = -18'sd431;
	Hsys[1][8] = -18'sd287;
	Hsys[2][8] = -18'sd144;
	Hsys[3][8] = 18'sd0;
	Hsys[4][8] = 18'sd144;
	Hsys[5][8] = 18'sd287;
	Hsys[6][8] = 18'sd431;
	Hsys[7][8] = -18'sd215;
	Hsys[8][8] = -18'sd72;
	Hsys[9][8] = 18'sd72;
	Hsys[10][8] = 18'sd215;
	Hsys[11][8] = 18'sd144;
	Hsys[0][9] = -18'sd470;
	Hsys[1][9] = -18'sd313;
	Hsys[2][9] = -18'sd157;
	Hsys[3][9] = 18'sd0;
	Hsys[4][9] = 18'sd157;
	Hsys[5][9] = 18'sd313;
	Hsys[6][9] = 18'sd470;
	Hsys[7][9] = -18'sd235;
	Hsys[8][9] = -18'sd78;
	Hsys[9][9] = 18'sd78;
	Hsys[10][9] = 18'sd235;
	Hsys[11][9] = 18'sd157;
	Hsys[0][10] = -18'sd197;
	Hsys[1][10] = -18'sd131;
	Hsys[2][10] = -18'sd66;
	Hsys[3][10] = 18'sd0;
	Hsys[4][10] = 18'sd66;
	Hsys[5][10] = 18'sd131;
	Hsys[6][10] = 18'sd197;
	Hsys[7][10] = -18'sd98;
	Hsys[8][10] = -18'sd33;
	Hsys[9][10] = 18'sd33;
	Hsys[10][10] = 18'sd98;
	Hsys[11][10] = 18'sd66;
	Hsys[0][11] = 18'sd302;
	Hsys[1][11] = 18'sd201;
	Hsys[2][11] = 18'sd101;
	Hsys[3][11] = 18'sd0;
	Hsys[4][11] = -18'sd101;
	Hsys[5][11] = -18'sd201;
	Hsys[6][11] = -18'sd302;
	Hsys[7][11] = 18'sd151;
	Hsys[8][11] = 18'sd50;
	Hsys[9][11] = -18'sd50;
	Hsys[10][11] = -18'sd151;
	Hsys[11][11] = -18'sd101;
	Hsys[0][12] = 18'sd754;
	Hsys[1][12] = 18'sd503;
	Hsys[2][12] = 18'sd251;
	Hsys[3][12] = 18'sd0;
	Hsys[4][12] = -18'sd251;
	Hsys[5][12] = -18'sd503;
	Hsys[6][12] = -18'sd754;
	Hsys[7][12] = 18'sd377;
	Hsys[8][12] = 18'sd126;
	Hsys[9][12] = -18'sd126;
	Hsys[10][12] = -18'sd377;
	Hsys[11][12] = -18'sd251;
	Hsys[0][13] = 18'sd837;
	Hsys[1][13] = 18'sd558;
	Hsys[2][13] = 18'sd279;
	Hsys[3][13] = 18'sd0;
	Hsys[4][13] = -18'sd279;
	Hsys[5][13] = -18'sd558;
	Hsys[6][13] = -18'sd837;
	Hsys[7][13] = 18'sd418;
	Hsys[8][13] = 18'sd139;
	Hsys[9][13] = -18'sd139;
	Hsys[10][13] = -18'sd418;
	Hsys[11][13] = -18'sd279;
	Hsys[0][14] = 18'sd383;
	Hsys[1][14] = 18'sd256;
	Hsys[2][14] = 18'sd128;
	Hsys[3][14] = 18'sd0;
	Hsys[4][14] = -18'sd128;
	Hsys[5][14] = -18'sd256;
	Hsys[6][14] = -18'sd383;
	Hsys[7][14] = 18'sd192;
	Hsys[8][14] = 18'sd64;
	Hsys[9][14] = -18'sd64;
	Hsys[10][14] = -18'sd192;
	Hsys[11][14] = -18'sd128;
	Hsys[0][15] = -18'sd451;
	Hsys[1][15] = -18'sd301;
	Hsys[2][15] = -18'sd150;
	Hsys[3][15] = 18'sd0;
	Hsys[4][15] = 18'sd150;
	Hsys[5][15] = 18'sd301;
	Hsys[6][15] = 18'sd451;
	Hsys[7][15] = -18'sd226;
	Hsys[8][15] = -18'sd75;
	Hsys[9][15] = 18'sd75;
	Hsys[10][15] = 18'sd226;
	Hsys[11][15] = 18'sd150;
	Hsys[0][16] = -18'sd1208;
	Hsys[1][16] = -18'sd806;
	Hsys[2][16] = -18'sd403;
	Hsys[3][16] = 18'sd0;
	Hsys[4][16] = 18'sd403;
	Hsys[5][16] = 18'sd806;
	Hsys[6][16] = 18'sd1208;
	Hsys[7][16] = -18'sd604;
	Hsys[8][16] = -18'sd201;
	Hsys[9][16] = 18'sd201;
	Hsys[10][16] = 18'sd604;
	Hsys[11][16] = 18'sd403;
	Hsys[0][17] = -18'sd1358;
	Hsys[1][17] = -18'sd906;
	Hsys[2][17] = -18'sd453;
	Hsys[3][17] = 18'sd0;
	Hsys[4][17] = 18'sd453;
	Hsys[5][17] = 18'sd906;
	Hsys[6][17] = 18'sd1358;
	Hsys[7][17] = -18'sd679;
	Hsys[8][17] = -18'sd226;
	Hsys[9][17] = 18'sd226;
	Hsys[10][17] = 18'sd679;
	Hsys[11][17] = 18'sd453;
	Hsys[0][18] = -18'sd647;
	Hsys[1][18] = -18'sd431;
	Hsys[2][18] = -18'sd216;
	Hsys[3][18] = 18'sd0;
	Hsys[4][18] = 18'sd216;
	Hsys[5][18] = 18'sd431;
	Hsys[6][18] = 18'sd647;
	Hsys[7][18] = -18'sd324;
	Hsys[8][18] = -18'sd108;
	Hsys[9][18] = 18'sd108;
	Hsys[10][18] = 18'sd324;
	Hsys[11][18] = 18'sd216;
	Hsys[0][19] = 18'sd661;
	Hsys[1][19] = 18'sd440;
	Hsys[2][19] = 18'sd220;
	Hsys[3][19] = 18'sd0;
	Hsys[4][19] = -18'sd220;
	Hsys[5][19] = -18'sd440;
	Hsys[6][19] = -18'sd661;
	Hsys[7][19] = 18'sd330;
	Hsys[8][19] = 18'sd110;
	Hsys[9][19] = -18'sd110;
	Hsys[10][19] = -18'sd330;
	Hsys[11][19] = -18'sd220;
	Hsys[0][20] = 18'sd1835;
	Hsys[1][20] = 18'sd1223;
	Hsys[2][20] = 18'sd612;
	Hsys[3][20] = 18'sd0;
	Hsys[4][20] = -18'sd612;
	Hsys[5][20] = -18'sd1223;
	Hsys[6][20] = -18'sd1835;
	Hsys[7][20] = 18'sd917;
	Hsys[8][20] = 18'sd306;
	Hsys[9][20] = -18'sd306;
	Hsys[10][20] = -18'sd917;
	Hsys[11][20] = -18'sd612;
	Hsys[0][21] = 18'sd2065;
	Hsys[1][21] = 18'sd1377;
	Hsys[2][21] = 18'sd688;
	Hsys[3][21] = 18'sd0;
	Hsys[4][21] = -18'sd688;
	Hsys[5][21] = -18'sd1377;
	Hsys[6][21] = -18'sd2065;
	Hsys[7][21] = 18'sd1033;
	Hsys[8][21] = 18'sd344;
	Hsys[9][21] = -18'sd344;
	Hsys[10][21] = -18'sd1033;
	Hsys[11][21] = -18'sd688;
	Hsys[0][22] = 18'sd989;
	Hsys[1][22] = 18'sd659;
	Hsys[2][22] = 18'sd330;
	Hsys[3][22] = 18'sd0;
	Hsys[4][22] = -18'sd330;
	Hsys[5][22] = -18'sd659;
	Hsys[6][22] = -18'sd989;
	Hsys[7][22] = 18'sd495;
	Hsys[8][22] = 18'sd165;
	Hsys[9][22] = -18'sd165;
	Hsys[10][22] = -18'sd495;
	Hsys[11][22] = -18'sd330;
	Hsys[0][23] = -18'sd962;
	Hsys[1][23] = -18'sd641;
	Hsys[2][23] = -18'sd321;
	Hsys[3][23] = 18'sd0;
	Hsys[4][23] = 18'sd321;
	Hsys[5][23] = 18'sd641;
	Hsys[6][23] = 18'sd962;
	Hsys[7][23] = -18'sd481;
	Hsys[8][23] = -18'sd160;
	Hsys[9][23] = 18'sd160;
	Hsys[10][23] = 18'sd481;
	Hsys[11][23] = 18'sd321;
	Hsys[0][24] = -18'sd2682;
	Hsys[1][24] = -18'sd1788;
	Hsys[2][24] = -18'sd894;
	Hsys[3][24] = 18'sd0;
	Hsys[4][24] = 18'sd894;
	Hsys[5][24] = 18'sd1788;
	Hsys[6][24] = 18'sd2682;
	Hsys[7][24] = -18'sd1341;
	Hsys[8][24] = -18'sd447;
	Hsys[9][24] = 18'sd447;
	Hsys[10][24] = 18'sd1341;
	Hsys[11][24] = 18'sd894;
	Hsys[0][25] = -18'sd2988;
	Hsys[1][25] = -18'sd1992;
	Hsys[2][25] = -18'sd996;
	Hsys[3][25] = 18'sd0;
	Hsys[4][25] = 18'sd996;
	Hsys[5][25] = 18'sd1992;
	Hsys[6][25] = 18'sd2988;
	Hsys[7][25] = -18'sd1494;
	Hsys[8][25] = -18'sd498;
	Hsys[9][25] = 18'sd498;
	Hsys[10][25] = 18'sd1494;
	Hsys[11][25] = 18'sd996;
	Hsys[0][26] = -18'sd1397;
	Hsys[1][26] = -18'sd931;
	Hsys[2][26] = -18'sd466;
	Hsys[3][26] = 18'sd0;
	Hsys[4][26] = 18'sd466;
	Hsys[5][26] = 18'sd931;
	Hsys[6][26] = 18'sd1397;
	Hsys[7][26] = -18'sd698;
	Hsys[8][26] = -18'sd233;
	Hsys[9][26] = 18'sd233;
	Hsys[10][26] = 18'sd698;
	Hsys[11][26] = 18'sd466;
	Hsys[0][27] = 18'sd1415;
	Hsys[1][27] = 18'sd943;
	Hsys[2][27] = 18'sd472;
	Hsys[3][27] = 18'sd0;
	Hsys[4][27] = -18'sd472;
	Hsys[5][27] = -18'sd943;
	Hsys[6][27] = -18'sd1415;
	Hsys[7][27] = 18'sd707;
	Hsys[8][27] = 18'sd236;
	Hsys[9][27] = -18'sd236;
	Hsys[10][27] = -18'sd707;
	Hsys[11][27] = -18'sd472;
	Hsys[0][28] = 18'sd3828;
	Hsys[1][28] = 18'sd2552;
	Hsys[2][28] = 18'sd1276;
	Hsys[3][28] = 18'sd0;
	Hsys[4][28] = -18'sd1276;
	Hsys[5][28] = -18'sd2552;
	Hsys[6][28] = -18'sd3828;
	Hsys[7][28] = 18'sd1914;
	Hsys[8][28] = 18'sd638;
	Hsys[9][28] = -18'sd638;
	Hsys[10][28] = -18'sd1914;
	Hsys[11][28] = -18'sd1276;
	Hsys[0][29] = 18'sd4176;
	Hsys[1][29] = 18'sd2784;
	Hsys[2][29] = 18'sd1392;
	Hsys[3][29] = 18'sd0;
	Hsys[4][29] = -18'sd1392;
	Hsys[5][29] = -18'sd2784;
	Hsys[6][29] = -18'sd4176;
	Hsys[7][29] = 18'sd2088;
	Hsys[8][29] = 18'sd696;
	Hsys[9][29] = -18'sd696;
	Hsys[10][29] = -18'sd2088;
	Hsys[11][29] = -18'sd1392;
	Hsys[0][30] = 18'sd1844;
	Hsys[1][30] = 18'sd1230;
	Hsys[2][30] = 18'sd615;
	Hsys[3][30] = 18'sd0;
	Hsys[4][30] = -18'sd615;
	Hsys[5][30] = -18'sd1230;
	Hsys[6][30] = -18'sd1844;
	Hsys[7][30] = 18'sd922;
	Hsys[8][30] = 18'sd307;
	Hsys[9][30] = -18'sd307;
	Hsys[10][30] = -18'sd922;
	Hsys[11][30] = -18'sd615;
	Hsys[0][31] = -18'sd2128;
	Hsys[1][31] = -18'sd1419;
	Hsys[2][31] = -18'sd709;
	Hsys[3][31] = 18'sd0;
	Hsys[4][31] = 18'sd709;
	Hsys[5][31] = 18'sd1419;
	Hsys[6][31] = 18'sd2128;
	Hsys[7][31] = -18'sd1064;
	Hsys[8][31] = -18'sd355;
	Hsys[9][31] = 18'sd355;
	Hsys[10][31] = 18'sd1064;
	Hsys[11][31] = 18'sd709;
	Hsys[0][32] = -18'sd5423;
	Hsys[1][32] = -18'sd3615;
	Hsys[2][32] = -18'sd1808;
	Hsys[3][32] = 18'sd0;
	Hsys[4][32] = 18'sd1808;
	Hsys[5][32] = 18'sd3615;
	Hsys[6][32] = 18'sd5423;
	Hsys[7][32] = -18'sd2711;
	Hsys[8][32] = -18'sd904;
	Hsys[9][32] = 18'sd904;
	Hsys[10][32] = 18'sd2711;
	Hsys[11][32] = 18'sd1808;
	Hsys[0][33] = -18'sd5734;
	Hsys[1][33] = -18'sd3823;
	Hsys[2][33] = -18'sd1911;
	Hsys[3][33] = 18'sd0;
	Hsys[4][33] = 18'sd1911;
	Hsys[5][33] = 18'sd3823;
	Hsys[6][33] = 18'sd5734;
	Hsys[7][33] = -18'sd2867;
	Hsys[8][33] = -18'sd956;
	Hsys[9][33] = 18'sd956;
	Hsys[10][33] = 18'sd2867;
	Hsys[11][33] = 18'sd1911;
	Hsys[0][34] = -18'sd2297;
	Hsys[1][34] = -18'sd1531;
	Hsys[2][34] = -18'sd766;
	Hsys[3][34] = 18'sd0;
	Hsys[4][34] = 18'sd766;
	Hsys[5][34] = 18'sd1531;
	Hsys[6][34] = 18'sd2297;
	Hsys[7][34] = -18'sd1148;
	Hsys[8][34] = -18'sd383;
	Hsys[9][34] = 18'sd383;
	Hsys[10][34] = 18'sd1148;
	Hsys[11][34] = 18'sd766;
	Hsys[0][35] = 18'sd3319;
	Hsys[1][35] = 18'sd2213;
	Hsys[2][35] = 18'sd1106;
	Hsys[3][35] = 18'sd0;
	Hsys[4][35] = -18'sd1106;
	Hsys[5][35] = -18'sd2213;
	Hsys[6][35] = -18'sd3319;
	Hsys[7][35] = 18'sd1660;
	Hsys[8][35] = 18'sd553;
	Hsys[9][35] = -18'sd553;
	Hsys[10][35] = -18'sd1660;
	Hsys[11][35] = -18'sd1106;
	Hsys[0][36] = 18'sd7798;
	Hsys[1][36] = 18'sd5199;
	Hsys[2][36] = 18'sd2599;
	Hsys[3][36] = 18'sd0;
	Hsys[4][36] = -18'sd2599;
	Hsys[5][36] = -18'sd5199;
	Hsys[6][36] = -18'sd7798;
	Hsys[7][36] = 18'sd3899;
	Hsys[8][36] = 18'sd1300;
	Hsys[9][36] = -18'sd1300;
	Hsys[10][36] = -18'sd3899;
	Hsys[11][36] = -18'sd2599;
	Hsys[0][37] = 18'sd7924;
	Hsys[1][37] = 18'sd5283;
	Hsys[2][37] = 18'sd2641;
	Hsys[3][37] = 18'sd0;
	Hsys[4][37] = -18'sd2641;
	Hsys[5][37] = -18'sd5283;
	Hsys[6][37] = -18'sd7924;
	Hsys[7][37] = 18'sd3962;
	Hsys[8][37] = 18'sd1321;
	Hsys[9][37] = -18'sd1321;
	Hsys[10][37] = -18'sd3962;
	Hsys[11][37] = -18'sd2641;
	Hsys[0][38] = 18'sd2711;
	Hsys[1][38] = 18'sd1808;
	Hsys[2][38] = 18'sd904;
	Hsys[3][38] = 18'sd0;
	Hsys[4][38] = -18'sd904;
	Hsys[5][38] = -18'sd1808;
	Hsys[6][38] = -18'sd2711;
	Hsys[7][38] = 18'sd1356;
	Hsys[8][38] = 18'sd452;
	Hsys[9][38] = -18'sd452;
	Hsys[10][38] = -18'sd1356;
	Hsys[11][38] = -18'sd904;
	Hsys[0][39] = -18'sd5492;
	Hsys[1][39] = -18'sd3661;
	Hsys[2][39] = -18'sd1831;
	Hsys[3][39] = 18'sd0;
	Hsys[4][39] = 18'sd1831;
	Hsys[5][39] = 18'sd3661;
	Hsys[6][39] = 18'sd5492;
	Hsys[7][39] = -18'sd2746;
	Hsys[8][39] = -18'sd915;
	Hsys[9][39] = 18'sd915;
	Hsys[10][39] = 18'sd2746;
	Hsys[11][39] = 18'sd1831;
	Hsys[0][40] = -18'sd11831;
	Hsys[1][40] = -18'sd7887;
	Hsys[2][40] = -18'sd3944;
	Hsys[3][40] = 18'sd0;
	Hsys[4][40] = 18'sd3944;
	Hsys[5][40] = 18'sd7887;
	Hsys[6][40] = 18'sd11831;
	Hsys[7][40] = -18'sd5916;
	Hsys[8][40] = -18'sd1972;
	Hsys[9][40] = 18'sd1972;
	Hsys[10][40] = 18'sd5916;
	Hsys[11][40] = 18'sd3944;
	Hsys[0][41] = -18'sd11542;
	Hsys[1][41] = -18'sd7695;
	Hsys[2][41] = -18'sd3847;
	Hsys[3][41] = 18'sd0;
	Hsys[4][41] = 18'sd3847;
	Hsys[5][41] = 18'sd7695;
	Hsys[6][41] = 18'sd11542;
	Hsys[7][41] = -18'sd5771;
	Hsys[8][41] = -18'sd1924;
	Hsys[9][41] = 18'sd1924;
	Hsys[10][41] = 18'sd5771;
	Hsys[11][41] = 18'sd3848;
	Hsys[0][42] = -18'sd3046;
	Hsys[1][42] = -18'sd2031;
	Hsys[2][42] = -18'sd1015;
	Hsys[3][42] = 18'sd0;
	Hsys[4][42] = 18'sd1015;
	Hsys[5][42] = 18'sd2031;
	Hsys[6][42] = 18'sd3046;
	Hsys[7][42] = -18'sd1523;
	Hsys[8][42] = -18'sd508;
	Hsys[9][42] = 18'sd508;
	Hsys[10][42] = 18'sd1523;
	Hsys[11][42] = 18'sd1015;
	Hsys[0][43] = 18'sd10255;
	Hsys[1][43] = 18'sd6837;
	Hsys[2][43] = 18'sd3418;
	Hsys[3][43] = 18'sd0;
	Hsys[4][43] = -18'sd3418;
	Hsys[5][43] = -18'sd6837;
	Hsys[6][43] = -18'sd10255;
	Hsys[7][43] = 18'sd5128;
	Hsys[8][43] = 18'sd1709;
	Hsys[9][43] = -18'sd1709;
	Hsys[10][43] = -18'sd5128;
	Hsys[11][43] = -18'sd3419;
	Hsys[0][44] = 18'sd20767;
	Hsys[1][44] = 18'sd13845;
	Hsys[2][44] = 18'sd6922;
	Hsys[3][44] = 18'sd0;
	Hsys[4][44] = -18'sd6922;
	Hsys[5][44] = -18'sd13845;
	Hsys[6][44] = -18'sd20767;
	Hsys[7][44] = 18'sd10383;
	Hsys[8][44] = 18'sd3461;
	Hsys[9][44] = -18'sd3461;
	Hsys[10][44] = -18'sd10383;
	Hsys[11][44] = -18'sd6922;
	Hsys[0][45] = 18'sd20054;
	Hsys[1][45] = 18'sd13369;
	Hsys[2][45] = 18'sd6685;
	Hsys[3][45] = 18'sd0;
	Hsys[4][45] = -18'sd6685;
	Hsys[5][45] = -18'sd13369;
	Hsys[6][45] = -18'sd20054;
	Hsys[7][45] = 18'sd10027;
	Hsys[8][45] = 18'sd3342;
	Hsys[9][45] = -18'sd3342;
	Hsys[10][45] = -18'sd10027;
	Hsys[11][45] = -18'sd6685;
	Hsys[0][46] = 18'sd3263;
	Hsys[1][46] = 18'sd2175;
	Hsys[2][46] = 18'sd1088;
	Hsys[3][46] = 18'sd0;
	Hsys[4][46] = -18'sd1088;
	Hsys[5][46] = -18'sd2175;
	Hsys[6][46] = -18'sd3263;
	Hsys[7][46] = 18'sd1632;
	Hsys[8][46] = 18'sd544;
	Hsys[9][46] = -18'sd544;
	Hsys[10][46] = -18'sd1632;
	Hsys[11][46] = -18'sd1088;
	Hsys[0][47] = -18'sd27675;
	Hsys[1][47] = -18'sd18450;
	Hsys[2][47] = -18'sd9225;
	Hsys[3][47] = 18'sd0;
	Hsys[4][47] = 18'sd9225;
	Hsys[5][47] = 18'sd18450;
	Hsys[6][47] = 18'sd27675;
	Hsys[7][47] = -18'sd13837;
	Hsys[8][47] = -18'sd4612;
	Hsys[9][47] = 18'sd4612;
	Hsys[10][47] = 18'sd13837;
	Hsys[11][47] = 18'sd9225;
	Hsys[0][48] = -18'sd63902;
	Hsys[1][48] = -18'sd42601;
	Hsys[2][48] = -18'sd21301;
	Hsys[3][48] = 18'sd0;
	Hsys[4][48] = 18'sd21301;
	Hsys[5][48] = 18'sd42601;
	Hsys[6][48] = 18'sd63902;
	Hsys[7][48] = -18'sd31951;
	Hsys[8][48] = -18'sd10650;
	Hsys[9][48] = 18'sd10650;
	Hsys[10][48] = 18'sd31951;
	Hsys[11][48] = 18'sd21301;
	Hsys[0][49] = -18'sd92942;
	Hsys[1][49] = -18'sd61961;
	Hsys[2][49] = -18'sd30981;
	Hsys[3][49] = 18'sd0;
	Hsys[4][49] = 18'sd30981;
	Hsys[5][49] = 18'sd61961;
	Hsys[6][49] = 18'sd92942;
	Hsys[7][49] = -18'sd46471;
	Hsys[8][49] = -18'sd15490;
	Hsys[9][49] = 18'sd15490;
	Hsys[10][49] = 18'sd46471;
	Hsys[11][49] = 18'sd30981;
	Hsys[0][50] = -18'sd104032;
	Hsys[1][50] = -18'sd69355;
	Hsys[2][50] = -18'sd34677;
	Hsys[3][50] = 18'sd0;
	Hsys[4][50] = 18'sd34677;
	Hsys[5][50] = 18'sd69355;
	Hsys[6][50] = 18'sd104032;
	Hsys[7][50] = -18'sd52016;
	Hsys[8][50] = -18'sd17339;
	Hsys[9][50] = 18'sd17339;
	Hsys[10][50] = 18'sd52016;
	Hsys[11][50] = 18'sd34678;
end

endmodule
