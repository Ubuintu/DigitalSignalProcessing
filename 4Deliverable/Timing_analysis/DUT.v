module DUT #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter LENGTH=15,
    parameter DELAY=4,
    parameter SUMLV1=8
)
(
    input sys_clk, sam_clk_en, reset, clk, sys_clk2_en,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);

(* preserve *) reg signed [WIDTH-1:0] sum_lvl_1[SUMLV1-1:0];
(* keep *) reg signed [2*WIDTH-1:0] mult_out;
(* preserve *) reg signed [WIDTH-1:0] mult_in;
(* preserve *) reg signed [WIDTH-1:0] mult_coeff;
(* preserve *) reg signed [WIDTH-1:0] odd_out;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
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
always @ (posedge clk)
    if (reset)
        cnt<=2'd1;
    else
        cnt<=cnt+2'd1;

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
		 for(i=0;i<SUMLV1;i=i+1)
			  sum_lvl_1[i] <= 18'sd0;
    end
    else if (sys_clk2_en) begin
		 for(i=0;i<SUMLV1;i=i+1)
            if (i==7)
                sum_lvl_1[7]<=$signed(x[7]);
            else
			  sum_lvl_1[i] <= $signed(x[i])+$signed(x[LENGTH-1-i]);
    end

/*-----------Mult_in (2s16)-----------*/
always @ * begin
    case (cnt)
        2'd0: mult_in=$signed(sum_lvl_1[0]);
        2'd1: mult_in=$signed(sum_lvl_1[2]);
        2'd2: mult_in=$signed(sum_lvl_1[4]);
        2'd3: mult_in=$signed(sum_lvl_1[6]);
    endcase
end

/*-----------Mult_coeff (0s18)-----------*/
always @ * begin
    case (cnt)
        2'd0: mult_coeff=$signed(Hsys[0]);
        2'd1: mult_coeff=$signed(Hsys[2]);
        2'd2: mult_coeff=$signed(Hsys[4]);
        2'd3: mult_coeff=$signed(Hsys[6]);
    endcase
end

/*-----------Mult_out for even taps (2s34)-----------*/
always @ *
    mult_out<=$signed(mult_coeff)*$signed(mult_in);

/*-----------Accumulator for mult-----------*/
(* preserve *) reg signed [WIDTH-1:0] acc;
always @ (posedge clk)
    if (reset || cnt==2'd0)
        acc<=$signed(mult_out[34:17]);
    else
        acc<=acc+$signed(mult_out[34:17]);
/*-----------odd_out 1s17-----------*/
//pk of halfband is always 0.5 so bitshift instead of mult
always @ * begin
    case (cnt)
        2'd0: odd_out=(18'sd0);
        2'd1: odd_out=(18'sd0);
        2'd2: odd_out=(18'sd0);
        2'd3: odd_out=$signed(sum_lvl_1[7]);
    endcase
end

always @ (sys_clk)
    y<=$signed(odd_out)+$signed(acc);

/*-----------coeffs 0s18-----------*/
initial begin
	Hsys[0] = -18'sd348;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd3274;
	Hsys[3] = 18'sd0;
	Hsys[4] = -18'sd15925;
	Hsys[5] = 18'sd0;
	Hsys[6] = 18'sd78535;
	Hsys[7] = 18'sd131072;
end

endmodule
