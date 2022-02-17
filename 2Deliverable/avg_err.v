module avg_err_squared #(parameter LFSR_WID = 22)( 
    //error 2s16
    input signed [17:0] error,
    input sym_clk_en, clr_acc, sys_clk, reset, 
    output reg signed [17:0] err_square
);

(* preserve *) reg signed [(LFSR_WID+18-1):0] acc_out;
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
always @ *
    det_edge = {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b10);

always @ (posedge sys_clk)
    if (reset || sig_edge) acc_out = {(LFSR_WID+18){1'b0}};
    else if (sym_clk_en) acc_out = acc_out + mult_out[34:17];
    else acc_out = acc_out;

always @ (posedge sys_clk)
    if (reset) err_square = 18'sd0;
    //else if (clr_acc) err_square = $signed(acc_out >>> $clog2(LFSR_WID));
    else if (clr_acc) err_square = acc_out[17:0] >>> (LFSR_WID-18);
    else err_square = err_square;

endmodule


module avg_err #(parameter LFSR_WID = 22)( 
    //error 2s16
    input signed [17:0] error,
    input sym_clk_en, clr_acc, sys_clk, reset, 
    output reg signed [17:0] err_acc
);

(* preserve *) reg signed [(LFSR_WID+18-1):0] acc_out;
(* keep *) reg [1:0] det_edge;
(* keep *) wire sig_edge;

initial begin
    err_acc = 18'd0;
    acc_out = {(LFSR_WID+18){1'b0}};
    det_edge = 2'd0;
end

//for detecting falling edge
always @ *
    det_edge = {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b10);

always @ (posedge sys_clk)
    if (reset || sig_edge) acc_out = {(LFSR_WID+18){1'b0}};
    else if (sym_clk_en) acc_out = acc_out + error;
    else acc_out = acc_out;

always @ (posedge sys_clk)
    if (reset) err_acc = 18'sd0;
    //else if (clr_acc) err_acc = $signed(acc_out >>> $clog2(LFSR_WID));
    else if (clr_acc) err_acc = acc_out[17:0] >>> (LFSR_WID-18);
    else err_acc = err_acc;

endmodule
