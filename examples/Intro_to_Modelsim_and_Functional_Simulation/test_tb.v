module test_tb;
// Example testbench provided to EE 465 class for the following purposes:
// - to provide a basic template to help the students get started writing testbenches
// - to illustrate the correct and incorrect way to generate input stimulus signals
// - to provide an example of file IO in verilog

reg clk;
reg reset;

reg a;
reg b;

reg [3:0] d;
 
wire c;

localparam PERIOD = 10;
localparam RESET_DELAY = 2;
localparam RESET_LENGTH = 12;


// Clock generation (OK to use hardcoded delays #)
initial
begin
  clk = 0;
  forever
    begin 
      #(PERIOD/2);
      clk = ~clk;
    end
end

// Reset generation (OK to use hardcoded delays #)
initial 
begin
  reset = 0;
  #(RESET_DELAY);
  reset = 1;
  #(RESET_LENGTH);
  reset = 0;
end 

// Generate input stimulus signals - correct method
// - stimulus signals should be generated inside always blocks
//   which are triggered off of the clock

always @(posedge clk)
  if(reset)
    begin
	  a <= 1'b0;
	  //b <= 1'b0;
	end
  else
    begin
	  a <= ~a;
	  //b <= ~b;
	end
	
	
// Generate input stimulus signals - incorrect method
// - stimulus signals should not be generated inside initial blocks
//   with hardcoded delays (#)
// DON'T DO THIS!

initial 
begin
  b = 0;
  #(PERIOD/2);
  forever
    begin 
	  #(PERIOD);	
	  b = ~b;
    end
end

//  Example of reading data into the simulation from a text file
//  - could connect into DUT to test various scenarios

integer file_in;

initial
begin
  file_in = $fopen("my_file.txt", "r");
end

always @ (posedge clk)
  if (reset)
    d[3:0] <= 4'd0;
  else
    $fscanf(file_in, "%d\n", d[3:0]);
   

// Instantiate device under test (DUT)
test test_inst (
  // clocks and resets
  .clk(clk),
  .reset(reset),
  
  // inputs
  .a(a),
  .b(b),
  
  //outputs
  .c(c)
);
	
endmodule

	
	
