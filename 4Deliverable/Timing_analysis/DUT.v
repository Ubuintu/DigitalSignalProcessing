module DUT #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=15,
    parameter DELAY=4,
    parameter SUMLV1=8,
    parameter SUMLV2=4,
    parameter SUMLV3=2
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);
(* preserve *) reg signed [WIDTH-1:0] x;

/*-----------x[n]-----------*/
always @ (posedge sys_clk)
    if (reset) 
        x<=18'sd0;
    else if (sam_clk_en) begin
        x<=$signed( x_in );
    end
    else
        x<=$signed(x);

/*------------Upsample b4 1st LPF | 12.5 MHz------------*/
(* preserve *) reg halfSysCnt;

always @ (posedge sys_clk)
	if (reset)
		halfSysCnt=1'd0;
	else if (sys_clk2_en)
		halfSysCnt=~halfSysCnt;
		
(* keep *) reg signed [17:0] UpSam1;

always @ * begin
	case (halfSysCnt)
		1'd0 : UpSam1=$signed(x);
		default : UpSam1=18'sd0;
	endcase
end
		
/*------------First halfband LPF | 12.5 MHz------------*/
wire signed [17:0] halfOut1;

halfband_1st_sym HB1 (
//halfband_1st_sym_copy HB1 (
	.x_in(UpSam1),
	.y(halfOut1),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.reset(reset),
	.clk(clk),
	.sys_clk2_en(sys_clk2_en)
	);

/*------------Upsample b4 2nd LPF | 25 MHz------------*/
(* preserve *) reg SysCnt;

always @ (posedge sys_clk)
	if (reset)
		SysCnt<=1'd0;
	else 
		SysCnt<=SysCnt+1'd1;
		
		
(* keep *) reg signed [17:0] UpSam2;

always @ * begin
	case (SysCnt)
		1'd0 : UpSam2=$signed(halfOut1);
		default : UpSam2=18'sd0;
	endcase
end
		
/*------------Second halfband LPF | 25 MHz------------*/
wire signed [17:0] halfOut2;

halfband_2nd_sym HB2 (
	.x_in(UpSam2),
	.y(halfOut2),
	.sys_clk(sys_clk),
	.sam_clk_en(sam_clk_en),
	.reset(reset),
	.clk(clk),
	.sys_clk2_en(sys_clk2_en)
	);

always @ (sys_clk)
	if (reset)
		y<=18'sd0;
	else
		y<=$signed(halfOut2);

endmodule

/*----------------------------------HB1----------------------------------*/
module halfband_1st_sym #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=15,
    parameter DELAY=4,
    parameter SUMLV1=8,
    parameter SUMLV2=4,
    parameter SUMLV3=2
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* keep *) reg signed [2*WIDTH-1:0] mult_out[SUMLV1-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV2-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_3[SUMLV3-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_4;
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
     for (i=0; i<SUMLV3; i=i+1)
        sum_lvl_3[i]=18'sd0;
     sum_lvl_4 = 18'sd0;
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
	for(i=0; i<SUMLV1; i=i+1)
				//mult_out (2s34) = 0s18 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);

/*-----------SUMLV2-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for (i=0; i<SUMLV2; i=i+1)				
	    //mult_out (2s34) -> sum_lvl_2 1s17
            sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
    end

/*-----------SUMLV3-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end

/*-----------SUMLV4-----------*/
always @ (posedge sys_clk)
    if (reset)
       sum_lvl_4<=18'sd0;
    else if (sys_clk2_en)
       sum_lvl_4<=$signed(sum_lvl_3[0])+$signed(sum_lvl_3[1]);

/*-----------Output-----------*/
always @ (posedge sys_clk)
    if (reset) 
	y<= 18'sd0;
    else if (sys_clk2_en)
	y<=$signed(sum_lvl_4);
    else 
	y<=$signed(y);

/*-----------coeffs 0s18-----------*/
initial begin
	Hsys[0] = -18'sd348;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd3274;
	Hsys[3] = 18'sd0;
	Hsys[4] = -18'sd15925;
	Hsys[5] = 18'sd0;
	Hsys[6] = 18'sd78535;
	Hsys[7] = 18'sd131071;
end

endmodule

/*----------------------------------HB2----------------------------------*/
module halfband_2nd_sym #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=15,
    parameter DELAY=4,
    parameter SUMLV1=8,
    parameter SUMLV2=4,
    parameter SUMLV3=2
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* keep *) reg signed [2*WIDTH-1:0] mult_out[SUMLV1-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_2[SUMLV2-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_3[SUMLV3-1:0];
(* noprune *) reg signed [WIDTH-1:0] sum_lvl_4;
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
     for (i=0; i<SUMLV3; i=i+1)
        sum_lvl_3[i]=18'sd0;
     sum_lvl_4 = 18'sd0;
     y = 18'sd0;
end


/*-----------x[n]-----------*/
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else
        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow

always @ (posedge sys_clk)
    if (reset) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=18'sd0;
    end
    else begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=$signed(x[i-1]);
    end

/*-----------sum_lvl_1-----------*/
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= 18'sd0;
    end
    else begin
		 for(i=0;i<SUMLV1-1;i=i+1)
			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

//cntr
always @ (posedge sys_clk)
    if (reset) sum_lvl_1[SUMLV1-1] <= 18'sd0;
    else sum_lvl_1[SUMLV1-1] <= $signed(x[SUMLV1-1]);

/*-----------Mult_out (2s34)-----------*/
always @ *
	for(i=0; i<SUMLV1; i=i+1)
				//mult_out (2s34) = 0s18 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);

/*-----------SUMLV2-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else begin
        for (i=0; i<SUMLV2; i=i+1)				
	    //mult_out (2s34) -> sum_lvl_2 1s17
            sum_lvl_2[i]<=$signed(mult_out[2*i][34:17])+$signed(mult_out[2*i+1][34:17]);
    end

/*-----------SUMLV3-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=18'sd0;
    end
    else begin
        for (i=0; i<SUMLV3; i=i+1)
            sum_lvl_3[i]<=$signed(sum_lvl_2[2*i])+$signed(sum_lvl_2[2*i+1]);
    end

/*-----------SUMLV4-----------*/
always @ (posedge sys_clk)
    if (reset)
       sum_lvl_4<=18'sd0;
    else
       sum_lvl_4<=$signed(sum_lvl_3[0])+$signed(sum_lvl_3[1]);

/*-----------Output-----------*/
always @ (posedge sys_clk)
    if (reset) 
		y<= 18'sd0;
    else 
		y<=$signed(sum_lvl_4);

/*-----------coeffs 0s18-----------*/
initial begin
	Hsys[0] = -18'sd322;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd3144;
	Hsys[3] = 18'sd0;
	Hsys[4] = -18'sd15695;
	Hsys[5] = 18'sd0;
	Hsys[6] = 18'sd78408;
	Hsys[7] = 18'sd131071;
end

endmodule

/*----------------------------------HB1_6coeffs----------------------------------*/
module halfband_1st_sym_copy #(
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
	for(i=0; i<SUMLV1; i=i+1)
				//mult_out (2s34) = 0s18 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);

/*-----------SUMLV2-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for (i=0; i<SUMLV2; i=i+1)				
	    //mult_out (2s34) -> sum_lvl_2 1s17
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
	Hsys[0] = -18'sd8495;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd74024;
	Hsys[3] = 18'sd131071;
end

endmodule

