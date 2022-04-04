module GSM_TS #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=101,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter SUMLV1=51,
    parameter SUMLV2=13, //num of taps for mixers
    parameter SUMLV3=7, //taps for sumLv2
    parameter SUMLV4=4,
    parameter SUMLV5=2,
    parameter SUMLV6=1
)
(
    input sys_clk, sam_clk_en, reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* preserve *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV3-1:0];
(* preserve *) reg signed [WIDTH-1:0] sum_lvl_3[SUMLV4-1:0];
(* preserve *) reg signed [WIDTH-1:0] sum_lvl_4[SUMLV5-1:0];
(* preserve *) reg signed [WIDTH-1:0] sum_lvl_5;
(* keep *) reg signed [2*WIDTH-1:0] mult_out[SUMLV2-1:0];
(* keep *) reg signed [WIDTH-1:0] mult_in[SUMLV2-1:0];
(* preserve *) reg signed [WIDTH-1:0] mult_coeff[SUMLV2-1:0];
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
//0s18 coeffs
(* keep *) reg signed [WIDTH-1:0] Hsys[(LENGTH-1)/2:0];
(* preserve *) reg [1:0] cnt;

//debugging
//integer inte=0;

integer i,j;
/*
initial begin
//     tol=18'sd10;
     for (i=0; i<SUMLV1; i=i+1)
        sum_lvl_1[i]=18'sd0;
     for (i=0; i<SUMLV3; i=i+1)
        sum_lvl_2[i]=18'sd0;
     for (i=0; i<SUMLV4; i=i+1)
        sum_lvl_3[i]=18'sd0;
     for (i=0; i<SUMLV5; i=i+1)
        sum_lvl_4[i]=18'sd0;
    sum_lvl_5=18'sd0;
     for (i=0; i<SUMLV2; i=i+1)
        mult_out[i]=36'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
     cnt=2'd0;
end
*/

//counter
always @ (posedge sys_clk)
    if (reset)
        cnt<=2'd1;  
    else
        cnt<=cnt+2'd1;

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
    if (reset) 
			sum_lvl_1[SUMLV1-1] <= 18'sd0;
    else if (sam_clk_en) 
			sum_lvl_1[SUMLV1-1] <= $signed(x[SUMLV1-1]);
    else 
			sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);

/*      Time-sharing Lvl        */

//multiplier input (2s16)
always @ *
    for (i=0;i<SUMLV2-1;i=i+1) begin
        case (cnt)
            2'd0    :   mult_in[i]=$signed(sum_lvl_1[4*i]); 
            2'd1    :   mult_in[i]=$signed(sum_lvl_1[4*i+1]); 
            2'd2    :   mult_in[i]=$signed(sum_lvl_1[4*i+2]); 
            default    :   mult_in[i]=$signed(sum_lvl_1[4*i+3]); 
        endcase
    end

/*
always @ (posedge sys_clk)
	 for (i=0;i<SUMLV2-1;i=i+1) begin
		  case (cnt)
				2'd0    :   mult_in[i]<=$signed(sum_lvl_1[4*i]); 
				2'd1    :   mult_in[i]<=$signed(sum_lvl_1[4*i+1]); 
				2'd2    :   mult_in[i]<=$signed(sum_lvl_1[4*i+2]); 
				default    :   mult_in[i]<=$signed(sum_lvl_1[4*i+3]); 
		  endcase
    end
*/
//cntr
always @ *
	begin
	case (cnt)
	    2'd0    :   mult_in[SUMLV2-1]=$signed(sum_lvl_1[48]); 
	    2'd1    :   mult_in[SUMLV2-1]=$signed(sum_lvl_1[49]); 
	    2'd2    :   mult_in[SUMLV2-1]=$signed(sum_lvl_1[50]); 
	    default    :   mult_in[SUMLV2-1]=18'sd0; 
	endcase
    end

//multiplier coeff (0s18)
//always @ (cnt)	// delayed in ModelSim
always @ *
    for (i=0;i<SUMLV2-1;i=i+1) begin
        case (cnt)
            2'd0    :   mult_coeff[i]=$signed(Hsys[4*i]); 
            2'd1    :   mult_coeff[i]=$signed(Hsys[4*i+1]); 
            2'd2    :   mult_coeff[i]=$signed(Hsys[4*i+2]); 
            default    :   mult_coeff[i]=$signed(Hsys[4*i+3]); 
        endcase
    end

//cntr
always @ *
	begin
        case (cnt)
            2'd0    :   mult_coeff[SUMLV2-1]=$signed(Hsys[48]); 
            2'd1    :   mult_coeff[SUMLV2-1]=$signed(Hsys[49]); 
            2'd2    :   mult_coeff[SUMLV2-1]=$signed(Hsys[50]); 
            default    :   mult_coeff[SUMLV2-1]=18'sd0; 
        endcase
    end

//Mixing logic (2s34)
always @ *
    for (i=0; i<SUMLV2; i=i+1) 
        mult_out[i]=$signed(mult_coeff[i])*$signed(mult_in[i]);

