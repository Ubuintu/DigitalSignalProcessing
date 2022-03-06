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
#set_false_path -from [get_ports ADC_DA*]
#set_false_path -from [get_ports ADC_DB*]
#set_false_path -from [get_ports KEY*]
#set_false_path -from [get_ports SW*]
set_false_path -from [get_ports {ADC_DA[0] ADC_DA[1] ADC_DA[2] ADC_DA[3] ADC_DA[4] ADC_DA[5] ADC_DA[6] ADC_DA[7] ADC_DA[8] ADC_DA[9] ADC_DA[10] ADC_DA[11] ADC_DA[12] ADC_DA[13]}]
set_false_path -from [get_ports {ADC_DB[0] ADC_DB[1] ADC_DB[2] ADC_DB[3] ADC_DB[4] ADC_DB[5] ADC_DB[6] ADC_DB[7] ADC_DB[8] ADC_DB[9] ADC_DB[10] ADC_DB[11] ADC_DB[12] ADC_DB[13]}]
set_false_path -from [get_ports {PHYS_KEY[0] PHYS_KEY[1] PHYS_KEY[2] PHYS_KEY[3]}]
set_false_path -from [get_ports {PHYS_SW[0] PHYS_SW[1] PHYS_SW[2] PHYS_SW[3] PHYS_SW[4] PHYS_SW[5] PHYS_SW[6] PHYS_SW[7] PHYS_SW[8] PHYS_SW[9] PHYS_SW[10] PHYS_SW[11] PHYS_SW[12] PHYS_SW[13] PHYS_SW[14] PHYS_SW[15] PHYS_SW[16] PHYS_SW[17]}]

## adding false path constraints to all output ports
#set_false_path -to [get_ports ADC_CLK_*]
#set_false_path -to [get_ports DAC_CLK_*]
#set_false_path -to [get_ports DAC_DA*]
#set_false_path -to [get_ports DAC_DB*]
#set_false_path -to [get_ports DAC_WRT*]
#set_false_path -to [get_ports LEDG*]
#set_false_path -to [get_ports LEDR*]
set_false_path -to [get_ports {ADC_CLK_A ADC_CLK_B DAC_CLK_A DAC_CLK_B DAC_DA[0] DAC_DA[1] DAC_DA[2] DAC_DA[3] DAC_DA[4] DAC_DA[5] DAC_DA[6] DAC_DA[7] DAC_DA[8] DAC_DA[9] DAC_DA[10] DAC_DA[11] DAC_DA[12] DAC_DA[13] DAC_DB[0] DAC_DB[1] DAC_DB[2] DAC_DB[3] DAC_DB[4] DAC_DB[5] DAC_DB[6] DAC_DB[7] DAC_DB[8] DAC_DB[9] DAC_DB[10] DAC_DB[11] DAC_DB[12] DAC_DB[13] DAC_WRT_A DAC_WRT_B LEDG[0] LEDG[1] LEDG[2] LEDG[3] LEDR[0] LEDR[1] LEDR[2] LEDR[3] LEDR[4] LEDR[5] LEDR[6] LEDR[7] LEDR[8] LEDR[9] LEDR[10] LEDR[11] LEDR[12] LEDR[13] LEDR[14] LEDR[15] LEDR[16] LEDR[17]}]


