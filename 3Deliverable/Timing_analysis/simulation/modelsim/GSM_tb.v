`timescale 1ns/1ps
module filter_TB();

reg clk_50, rst;

reg signed [17:0] x_in;
wire signed [17:0] y;
wire sys_clk, sam_clk_en, sym_clk_en;

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
    //file_in=$fopen("../../../D3_ASK_in.txt","r");
    #(RSTDELAY*RSTLEN);
    rst=1;
    #(RSTLEN*RSTLEN*10);
    rst=0;
end

always @ (posedge sys_clk)
    if(rst)
        x_in <=18'sd0;
    else if (sam_clk_en)
        $fscanf(file_in,"%d\n",x_in);
    else
        x_in<=x_in;

clk_en EN_CLK( .clk(clk_50), .reset(rst), .sys_clk(sys_clk), .sam_clk_en(sam_clk_en), .sym_clk_en(sym_clk_en) );

GSM_101Mults DUT (
    .sys_clk(sys_clk),
    .sam_clk_en(sam_clk_en),
    .reset(rst),
    .x_in(x_in),
    .y(y)
);

endmodule
