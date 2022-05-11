`timescale 1ns/1ps
module filter_TB();

reg clk_50, rst;

reg signed [17:0] x_in;
wire signed [17:0] y;
wire sys_clk, sam_clk_en, sym_clk_en, sys_clk2_en;

localparam PERIOD=20; 
localparam RSTDELAY=2; 
localparam RSTLEN=2; 

integer file_in;

initial begin
    clk_50=0;
    forever begin
    #(PERIOD/2);
    clk_50=~clk_50;
    end
end

initial begin
    rst=0;
    x_in=0;
    file_in=$fopen("impulse_response.txt","r");
    #(RSTDELAY*RSTLEN);
    rst=1;
    #(RSTLEN*RSTLEN*100);
    rst=0;
end

always @ (posedge sys_clk) //cascade
//always @ (posedge clk_50) //2nd halfband
    if(rst)
        x_in <=18'sd0;
/*
    //for others
    else if (sam_clk_en)
        $fscanf(file_in,"%d\n",x_in);
*/
    else if (sys_clk2_en) //for halfband
        $fscanf(file_in,"%d\n",x_in);
    else
        x_in<=x_in;
/*
    //2nd halfband
    else
        $fscanf(file_in,"%d\n",x_in);
*/
clk_en EN_CLK( 
    .clk(clk_50), 
    .reset(rst), 
    .sys_clk(sys_clk), 
    .sys_clk2_en(sys_clk2_en), 
    .sam_clk_en(sam_clk_en), 
    .sym_clk_en(sym_clk_en) 
);

DUT DUT (
    .clk(clk_50), 
    .sys_clk(sys_clk),
    .sam_clk_en(sam_clk_en),
    .sys_clk2_en(sys_clk2_en),    //for 12.5 clk
    .reset(rst),
    .x_in(x_in),
    .y(y)
);

endmodule