## My attempt of false path
#set_false_path -from [get_ports {ADC_DA[0] ADC_DA[1] ADC_DA[2] ADC_DA[3] ADC_DA[4] ADC_DA[5] ADC_DA[6] ADC_DA[7] ADC_DA[8] ADC_DA[9] ADC_DA[10] ADC_DA[11] ADC_DA[12] ADC_DA[13] ADC_DB[0] ADC_DB[1] ADC_DB[2] ADC_DB[3] ADC_DB[4] ADC_DB[5] ADC_DB[6] ADC_DB[7] ADC_DB[8] ADC_DB[9] ADC_DB[10] ADC_DB[11] ADC_DB[12] ADC_DB[13] PHYS_KEY[0] PHYS_KEY[1] PHYS_KEY[2] PHYS_KEY[3] PHYS_SW[0] PHYS_SW[1] PHYS_SW[2] PHYS_SW[3] PHYS_SW[4] PHYS_SW[5] PHYS_SW[6] PHYS_SW[7] PHYS_SW[8] PHYS_SW[9] PHYS_SW[10] PHYS_SW[11] PHYS_SW[12] PHYS_SW[13] PHYS_SW[14] PHYS_SW[15] PHYS_SW[16] PHYS_SW[17]}] -to [get_ports {ADC_CLK_A ADC_CLK_B DAC_CLK_A DAC_CLK_B DAC_DA[0] DAC_DA[1] DAC_DA[2] DAC_DA[3] DAC_DA[4] DAC_DA[5] DAC_DA[6] DAC_DA[7] DAC_DA[8] DAC_DA[9] DAC_DA[10] DAC_DA[11] DAC_DA[12] DAC_DA[13] DAC_DB[0] DAC_DB[1] DAC_DB[2] DAC_DB[3] DAC_DB[4] DAC_DB[5] DAC_DB[6] DAC_DB[7] DAC_DB[8] DAC_DB[9] DAC_DB[10] DAC_DB[11] DAC_DB[12] DAC_DB[13] DAC_WRT_A DAC_WRT_B LEDG[0] LEDG[1] LEDG[2] LEDG[3] LEDR[0] LEDR[1] LEDR[2] LEDR[3] LEDR[4] LEDR[5] LEDR[6] LEDR[7] LEDR[8] LEDR[9] LEDR[10] LEDR[11] LEDR[12] LEDR[13] LEDR[14] LEDR[15] LEDR[16] LEDR[17]}]

#set_false_path -from [get_ports {PHYS_SW[17] ADC_CLK_A ADC_CLK_B ADC_DA[0] ADC_DA[1] ADC_DA[2] ADC_DA[3] ADC_DA[4] ADC_DA[5] ADC_DA[6] ADC_DA[7] ADC_DA[8] ADC_DA[9] ADC_DA[10] ADC_DA[11] ADC_DA[12] ADC_DA[13] ADC_DB[0] ADC_DB[1] ADC_DB[2] ADC_DB[3] ADC_DB[4] ADC_DB[5] ADC_DB[6] ADC_DB[7] ADC_DB[8] ADC_DB[9] ADC_DB[10] ADC_DB[11] ADC_DB[12] ADC_DB[13] ADC_OEB_A ADC_OEB_B DAC_CLK_A DAC_CLK_B DAC_DA[0] DAC_DA[1] DAC_DA[2] DAC_DA[3] DAC_DA[4] DAC_DA[5] DAC_DA[6] DAC_DA[7] DAC_DA[8] DAC_DA[9] DAC_DA[10] DAC_DA[11] DAC_DA[12] DAC_DA[13] DAC_DB[0] DAC_DB[1] DAC_DB[2] DAC_DB[3] DAC_DB[4] DAC_DB[5] DAC_DB[6] DAC_DB[7] DAC_DB[8] DAC_DB[9] DAC_DB[10] DAC_DB[11] DAC_DB[12] DAC_DB[13] DAC_MODE DAC_WRT_A DAC_WRT_B LEDG[0] LEDG[1] LEDG[2] LEDG[3] LEDR[0] LEDR[1] LEDR[2] LEDR[3] LEDR[4] LEDR[5] LEDR[6] LEDR[7] LEDR[8] LEDR[9] LEDR[10] LEDR[11] LEDR[12] LEDR[13] LEDR[14] LEDR[15] LEDR[16] LEDR[17] PHYS_KEY[0] PHYS_KEY[1] PHYS_KEY[2] PHYS_KEY[3] PHYS_SW[0] PHYS_SW[1] PHYS_SW[2] PHYS_SW[3] PHYS_SW[4] PHYS_SW[5] PHYS_SW[6] PHYS_SW[7] PHYS_SW[8] PHYS_SW[9] PHYS_SW[10] PHYS_SW[11] PHYS_SW[12] PHYS_SW[13] PHYS_SW[14] PHYS_SW[15] PHYS_SW[16]}]
set_false_path -from [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_false_path -to [get_ports {altera_reserved_tdo}]