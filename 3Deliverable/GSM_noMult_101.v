module GSM_noMult_101 #(
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
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[(LENGTH-1):0];

integer i,j;
initial begin
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
            x[i]<=$signed(x[i]);
    end


//always @ (posedge clk)
always @ *
    for (i=0; i<LENGTH; i=i+1)
        mult_out[i]=$signed(Hsys[i])*$signed(x[i]);

//always @ (posedge clk)


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
//for center
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
	Hsys[0] = 18'sd97;
	Hsys[1] = -18'sd10;
	Hsys[2] = -18'sd118;
	Hsys[3] = -18'sd133;
	Hsys[4] = -18'sd30;
	Hsys[5] = 18'sd116;
	Hsys[6] = 18'sd182;
	Hsys[7] = 18'sd101;
	Hsys[8] = -18'sd80;
	Hsys[9] = -18'sd223;
	Hsys[10] = -18'sd204;
	Hsys[11] = -18'sd16;
	Hsys[12] = 18'sd208;
	Hsys[13] = 18'sd292;
	Hsys[14] = 18'sd154;
	Hsys[15] = -18'sd116;
	Hsys[16] = -18'sd313;
	Hsys[17] = -18'sd273;
	Hsys[18] = -18'sd12;
	Hsys[19] = 18'sd269;
	Hsys[20] = 18'sd335;
	Hsys[21] = 18'sd112;
	Hsys[22] = -18'sd231;
	Hsys[23] = -18'sd395;
	Hsys[24] = -18'sd198;
	Hsys[25] = 18'sd245;
	Hsys[26] = 18'sd568;
	Hsys[27] = 18'sd426;
	Hsys[28] = -18'sd187;
	Hsys[29] = -18'sd851;
	Hsys[30] = -18'sd974;
	Hsys[31] = -18'sd264;
	Hsys[32] = 18'sd940;
	Hsys[33] = 18'sd1771;
	Hsys[34] = 18'sd1410;
	Hsys[35] = -18'sd237;
	Hsys[36] = -18'sd2247;
	Hsys[37] = -18'sd3130;
	Hsys[38] = -18'sd1825;
	Hsys[39] = 18'sd1351;
	Hsys[40] = 18'sd4544;
	Hsys[41] = 18'sd5294;
	Hsys[42] = 18'sd2168;
	Hsys[43] = -18'sd3883;
	Hsys[44] = -18'sd9408;
	Hsys[45] = -18'sd9934;
	Hsys[46] = -18'sd2394;
	Hsys[47] = 18'sd12787;
	Hsys[48] = 18'sd31254;
	Hsys[49] = 18'sd46360;
	Hsys[50] = 18'sd52183;
	Hsys[51] = 18'sd46360;
	Hsys[52] = 18'sd31254;
	Hsys[53] = 18'sd12787;
	Hsys[54] = -18'sd2394;
	Hsys[55] = -18'sd9934;
	Hsys[56] = -18'sd9408;
	Hsys[57] = -18'sd3883;
	Hsys[58] = 18'sd2168;
	Hsys[59] = 18'sd5294;
	Hsys[60] = 18'sd4544;
	Hsys[61] = 18'sd1351;
	Hsys[62] = -18'sd1825;
	Hsys[63] = -18'sd3130;
	Hsys[64] = -18'sd2247;
	Hsys[65] = -18'sd237;
	Hsys[66] = 18'sd1410;
	Hsys[67] = 18'sd1771;
	Hsys[68] = 18'sd940;
	Hsys[69] = -18'sd264;
	Hsys[70] = -18'sd974;
	Hsys[71] = -18'sd851;
	Hsys[72] = -18'sd187;
	Hsys[73] = 18'sd426;
	Hsys[74] = 18'sd568;
	Hsys[75] = 18'sd245;
	Hsys[76] = -18'sd198;
	Hsys[77] = -18'sd395;
	Hsys[78] = -18'sd231;
	Hsys[79] = 18'sd112;
	Hsys[80] = 18'sd335;
	Hsys[81] = 18'sd269;
	Hsys[82] = -18'sd12;
	Hsys[83] = -18'sd273;
	Hsys[84] = -18'sd313;
	Hsys[85] = -18'sd116;
	Hsys[86] = 18'sd154;
	Hsys[87] = 18'sd292;
	Hsys[88] = 18'sd208;
	Hsys[89] = -18'sd16;
	Hsys[90] = -18'sd204;
	Hsys[91] = -18'sd223;
	Hsys[92] = -18'sd80;
	Hsys[93] = 18'sd101;
	Hsys[94] = 18'sd182;
	Hsys[95] = 18'sd116;
	Hsys[96] = -18'sd30;
	Hsys[97] = -18'sd133;
	Hsys[98] = -18'sd118;
	Hsys[99] = -18'sd10;
	Hsys[100] = 18'sd97;
end

endmodule 
