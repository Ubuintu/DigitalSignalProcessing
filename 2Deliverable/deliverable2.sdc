# Clock constraints

create_clock -name "sys_clk" -period 20.000ns [get_ports {CLOCK_50}]
create_generated_clock -divide_by 2 -source [get_ports {CLOCK_50}] -name sampling_clk [get_registers {clk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

