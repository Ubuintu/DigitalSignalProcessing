module DUT #(
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
(* noprune *) reg signed [2*WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
//(* noprune *) reg signed [WIDTH-1:0] tol;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[(LENGTH-1)/2:0];

integer i,j;
initial begin
//     tol=18'sd10;
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
//     for (i=0; i<SUMLV1; i=i+1)
//        mult_out[i]=18'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
end

//scale 1s17->2s16 for summing
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else if (sam_clk_en) begin
        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
        //x[0]<=$signed(x_in );	// for IR
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
			  sum_lvl_1[i] <= 18'sd0;
    end
    else if (sam_clk_en) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

//cntr
always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] <= $signed(x[SUMLV1-1]);
	else sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);


//always @ (posedge clk)
always @ *
    if (reset) begin
		 for(i=0;i<SUMLV1; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for(i=0; i<SUMLV1; i=i+1)
				//mult_out (2s34) = 0s18 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);
    end

//!!! SEE D3.m for structure of filter/center tap location !!!
/*          SUMLV2              */
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2-1; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for (i=0; i<SUMLV2-1; i=i+1)
//				//mult_out (2s34) -> sum_lvl_2 1s17
//            sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
				//mult_out (3s33) -> sum_lvl_2 1s17
            sum_lvl_2[i]<=$signed(mult_out[2*i][33:16])+$signed(mult_out[2*i+1][33:16]);
    end
//for center
always @ (posedge sys_clk)
    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
//    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1][34:17]);
    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1][33:16]);

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


//integer inte=0;
always @ (posedge sys_clk)
    if (reset) y<= 18'sd0;
    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
    else if (sam_clk_en) begin
	y<=$signed(sum_lvl_7);
//	$display("index: %d | y: %d",i,y);
//	inte=inte+1;
    end
    else y<=$signed(y);

initial begin
	Hsys[0] = 18'sd49;
	Hsys[1] = 18'sd22;
	Hsys[2] = -18'sd25;
	Hsys[3] = -18'sd58;
	Hsys[4] = -18'sd51;
	Hsys[5] = -18'sd6;
	Hsys[6] = 18'sd48;
	Hsys[7] = 18'sd71;
	Hsys[8] = 18'sd44;
	Hsys[9] = -18'sd16;
	Hsys[10] = -18'sd69;
	Hsys[11] = -18'sd74;
	Hsys[12] = -18'sd26;
	Hsys[13] = 18'sd43;
	Hsys[14] = 18'sd83;
	Hsys[15] = 18'sd63;
	Hsys[16] = -18'sd4;
	Hsys[17] = -18'sd70;
	Hsys[18] = -18'sd84;
	Hsys[19] = -18'sd32;
	Hsys[20] = 18'sd48;
	Hsys[21] = 18'sd94;
	Hsys[22] = 18'sd65;
	Hsys[23] = -18'sd23;
	Hsys[24] = -18'sd104;
	Hsys[25] = -18'sd107;
	Hsys[26] = -18'sd17;
	Hsys[27] = 18'sd108;
	Hsys[28] = 18'sd170;
	Hsys[29] = 18'sd103;
	Hsys[30] = -18'sd68;
	Hsys[31] = -18'sd228;
	Hsys[32] = -18'sd245;
	Hsys[33] = -18'sd71;
	Hsys[34] = 18'sd202;
	Hsys[35] = 18'sd387;
	Hsys[36] = 18'sd322;
	Hsys[37] = -18'sd2;
	Hsys[38] = -18'sd402;
	Hsys[39] = -18'sd598;
	Hsys[40] = -18'sd400;
	Hsys[41] = 18'sd136;
	Hsys[42] = 18'sd695;
	Hsys[43] = 18'sd879;
	Hsys[44] = 18'sd471;
	Hsys[45] = -18'sd369;
	Hsys[46] = -18'sd1140;
	Hsys[47] = -18'sd1278;
	Hsys[48] = -18'sd533;
	Hsys[49] = 18'sd784;
	Hsys[50] = 18'sd1887;
	Hsys[51] = 18'sd1934;
	Hsys[52] = 18'sd580;
	Hsys[53] = -18'sd1658;
	Hsys[54] = -18'sd3496;
	Hsys[55] = -18'sd3447;
	Hsys[56] = -18'sd610;
	Hsys[57] = 18'sd4729;
	Hsys[58] = 18'sd11041;
	Hsys[59] = 18'sd16127;
	Hsys[60] = 18'sd18074;
end

endmodule
