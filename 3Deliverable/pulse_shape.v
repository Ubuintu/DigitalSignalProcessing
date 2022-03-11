module GSPS_filt #(
    parameter WIDTH=18,
    parameter SUMLVL=6,
    parameter LENGTH=93,
    parameter POSSMAPPER=7,
    parameter integer SUMLVLWID [SUMLVL-1:0]={46,23,11,5,2,1},
    parameter [7:0] POSSINPUTS [(POSSMAPPER+4)-1:0]={-18'sd98303,-18'sd65536,-18'sd32768,18'sd0,18'sd32768,18'sd65536,18'sd98303,-18'sd49152,-18'sd16384,18'sd16384,18'sd49152}
)
(
    input sys_clk, sam_clk_en, sym_clk_en, reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);
/*      Register/variable Declaration    */
//18 bits wide; 6 rows and SUMLVLWID[rows] # of cols; TODO: find multdimensional irregular register declaration
//currently using 2D dynamic sum_lvl
(* noprune *) reg signed [WIDTH-1:0] sum_lvl[NUMSUMREGS-1:0];
(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
(* noprune *) reg signed [WIDTH-1:0] tol;
(* noprune *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[POSSMAPPER:0][(LENGTH-1)/2:0];
integer i,j;

initial begin
    tol=18'sd10;
end

//scale 1s17->2s16 for summing
always @ (posedge sys_clk)
    if (reset) 
        x[0]=18'sd0;
    else if (sym_clk_en) begin
        x[0]<=$signed({x_in[17],x_in[17:1]});
    end
    else
        x[0]<=$signed(x[0]);

always @ (posedge sys_clk)
    if (reset) begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]=18'sd0;
    end
    else begin
        for(i=1; i<LENGTH; i=i+1)
            x[i]<=$signed(x[i-1]);
    end

//sum all sym taps
always @ (posedge sys_clk)
    if (reset) begin
        for(i=0; i<(SUMLVLWID[SUMLVL]-1); i=i+1)
            sum_lvl[i]=18'sd0;
    end
    else begin
        for(i=0; i<(SUMLVLWID[SUMLVL]-1); i=i+1)
            sum_lvl[i]=$signed(x[i])+$signed(x[LENGTH-i]);
    end
//sum last odd tap
always @ (posedge sys_clk)
    if (reset) sum_lvl[(SUMLVLWID[SUMLVL])]=18'sd0;
    else sum_lvl[(SUMLVLWID[SUMLVL])]=$signed( x[(SUMLVLWID[SUMLVL])] );

//always @ (posedge sys_clk)
always @ *
    if (reset) begin
		 for(i=0;i<=SUMLVLWID[SUMLVL]; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        for (i=0; i<=SUMLVLWID[SUMLVL])]; i=i+1)
            if ( sum_lvl[i]==18'sd65500 ) mult_out[i]=b[7][i]; //impulse response
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[0])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[0])+tol) ) ) mult_out[i] = $signed(b[0][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[1])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[1])+tol) ) ) mult_out[i] = $signed(b[1][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[2])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[2])+tol) ) ) mult_out[i] = $signed(b[2][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[3])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[3])+tol) ) ) mult_out[i] = $signed(b[3][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[4])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[4])+tol) ) ) mult_out[i] = $signed(b[4][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[5])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[5])+tol) ) ) mult_out[i] = $signed(b[5][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[6])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[6])+tol) ) ) mult_out[i] = $signed(b[6][i]);
                else mult_out[i] = 18'sd0;
            else
                /*Center Tap*/
                /*For verifying taps*/
                if( sum_lvl[i] == 18'sd65500 ) mult_out[i] = $signed(b[7][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[7])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[7])+tol ) ) mult_out[i] = $signed(b[7][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[8])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[8])+tol ) ) mult_out[i] = $signed(b[8][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[9])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[9])+tol ) mult_out[i] = $signed(b[9][i]);
                else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[10])-tol) ) && ( sum_lvl[i]<(18'sd65536+tol) ) ) mult_out[i] = b[6][i];
                else mult_out[i] = 18'sd0;
    end
            




endmodule
