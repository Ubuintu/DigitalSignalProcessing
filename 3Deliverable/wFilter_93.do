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
add wave -noupdate -radix decimal /filter_TB/DUT/mult_out
add wave -noupdate -radix decimal /filter_TB/DUT/sum_lvl
#add wave -noupdate -radix decimal /filter_TB/DUT/i
#add wave -noupdate -radix decimal /filter_TB/DUT/j
#add wave -noupdate -radix decimal /filter_TB/DUT/Hsys
# DEBUG SUMLVL1
#add wave -noupdate  /filter_TB/DUT/sum_lvl[46]
#add wave -noupdate  /filter_TB/DUT/x[46]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[45]
#add wave -noupdate  /filter_TB/DUT/x[92]
# DEBUG SUMLVL2
#add wave -noupdate  /filter_TB/DUT/sum_lvl[47]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[69]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[70]
# DEBUG SUMLVL4
#add wave -noupdate  /filter_TB/DUT/sum_lvl[81]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[82]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[87]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[88]
# DEBUG SUMLVL7
#add wave -noupdate  /filter_TB/DUT/sum_lvl[92]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[93]
#add wave -noupdate  /filter_TB/DUT/sum_lvl[94]
add wave -noupdate -radix decimal /filter_TB/DUT/y
update
