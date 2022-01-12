module test (
  input wire clk,
  input wire reset,
  
  input wire a,
  input wire b,
  
  output wire c
);

reg a_reg;
reg b_reg;

assign c = a_reg & b_reg;


always @ (posedge clk or posedge reset)
  if (reset)
    begin
	  a_reg <= 1'b0;
	  b_reg <= 1'b0;
	end
  else
    begin
	  a_reg <= a;
	  b_reg <= b;
	end
	
endmodule
	
	