/*---------------SUMLV2---------------*/
// remove pipeline to time logic
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3-1; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
//    else if (sam_clk_en) begin
    else begin
        for (i=0; i<SUMLV3-1; i=i+1)
			//mult_out (2s34) -> sum_lvl_2 1s17
            sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
//            $display("index: %d | SL2: %d",i,sum_lvl_2[i]);
//            inte=inte+1;
    end

//cntr
always @ (posedge sys_clk)
    if (reset)
        sum_lvl_2[SUMLV3-1]<=18'sd0;
    else
        sum_lvl_2[SUMLV3-1]<=$signed(mult_out[SUMLV2-1][34:17]);

/*---------------SUMLV3---------------*/
//pipeline w/sys_clk to avoid timing issues
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV4-1; i=i+1)
            sum_lvl_3[i]<=18'sd0;
    end
    else begin
        for (i=0; i<SUMLV4-1; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end

//center
always @ (posedge sys_clk)
    if (reset) 
        sum_lvl_3[SUMLV4-1] <= 18'sd0;
    else 
        sum_lvl_3[SUMLV4-1]<=$signed(sum_lvl_2[SUMLV3-1]);

/*---------------SUMLV4---------------*/
always @ (posedge sys_clk)
//always @ *
    if (reset) begin
        //SUMLV3=4 -> SUMLV4=2
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_4[i]<=18'sd0;
    end
    else begin
        for (i=0; i<SUMLV5; i=i+1)
            sum_lvl_4[i]<=$signed(sum_lvl_3[2*i])+$signed(sum_lvl_3[2*i+1]);
    end

/*---------------SUMLV5---------------*/
//always @ (posedge sys_clk)
always @ *
    if (reset) 
        sum_lvl_5 = 18'sd0;
    else 
        sum_lvl_5 = $signed(sum_lvl_4[0])+$signed(sum_lvl_4[1]);


/*---------------Accumulator---------------*/
//coeffs scaled down for wc 1s17 input
(* preserve *) reg signed [WIDTH-1:0] acc_out;

initial begin
    acc_out = 18'sd0;
    det_edge = 2'd0;
end
assign sig_edge = (det_edge == 2'b01);

always @ (posedge sys_clk)
    if (reset || sam_clk_en) 
        acc_out <= $signed(sum_lvl_5);
    else 
        acc_out <= acc_out + $signed(sum_lvl_5);

/*---------------Final Reg---------------*/
always @ (posedge sys_clk)
    if (reset) 
		  y<= 18'sd0;
    else if (sam_clk_en) begin
        y<=$signed(acc_out);
    end
	else
        y<=$signed(y);
		

initial begin
	Hsys[0] = 18'sd73;
	Hsys[1] = -18'sd7;
	Hsys[2] = -18'sd89;
	Hsys[3] = -18'sd99;
	Hsys[4] = -18'sd22;
	Hsys[5] = 18'sd87;
	Hsys[6] = 18'sd137;
	Hsys[7] = 18'sd76;
	Hsys[8] = -18'sd60;
	Hsys[9] = -18'sd167;
	Hsys[10] = -18'sd153;
	Hsys[11] = -18'sd12;
	Hsys[12] = 18'sd156;
	Hsys[13] = 18'sd219;
	Hsys[14] = 18'sd116;
	Hsys[15] = -18'sd87;
	Hsys[16] = -18'sd235;
	Hsys[17] = -18'sd205;
	Hsys[18] = -18'sd9;
	Hsys[19] = 18'sd201;
	Hsys[20] = 18'sd251;
	Hsys[21] = 18'sd84;
	Hsys[22] = -18'sd173;
	Hsys[23] = -18'sd297;
	Hsys[24] = -18'sd149;
	Hsys[25] = 18'sd184;
	Hsys[26] = 18'sd426;
	Hsys[27] = 18'sd320;
	Hsys[28] = -18'sd141;
	Hsys[29] = -18'sd639;
	Hsys[30] = -18'sd731;
	Hsys[31] = -18'sd198;
	Hsys[32] = 18'sd705;
	Hsys[33] = 18'sd1329;
	Hsys[34] = 18'sd1057;
	Hsys[35] = -18'sd178;
	Hsys[36] = -18'sd1686;
	Hsys[37] = -18'sd2348;
	Hsys[38] = -18'sd1369;
	Hsys[39] = 18'sd1014;
	Hsys[40] = 18'sd3408;
	Hsys[41] = 18'sd3971;
	Hsys[42] = 18'sd1626;
	Hsys[43] = -18'sd2912;
	Hsys[44] = -18'sd7056;
	Hsys[45] = -18'sd7450;
	Hsys[46] = -18'sd1796;
	Hsys[47] = 18'sd9590;
	Hsys[48] = 18'sd23440;
	Hsys[49] = 18'sd34770;
	Hsys[50] = 18'sd39137;
end

endmodule 
