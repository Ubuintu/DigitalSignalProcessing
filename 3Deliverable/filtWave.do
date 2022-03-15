onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB_filter/x_in
add wave -noupdate /TB_filter/y
add wave -noupdate /TB_filter/rst
add wave -noupdate /TB_filter/EN_CLK/clk
add wave -noupdate /TB_filter/EN_CLK/reset
add wave -noupdate /TB_filter/clk_50
add wave -noupdate /TB_filter/EN_CLK/sys_clk
add wave -noupdate /TB_filter/EN_CLK/sam_clk_en
add wave -noupdate /TB_filter/EN_CLK/sym_clk_en
add wave -noupdate /TB_filter/DUT/x
add wave -noupdate /TB_filter/DUT/x_in
add wave -noupdate /TB_filter/DUT/sum_lvl_1
add wave -noupdate /TB_filter/DUT/mult_out
add wave -noupdate /TB_filter/DUT/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3701 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
configure wave -valuecolwidth 383
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3525 ns} {4306 ns}
