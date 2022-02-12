module clk_en (
    input clk,
    output reg sys_clk, sam_clk_en, sym_clk_en
    );

(* noprune *) reg [3:0] cnt;

initial begin
    sys_clk = 1'b0;
    sam_clk_en = 1'b0;
    sym_clk_en = 1'b0;
    cnt = 4'b0;
end

always @ (posedge clk)
    sys_clk = ~sys_clk;

always @ (posedge sys_clk)
    cnt = cnt + 4'b1;

always @ (posedge sys_clk)
    //account for delay; checks for logic and performs op on next posedge
    if ( (cnt+2)%4 == 0 )
        sam_clk_en = 1'b1;
    else
        sam_clk_en = 1'b0;
        
always @ (posedge sys_clk)
    if ( cnt == 4'd14 )
        sym_clk_en = 1'b1;
    else
        sym_clk_en = 1'b0;

endmodule
