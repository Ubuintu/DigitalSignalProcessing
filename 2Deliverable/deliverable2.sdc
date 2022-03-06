# Clock constraints

create_clock -name {CLOCK_50} -period 20.000ns [get_ports {CLOCK_50}]
create_generated_clock -divide_by 2 -source [get_ports {CLOCK_50}] -name sampling_clk [get_registers {clk}]
# made this clock below
create_generated_clock -name {sys_clk} -source [get_ports {CLOCK_50}] -divide_by 2 -master_clock {CLOCK_50} [get_registers {clk_en:EN_CLK|sys_clk}]
# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

#**************************************************************
# Set False Path
#**************************************************************

## adding false path constraints to all input ports
set_false_path -from [get_ports ADC_DA*]
set_false_path -from [get_ports ADC_DB*]
set_false_path -from [get_ports KEY*]
set_false_path -from [get_ports SW*]

## adding false path constraints to all output ports
set_false_path -to [get_ports ADC_CLK_*]
set_false_path -to [get_ports DAC_CLK_*]
set_false_path -to [get_ports DAC_DA*]
set_false_path -to [get_ports DAC_DB*]
set_false_path -to [get_ports DAC_WRT*]
set_false_path -to [get_ports LEDG*]
set_false_path -to [get_ports LEDR*]