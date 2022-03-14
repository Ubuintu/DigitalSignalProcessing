onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /filter_TB/x_in
add wave -noupdate -radix decimal /filter_TB/y
add wave -noupdate -radix decimal /filter_TB/rst
add wave -noupdate -radix decimal /filter_TB/clk_50
add wave -noupdate -radix binary /filter_TB/EN_CLK/sys_clk
add wave -noupdate -radix binary /filter_TB/EN_CLK/sam_clk_en
add wave -noupdate -radix decimal /filter_TB/DUT/x_in
add wave -noupdate -radix decimal /filter_TB/DUT/x
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl
#add wave -noupdate -radix decimal /filter_TB/DUT/i
#add wave -noupdate -radix decimal /filter_TB/DUT/j
add wave -noupdate -radix decimal /filter_TB/DUT/mult_out
#add wave -noupdate -radix decimal /filter_TB/DUT/Hsys
add wave -noupdate -radix decimal /filter_TB/DUT/y
#add wave -noupdate  /filter_TB/DUT/sum_lvl[46]
#add wave -noupdate  /filter_TB/DUT/x[46]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[45]
add wave -noupdate  /filter_TB/DUT/x[92]
update
