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
	Hsys[0] = -18'sd4244;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd36976;
	Hsys[3] = 18'sd65472;
end

endmodule

/*-----------halfband timesharing-----------*/
module halfband_1st_bitShift #(
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
		if (i<SUMLV1 && i!=1)
				//mult_out (3s34) = 1s17 * 2s16
				mult_out[i] = $signed(Hsys[i])*$signed(sum_lvl_1[i]);
		else if (i==0)
			mult_out[i]=36'sd0;
		else
			//center of sumlvl 1 is alraedy bitshifted
			mult_out[i]=$signed( {sum_lvl_1[i],{18{1'd0}}} );
	end

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
	Hsys[0] = -18'sd4248;
	Hsys[1] = 18'sd0;
	Hsys[2] = 18'sd37012;
	Hsys[3] = 18'sd65536;
end

endmodule
