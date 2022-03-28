module GSM_TS #(
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
always @ (cnt)	// delayed in ModelSim
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