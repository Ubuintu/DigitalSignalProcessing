module avg_err_squared #(parameter LFSR_WID = 20)( 
    //error 2s16
    input signed [17:0] error,
    input sym_clk_en, clr_acc, sys_clk, reset, 
    output reg signed [17:0] err_square
);

(* preserve *) reg signed [(LFSR_WID+18-1):0] acc_out, err_int;
(* keep *) reg signed [35:0] mult_out;
(* keep *) reg [1:0] det_edge;
(* keep *) wire sig_edge;

initial begin
    mult_out = 36'd0;
    err_square = 18'd0;
    acc_out = {(LFSR_WID+18){1'b0}};
    det_edge = 2'd0;
end

always @ *
    mult_out = error * error;

//for detecting falling edge
always @ (posedge sys_clk)
    if (reset) det_edge <= 2'd0;
    else det_edge <= {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b01);

always @ (posedge sys_clk)
    if (reset || sig_edge) acc_out <= {(LFSR_WID+18){1'b0}};
    else if (sym_clk_en) acc_out <= acc_out + mult_out[34:17];
    else acc_out <= acc_out;

always @ (posedge sys_clk)
    if (reset) err_int <= {(LFSR_WID+18){1'b0}};
    //else if (clr_acc) err_int = $signed(acc_out >>> $clog2(LFSR_WID));
    else if (clr_acc) err_int <= acc_out >>> (LFSR_WID);
    else err_int <= err_int;

always @ *
    if (reset) err_square = 18'sd0;
    else err_square = err_int[17:0];

endmodule


module avg_err #(parameter LFSR_WID = 20)( 
    //error 2s16
    input signed [17:0] error,
    input sym_clk_en, clr_acc, sys_clk, reset, 
    output reg signed [17:0] err_acc
);

(* preserve *) reg signed [(LFSR_WID+18-1):0] acc_out, err_int;
(* keep *) reg [1:0] det_edge;
(* keep *) wire sig_edge;

initial begin
    err_acc = 18'd0;
    acc_out = {(LFSR_WID+18){1'b0}};
    det_edge = 2'd0;
end

//for detecting falling edge
/*
always @ *
    det_edge = {det_edge[0], clr_acc};
*/
always @ (posedge sys_clk)
    if (reset) det_edge <= 2'd0;
    else det_edge <= {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b01);

always @ (posedge sys_clk)
    if (reset || sig_edge) acc_out <= {(LFSR_WID+18){1'b0}};
    else if (sym_clk_en) acc_out <= acc_out + error;
    else acc_out <= acc_out;

always @ (posedge sys_clk)
    if (reset) err_int <= {(LFSR_WID+18){1'b0}};
    //else if (clr_acc) err_int = $signed(acc_out >>> $clog2(LFSR_WID));
    else if (clr_acc) err_int <= acc_out >>> (LFSR_WID);
    else err_int <= err_int;

always @ *
    if (reset) err_acc = 18'sd0;
    else err_acc = err_int[17:0];

endmodule

module avg_err_squared_55 #(parameter LFSR_WID = 56)( 
    //error 2s16
    input signed [17:0] error,
    input sym_clk_en, clr_acc, sys_clk, reset, 
    output reg signed [(LFSR_WID-1):0] err_square
);

(* preserve *) reg signed [(LFSR_WID-1):0] acc_out, err_int;
(* keep *) reg signed [35:0] mult_out;
(* preserve *) reg [1:0] det_edge;
(* keep *) wire sig_edge;

initial begin
    mult_out = 36'd0;
    err_square = 18'd0;
    acc_out = {(LFSR_WID){1'b0}};
    det_edge = 2'd0;
end

always @ *
    mult_out = error * error;

//for detecting falling edge
always @ (posedge sys_clk)
    if (reset) det_edge <= 2'd0;
    else det_edge <= {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b01);

always @ (posedge sys_clk)
    if (reset || sig_edge) acc_out <= {(LFSR_WID){1'b0}};
    else if (sym_clk_en) acc_out <= acc_out + mult_out;
    else acc_out <= acc_out;

always @ (posedge sys_clk)
    if (reset) err_int <= {(LFSR_WID){1'b0}};
    //else if (clr_acc) err_int = $signed(acc_out >>> $clog2(LFSR_WID));
    else if (clr_acc) err_int <= acc_out;
    else err_int <= err_int;

always @ *
    if (reset) err_square = {(LFSR_WID){1'b0}};
    else err_square = err_int;

endmodule
