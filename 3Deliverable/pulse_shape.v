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
(* noprune *) reg signed [WIDTH-1:0] Hsys[POSSMAPPER:0][(LENGTH-1)/2:0];
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
     for (i=0; i<(LENGTH-1)/2; i=i+1)
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
    else begin
        //For N=93, should be 46 pairs of taps
        for (i=0; i<SUMLV1; i=i+1) begin
            //All taps besides center/odd tap
            if(i<SUMLV1-1) begin
                //Possible input to sym taps
                for(j=0; j<POSSMAPPER; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]<=$signed(Hsys[7][i]);
                    else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j])-tol) ) && ( $signed(sum_lvl[i])<($signed(POSSINPUTS[j])+tol) ) ) mult_out[i]<=$signed(Hsys[j][i]);
                    else mult_out[i]<=18'sd0;
                end
            end
            //for last tap/center
            else if(i>=SUMLV1-1)begin
                //$display("In odd tap %t",$time);
                for(j=0; j<MAPSIZE; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]<=$signed(Hsys[7][i]);
                    else if ( ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j+POSSMAPPER])-tol) ) && ( $signed(sum_lvl[i])<$signed(POSSINPUTS[j+POSSMAPPER])+tol) ) mult_out[i]<=$signed(Hsys[j+POSSMAPPER][i]);
                    else mult_out[i]<=18'sd0;
                end
            end
            else 
                mult_out[i]<=mult_out[i];
        end
    end
        
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
        else if (sam_clk_en) y<=$signed( sum_lvl[LENGTH+OFFSET] );
        else y<=$signed(y);

