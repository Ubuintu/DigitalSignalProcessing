module KeyCCT #(parameter PERSIST = 1)( input clk,
					 input key,
					 output key_out);

	integer i;
					 
	reg sig_and, sig_or;
	reg z1;
	reg [0:(PERSIST-32'd1)]delay;
	
	always@ (posedge clk)
		z1 <= key;
	

	always@ *
		sig_and <= ~key & z1;
	
	always@ (posedge clk)
		if (PERSIST > 32'd0)
			delay[0] <= sig_and;
			
	always@ (posedge clk)
		if (PERSIST > 32'd1)
			for (i = 1; i < PERSIST; i = i + 32'd1)
				begin
					delay[i] <= delay[i - 32'd1];
				end
	
	always@ *
		if (PERSIST > 32'd0)
			sig_or <= |delay;
		else
			sig_or <= 1'b0;
		
	assign key_out = ~(sig_and | sig_or);
	
					 
				
endmodule
					 