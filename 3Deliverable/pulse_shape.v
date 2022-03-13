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
    parameter integer SUMLVLWID [SUMLVL-1:0]={47,24,12,6,3,2,1},
    parameter [7:0] POSSINPUTS [(POSSMAPPER+4)-1:0]={-18'sd98303,-18'sd65536,-18'sd32768,18'sd0,18'sd32768,18'sd65536,18'sd98303,-18'sd49152,-18'sd16384,18'sd16384,18'sd49152}
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
        for(i=0; i<(SUMLVLWID[SUMLVL]-2); i=i+1)
            sum_lvl[i]=18'sd0;
    end
    else begin
        for(i=0; i<(SUMLVLWID[SUMLVL]-2); i=i+1)
            sum_lvl[i]=$signed(x[i])+$signed(x[LENGTH-i]);
    end
//sum last odd tap
always @ (posedge sys_clk)
    if (reset) sum_lvl[(SUMLVLWID[SUMLVL])-1]=18'sd0;
    else sum_lvl[(SUMLVLWID[SUMLVL])-1]=$signed( x[(SUMLVLWID[SUMLVL])-1] );

//always @ (posedge sys_clk)    //need <=
always @ *    //use =
    if (reset) begin
		 for(i=0;i<SUMLVLWID[SUMLVL]-1; i=i+1)
		 //should be 2s34 (2s16*0s18)
			  mult_out[i] = 18'sd0;
    end
    else begin
        //For N=93, should be 46 pairs of taps
        for (i=0; i<SUMLVLWID[SUMLVL]-1)]; i=i+1) begin
            //All taps besides center/odd tap
            if(i<SUMLVLWID[SUMLVL]-2) begin
                //Possible input to sym taps
                for(j=0; j<POSSMAPPER; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]=$signed(b[7][i]);
                    else if ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j])-tol) ) && ( $signed(sum_lvl[i])<$signed(POSSINPUTS[j])+tol) ) ) mult_out[i]=$signed(b[j][i]);
                    else mult_out[i]=18'sd0;
                end
            end
            //for last tap/center
            else begin
                for(j=0; j<MAPSIZE; j=j+1) begin
                    if ( $signed(sum_lvl[i])==18'sd65500 ) mult_out[i]=$signed(b[j+POSSMAPPER][i]);
                    else if ( $signed(sum_lvl[i])>($signed(POSSINPUTS[j+POSSMAPPER])-tol) ) && ( $signed(sum_lvl[i])<$signed(POSSINPUTS[j+POSSMAPPER])+tol) ) ) mult_out[i]=$signed(b[j+POSSMAPPER][i]);
                    else mult_out[i]=18'sd0;
                end
            end
        end
    end
        
integer ind=0;
integer index=0;
//coeffs 0s18; x 2s16
always @ *
   if (reset) begin
        //sum(SUMLVLWID+SUMLVL)=total regs required
        for (i=SUMLVLWID[SUMLVL-1];i<LENGTH;i=i+1)
            sum_lvl[i]=18'sd0;
   end
   else begin
        //Will have to manually adjust if statements based on len of filt & sum lvls required
        
        //for (i=SUMLVLWID[SUMLVL-1]; i<(LENGTH+OFFSET); i=i+1)
        //    //sum_level_2
        //    if (i>=SUMLVLWID[SUMLVL-1]&&i<(SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]))
        //        sum_lvl[i]=$signed(mult_out[2*(i-SUMLVLWID[SUMLVL-1])])+$signed(mult_out[2*(i-SUMLVLWID[SUMLVL-1])+1]);
        //    //sum lvl 2 center tap
        //    else if (i==(SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]-1))
        //        sum_lvl[i]=$signed(mult_out[SUMLVLWID[SUMLVL-1]]);
        //    //sum lvl 3
        //    else if(i>(SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2])&&i<(SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+SUMLVLWID[SUMLVL-3]))
        //        sum_lvl[i]=$signed(
        
        /*          sum lvl 2; multiple begin-ends work sequentially            */
        for (i=0; i<SUMLVLWID[SUMLVL-2]-1; i=i+1) begin
            if (i==SUMLVLWID[SUMLVL-2]-1)
                sum_lvl[i+SUMLVLWID[SUMLVL-1]]=$signed(mult_out[2*i]);
            else 
                sum_lvl[i+SUMLVLWID[SUMLVL-1]]=$signed(mult_out[2*i])+$signed(mult_out[2*i+1]);
        end
        //sum lvl 3
        for (i=0; i<SUMLVLWID[SUMLVL-3]-1; i=i+1) begin
            sum_lvl[i+SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]]=$signed(sum_lvl[SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+2*i])+$signed(sum_lvl[SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+2*i+1]);
        end
        //sum lvl 4
        for (i=0; i<SUMLVLWID[SUMLVL-4]-1; i=i+1) begin
            sum_lvl[i+SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+SUMLVLWID[SUMLVL-3]]=$signed(sum_lvl[SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+SUMLVLWID[SUMLVL-3]+2*i])+$signed(sum_lvl[SUMLVLWID[SUMLVL-1]+SUMLVLWID[SUMLVL-2]+SUMLVLWID[SUMLVL-3]+2*i+1])];
        end
        //sum lvl 5
        begin
            ind=sum(SUMLVLWID,5);
            index=sum(SUMLVLWID,4);
        end
        for (i=0; i<SUMLVLWID[SUMLVL-5]-1; i=i+1) begin
            sum_lvl[i+ind]=$signed(sum_lvl[index+2*i])+$signed(sum_lvl[index+2*i+1])];
        end
        //sum lvl 6 (2ND LAST)
        begin
        ind=sum(SUMLVLWID,6);
        index=sum(SUMLVLWID,5);
        end
        for (i=0; i<SUMLVLWID[SUMLVL-6]-1; i=i+1) begin
            if(i==0)
                sum_lvl[i+ind]=$signed(sum_lvl[index+2*i])+$signed(sum_lvl[index+2*i+1])];
            else
                sum_lvl[i+ind]=$signed(sum_lvl[index+2*i])
        end
        //sum lvl 7 (FINAL)
        begin
        ind=sum(SUMLVLWID,7);
        index=sum(SUMLVLWID,6);
        end
        for (i=0; i<SUMLVLWID[SUMLVL-7]; i=i+1) begin
            if(i==0)
                sum_lvl[i+ind]=$signed(sum_lvl[index+2*i])+$signed(sum_lvl[index+2*i+1]);
            else
                sum_lvl[i+ind]=$signed(sum_lvl[index+2*i]);
        end
   end

    always @ (posedge sys_clk)
        if (reset) y<= 18'sd0;
        else if (sam_clk_en) y<=$signed( sum_lvl[sum(SUMLVLWID,7)] );
        else y<=$signed(y);

endmodule


function automatic integer sum( input integer ar[6:0], N);
    begin
        integer toAdd=0;
        for (i=0; i<N; i=i+1)
            toAdd=ar[i]+toAdd;
        sum=toAdd;
    end
endfunction
