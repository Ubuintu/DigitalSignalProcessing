onbreak resume
onerror resume
vsim work.filter_tb
add wave sim:/filter_tb/u_testSRRCdesigner/clk
add wave sim:/filter_tb/u_testSRRCdesigner/clk_enable
add wave sim:/filter_tb/u_testSRRCdesigner/reset
add wave sim:/filter_tb/u_testSRRCdesigner/filter_in
add wave sim:/filter_tb/u_testSRRCdesigner/filter_out
add wave sim:/filter_tb/filter_out_ref
run -all
