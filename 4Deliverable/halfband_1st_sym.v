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
        x[0]<=$signed({x_in[17], x_in[17:1]});	//format input to 1s17
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
				//mult_out (2s34) = 1s17 * 1s17
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);

/*-----------SUMLV2-----------*/
always @ (posedge sys_clk)
    if (reset) begin
        for (i=0; i<SUMLV2; i=i+1)
            sum_lvl_2[i]<=18'sd0;
    end
    else if (sys_clk2_en) begin
        for (i=0; i<SUMLV2; i=i+1)				
	    //mult_out (3s33) -> sum_lvl_2 1s17
            sum_lvl_2[i]<=$signed(mult_out[2*i][33:16])+$signed(mult_out[2*i+1][33:16]);
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

/*-----------coeffs 1s17-----------*/
/*

initial begin
	Hsys[0] = -18'sd87;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd819;
	Hsys[3] = 18'sd0;
	Hsys[4] = -18'sd3981;
	Hsys[5] = 18'sd0;
	Hsys[6] = 18'sd19634;
	Hsys[7] = 18'sd32768;
end
*/

initial begin
	Hsys[0] = -18'sd174;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd1637;
	Hsys[3] = 18'sd0;
	Hsys[4] = -18'sd7962;
	Hsys[5] = 18'sd0;
	Hsys[6] = 18'sd39267;
	Hsys[7] = 18'sd65536;
end

endmodule
