project compileall
vsim work.MER_TB -L cycloneive_ver -L altera_mf_ver -L altera_ver
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /MER_TB/EN_CLK/clk
add wave -noupdate -radix binary /MER_TB/EN_CLK/reset
add wave -noupdate -radix binary /MER_TB/a_reset
add wave -noupdate -radix binary /MER_TB/load
add wave -noupdate -radix binary /MER_TB/EN_CLK/sys_clk
add wave -noupdate -radix binary /MER_TB/EN_CLK/sam_clk_en
add wave -noupdate -radix binary /MER_TB/EN_CLK/sym_clk_en
add wave -noupdate -radix decimal -childformat {{{/MER_TB/MEAS_DUT/LFSR_out[21]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[20]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[19]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[18]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[17]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[16]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[15]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[14]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[13]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[12]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[11]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[10]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[9]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[8]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[7]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[6]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[5]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[4]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[3]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[2]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[1]} -radix decimal} {{/MER_TB/MEAS_DUT/LFSR_out[0]} -radix decimal}} -subitemconfig {{/MER_TB/MEAS_DUT/LFSR_out[21]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[20]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[19]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[18]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[17]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[16]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[15]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[14]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[13]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[12]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[11]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[10]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[9]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[8]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[7]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[6]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[5]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[4]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[3]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[2]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[1]} {-radix decimal} {/MER_TB/MEAS_DUT/LFSR_out[0]} {-radix decimal}} /MER_TB/MEAS_DUT/LFSR_out
add wave -noupdate -radix binary /MER_TB/MEAS_DUT/cycle
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/load
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/map_out
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/MUX_out_in
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/TX_out
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/RCV_out
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/MUX_out_out
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/dec_var
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/map_out_pwr
#add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/map_out_ref_lvl
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/ref_lvl
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/err_acc
#add wave -noupdate -radix unsigned /MER_TB/MEAS_DUT/slice
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/error
add wave -noupdate -radix decimal /MER_TB/MEAS_DUT/err_square
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {484026 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
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
WaveRestoreZoom {0 ps} {3268480 ps}
run 200000000
