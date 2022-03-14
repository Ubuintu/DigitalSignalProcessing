module GSPS_filt #(
//Will have to manually adjust line 110 if statements based on len of filt & sum lvls required
    parameter WIDTH=18,
    parameter SUMLVL=7,
    parameter LENGTH=93,
    //Matlab: N-sum(tapsPerlvl);
    parameter OFFSET=2,
    parameter POSSMAPPER=7,
    parameter MAPSIZE=4,
    /* 46:0 first lvl regs; (46+1):(46+1+23-1+1) 2nd lvl; numbers in array count sym regs*/
//    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
	 parameter SUMLV1=47,
	 parameter SUMLV2=24,
	 parameter SUMLV3=12,
	 parameter SUMLV4=6,
	 parameter SUMLV5=3,
	 parameter SUMLV6=2,
	 parameter SUMLV7=1
    //parameter [7:0] POSSINPUTS [(POSSMAPPER+4)-1:0]={-18'sd98303,-18'sd65536,-18'sd32768,18'sd0,18'sd32768,18'sd65536,18'sd98303,-18'sd49152,-18'sd16384,18'sd16384,18'sd49152}
)
(
    input sys_clk, 
          sam_clk_en, 
          //sym_clk_en, 
          //clk, 
          reset,
    input signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y
);
/*      Register/variable Declaration    */
//18 bits wide; 6 rows and SUMLVLWID[rows] # of cols; TODO: find multdimensional irregular register declaration
//currently using 2D dynamic sum_lvl
(* noprune *) reg signed [WIDTH-1:0] sum_lvl[LENGTH+OFFSET-1:0];
(* noprune *) reg signed [WIDTH-1:0] mult_out[(LENGTH-1)/2:0];
(* noprune *) reg signed [WIDTH-1:0] tol;
(* preserve *) reg signed [WIDTH-1:0] x[(LENGTH-1):0];
(* noprune *) reg signed [WIDTH-1:0] Hsys[POSSMAPPER+MAPSIZE:0][(LENGTH-1)/2:0];
(* noprune *) reg signed [WIDTH-1:0] POSSINPUTS[POSSMAPPER-1:0];
/*
function automatic sum( input integer ar[6:0], N);
    begin
        integer toAdd=0, i;
        for (i=0; i<N; i=i+1)
            toAdd=ar[i]+toAdd;
        sum=toAdd;
    end
endfunction
*/
integer i,j;
initial begin
     tol=18'sd10;
	 POSSINPUTS[0]=-18'sd98303;
	 POSSINPUTS[1]=-18'sd65536;
	 POSSINPUTS[2]=-18'sd32768;
	 POSSINPUTS[3]=18'sd0;
	 POSSINPUTS[4]=18'sd32768;
	 POSSINPUTS[5]=18'sd65536;
	 POSSINPUTS[6]=18'sd98303;
	 POSSINPUTS[7]=-18'sd49152;
	 POSSINPUTS[8]=-18'sd16384;
	 POSSINPUTS[9]=18'sd16384;
	 POSSINPUTS[10]=18'sd49152;
     for (i=0; i<OFFSET+LENGTH; i=i+1)
        sum_lvl[i]=18'sd0;
     for (i=0; i<SUMLV1; i=i+1)
        mult_out[i]=18'sd0;
     for (i=0; i<LENGTH; i=i+1)
        x[i]=18'sd0;
end

//scale 1s17->2s16 for summing
always @ (posedge sys_clk)
    if (reset) 
        x[0]=18'sd0;
    else if (sam_clk_en) begin
        x[0]<=$signed({x_in[17],x_in[17:1]});
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

