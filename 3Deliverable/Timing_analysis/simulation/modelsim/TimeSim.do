project compileall
vsim -L cycloneive_ver -L altera_mf_ver -L altera_ver work.filter_TB
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /filter_TB/clk_50
add wave -noupdate -radix binary /filter_TB/sys_clk
add wave -noupdate -radix binary /filter_TB/sam_clk_en
add wave -noupdate -radix binary /filter_TB/sym_clk_en
add wave -noupdate -radix binary /filter_TB/rstdo
add wave -noupdate -radix decimal /filter_TB/x_in
add wave -noupdate -radix unsigned /filter_TB/DUT/cnt
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl_1
add wave -noupdate -radix decimal /filter_TB/DUT/mult_in
add wave -noupdate -radix decimal /filter_TB/DUT/mult_coeff
add wave -noupdate -radix decimal /filter_TB/DUT/mult_out
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl_2
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl_3
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl_4
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl_5
add wave -noupdate -radix decimal /filter_TB/DUT/acc_out
add wave -noupdate -radix decimal /filter_TB/DUT/y
add wave -noupdate -radix binary /filter_TB/DUT/det_edge
add wave -noupdate -format Analog-Interpolated -height 74 -max 50000.0 -min -10000.0 -radix decimal /filter_TB/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6855967 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {21411712 ps}
view wave
WaveCollapseAll -1
wave clipboard restore
run 20000000