initial begin
	Hsys[0][0] = 18'sd66;
	Hsys[1][0] = 18'sd44;
	Hsys[2][0] = 18'sd22;
	Hsys[3][0] = 18'sd0;
	Hsys[4][0] = -18'sd22;
	Hsys[5][0] = -18'sd44;
	Hsys[6][0] = -18'sd66;
	Hsys[7][0] = -18'sd44;
	Hsys[0][1] = 18'sd19;
	Hsys[1][1] = 18'sd13;
	Hsys[2][1] = 18'sd6;
	Hsys[3][1] = 18'sd0;
	Hsys[4][1] = -18'sd6;
	Hsys[5][1] = -18'sd13;
	Hsys[6][1] = -18'sd19;
	Hsys[7][1] = -18'sd13;
	Hsys[0][2] = -18'sd54;
	Hsys[1][2] = -18'sd36;
	Hsys[2][2] = -18'sd18;
	Hsys[3][2] = 18'sd0;
	Hsys[4][2] = 18'sd18;
	Hsys[5][2] = 18'sd36;
	Hsys[6][2] = 18'sd54;
	Hsys[7][2] = 18'sd36;
	Hsys[0][3] = -18'sd169;
	Hsys[1][3] = -18'sd113;
	Hsys[2][3] = -18'sd56;
	Hsys[3][3] = 18'sd0;
	Hsys[4][3] = 18'sd56;
	Hsys[5][3] = 18'sd113;
	Hsys[6][3] = 18'sd169;
	Hsys[7][3] = 18'sd113;
	Hsys[0][4] = -18'sd264;
	Hsys[1][4] = -18'sd176;
	Hsys[2][4] = -18'sd88;
	Hsys[3][4] = 18'sd0;
	Hsys[4][4] = 18'sd88;
	Hsys[5][4] = 18'sd176;
	Hsys[6][4] = 18'sd264;
	Hsys[7][4] = 18'sd176;
	Hsys[0][5] = -18'sd256;
	Hsys[1][5] = -18'sd171;
	Hsys[2][5] = -18'sd85;
	Hsys[3][5] = 18'sd0;
	Hsys[4][5] = 18'sd85;
	Hsys[5][5] = 18'sd171;
	Hsys[6][5] = 18'sd256;
	Hsys[7][5] = 18'sd171;
	Hsys[0][6] = -18'sd105;
	Hsys[1][6] = -18'sd70;
	Hsys[2][6] = -18'sd35;
	Hsys[3][6] = 18'sd0;
	Hsys[4][6] = 18'sd35;
	Hsys[5][6] = 18'sd70;
	Hsys[6][6] = 18'sd105;
	Hsys[7][6] = 18'sd70;
	Hsys[0][7] = 18'sd148;
	Hsys[1][7] = 18'sd99;
	Hsys[2][7] = 18'sd49;
	Hsys[3][7] = 18'sd0;
	Hsys[4][7] = -18'sd49;
	Hsys[5][7] = -18'sd99;
	Hsys[6][7] = -18'sd148;
	Hsys[7][7] = -18'sd99;
	Hsys[0][8] = 18'sd373;
	Hsys[1][8] = 18'sd249;
	Hsys[2][8] = 18'sd124;
	Hsys[3][8] = 18'sd0;
	Hsys[4][8] = -18'sd124;
	Hsys[5][8] = -18'sd249;
	Hsys[6][8] = -18'sd373;
	Hsys[7][8] = -18'sd249;
	Hsys[0][9] = 18'sd411;
	Hsys[1][9] = 18'sd274;
	Hsys[2][9] = 18'sd137;
	Hsys[3][9] = 18'sd0;
	Hsys[4][9] = -18'sd137;
	Hsys[5][9] = -18'sd274;
	Hsys[6][9] = -18'sd411;
	Hsys[7][9] = -18'sd274;
	Hsys[0][10] = 18'sd181;
	Hsys[1][10] = 18'sd121;
	Hsys[2][10] = 18'sd60;
	Hsys[3][10] = 18'sd0;
	Hsys[4][10] = -18'sd60;
	Hsys[5][10] = -18'sd121;
	Hsys[6][10] = -18'sd181;
	Hsys[7][10] = -18'sd121;
	Hsys[0][11] = -18'sd238;
	Hsys[1][11] = -18'sd159;
	Hsys[2][11] = -18'sd79;
	Hsys[3][11] = 18'sd0;
	Hsys[4][11] = 18'sd79;
	Hsys[5][11] = 18'sd159;
	Hsys[6][11] = 18'sd238;
	Hsys[7][11] = 18'sd159;
	Hsys[0][12] = -18'sd619;
	Hsys[1][12] = -18'sd413;
	Hsys[2][12] = -18'sd206;
	Hsys[3][12] = 18'sd0;
	Hsys[4][12] = 18'sd206;
	Hsys[5][12] = 18'sd413;
	Hsys[6][12] = 18'sd619;
	Hsys[7][12] = 18'sd413;
	Hsys[0][13] = -18'sd693;
	Hsys[1][13] = -18'sd462;
	Hsys[2][13] = -18'sd231;
	Hsys[3][13] = 18'sd0;
	Hsys[4][13] = 18'sd231;
	Hsys[5][13] = 18'sd462;
	Hsys[6][13] = 18'sd693;
	Hsys[7][13] = 18'sd462;
	Hsys[0][14] = -18'sd328;
	Hsys[1][14] = -18'sd219;
	Hsys[2][14] = -18'sd109;
	Hsys[3][14] = 18'sd0;
	Hsys[4][14] = 18'sd109;
	Hsys[5][14] = 18'sd219;
	Hsys[6][14] = 18'sd328;
	Hsys[7][14] = 18'sd219;
	Hsys[0][15] = 18'sd340;
	Hsys[1][15] = 18'sd227;
	Hsys[2][15] = 18'sd113;
	Hsys[3][15] = 18'sd0;
	Hsys[4][15] = -18'sd113;
	Hsys[5][15] = -18'sd227;
	Hsys[6][15] = -18'sd340;
	Hsys[7][15] = -18'sd227;
	Hsys[0][16] = 18'sd945;
	Hsys[1][16] = 18'sd630;
	Hsys[2][16] = 18'sd315;
	Hsys[3][16] = 18'sd0;
	Hsys[4][16] = -18'sd315;
	Hsys[5][16] = -18'sd630;
	Hsys[6][16] = -18'sd945;
	Hsys[7][16] = -18'sd630;
	Hsys[0][17] = 18'sd1066;
	Hsys[1][17] = 18'sd711;
	Hsys[2][17] = 18'sd355;
	Hsys[3][17] = 18'sd0;
	Hsys[4][17] = -18'sd355;
	Hsys[5][17] = -18'sd711;
	Hsys[6][17] = -18'sd1066;
	Hsys[7][17] = -18'sd711;
	Hsys[0][18] = 18'sd517;
	Hsys[1][18] = 18'sd345;
	Hsys[2][18] = 18'sd172;
	Hsys[3][18] = 18'sd0;
	Hsys[4][18] = -18'sd172;
	Hsys[5][18] = -18'sd345;
	Hsys[6][18] = -18'sd517;
	Hsys[7][18] = -18'sd345;
	Hsys[0][19] = -18'sd486;
	Hsys[1][19] = -18'sd324;
	Hsys[2][19] = -18'sd162;
	Hsys[3][19] = 18'sd0;
	Hsys[4][19] = 18'sd162;
	Hsys[5][19] = 18'sd324;
	Hsys[6][19] = 18'sd486;
	Hsys[7][19] = 18'sd324;
	Hsys[0][20] = -18'sd1377;
	Hsys[1][20] = -18'sd918;
	Hsys[2][20] = -18'sd459;
	Hsys[3][20] = 18'sd0;
	Hsys[4][20] = 18'sd459;
	Hsys[5][20] = 18'sd918;
	Hsys[6][20] = 18'sd1377;
	Hsys[7][20] = 18'sd918;
	Hsys[0][21] = -18'sd1548;
	Hsys[1][21] = -18'sd1032;
	Hsys[2][21] = -18'sd516;
	Hsys[3][21] = 18'sd0;
	Hsys[4][21] = 18'sd516;
	Hsys[5][21] = 18'sd1032;
	Hsys[6][21] = 18'sd1548;
	Hsys[7][21] = 18'sd1032;
	Hsys[0][22] = -18'sd742;
	Hsys[1][22] = -18'sd495;
	Hsys[2][22] = -18'sd247;
	Hsys[3][22] = 18'sd0;
	Hsys[4][22] = 18'sd247;
	Hsys[5][22] = 18'sd495;
	Hsys[6][22] = 18'sd742;
	Hsys[7][22] = 18'sd495;
	Hsys[0][23] = 18'sd700;
	Hsys[1][23] = 18'sd467;
	Hsys[2][23] = 18'sd233;
	Hsys[3][23] = 18'sd0;
	Hsys[4][23] = -18'sd233;
	Hsys[5][23] = -18'sd467;
	Hsys[6][23] = -18'sd700;
	Hsys[7][23] = -18'sd467;
	Hsys[0][24] = 18'sd1954;
	Hsys[1][24] = 18'sd1303;
	Hsys[2][24] = 18'sd651;
	Hsys[3][24] = 18'sd0;
	Hsys[4][24] = -18'sd651;
	Hsys[5][24] = -18'sd1303;
	Hsys[6][24] = -18'sd1954;
	Hsys[7][24] = -18'sd1303;
	Hsys[0][25] = 18'sd2158;
	Hsys[1][25] = 18'sd1439;
	Hsys[2][25] = 18'sd719;
	Hsys[3][25] = 18'sd0;
	Hsys[4][25] = -18'sd719;
	Hsys[5][25] = -18'sd1439;
	Hsys[6][25] = -18'sd2158;
	Hsys[7][25] = -18'sd1439;
	Hsys[0][26] = 18'sd987;
	Hsys[1][26] = 18'sd658;
	Hsys[2][26] = 18'sd329;
	Hsys[3][26] = 18'sd0;
	Hsys[4][26] = -18'sd329;
	Hsys[5][26] = -18'sd658;
	Hsys[6][26] = -18'sd987;
	Hsys[7][26] = -18'sd658;
	Hsys[0][27] = -18'sd1041;
	Hsys[1][27] = -18'sd694;
	Hsys[2][27] = -18'sd347;
	Hsys[3][27] = 18'sd0;
	Hsys[4][27] = 18'sd347;
	Hsys[5][27] = 18'sd694;
	Hsys[6][27] = 18'sd1041;
	Hsys[7][27] = 18'sd694;
	Hsys[0][28] = -18'sd2748;
	Hsys[1][28] = -18'sd1832;
	Hsys[2][28] = -18'sd916;
	Hsys[3][28] = 18'sd0;
	Hsys[4][28] = 18'sd916;
	Hsys[5][28] = 18'sd1832;
	Hsys[6][28] = 18'sd2748;
	Hsys[7][28] = 18'sd1832;
	Hsys[0][29] = -18'sd2949;
	Hsys[1][29] = -18'sd1966;
	Hsys[2][29] = -18'sd983;
	Hsys[3][29] = 18'sd0;
	Hsys[4][29] = 18'sd983;
	Hsys[5][29] = 18'sd1966;
	Hsys[6][29] = 18'sd2949;
	Hsys[7][29] = 18'sd1966;
	Hsys[0][30] = -18'sd1234;
	Hsys[1][30] = -18'sd823;
	Hsys[2][30] = -18'sd411;
	Hsys[3][30] = 18'sd0;
	Hsys[4][30] = 18'sd411;
	Hsys[5][30] = 18'sd823;
	Hsys[6][30] = 18'sd1234;
	Hsys[7][30] = 18'sd823;
	Hsys[0][31] = 18'sd1617;
	Hsys[1][31] = 18'sd1078;
	Hsys[2][31] = 18'sd539;
	Hsys[3][31] = 18'sd0;
	Hsys[4][31] = -18'sd539;
	Hsys[5][31] = -18'sd1078;
	Hsys[6][31] = -18'sd1617;
	Hsys[7][31] = -18'sd1078;
	Hsys[0][32] = 18'sd3924;
	Hsys[1][32] = 18'sd2616;
	Hsys[2][32] = 18'sd1308;
	Hsys[3][32] = 18'sd0;
	Hsys[4][32] = -18'sd1308;
	Hsys[5][32] = -18'sd2616;
	Hsys[6][32] = -18'sd3924;
	Hsys[7][32] = -18'sd2616;
	Hsys[0][33] = 18'sd4047;
	Hsys[1][33] = 18'sd2698;
	Hsys[2][33] = 18'sd1349;
	Hsys[3][33] = 18'sd0;
	Hsys[4][33] = -18'sd1349;
	Hsys[5][33] = -18'sd2698;
	Hsys[6][33] = -18'sd4047;
	Hsys[7][33] = -18'sd2698;
	Hsys[0][34] = 18'sd1459;
	Hsys[1][34] = 18'sd973;
	Hsys[2][34] = 18'sd486;
	Hsys[3][34] = 18'sd0;
	Hsys[4][34] = -18'sd486;
	Hsys[5][34] = -18'sd973;
	Hsys[6][34] = -18'sd1459;
	Hsys[7][34] = -18'sd973;
	Hsys[0][35] = -18'sd2677;
	Hsys[1][35] = -18'sd1785;
	Hsys[2][35] = -18'sd892;
	Hsys[3][35] = 18'sd0;
	Hsys[4][35] = 18'sd892;
	Hsys[5][35] = 18'sd1785;
	Hsys[6][35] = 18'sd2677;
	Hsys[7][35] = 18'sd1785;
	Hsys[0][36] = -18'sd5917;
	Hsys[1][36] = -18'sd3945;
	Hsys[2][36] = -18'sd1972;
	Hsys[3][36] = 18'sd0;
	Hsys[4][36] = 18'sd1972;
	Hsys[5][36] = 18'sd3945;
	Hsys[6][36] = 18'sd5917;
	Hsys[7][36] = 18'sd3945;
	Hsys[0][37] = -18'sd5847;
	Hsys[1][37] = -18'sd3898;
	Hsys[2][37] = -18'sd1949;
	Hsys[3][37] = 18'sd0;
	Hsys[4][37] = 18'sd1949;
	Hsys[5][37] = 18'sd3898;
	Hsys[6][37] = 18'sd5847;
	Hsys[7][37] = 18'sd3898;
	Hsys[0][38] = -18'sd1639;
	Hsys[1][38] = -18'sd1093;
	Hsys[2][38] = -18'sd546;
	Hsys[3][38] = 18'sd0;
	Hsys[4][38] = 18'sd546;
	Hsys[5][38] = 18'sd1093;
	Hsys[6][38] = 18'sd1639;
	Hsys[7][38] = 18'sd1093;
	Hsys[0][39] = 18'sd5023;
	Hsys[1][39] = 18'sd3349;
	Hsys[2][39] = 18'sd1674;
	Hsys[3][39] = 18'sd0;
	Hsys[4][39] = -18'sd1674;
	Hsys[5][39] = -18'sd3349;
	Hsys[6][39] = -18'sd5023;
	Hsys[7][39] = -18'sd3349;
	Hsys[0][40] = 18'sd10341;
	Hsys[1][40] = 18'sd6894;
	Hsys[2][40] = 18'sd3447;
	Hsys[3][40] = 18'sd0;
	Hsys[4][40] = -18'sd3447;
	Hsys[5][40] = -18'sd6894;
	Hsys[6][40] = -18'sd10341;
	Hsys[7][40] = -18'sd6894;
	Hsys[0][41] = 18'sd10071;
	Hsys[1][41] = 18'sd6714;
	Hsys[2][41] = 18'sd3357;
	Hsys[3][41] = 18'sd0;
	Hsys[4][41] = -18'sd3357;
	Hsys[5][41] = -18'sd6714;
	Hsys[6][41] = -18'sd10071;
	Hsys[7][41] = -18'sd6714;
	Hsys[0][42] = 18'sd1756;
	Hsys[1][42] = 18'sd1171;
	Hsys[2][42] = 18'sd585;
	Hsys[3][42] = 18'sd0;
	Hsys[4][42] = -18'sd585;
	Hsys[5][42] = -18'sd1171;
	Hsys[6][42] = -18'sd1756;
	Hsys[7][42] = -18'sd1171;
	Hsys[0][43] = -18'sd13657;
	Hsys[1][43] = -18'sd9105;
	Hsys[2][43] = -18'sd4552;
	Hsys[3][43] = 18'sd0;
	Hsys[4][43] = 18'sd4552;
	Hsys[5][43] = 18'sd9105;
	Hsys[6][43] = 18'sd13657;
	Hsys[7][43] = 18'sd9105;
	Hsys[0][44] = -18'sd31744;
	Hsys[1][44] = -18'sd21163;
	Hsys[2][44] = -18'sd10581;
	Hsys[3][44] = 18'sd0;
	Hsys[4][44] = 18'sd10581;
	Hsys[5][44] = 18'sd21163;
	Hsys[6][44] = 18'sd31744;
	Hsys[7][44] = 18'sd21163;
	Hsys[0][45] = -18'sd46258;
	Hsys[1][45] = -18'sd30839;
	Hsys[2][45] = -18'sd15419;
	Hsys[3][45] = 18'sd0;
	Hsys[4][45] = 18'sd15419;
	Hsys[5][45] = 18'sd30839;
	Hsys[6][45] = 18'sd46258;
	Hsys[7][45] = 18'sd30839;
	Hsys[0][46] = -18'sd51802;
	Hsys[1][46] = -18'sd34535;
	Hsys[2][46] = -18'sd17267;
	Hsys[3][46] = 18'sd0;
	Hsys[4][46] = 18'sd17267;
	Hsys[5][46] = 18'sd34535;
	Hsys[6][46] = 18'sd51802;
	Hsys[7][46] = 18'sd34535;
end

endmodule