//sum all sym taps
always @ (posedge sys_clk)
    if (reset) begin
        for(i=0; i<(SUMLV1-1); i=i+1)
            sum_lvl[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        for(i=0; i<(SUMLV1-1); i=i+1)
            sum_lvl[i]<=$signed(x[i])+$signed(x[LENGTH-i-1]);
    end
    else begin
        for(i=0; i<(SUMLV1-1); i=i+1)
            sum_lvl[i]<=$signed(sum_lvl[i]);
    end

//sum last odd tap
always @ (posedge sys_clk)
    if (reset) sum_lvl[SUMLV1-1]<=18'sd0;
    else if (sam_clk_en) sum_lvl[SUMLV1-1]<=$signed( x[(SUMLV1)-1] );
    else sum_lvl[SUMLV1-1]<=$signed( sum_lvl[(SUMLV1)-1] );

always @ (posedge sys_clk)    //need <=
//always @ *    //use =
    if (reset) begin
		 for(i=0;i<SUMLV1-1; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i]<=18'sd0;
    end
    else if (sam_clk_en) begin
        //For N=93, should be 46 pairs of taps
        for (i=0; i<SUMLV1; i=i+1) begin
            //All taps besides center/odd tap
            if (i<=SUMLV1-2) begin
                //Possible input to sym taps. Note: for loop won't work here, overwriting issue
                /*
                for(j=0; j<POSSMAPPER; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]<=$signed(Hsys[7][i]);
                    else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[j])+tol) ) ) mult_out[i]<=$signed(Hsys[j][i]);
                    else mult_out[i]<=18'sd0;
                end
                */
                if( sum_lvl[i] == 18'sd65500 ) mult_out[i] <= Hsys[11][i];
                //$display("%t poonis | Hsys: %d | mult_out: %d",$time,Hsys[11][i],mult_out[i]);
                else if ( ( sum_lvl[i]>(-18'sd98303-tol) ) && ( sum_lvl[i]<(-18'sd98303+tol) ) ) mult_out[i] <= Hsys[0][i];
                else if ( ( sum_lvl[i]>(-18'sd65536-tol) ) && ( sum_lvl[i]<(-18'sd65536+tol) ) ) mult_out[i] <= Hsys[1][i];
                else if ( ( sum_lvl[i]>(-18'sd32678-tol) ) && ( sum_lvl[i]<(-18'sd32678+tol) ) ) mult_out[i] <= Hsys[2][i];
                else if ( ( sum_lvl[i]>(18'sd0-tol) ) && ( sum_lvl[i]<(18'sd0+tol) ) ) mult_out[i] <= Hsys[3][i];
                else if ( ( sum_lvl[i]>(18'sd32678-tol) ) && ( sum_lvl[i]<(18'sd32678+tol) ) ) mult_out[i] <= Hsys[4][i];
                else if ( ( sum_lvl[i]>(18'sd65536-tol) ) && ( sum_lvl[i]<(18'sd65536+tol) ) ) mult_out[i] <= Hsys[5][i];
                else if ( ( sum_lvl[i]>(18'sd98303-tol) ) && ( sum_lvl[i]<(18'sd98303+tol) ) ) mult_out[i] <= Hsys[6][i];
                else mult_out[i] <= 18'sd0;
            end
            //for last tap/center
            else begin
                //$display("In center tap %t | x[center]=%d",$time,x[46]);
                /*
                for(j=0; j<MAPSIZE; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]<=$signed(Hsys[7][i]);
                    else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j+POSSMAPPER])-tol) ) && ( $signed(sum_lvl[i])<$signed(POSSINPUTS[j+POSSMAPPER])+tol) ) mult_out[i]<=$signed(Hsys[j+POSSMAPPER][i]);
                    else mult_out[i]<=18'sd0;
                end
                */
                if( ( sum_lvl[i]>(18'sd65500-tol) ) && ( sum_lvl[i]<(18'sd65500+tol) ) ) begin
                    mult_out[i] <= Hsys[11][i];
                    $display("In center tap %t | x[center]=%d | Hsys[11]: %d | i: %d",$time,x[46],Hsys[11][i],i);
                end
                else if ( ( sum_lvl[i]>(-18'sd49152-tol) ) && ( sum_lvl[i]<(-18'sd49152+tol) ) ) mult_out[i] <= Hsys[7][i];
                else if ( ( sum_lvl[i]>(-18'sd16384-tol) ) && ( sum_lvl[i]<(-18'sd16384+tol) ) ) mult_out[i] <= Hsys[8][i];
                else if ( ( sum_lvl[i]>(18'sd16384-tol) ) && ( sum_lvl[i]<(18'sd16384+tol) ) ) mult_out[i] <= Hsys[9][i];
                else if ( ( sum_lvl[i]>(18'sd49152-tol) ) && ( sum_lvl[i]<(18'sd49152+tol) ) ) mult_out[i] <= Hsys[10][i];
                else begin
                    mult_out[i] <= 18'sd0;
                    $display("trapped in else");
                    $display("In center tap %t | x[center]=%d | Hsys[11]: %d | i: %d",$time,x[46],Hsys[11][i],i);
                end
            end
            else 
                for (i=0; i<SUMLV1; i=i+1)
                    mult_out[i]<=$signed(mult_out[i]);
        end
    end
    else 
        for (i=0; i<SUMLV1; i=i+1)
            mult_out[i]<=$signed(mult_out[i]);
    
        
integer ind=0;
integer index=0;
//coeffs 0s18; x 2s16
always @ (posedge sys_clk)
   if (reset) begin
        //sum(SUMLVLWID+SUMLVL)=total regs required
        for (i=SUMLV1-1;i<LENGTH;i=i+1)
            sum_lvl[i]=18'sd0;
   end
	//Will have to manually adjust if statements based on len of filt & sum lvls required
   else begin
        if (sam_clk_en) begin
            /*          sum lvl 2; multiple begin-ends work sequentially            */
            for (i=0; i<(SUMLV2)-1; i=i+1) begin
                if (i==(SUMLV1+SUMLV2)-1)
                    sum_lvl[i+(SUMLV1)-1]<=$signed(mult_out[2*i]);
                else 
                    sum_lvl[i+(SUMLV1)-1]<=$signed(mult_out[2*i])+$signed(mult_out[2*i+1]);
            end
            //sum lvl 3
            for (i=0; i<(SUMLV3)-1; i=i+1) begin
                sum_lvl[i+(SUMLV1+SUMLV2+SUMLV3)]<=$signed(sum_lvl[(SUMLV1+SUMLV2)+2*i])+$signed(sum_lvl[(SUMLV1+SUMLV2)+2*i+1]);
            end
            //sum lvl 4
            for (i=0; i<(SUMLV4)-1; i=i+1) begin
                sum_lvl[i+(SUMLV1+SUMLV2+SUMLV3+SUMLV4)]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3)+2*i])+$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3)+2*i+1]);
            end
            //sum lvl 5
            for (i=0; i<(SUMLV5)-1; i=i+1) begin
                sum_lvl[i+SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4)+2*i])+$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4)+2*i+1]);
            end
            //sum lvl 6 (2ND LAST)
            for (i=0; i<(SUMLV6)-1; i=i+1) begin
                if(i==0)
                    sum_lvl[i+(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6)]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5)+2*i])+$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5)+2*i+1]);
                else
                    sum_lvl[i+(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6)]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5)+2*i]);
            end
            //sum lvl 7 (FINAL)
            for (i=0; i<(SUMLV7); i=i+1) begin
                if(i==0)
                    sum_lvl[i+SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6+SUMLV7]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6)+2*i])+$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6)+2*i+1]);
                else
                    sum_lvl[i+SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6+SUMLV7]<=$signed(sum_lvl[(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6)+2*i]);
            end
        end
        else begin
            for (i=0; i<(SUMLV1+SUMLV2+SUMLV3+SUMLV4+SUMLV5+SUMLV6+SUMLV7); i=i+1)
                sum_lvl[i]<=sum_lvl[i];
        end
   end

    always @ (posedge sys_clk)
        if (reset) y<= 18'sd0;
        else if (sam_clk_en) y<=$signed( sum_lvl[LENGTH+OFFSET-1] );
        else y<=$signed(y);

