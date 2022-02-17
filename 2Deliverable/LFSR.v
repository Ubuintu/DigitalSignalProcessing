module LFSR_22 (
    input sys_clk, reset, load, sam_clk_en,
    output reg cycle,
    output reg signed[21:0] out
    );

(* preserve *) reg [21:0] x, cnt;
/*
initial begin
    x = {22{1'b0}};
    cycle = 1'b0;
    out = {22{1'b0}};
    cnt = 22'd1;
end
*/

always @ (posedge sys_clk)
    if (reset) cycle = 1'b0;
    else if (sam_clk_en && cnt == 22'd4194303) cycle = 1'b1;
    else cycle = 1'b0;

always @ (posedge sys_clk) 
    if (reset || sam_clk_en && cnt == 22'd4194303) cnt = 22'd1;
    else if (sam_clk_en) cnt = cnt + 22'd1;
    else cnt = cnt;

always @ (posedge sys_clk)
    if (reset) x = 22'd0;
    else if (load) x = { 1'b1,1'b0,{20{1'b1}} };
	 else if (sam_clk_en) x = $signed({ x[20:0],(x[21]^x[20]) });
    else x = x;

always @ *
    if (reset) out = {22{1'b0}};
    else out = $signed(x);

endmodule

module LFSR_test #(parameter WIDTH = 4)(
    input sys_clk, reset, load, sam_clk_en,
    output reg cycle,
    output reg signed [WIDTH-1:0] out
    );

(* preserve *) reg signed [WIDTH-1:0] x;
(* preserve *) reg [WIDTH-1:0] cnt;

//for MS NEED to initialize regs to 0
initial begin
    x = {WIDTH{1'b0}};
    cycle = 1'b0;
    out = {WIDTH{1'b0}};
    cnt = {WIDTH{1'b0}};
end

always @ (posedge sys_clk)
    if (reset) cycle = 1'b0;
    else if (sam_clk_en && cnt == { {(WIDTH-1){1'b1}},1'b0 }) cycle = 1'b1;
    else cycle = 1'b0;

always @ (posedge sys_clk) 
    if (reset || (sam_clk_en && cnt == { {(WIDTH-1){1'b1}},1'b0}) ) cnt = {WIDTH{1'b0}};
    else if (sam_clk_en) cnt = cnt + {{(WIDTH-1){1'b0}},1'b1};
    else cnt = cnt;

always @ (posedge sys_clk)
    if (reset) x = {WIDTH{1'b0}};
    else if (load) x = {WIDTH{1'b1}};
	 else if (sam_clk_en) x = $signed({ x[2:0], (x[2]^x[3]) });
    else x = x;

always @ *
    if (reset) out = {WIDTH{1'b0}};
    else out = $signed(x);

endmodule
