module LFSR_22 (
    input clk, reset, load,
    output reg cycle,
    output [21:0] out
    );

(* noprune *) reg [21:0] x, cnt;

//initial begin
//    x = 22'd0;
//    repeat (2) @(negedge reset)
//    x[21] = 1'b1;
//end

always @ (posedge clk)
    if (reset) cycle = 1'b0;
    else if (cnt == 22'd4194303) cycle = 1'b1;
    else cycle = 1'b0;

always @ (posedge clk) 
    if (reset) cnt = 22'd0;
    else cnt = cnt + 22'd1;

always @ (posedge clk)
    if (reset) x = 22'd0;
    else if (load) x = { 1'b1,1'b0,{20{1'b1}} };
	else x = { x[20:0],(x[21]^x[20]) };

assign out = x;

endmodule

module LFSR_test #(parameter WIDTH = 4)(
    input clk, reset, load,
    output reg cycle,
    output reg signed [WIDTH-1:0] out
    );

(* noprune *) reg signed [WIDTH-1:0] x;
(* noprune *) reg [WIDTH-1:0] cnt;

//for MS NEED to initialize regs to 0
initial begin
    x = {WIDTH{1'b0}};
    cycle = 1'b0;
    out = {WIDTH{1'b0}};
    cnt = {WIDTH{1'b0}};
end

always @ (posedge clk)
    if (reset) cycle = 1'b0;
    else if (cnt == {WIDTH{1'b1}}) cycle = 1'b1;
    else cycle = 1'b0;

always @ (posedge clk) 
    if (reset) cnt = {WIDTH{1'b0}};
    else cnt = cnt + {{(WIDTH-1){1'b0}},1'b1};

always @ (posedge clk)
    if (reset) x = {WIDTH{1'b0}};
    else if (load) x = { 2'b01,{WIDTH-2{1'b0}} };
	else x = $signed({ x[3:1], (x[2]^x[3]) });

always @ *
    if (reset) out = {WIDTH{1'b0}};
    else out = $signed(x);

endmodule
