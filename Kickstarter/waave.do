onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /tb_filter/DUT/clk
add wave -noupdate -radix binary /tb_filter/reset
add wave -noupdate -radix binary /tb_filter/clk
add wave -noupdate -radix decimal /tb_filter/DUT/x_in
add wave -noupdate -radix hexadecimal /tb_filter/DUT/y
add wave -noupdate -radix decimal /tb_filter/DUT/x
add wave -noupdate -radix decimal /tb_filter/DUT/sum_level_1
add wave -noupdate -radix decimal /tb_filter/DUT/b
add wave -noupdate -radix decimal /tb_filter/DUT/mult_out
add wave -noupdate -radix decimal /tb_filter/DUT/sum_level_2
add wave -noupdate -radix decimal /tb_filter/DUT/sum_level_3
add wave -noupdate -radix decimal /tb_filter/DUT/sum_level_4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 308
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
configure wave -timelineunits ns
update
WaveRestoreZoom {6646 ns} {6700 ns}
