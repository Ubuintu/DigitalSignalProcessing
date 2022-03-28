module GSM_101Mults #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=101,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter SUMLV1=51,
    parameter SUMLV2=13,
    parameter SUMLV3=7,
    parameter SUMLV4=4,
    parameter SUMLV5=2,
    parameter SUMLV6=1
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
(* noprune *) reg signed [2*WIDTH-1:0] mult_out[SUMLV2:0];
(* noprune *) reg signed [WIDTH-1:0] mult_in[SUMLV2-1:0];
(* noprune *) reg signed [WIDTH-1:0] mult_coeff[SUMLV2:0];
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
//0s18 coeffs
(* noprune *) reg signed [WIDTH-1:0] Hsys[(LENGTH-1)/2:0];
(* noprune *) reg [1:0] cnt;

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
     for (i=0; i<SUMLV2; i=i+1)
        mult_out[i]=36'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
     cnt=2'd0;
end

//counter
always @ (posedge sys_clk)
    if (reset)
        cnt=2'd3;   //offset for pipeline
    else
        cnt=cnt+2'd1;

/*  scale 1s17->2s16 for summing    */
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else if (sam_clk_en) begin
        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
        //x[0]<=$signed(x_in );	// for Debuggin
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

/*      SUMLV1      */
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


/*      Time-sharing Lvl        */
//multiplier input
//always @ (cnt)	// delayed in ModelSim
always @ *
    for (i=0;i<SUMLV2-1;i=i+1) begin
        case (cnt)
            2'd0    :   mult_in[i]<=$signed(sum_lvl_1[4*i]); 
            2'd1    :   mult_in[i]<=$signed(sum_lvl_1[4*i+1]); 
            2'd2    :   mult_in[i]<=$signed(sum_lvl_1[4*i+2]); 
            default    :   mult_in[i]<=$signed(sum_lvl_1[4*i+3]); 
        endcase
    end

//cntr
always @ *
	begin
        case (cnt)
            2'd0    :   mult_in[SUMLV2-1]<=$signed(sum_lvl_1[48]); 
            2'd1    :   mult_in[SUMLV2-1]<=$signed(sum_lvl_1[49]); 
            2'd2    :   mult_in[SUMLV2-1]<=$signed(sum_lvl_1[50]); 
            default    :   mult_in[SUMLV2-1]<=18'sd0; 
        endcase
    end

//integer inte=0;
always @ (posedge sys_clk)
    if (reset) y<= 18'sd0;
    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
    else if (sam_clk_en) begin
        /*
        y<=$signed(sum_lvl_7);
    	$display("index: %d | y: %d",i,y);
    	inte=inte+1;
        */
        //debugging
        for (i=0; i<SUMLV2;i=i+1)
            y<=$signed(y);
    end
    else y<=$signed(y);

endmodule


/*			!!!FOR TESTING!!!		*/


//module GSM_101Mults #(
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
//(* noprune *) reg signed [2*WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
////(* noprune *) reg signed [WIDTH-1:0] tol;
//(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
//(* noprune *) reg signed [WIDTH-1:0] Hsys[(LENGTH-1)/2:0];
//
//integer i,j;
//initial begin
////     tol=18'sd10;
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
//        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
//        //x[0]<=$signed(x_in );	// for IR
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
////1s17 + 1s17 will cause overflow for sum_lvl_1[i]
//always @ (posedge sys_clk)
//    if (reset) begin
//		 for(i=0;i<SUMLV1-1;i=i+1)
//			  sum_lvl_1[i] <= 18'sd0;
//    end
//    else if (sam_clk_en) begin
//		 for(i=0;i<SUMLV1-1;i=i+1)
//			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
//    end
//
////cntr
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
//	else if (sam_clk_en) sum_lvl_1[SUMLV1-1] <= $signed(x[SUMLV1-1]);
//	else sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);
//
//
////always @ (posedge clk)
//always @ *
//    if (reset) begin
//		 for(i=0;i<SUMLV1; i=i+1)
//		 //should be 2s34 (2s16*0s18)
//			  mult_out[i] = 18'sd0;
//    end
//    else begin
//        for(i=0; i<SUMLV1; i=i+1)
//				//mult_out (2s34) = 0s18 * 2s16
//				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);
//    end
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
////				//mult_out (2s34) -> sum_lvl_2 1s17
////            sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
//				//mult_out (3s33) -> sum_lvl_2 1s17
//            sum_lvl_2[i]<=$signed(mult_out[2*i][33:16])+$signed(mult_out[2*i+1][33:16]);
//    end
////for center
//always @ (posedge sys_clk)
//    if (reset) sum_lvl_2[SUMLV2-1] <= 18'sd0;
////    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1][34:17]);
//    else if (sam_clk_en) sum_lvl_2[SUMLV2-1]<=$signed(mult_out[SUMLV1-1][33:16]);
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
////integer inte=0;
//always @ (posedge sys_clk)
//    if (reset) y<= 18'sd0;
//    //else if (sam_clk_en) y<=$signed( {sum_lvl[LENGTH+OFFSET-1][16:0],1'b0} );
//    else if (sam_clk_en) begin
//	y<=$signed(sum_lvl_7);
////	$display("index: %d | y: %d",i,y);
////	inte=inte+1;
//    end
//    else y<=$signed(y);
//
//initial begin
//	Hsys[0] = 18'sd90;
//	Hsys[1] = -18'sd9;
//	Hsys[2] = -18'sd109;
//	Hsys[3] = -18'sd122;
//	Hsys[4] = -18'sd27;
//	Hsys[5] = 18'sd107;
//	Hsys[6] = 18'sd168;
//	Hsys[7] = 18'sd93;
//	Hsys[8] = -18'sd74;
//	Hsys[9] = -18'sd206;
//	Hsys[10] = -18'sd188;
//	Hsys[11] = -18'sd15;
//	Hsys[12] = 18'sd192;
//	Hsys[13] = 18'sd269;
//	Hsys[14] = 18'sd142;
//	Hsys[15] = -18'sd107;
//	Hsys[16] = -18'sd289;
//	Hsys[17] = -18'sd252;
//	Hsys[18] = -18'sd11;
//	Hsys[19] = 18'sd248;
//	Hsys[20] = 18'sd309;
//	Hsys[21] = 18'sd103;
//	Hsys[22] = -18'sd213;
//	Hsys[23] = -18'sd365;
//	Hsys[24] = -18'sd183;
//	Hsys[25] = 18'sd226;
//	Hsys[26] = 18'sd524;
//	Hsys[27] = 18'sd393;
//	Hsys[28] = -18'sd173;
//	Hsys[29] = -18'sd786;
//	Hsys[30] = -18'sd899;
//	Hsys[31] = -18'sd244;
//	Hsys[32] = 18'sd867;
//	Hsys[33] = 18'sd1635;
//	Hsys[34] = 18'sd1301;
//	Hsys[35] = -18'sd218;
//	Hsys[36] = -18'sd2074;
//	Hsys[37] = -18'sd2889;
//	Hsys[38] = -18'sd1684;
//	Hsys[39] = 18'sd1247;
//	Hsys[40] = 18'sd4194;
//	Hsys[41] = 18'sd4886;
//	Hsys[42] = 18'sd2001;
//	Hsys[43] = -18'sd3583;
//	Hsys[44] = -18'sd8683;
//	Hsys[45] = -18'sd9168;
//	Hsys[46] = -18'sd2210;
//	Hsys[47] = 18'sd11801;
//	Hsys[48] = 18'sd28844;
//	Hsys[49] = 18'sd42785;
//	Hsys[50] = 18'sd48159;
//end
//
//endmodule 
