onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /avg_mag_tb/timing/clk
add wave -noupdate /avg_mag_tb/drv/reset
add wave -noupdate -radix binary /avg_mag_tb/timing/sys_clk
add wave -noupdate -radix unsigned /avg_mag_tb/timing/cnt
add wave -noupdate -radix binary /avg_mag_tb/timing/sym_clk_en
add wave -noupdate -color Cyan -radix unsigned /avg_mag_tb/drv/x
add wave -noupdate -color Cyan -radix binary /avg_mag_tb/drv/load
add wave -noupdate -color Cyan -radix unsigned /avg_mag_tb/drv/cnt
add wave -noupdate -color Cyan -radix binary /avg_mag_tb/drv/cycle
add wave -noupdate -color Cyan -radix unsigned /avg_mag_tb/drv/out
add wave -noupdate -color Yellow -radix binary /avg_mag_tb/DUT/sym_clk_en
add wave -noupdate -color Yellow -radix binary /avg_mag_tb/DUT/reset
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/dec_var
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/abs
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/acc_out
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/reg_out
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/ref_lvl
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/mult_out
add wave -noupdate -color Yellow -radix decimal /avg_mag_tb/DUT/map_out_pwr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {277 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 255
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
WaveRestoreZoom {0 ns} {460 ns}
