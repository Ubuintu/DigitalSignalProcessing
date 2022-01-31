onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /cascade_tb/clk
add wave -noupdate -radix binary /cascade_tb/reset
add wave -noupdate -radix decimal /cascade_tb/x_in
add wave -noupdate -radix decimal /cascade_tb/TX/x_in
add wave -noupdate -radix decimal /cascade_tb/TX/x
add wave -noupdate -radix decimal /cascade_tb/TX/y
add wave -noupdate -radix decimal /cascade_tb/cascade
add wave -noupdate -radix decimal /cascade_tb/RCV/x_in
add wave -noupdate -radix decimal /cascade_tb/RCV/y
add wave -noupdate -radix decimal /cascade_tb/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {285 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 242
configure wave -valuecolwidth 288
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
WaveRestoreZoom {3907 ns} {4005 ns}
