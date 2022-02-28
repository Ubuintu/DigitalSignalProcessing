module test_tb;
// Example testbench provided to EE 465 class for the following purposes:
// - to provide a basic template to help the students get started writing testbenches
// - to illustrate the correct and incorrect way to generate input stimulus signals
// - to provide an example of file IO in verilog

//within our TB we need to compute registers for the 4 inputs of our test and a
//wire for our output.
reg clk;
reg reset;

reg a;
reg b;

reg [3:0] d;
 
wire c;

//period of clock
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
	/*when generating input stimulus in modelsim, it is recommended that stimulus is
		based off the clock since we cannot simulate the propagation delays*/
	  a <= 1'b0;
	  //b <= 1'b0;
	end
  else
    begin
	//Here the inputs are toggled
	  a <= ~a;
	  //b <= ~b;
	end
	
	
// Generate input stimulus signals - incorrect method
// - stimulus signals should not be generated inside initial blocks
//   with hardcoded delays (#)
// DON'T DO THIS!

//comment this code and uncomment the above b assignments.
initial 
begin
  b = 0;
  //Don't use hardcoded delays like this since your tb will not simulate what would happened on the FPGA
  //you will see in Modelsim that that hardcoded delays will occur without taking into account of all the other registers
  //that run at the same time
  #(PERIOD/2);
  forever
    begin 
	//seems that b has toggled on the clock instead of after the cc
	  #(PERIOD);	
	  b = ~b;
    end
end

//  Example of reading data into the simulation from a text file
//  - could connect into DUT to test various scenarios

//this integer variable acts as a file handler
integer file_in;

initial
begin
//use $fopen, the parameters are the file name you want to open and 
//the mode you would like to open the file in
  file_in = $fopen("my_file.txt", "r");
end

always @ (posedge clk)
  if (reset)
    d[3:0] <= 4'd0;
  else
  //$fscanf is used to read values from the textfile
    $fscanf(file_in, "%d\n", d[3:0]);
   

// Instantiate device under test (DUT)
// module_name module_instance();
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

	
	