initial begin
	Hsys[0][0] = -18'sd31;
	Hsys[1][0] = -18'sd21;
	Hsys[2][0] = -18'sd10;
	Hsys[3][0] = 18'sd0;
	Hsys[4][0] = 18'sd10;
	Hsys[5][0] = 18'sd21;
	Hsys[6][0] = 18'sd31;
	Hsys[7][0] = -18'sd16;
	Hsys[8][0] = -18'sd5;
	Hsys[9][0] = 18'sd5;
	Hsys[10][0] = 18'sd16;
	Hsys[11][0] = 18'sd21;
	Hsys[0][1] = -18'sd189;
	Hsys[1][1] = -18'sd126;
	Hsys[2][1] = -18'sd63;
	Hsys[3][1] = 18'sd0;
	Hsys[4][1] = 18'sd63;
	Hsys[5][1] = 18'sd126;
	Hsys[6][1] = 18'sd189;
	Hsys[7][1] = -18'sd94;
	Hsys[8][1] = -18'sd31;
	Hsys[9][1] = 18'sd31;
	Hsys[10][1] = 18'sd94;
	Hsys[11][1] = 18'sd126;
	Hsys[0][2] = -18'sd213;
	Hsys[1][2] = -18'sd142;
	Hsys[2][2] = -18'sd71;
	Hsys[3][2] = 18'sd0;
	Hsys[4][2] = 18'sd71;
	Hsys[5][2] = 18'sd142;
	Hsys[6][2] = 18'sd213;
	Hsys[7][2] = -18'sd106;
	Hsys[8][2] = -18'sd35;
	Hsys[9][2] = 18'sd35;
	Hsys[10][2] = 18'sd106;
	Hsys[11][2] = 18'sd142;
	Hsys[0][3] = -18'sd66;
	Hsys[1][3] = -18'sd44;
	Hsys[2][3] = -18'sd22;
	Hsys[3][3] = 18'sd0;
	Hsys[4][3] = 18'sd22;
	Hsys[5][3] = 18'sd44;
	Hsys[6][3] = 18'sd66;
	Hsys[7][3] = -18'sd33;
	Hsys[8][3] = -18'sd11;
	Hsys[9][3] = 18'sd11;
	Hsys[10][3] = 18'sd33;
	Hsys[11][3] = 18'sd44;
	Hsys[0][4] = 18'sd156;
	Hsys[1][4] = 18'sd104;
	Hsys[2][4] = 18'sd52;
	Hsys[3][4] = 18'sd0;
	Hsys[4][4] = -18'sd52;
	Hsys[5][4] = -18'sd104;
	Hsys[6][4] = -18'sd156;
	Hsys[7][4] = 18'sd78;
	Hsys[8][4] = 18'sd26;
	Hsys[9][4] = -18'sd26;
	Hsys[10][4] = -18'sd78;
	Hsys[11][4] = -18'sd104;
	Hsys[0][5] = 18'sd282;
	Hsys[1][5] = 18'sd188;
	Hsys[2][5] = 18'sd94;
	Hsys[3][5] = 18'sd0;
	Hsys[4][5] = -18'sd94;
	Hsys[5][5] = -18'sd188;
	Hsys[6][5] = -18'sd282;
	Hsys[7][5] = 18'sd141;
	Hsys[8][5] = 18'sd47;
	Hsys[9][5] = -18'sd47;
	Hsys[10][5] = -18'sd141;
	Hsys[11][5] = -18'sd188;
	Hsys[0][6] = 18'sd201;
	Hsys[1][6] = 18'sd134;
	Hsys[2][6] = 18'sd67;
	Hsys[3][6] = 18'sd0;
	Hsys[4][6] = -18'sd67;
	Hsys[5][6] = -18'sd134;
	Hsys[6][6] = -18'sd201;
	Hsys[7][6] = 18'sd100;
	Hsys[8][6] = 18'sd33;
	Hsys[9][6] = -18'sd33;
	Hsys[10][6] = -18'sd100;
	Hsys[11][6] = -18'sd134;
	Hsys[0][7] = -18'sd46;
	Hsys[1][7] = -18'sd31;
	Hsys[2][7] = -18'sd15;
	Hsys[3][7] = 18'sd0;
	Hsys[4][7] = 18'sd15;
	Hsys[5][7] = 18'sd31;
	Hsys[6][7] = 18'sd46;
	Hsys[7][7] = -18'sd23;
	Hsys[8][7] = -18'sd8;
	Hsys[9][7] = 18'sd8;
	Hsys[10][7] = 18'sd23;
	Hsys[11][7] = 18'sd31;
	Hsys[0][8] = -18'sd280;
	Hsys[1][8] = -18'sd187;
	Hsys[2][8] = -18'sd93;
	Hsys[3][8] = 18'sd0;
	Hsys[4][8] = 18'sd93;
	Hsys[5][8] = 18'sd187;
	Hsys[6][8] = 18'sd280;
	Hsys[7][8] = -18'sd140;
	Hsys[8][8] = -18'sd47;
	Hsys[9][8] = 18'sd47;
	Hsys[10][8] = 18'sd140;
	Hsys[11][8] = 18'sd187;
	Hsys[0][9] = -18'sd315;
	Hsys[1][9] = -18'sd210;
	Hsys[2][9] = -18'sd105;
	Hsys[3][9] = 18'sd0;
	Hsys[4][9] = 18'sd105;
	Hsys[5][9] = 18'sd210;
	Hsys[6][9] = 18'sd315;
	Hsys[7][9] = -18'sd157;
	Hsys[8][9] = -18'sd52;
	Hsys[9][9] = 18'sd52;
	Hsys[10][9] = 18'sd157;
	Hsys[11][9] = 18'sd210;
	Hsys[0][10] = -18'sd109;
	Hsys[1][10] = -18'sd73;
	Hsys[2][10] = -18'sd36;
	Hsys[3][10] = 18'sd0;
	Hsys[4][10] = 18'sd36;
	Hsys[5][10] = 18'sd73;
	Hsys[6][10] = 18'sd109;
	Hsys[7][10] = -18'sd55;
	Hsys[8][10] = -18'sd18;
	Hsys[9][10] = 18'sd18;
	Hsys[10][10] = 18'sd55;
	Hsys[11][10] = 18'sd73;
	Hsys[0][11] = 18'sd193;
	Hsys[1][11] = 18'sd129;
	Hsys[2][11] = 18'sd64;
	Hsys[3][11] = 18'sd0;
	Hsys[4][11] = -18'sd64;
	Hsys[5][11] = -18'sd129;
	Hsys[6][11] = -18'sd193;
	Hsys[7][11] = 18'sd97;
	Hsys[8][11] = 18'sd32;
	Hsys[9][11] = -18'sd32;
	Hsys[10][11] = -18'sd97;
	Hsys[11][11] = -18'sd129;
	Hsys[0][12] = 18'sd357;
	Hsys[1][12] = 18'sd238;
	Hsys[2][12] = 18'sd119;
	Hsys[3][12] = 18'sd0;
	Hsys[4][12] = -18'sd119;
	Hsys[5][12] = -18'sd238;
	Hsys[6][12] = -18'sd357;
	Hsys[7][12] = 18'sd178;
	Hsys[8][12] = 18'sd59;
	Hsys[9][12] = -18'sd59;
	Hsys[10][12] = -18'sd178;
	Hsys[11][12] = -18'sd238;
	Hsys[0][13] = 18'sd240;
	Hsys[1][13] = 18'sd160;
	Hsys[2][13] = 18'sd80;
	Hsys[3][13] = 18'sd0;
	Hsys[4][13] = -18'sd80;
	Hsys[5][13] = -18'sd160;
	Hsys[6][13] = -18'sd240;
	Hsys[7][13] = 18'sd120;
	Hsys[8][13] = 18'sd40;
	Hsys[9][13] = -18'sd40;
	Hsys[10][13] = -18'sd120;
	Hsys[11][13] = -18'sd160;
	Hsys[0][14] = -18'sd78;
	Hsys[1][14] = -18'sd52;
	Hsys[2][14] = -18'sd26;
	Hsys[3][14] = 18'sd0;
	Hsys[4][14] = 18'sd26;
	Hsys[5][14] = 18'sd52;
	Hsys[6][14] = 18'sd78;
	Hsys[7][14] = -18'sd39;
	Hsys[8][14] = -18'sd13;
	Hsys[9][14] = 18'sd13;
	Hsys[10][14] = 18'sd39;
	Hsys[11][14] = 18'sd52;
	Hsys[0][15] = -18'sd343;
	Hsys[1][15] = -18'sd229;
	Hsys[2][15] = -18'sd114;
	Hsys[3][15] = 18'sd0;
	Hsys[4][15] = 18'sd114;
	Hsys[5][15] = 18'sd229;
	Hsys[6][15] = 18'sd343;
	Hsys[7][15] = -18'sd172;
	Hsys[8][15] = -18'sd57;
	Hsys[9][15] = 18'sd57;
	Hsys[10][15] = 18'sd172;
	Hsys[11][15] = 18'sd229;
	Hsys[0][16] = -18'sd325;
	Hsys[1][16] = -18'sd217;
	Hsys[2][16] = -18'sd108;
	Hsys[3][16] = 18'sd0;
	Hsys[4][16] = 18'sd108;
	Hsys[5][16] = 18'sd217;
	Hsys[6][16] = 18'sd325;
	Hsys[7][16] = -18'sd163;
	Hsys[8][16] = -18'sd54;
	Hsys[9][16] = 18'sd54;
	Hsys[10][16] = 18'sd163;
	Hsys[11][16] = 18'sd217;
	Hsys[0][17] = -18'sd7;
	Hsys[1][17] = -18'sd5;
	Hsys[2][17] = -18'sd2;
	Hsys[3][17] = 18'sd0;
	Hsys[4][17] = 18'sd2;
	Hsys[5][17] = 18'sd5;
	Hsys[6][17] = 18'sd7;
	Hsys[7][17] = -18'sd4;
	Hsys[8][17] = -18'sd1;
	Hsys[9][17] = 18'sd1;
	Hsys[10][17] = 18'sd4;
	Hsys[11][17] = 18'sd5;
	Hsys[0][18] = 18'sd360;
	Hsys[1][18] = 18'sd240;
	Hsys[2][18] = 18'sd120;
	Hsys[3][18] = 18'sd0;
	Hsys[4][18] = -18'sd120;
	Hsys[5][18] = -18'sd240;
	Hsys[6][18] = -18'sd360;
	Hsys[7][18] = 18'sd180;
	Hsys[8][18] = 18'sd60;
	Hsys[9][18] = -18'sd60;
	Hsys[10][18] = -18'sd180;
	Hsys[11][18] = -18'sd240;
	Hsys[0][19] = 18'sd447;
	Hsys[1][19] = 18'sd298;
	Hsys[2][19] = 18'sd149;
	Hsys[3][19] = 18'sd0;
	Hsys[4][19] = -18'sd149;
	Hsys[5][19] = -18'sd298;
	Hsys[6][19] = -18'sd447;
	Hsys[7][19] = 18'sd223;
	Hsys[8][19] = 18'sd74;
	Hsys[9][19] = -18'sd74;
	Hsys[10][19] = -18'sd223;
	Hsys[11][19] = -18'sd298;
	Hsys[0][20] = 18'sd111;
	Hsys[1][20] = 18'sd74;
	Hsys[2][20] = 18'sd37;
	Hsys[3][20] = 18'sd0;
	Hsys[4][20] = -18'sd37;
	Hsys[5][20] = -18'sd74;
	Hsys[6][20] = -18'sd111;
	Hsys[7][20] = 18'sd55;
	Hsys[8][20] = 18'sd18;
	Hsys[9][20] = -18'sd18;
	Hsys[10][20] = -18'sd55;
	Hsys[11][20] = -18'sd74;
	Hsys[0][21] = -18'sd430;
	Hsys[1][21] = -18'sd287;
	Hsys[2][21] = -18'sd143;
	Hsys[3][21] = 18'sd0;
	Hsys[4][21] = 18'sd143;
	Hsys[5][21] = 18'sd287;
	Hsys[6][21] = 18'sd430;
	Hsys[7][21] = -18'sd215;
	Hsys[8][21] = -18'sd72;
	Hsys[9][21] = 18'sd72;
	Hsys[10][21] = 18'sd215;
	Hsys[11][21] = 18'sd287;
	Hsys[0][22] = -18'sd726;
	Hsys[1][22] = -18'sd484;
	Hsys[2][22] = -18'sd242;
	Hsys[3][22] = 18'sd0;
	Hsys[4][22] = 18'sd242;
	Hsys[5][22] = 18'sd484;
	Hsys[6][22] = 18'sd726;
	Hsys[7][22] = -18'sd363;
	Hsys[8][22] = -18'sd121;
	Hsys[9][22] = 18'sd121;
	Hsys[10][22] = 18'sd363;
	Hsys[11][22] = 18'sd484;
	Hsys[0][23] = -18'sd429;
	Hsys[1][23] = -18'sd286;
	Hsys[2][23] = -18'sd143;
	Hsys[3][23] = 18'sd0;
	Hsys[4][23] = 18'sd143;
	Hsys[5][23] = 18'sd286;
	Hsys[6][23] = 18'sd429;
	Hsys[7][23] = -18'sd214;
	Hsys[8][23] = -18'sd71;
	Hsys[9][23] = 18'sd71;
	Hsys[10][23] = 18'sd214;
	Hsys[11][23] = 18'sd286;
	Hsys[0][24] = 18'sd373;
	Hsys[1][24] = 18'sd249;
	Hsys[2][24] = 18'sd124;
	Hsys[3][24] = 18'sd0;
	Hsys[4][24] = -18'sd124;
	Hsys[5][24] = -18'sd249;
	Hsys[6][24] = -18'sd373;
	Hsys[7][24] = 18'sd187;
	Hsys[8][24] = 18'sd62;
	Hsys[9][24] = -18'sd62;
	Hsys[10][24] = -18'sd187;
	Hsys[11][24] = -18'sd249;
	Hsys[0][25] = 18'sd1123;
	Hsys[1][25] = 18'sd749;
	Hsys[2][25] = 18'sd374;
	Hsys[3][25] = 18'sd0;
	Hsys[4][25] = -18'sd374;
	Hsys[5][25] = -18'sd749;
	Hsys[6][25] = -18'sd1123;
	Hsys[7][25] = 18'sd562;
	Hsys[8][25] = 18'sd187;
	Hsys[9][25] = -18'sd187;
	Hsys[10][25] = -18'sd562;
	Hsys[11][25] = -18'sd749;
	Hsys[0][26] = 18'sd1149;
	Hsys[1][26] = 18'sd766;
	Hsys[2][26] = 18'sd383;
	Hsys[3][26] = 18'sd0;
	Hsys[4][26] = -18'sd383;
	Hsys[5][26] = -18'sd766;
	Hsys[6][26] = -18'sd1149;
	Hsys[7][26] = 18'sd574;
	Hsys[8][26] = 18'sd191;
	Hsys[9][26] = -18'sd191;
	Hsys[10][26] = -18'sd574;
	Hsys[11][26] = -18'sd766;
	Hsys[0][27] = 18'sd193;
	Hsys[1][27] = 18'sd129;
	Hsys[2][27] = 18'sd64;
	Hsys[3][27] = 18'sd0;
	Hsys[4][27] = -18'sd64;
	Hsys[5][27] = -18'sd129;
	Hsys[6][27] = -18'sd193;
	Hsys[7][27] = 18'sd97;
	Hsys[8][27] = 18'sd32;
	Hsys[9][27] = -18'sd32;
	Hsys[10][27] = -18'sd97;
	Hsys[11][27] = -18'sd129;
	Hsys[0][28] = -18'sd1248;
	Hsys[1][28] = -18'sd832;
	Hsys[2][28] = -18'sd416;
	Hsys[3][28] = 18'sd0;
	Hsys[4][28] = 18'sd416;
	Hsys[5][28] = 18'sd832;
	Hsys[6][28] = 18'sd1248;
	Hsys[7][28] = -18'sd624;
	Hsys[8][28] = -18'sd208;
	Hsys[9][28] = 18'sd208;
	Hsys[10][28] = 18'sd624;
	Hsys[11][28] = 18'sd832;
	Hsys[0][29] = -18'sd2140;
	Hsys[1][29] = -18'sd1427;
	Hsys[2][29] = -18'sd713;
	Hsys[3][29] = 18'sd0;
	Hsys[4][29] = 18'sd713;
	Hsys[5][29] = 18'sd1427;
	Hsys[6][29] = 18'sd2140;
	Hsys[7][29] = -18'sd1070;
	Hsys[8][29] = -18'sd357;
	Hsys[9][29] = 18'sd357;
	Hsys[10][29] = 18'sd1070;
	Hsys[11][29] = 18'sd1427;
	Hsys[0][30] = -18'sd1587;
	Hsys[1][30] = -18'sd1058;
	Hsys[2][30] = -18'sd529;
	Hsys[3][30] = 18'sd0;
	Hsys[4][30] = 18'sd529;
	Hsys[5][30] = 18'sd1058;
	Hsys[6][30] = 18'sd1587;
	Hsys[7][30] = -18'sd793;
	Hsys[8][30] = -18'sd264;
	Hsys[9][30] = 18'sd264;
	Hsys[10][30] = 18'sd793;
	Hsys[11][30] = 18'sd1058;
	Hsys[0][31] = 18'sd409;
	Hsys[1][31] = 18'sd273;
	Hsys[2][31] = 18'sd136;
	Hsys[3][31] = 18'sd0;
	Hsys[4][31] = -18'sd136;
	Hsys[5][31] = -18'sd273;
	Hsys[6][31] = -18'sd409;
	Hsys[7][31] = 18'sd205;
	Hsys[8][31] = 18'sd68;
	Hsys[9][31] = -18'sd68;
	Hsys[10][31] = -18'sd205;
	Hsys[11][31] = -18'sd273;
	Hsys[0][32] = 18'sd2713;
	Hsys[1][32] = 18'sd1809;
	Hsys[2][32] = 18'sd904;
	Hsys[3][32] = 18'sd0;
	Hsys[4][32] = -18'sd904;
	Hsys[5][32] = -18'sd1809;
	Hsys[6][32] = -18'sd2713;
	Hsys[7][32] = 18'sd1357;
	Hsys[8][32] = 18'sd452;
	Hsys[9][32] = -18'sd452;
	Hsys[10][32] = -18'sd1357;
	Hsys[11][32] = -18'sd1809;
	Hsys[0][33] = 18'sd3618;
	Hsys[1][33] = 18'sd2412;
	Hsys[2][33] = 18'sd1206;
	Hsys[3][33] = 18'sd0;
	Hsys[4][33] = -18'sd1206;
	Hsys[5][33] = -18'sd2412;
	Hsys[6][33] = -18'sd3618;
	Hsys[7][33] = 18'sd1809;
	Hsys[8][33] = 18'sd603;
	Hsys[9][33] = -18'sd603;
	Hsys[10][33] = -18'sd1809;
	Hsys[11][33] = -18'sd2412;
	Hsys[0][34] = 18'sd1996;
	Hsys[1][34] = 18'sd1331;
	Hsys[2][34] = 18'sd665;
	Hsys[3][34] = 18'sd0;
	Hsys[4][34] = -18'sd665;
	Hsys[5][34] = -18'sd1331;
	Hsys[6][34] = -18'sd1996;
	Hsys[7][34] = 18'sd998;
	Hsys[8][34] = 18'sd333;
	Hsys[9][34] = -18'sd333;
	Hsys[10][34] = -18'sd998;
	Hsys[11][34] = -18'sd1331;
	Hsys[0][35] = -18'sd1680;
	Hsys[1][35] = -18'sd1120;
	Hsys[2][35] = -18'sd560;
	Hsys[3][35] = 18'sd0;
	Hsys[4][35] = 18'sd560;
	Hsys[5][35] = 18'sd1120;
	Hsys[6][35] = 18'sd1680;
	Hsys[7][35] = -18'sd840;
	Hsys[8][35] = -18'sd280;
	Hsys[9][35] = 18'sd280;
	Hsys[10][35] = 18'sd840;
	Hsys[11][35] = 18'sd1120;
	Hsys[0][36] = -18'sd5251;
	Hsys[1][36] = -18'sd3501;
	Hsys[2][36] = -18'sd1750;
	Hsys[3][36] = 18'sd0;
	Hsys[4][36] = 18'sd1750;
	Hsys[5][36] = 18'sd3501;
	Hsys[6][36] = 18'sd5251;
	Hsys[7][36] = -18'sd2626;
	Hsys[8][36] = -18'sd875;
	Hsys[9][36] = 18'sd875;
	Hsys[10][36] = 18'sd2626;
	Hsys[11][36] = 18'sd3501;
	Hsys[0][37] = -18'sd5973;
	Hsys[1][37] = -18'sd3982;
	Hsys[2][37] = -18'sd1991;
	Hsys[3][37] = 18'sd0;
	Hsys[4][37] = 18'sd1991;
	Hsys[5][37] = 18'sd3982;
	Hsys[6][37] = 18'sd5973;
	Hsys[7][37] = -18'sd2986;
	Hsys[8][37] = -18'sd995;
	Hsys[9][37] = 18'sd995;
	Hsys[10][37] = 18'sd2986;
	Hsys[11][37] = 18'sd3982;
	Hsys[0][38] = -18'sd2331;
	Hsys[1][38] = -18'sd1554;
	Hsys[2][38] = -18'sd777;
	Hsys[3][38] = 18'sd0;
	Hsys[4][38] = 18'sd777;
	Hsys[5][38] = 18'sd1554;
	Hsys[6][38] = 18'sd2331;
	Hsys[7][38] = -18'sd1165;
	Hsys[8][38] = -18'sd388;
	Hsys[9][38] = 18'sd388;
	Hsys[10][38] = 18'sd1165;
	Hsys[11][38] = 18'sd1554;
	Hsys[0][39] = 18'sd4504;
	Hsys[1][39] = 18'sd3003;
	Hsys[2][39] = 18'sd1501;
	Hsys[3][39] = 18'sd0;
	Hsys[4][39] = -18'sd1501;
	Hsys[5][39] = -18'sd3003;
	Hsys[6][39] = -18'sd4504;
	Hsys[7][39] = 18'sd2252;
	Hsys[8][39] = 18'sd751;
	Hsys[9][39] = -18'sd751;
	Hsys[10][39] = -18'sd2252;
	Hsys[11][39] = -18'sd3003;
	Hsys[0][40] = 18'sd10627;
	Hsys[1][40] = 18'sd7085;
	Hsys[2][40] = 18'sd3542;
	Hsys[3][40] = 18'sd0;
	Hsys[4][40] = -18'sd3542;
	Hsys[5][40] = -18'sd7085;
	Hsys[6][40] = -18'sd10627;
	Hsys[7][40] = 18'sd5314;
	Hsys[8][40] = 18'sd1771;
	Hsys[9][40] = -18'sd1771;
	Hsys[10][40] = -18'sd5314;
	Hsys[11][40] = -18'sd7085;
	Hsys[0][41] = 18'sd11082;
	Hsys[1][41] = 18'sd7388;
	Hsys[2][41] = 18'sd3694;
	Hsys[3][41] = 18'sd0;
	Hsys[4][41] = -18'sd3694;
	Hsys[5][41] = -18'sd7388;
	Hsys[6][41] = -18'sd11082;
	Hsys[7][41] = 18'sd5541;
	Hsys[8][41] = 18'sd1847;
	Hsys[9][41] = -18'sd1847;
	Hsys[10][41] = -18'sd5541;
	Hsys[11][41] = -18'sd7388;
	Hsys[0][42] = 18'sd2548;
	Hsys[1][42] = 18'sd1699;
	Hsys[2][42] = 18'sd849;
	Hsys[3][42] = 18'sd0;
	Hsys[4][42] = -18'sd849;
	Hsys[5][42] = -18'sd1699;
	Hsys[6][42] = -18'sd2548;
	Hsys[7][42] = 18'sd1274;
	Hsys[8][42] = 18'sd425;
	Hsys[9][42] = -18'sd425;
	Hsys[10][42] = -18'sd1274;
	Hsys[11][42] = -18'sd1699;
	Hsys[0][43] = -18'sd14416;
	Hsys[1][43] = -18'sd9611;
	Hsys[2][43] = -18'sd4805;
	Hsys[3][43] = 18'sd0;
	Hsys[4][43] = 18'sd4805;
	Hsys[5][43] = 18'sd9611;
	Hsys[6][43] = 18'sd14416;
	Hsys[7][43] = -18'sd7208;
	Hsys[8][43] = -18'sd2403;
	Hsys[9][43] = 18'sd2403;
	Hsys[10][43] = 18'sd7208;
	Hsys[11][43] = 18'sd9611;
	Hsys[0][44] = -18'sd34945;
	Hsys[1][44] = -18'sd23297;
	Hsys[2][44] = -18'sd11648;
	Hsys[3][44] = 18'sd0;
	Hsys[4][44] = 18'sd11648;
	Hsys[5][44] = 18'sd23297;
	Hsys[6][44] = 18'sd34945;
	Hsys[7][44] = -18'sd17473;
	Hsys[8][44] = -18'sd5824;
	Hsys[9][44] = 18'sd5824;
	Hsys[10][44] = 18'sd17473;
	Hsys[11][44] = 18'sd23297;
	Hsys[0][45] = -18'sd51691;
	Hsys[1][45] = -18'sd34461;
	Hsys[2][45] = -18'sd17230;
	Hsys[3][45] = 18'sd0;
	Hsys[4][45] = 18'sd17230;
	Hsys[5][45] = 18'sd34461;
	Hsys[6][45] = 18'sd51691;
	Hsys[7][45] = -18'sd25846;
	Hsys[8][45] = -18'sd8615;
	Hsys[9][45] = 18'sd8615;
	Hsys[10][45] = 18'sd25846;
	Hsys[11][45] = 18'sd34461;
	Hsys[0][46] = -18'sd58137;
	Hsys[1][46] = -18'sd38758;
	Hsys[2][46] = -18'sd19379;
	Hsys[3][46] = 18'sd0;
	Hsys[4][46] = 18'sd19379;
	Hsys[5][46] = 18'sd38758;
	Hsys[6][46] = 18'sd58137;
	Hsys[7][46] = -18'sd29068;
	Hsys[8][46] = -18'sd9689;
	Hsys[9][46] = 18'sd9689;
	Hsys[10][46] = 18'sd29068;
	Hsys[11][46] = 18'sd38758;
end

endmodule


