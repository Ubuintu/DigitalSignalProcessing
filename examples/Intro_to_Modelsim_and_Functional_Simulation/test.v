module test (
  input wire clk,
  input wire reset,
  
  input wire a,
  input wire b,
  
  output wire c
);

//This module delays the inputs & output and takes the logical AND of them 

reg a_reg;
reg b_reg;

//c is output wire
assign c = a_reg & b_reg;

//a & b regs should pass the a & b wires on the next cc
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
	
	