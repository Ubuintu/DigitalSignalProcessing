onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /filter_TB/EN_CLK/clk
add wave -noupdate /filter_TB/EN_CLK/sys_clk
#add wave -noupdate /filter_TB/EN_CLK/cnt
add wave -noupdate /filter_TB/EN_CLK/sys_clk2_en
add wave -noupdate /filter_TB/EN_CLK/sam_clk_en
add wave -noupdate -radix unsigned /filter_TB/EN_CLK/cnt
#add wave -noupdate /filter_TB/EN_CLK/sym_clk_en
add wave -noupdate /filter_TB/rst
add wave -noupdate /filter_TB/DUT/x_in
add wave -noupdate /filter_TB/DUT/x
add wave -noupdate /filter_TB/DUT/halfSysCnt
add wave -noupdate /filter_TB/DUT/UpSam1
add wave -noupdate /filter_TB/DUT/HB1/x_in
add wave -noupdate /filter_TB/DUT/HB1/y
add wave -noupdate /filter_TB/DUT/SysCnt
add wave -noupdate /filter_TB/DUT/HB2/x_in
add wave -noupdate /filter_TB/DUT/HB2/sum_lvl_1
add wave -noupdate /filter_TB/DUT/HB2/sum_lvl_2
add wave -noupdate /filter_TB/DUT/HB2/sum_lvl_3
add wave -noupdate /filter_TB/DUT/HB2/sum_lvl_4
add wave -noupdate /filter_TB/DUT/HB2/y
add wave -noupdate /filter_TB/DUT/y
#add wave -noupdate -format Analog-Interpolated -height 84 -max 39137.0 -min -7450.0 /filter_TB/DUT/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {130 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
configure wave -valuecolwidth 316
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
WaveRestoreZoom {0 ns} {959 ns}
