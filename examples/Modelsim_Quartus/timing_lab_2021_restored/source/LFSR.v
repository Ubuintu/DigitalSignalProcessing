
module LFSR( 	input clk,
					input load_data,
					output [3:0]q);
					
	reg [15:0]q_int;
		always@ (posedge clk)
		begin
			if (load_data == 1'b1)
				q_int <= {16{1'b1}};
			else
				begin
					q_int <= {q_int[14:0], (q_int[1] ^ (q_int[2] ^ (q_int[4] ^ q_int[15])))};
				end
		end

	assign q = q_int[3:0];

endmodule
					