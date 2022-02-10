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

module LFSR_16 (
    input clk,
    output [15:0] out
    );

(* noprune *) reg [15:0] x;

initial begin
    x = 16'd0;
end

always @ (posedge clk)
	x = { x[15:1], (x[15]^x[14]^x[12]^x[3]) };

assign out = x;

endmodule
