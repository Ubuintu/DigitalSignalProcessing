module avg_mag #(parameter LFSR_WID = 22,parameter ACC_WID = 40)( 
    input signed [17:0] dec_var,
    input sym_clk_en, clr_acc, clk, reset, 
    output reg signed [17:0] ref_lvl, map_out_pwr
);

(* noprune *) reg signed [ACC_WID-1:0] acc_out;
(* noprune *) reg signed [17:0] reg_out, abs, square;
(* noprune *) reg signed [35:0] mult_out, mult_out_2;
(* noprune *) reg [1:0] det_edge;
(* noprune *) wire sig_edge;

initial begin
    ref_lvl = 18'd0;
    map_out_pwr = 18'd0;
    acc_out = 18'd0;
    reg_out = 18'd0;
    square = 18'd0;
    abs = 18'd0;
    mult_out = 36'd0;
    mult_out_2 = 36'd0;
    det_edge = 2'd0;
end

always @ *
    det_edge = {det_edge[0], clr_acc};

assign sig_edge = (det_edge == 2'b10);

always @ *
    if (reset) abs = 18'sd0;
    else if (dec_var == -18'sd131072) abs = ~dec_var;
    else if ($signed(dec_var) < 18'sd0) abs = -$signed(dec_var);
    else abs = dec_var;

always @ (posedge clk)
    if (reset || sig_edge) acc_out = {ACC_WID{1'b0}};
    else if (sym_clk_en) acc_out = acc_out + abs;
    else acc_out = acc_out;

always @ (posedge clk)
    if (reset) reg_out = 18'sd0;
    //else if (clr_acc) reg_out = $signed(acc_out >>> $clog2(LFSR_WID));
    //else if (clr_acc) reg_out = acc_out >>> 2;
    else if (clr_acc) reg_out = acc_out >>> (ACC_WID-18);
    //else if (clr_acc) reg_out = acc_out/18'sd4;
    else reg_out = reg_out;

always @ *
    if (reset) ref_lvl = 18'sd0;
    else ref_lvl = reg_out;

always @ *
    if (reset) mult_out = 18'sd0;
    //Ask Rory about this
    //else mult_out <= reg_out * reg_out * 18'sd81920;
    else mult_out = reg_out * reg_out;

always @ *
    square = $signed(mult_out[34:17]);

always @ *
    //1.25 -> 2s16 -> 81920
    mult_out_2 = square * 18'sd81920;

always @ * 
    if (reset) ref_lvl = 18'sd0;
    else ref_lvl = reg_out;

always @ * 
    if (reset) map_out_pwr = 18'sd0;
    else map_out_pwr = $signed(mult_out_2[34:17]);

endmodule
