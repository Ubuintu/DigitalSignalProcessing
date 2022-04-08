//module DUT #(
////Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
//    parameter WIDTH=18,
//    parameter LENGTH=15,
//    parameter DELAY=2,
//    parameter SUMLV1=8,
//    parameter SUMLV2=4,
//    parameter SUMLV3=2
//)
//(
//    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
//    input signed [WIDTH-1:0] x_in,
//    output reg signed [WIDTH-1:0] y
//);
//
//(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
//(* preserve *) reg signed [WIDTH-1:0] sum_lvl_2;
//(* keep *) reg signed [2*WIDTH-1:0] mult_out;
//(* preserve *) reg signed [WIDTH-1:0] mult_in;
//(* preserve *) reg signed [WIDTH-1:0] mult_coeff;
//(* preserve *) reg signed [WIDTH-1:0] center_coeff;
//(* preserve *) reg signed [WIDTH-1:0] acc;
//(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
////0s18 coeffs
//(* keep *) reg signed [WIDTH-1:0] Hsys[SUMLV1:0];
////run @ 50 MHz
//(* preserve *) reg [1:0] cnt;
//
//integer i;
///*-----------comment out for Quartus-----------*/
//initial begin
//     for (i=0; i<SUMLV1; i=i+1)
//        sum_lvl_1[i]=18'sd0;
//     mult_out=36'sd0;
//     mult_in=18'sd0;
//     mult_coeff=18'sd0;
//     for (i=0; i<LENGTH; i=i+1)
//        x[i]=18'sd0;
//     y = 18'sd0;
//     sum_lvl_2 = 18'sd0;
//     center_coeff = 18'sd0;
//     acc = 18'sd0;
//     cnt=2'd3;
//end
//
////cnt
//always @ (posedge clk)
//    if (reset)
//        cnt<=2'd3;
//    else
//        cnt<=cnt+2'd1;
//
///*-----------x[n]-----------*/
//always @ (posedge sys_clk)
//    if (reset) 
//        x[0]<=18'sd0;
//    else if (sys_clk2_en) begin
//        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
//    end
//    else
//        x[0]<=$signed(x[0]);
//
//always @ (posedge sys_clk)
//    if (reset) begin
//        for(i=1; i<LENGTH; i=i+1)
//            x[i]<=18'sd0;
//    end
//    else if (sys_clk2_en) begin
//        for(i=1; i<LENGTH; i=i+1)
//            x[i]<=$signed(x[i-1]);
//    end
//
///*-----------sum_lvl_1-----------*/
//always @ (posedge sys_clk)
//    if (reset) begin
//		 for(i=0;i<SUMLV1;i=i+1)
//			  sum_lvl_1[i] <= 18'sd0;
//    end
//    else if (sys_clk2_en) begin
//		 for(i=0;i<SUMLV1;i=i+1)
//            if (i==7)
//                sum_lvl_1[7]<=$signed(x[7]);
//            else
//			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
//    end
//
///*-----------Mult_in (2s16)-----------*/
//always @ * begin
//    case (cnt)
//        2'd0: mult_in=$signed(sum_lvl_1[0]);
//        2'd1: mult_in=$signed(sum_lvl_1[2]);
//        2'd2: mult_in=$signed(sum_lvl_1[4]);
//        2'd3: mult_in=$signed(sum_lvl_1[6]);
//    endcase
//end
//
///*-----------Mult_coeff (1s17)-----------*/
//always @ * begin
//    case (cnt)
//        2'd0: mult_coeff=$signed(Hsys[0]);
//        2'd1: mult_coeff=$signed(Hsys[2]);
//        2'd2: mult_coeff=$signed(Hsys[4]);
//        2'd3: mult_coeff=$signed(Hsys[6]);
//    endcase
//end
//
///*-----------Mult_out for even taps (3s33)-----------*/
//always @ *
//    mult_out<=$signed(mult_coeff)*$signed(mult_in);
//
///*-----------center_coeff 1s17-----------*/
////pk of halfband is always 0.5 so bitshift instead of mult
//always @ * begin
//    case (cnt)
//        2'd0: center_coeff=(18'sd0);
//        2'd1: center_coeff=(18'sd0);
//        2'd2: center_coeff=(18'sd0);
//        2'd3: center_coeff=$signed(sum_lvl_1[7]);
//    endcase
//end
//
//always @ (posedge clk)
////always @ *
//    sum_lvl_2=$signed(mult_out[33:17])+center_coeff;
//
///*-----------Delay-----------*/
//reg signed [17:0] pipe [DELAY-1:0];
//
//always @ (posedge clk)
//    for (i=0; i<DELAY; i=i+1)
//        if (i==0)
//            pipe[i]<=sum_lvl_2;
//        else
//            pipe[i]<=pipe[i-1];
//
///*-----------Accumulator-----------*/
//always @ (posedge clk)
//    if (reset || (sys_clk2_en && cnt==2'd3) )
//        acc<=$signed(pipe[DELAY-1]);
//        //acc<=$signed(sum_lvl_2);
//    else
//        acc<=acc+$signed(pipe[DELAY-1]);
//        //acc<=acc+$signed(sum_lvl_2);
//
///*-----------Impulse response of filter-----------*/
//initial begin
//	Hsys[0] = -18'sd174;
//	Hsys[1] = 18'sd0;
//	Hsys[2] = 18'sd1637;
//	Hsys[3] = 18'sd0;
//	Hsys[4] = -18'sd7962;
//	Hsys[5] = 18'sd0;
//	Hsys[6] = 18'sd39267;
//	Hsys[7] = 18'sd65536;
//end
//
//endmodule

