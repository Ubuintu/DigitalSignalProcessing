module DUT #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=15,
    parameter DELAY=4,
    parameter SUMLV1=4
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

//E0(z)
(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
//E0 & E1
(* keep *) reg signed [2*WIDTH-1:0] mult_out;
(* preserve *) reg signed [WIDTH-1:0] mult_in;
(* preserve *) reg signed [WIDTH-1:0] mult_coeff;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* preserve *) reg signed [WIDTH-1:0] x_Delay;
//0s18 coeffs
(* keep *) reg signed [WIDTH-1:0] Hsys[SUMLV1:0];
//run @ 50 MHz
(* preserve *) reg [1:0] cnt;


integer i;
initial begin
     for (i=0; i<SUMLV1; i=i+1)
        sum_lvl_1[i]=18'sd0;
     mult_out=36'sd0;
     mult_in=18'sd0;
     mult_coeff=18'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
     y = 18'sd0;
     cnt=2'd0;
end

//cnt
always @ (posedge sys_clk)
    if (reset)
        cnt<=2'd0;
    else
        cnt<=cnt+2'd1;

/*-----------E0(z)-----------*/
always @ (posedge sys_clk)
    if (reset) 
        x[0]<=18'sd0;
    else if (sam_clk_en) begin
        x[0]<=$signed( {x_in[17],x_in[17:1]} );	//format input to 2s16 to prevent overflow
    end
    else
        x[0]<=$signed(x[0]);

always @ (posedge sys_clk)
    if (reset) begin
        for(i=2; i<LENGTH; i=i+2)
            x[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for(i=2; i<LENGTH; i=i+2)
            x[i]<=$signed(x[i-2]);
    end

/*      SUMLV1 of E0(z)      */
always @ (posedge sys_clk)
    if (reset) begin
		 for(i=0;i<SUMLV1;i=i+1)
			  sum_lvl_1[i] <= 18'sd0;
    end
    else if (sam_clk_en) begin
		 for(i=0;i<(LENGTH-1)/2;i=i+2)
			  sum_lvl_1[i/2] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

/*-----------Mult_in of E0(z) (2s16)-----------*/
always @ * begin
    case (cnt)
        2'd0: mult_in=$signed(sum_lvl_1[0]);
        2'd1: mult_in=$signed(sum_lvl_1[1]);
        2'd2: mult_in=$signed(sum_lvl_1[2]);
        2'd3: mult_in=$signed(sum_lvl_1[3]);
    endcase
end

/*-----------Mult_coeff of E0(z) (0s18)-----------*/
always @ * begin
    case (cnt)
        2'd0: mult_coeff=$signed(Hsys[0]);
        2'd1: mult_coeff=$signed(Hsys[1]);
        2'd2: mult_coeff=$signed(Hsys[2]);
        2'd3: mult_coeff=$signed(Hsys[3]);
    endcase
end

always @ *
    mult_out<=$signed(mult_coeff)*$signed(mult_in);

(* perserve *) reg signed [WIDTH-1:0] up1;
(* noprune *) reg signed [WIDTH-1:0] multOut_D[DELAY-1:0];
(* perserve *) reg cntUp;


always @ (posedge sys_clk)
    if (reset)
        cntUp<=1'd0;
    else if (sys_clk2_en)
        cntUp<=cntUp+1'd1;
/*
always @ (posedge sys_clk)
    multOut_D[0]<=$signed(mult_out[34:17]);

always @ (posedge sys_clk)
    for (i=1; i<DELAY; i=i+1)
        multOut_D[i]<=$signed(multOut_D[i-1]);
*/

always @ * begin
    case (cntUp)
        2'd0: up1=18'sd0;
        //2'd1: up1=$signed(multOut_D[DELAY-1]);
        2'd1: up1=$signed(mult_out[34:17]);
    endcase
end

//      delay of x      
always @ (posedge sys_clk)
    if (reset) 
        x_Delay<=18'sd0;
    else if (sam_clk_en) begin
        x_Delay<=$signed(x_in);	//format input to 2s16 to prevent overflow
    end
    else
        x_Delay<=$signed(x_Delay);

/*-----------Beginning of E1(z)-----------*/
/*
always @ (posedge sys_clk)
    if (reset) 
        x[1]<=18'sd0;
    else if (sam_clk_en) begin
        x[1]<=$signed( {x_Delay[17],x_Delay[17:1]} );	//format input to 2s16 to prevent overflow
    end
    else
        x[1]<=$signed(x[1]);

always @ (posedge sys_clk)
    if (reset) begin
        for(i=3; i<LENGTH; i=i+2)
            x[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for(i=3; i<LENGTH; i=i+2)
            x[i]<=$signed(x[i-2]);
    end
*/	 

always @ (posedge sys_clk)
    if (reset)
        y<=18'sd0;
    else if (sys_clk2_en)
        y<=$signed(up1);

initial begin
	Hsys[0] = -18'sd348;
	Hsys[1] = 18'sd3274;
	Hsys[2] = -18'sd15925;
	Hsys[3] = 18'sd78535;
	Hsys[4] = 18'sd131072;
end

endmodule
