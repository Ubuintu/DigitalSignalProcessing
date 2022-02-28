module mapper (input wire [1:0]symbol,
					output reg signed [17:0]value);
					
		//MAPPER: Takes a 2-bit symbol value and converts the values
		//			into a 1s17 "voltage" for the I or Q constellation
		//			level.
		

	// random constellation values selected for illustration purposes only
	
	always @ *
	  begin
	    if (symbol[1:0] == 2'b00)
		   value <= 18'd131071;
	    else if (symbol[1:0] == 2'b01)
		   value <= 18'd5000;
	    else if (symbol[1:0] == 2'b10)
		   value <= 18'd131072;
	    else
		   value <= 18'd128000;
	  end

endmodule
