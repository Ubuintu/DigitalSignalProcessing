create_clock -name clk -period 20 [get_ports {clk}]
create_clock -name sys_clk -period 40 [get_ports {sys_clk}]
#create_clock -name sam_clk_en -period 160 [get_ports {sam_clk_en}]