module slicer (
    input signed [17:0] dec_var, ref_lvl,
    output reg [1:0] slice
);

always @ *
    if ( dec_var < -ref_lvl )
        slice = 2'b00;	//-3b
    else if ( dec_var[17] )
        slice = 2'b01;	//-b
    else if (  dec_var > ref_lvl )
        slice = 2'b10;	//3b
    else
        slice = 2'b11;	//b

endmodule
