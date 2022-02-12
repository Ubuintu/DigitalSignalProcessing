module avg_mag #(parameter WIDTH = 4)(
    input signed [17:0] dec_var,
    input sym_clk_en, clr_acc, clk, reset, 
    output reg signed [17:0] ref_lvl, map_out_pwr
);

(* noprune *) reg signed [39:0] acc_out;
(* noprune *) reg signed [17:0] reg_out, abs;
(* noprune *) reg signed [35:0] mult_out;

initial begin
    ref_lvl = 18'd0;
    map_out_pwr = 18'd0;
    acc_out = 18'd0;
    reg_out = 18'd0;
    abs = 18'd0;
    mult_out = 36'd0;
end

always @ *
    if (reset) abs <= 18'sd0;
    else if (dec_var < 0) abs <= -18'sd1*dec_var;
    else abs <= dec_var;

always @ (posedge clk)
    if (reset || clr_acc) acc_out = 40'sd0;
    else if (sym_clk_en) acc_out = acc_out + abs;
    else acc_out = acc_out;

always @ (posedge clk)
    if (reset) reg_out = 18'sd0;
    else if (clr_acc) reg_out = acc_out >> WIDTH;
    else acc_out = acc_out;

always @ *
    if (reset) ref_lvl <= 18'sd0;
    else ref_lvl <= acc_out;

always @ *
    if (reset) mult_out <= 18'sd0;
    else mult_out <= reg_out * reg_out * 18'sd81920;

always @ * 
    if (reset || clr_acc) ref_lvl <= 18'sd0;
    else ref_lvl <= reg_out;

always @ * 
    if (reset || clr_acc) map_out_pwr <= 18'sd0;
    else map_out_pwr <= mult_out[33:17];

endmodule
