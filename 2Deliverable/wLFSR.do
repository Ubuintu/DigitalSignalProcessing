onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /LFSR_tb/DUT/clk
add wave -noupdate -radix binary /LFSR_tb/DUT/reset
add wave -noupdate /LFSR_tb/load
add wave -noupdate /LFSR_tb/DUT/cycle
add wave -noupdate -radix unsigned /LFSR_tb/DUT/cnt
add wave -noupdate -radix unsigned /LFSR_tb/DUT/out
add wave -noupdate -radix unsigned /LFSR_tb/DUT/x
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49909 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 261
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
WaveRestoreZoom {49895 ns} {50006 ns}