module DUT #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=7,
    parameter DELAY=4,
    parameter SUMLV1=4,
    parameter SUMLV2=2,
    parameter SUMLV3=1
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* keep *) reg signed [2*WIDTH-1:0] mult_out[SUMLV1-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV2-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_3;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
//0s18 coeffs
(* keep *) reg signed [WIDTH-1:0] Hsys[SUMLV1-1:0];


integer i;
initial begin
     for (i=0; i<SUMLV1; i=i+1)
        sum_lvl_1[i]=18'sd0;
     for (i=0; i<SUMLV1; i=i+1)
        mult_out[i]=36'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     sum_lvl_3=18'sd0;
     y = 18'sd0;
end


/*-----------x[n]-----------*/
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else if (sys_clk2_en) begin
        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
    end
    else
        x[0]<=$signed(x[0]);

always @ (posedge sys_clk)
    if (reset) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=$signed(x[i-1]);
    end

/*-----------sum_lvl_1-----------*/
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= 18'sd0;
    end
    else if (sys_clk2_en) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

//cntr
always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
    else if (sys_clk2_en) sum_lvl_1[SUMLV1-1] <= $signed(x[SUMLV1-1]);
    else sum_lvl_1[SUMLV1-1] <= $signed(sum_lvl_1[SUMLV1-1]);

/*-----------Mult_out (2s34)-----------*/
always @ *
	for(i=0; i<SUMLV1; i=i+1) begin
		if (i<SUMLV1-1 && i!=1)
				//mult_out (3s34) = 1s17 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);
		else if (i==1)
			mult_out[i]=36'sd0;
		else
			//center of sumlvl 1 is alraedy bitshifted
			mult_out[i]=$signed( {1'd0,sum_lvl_1[i],{17{1'd0}}} );
	end

/*-----------SUMLV2-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for (i=0; i<SUMLV2; i=i+1)
	    if (i==0)				
	    	//mult_out (2s34) -> sum_lvl_2 1s17
            	sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
	    else
		sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
    end

/*-----------SUMLV3-----------*/
always @ (posedge sys_clk)
    if (reset)
       sum_lvl_3<=18'sd0;
    else if (sys_clk2_en)
       sum_lvl_3<=$signed(sum_lvl_2[0])+$signed(sum_lvl_2[1]);

/*-----------Output-----------*/
always @ (posedge sys_clk)
    if (reset) 
	y<= 18'sd0;
    else if (sys_clk2_en)
	y<=$signed(sum_lvl_3);
    else 
	y<=$signed(y);

/*-----------coeffs 0s18-----------*/
initial begin
	Hsys[0] = -18'sd4248;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd37012;
	Hsys[3] = 18'sd65536;
end

endmodule
