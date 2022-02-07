`module LFSR_22 (
    input clk,
    output [1:0] out
    );
integer i;
(* noprune *) reg [21:0] x;

initial begin
    x = 21'd0;
end

always @ (posedge clk)
	x = { x[21:1],(x[21]^x[20]) };

assign out = x[1:0];

endmodule

module LFSR_16 (
    input clk,
    output [1:0] out
    );

assign out = 2'd0;

endmodule
