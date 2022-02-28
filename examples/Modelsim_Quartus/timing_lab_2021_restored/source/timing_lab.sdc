#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
# faster clock for illustration purposes to test timing errors
#create_clock -name {CLOCK_50} -period 8.000 -waveform { 0.000 4.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {sys_clk} -source [get_ports {CLOCK_50}] -divide_by 2 -master_clock {CLOCK_50} [get_registers {EE456_QAM_Transmitter:mainSig|clock_box:clocks|counter[0]}] 
create_generated_clock -name {up8_clk_ena} -source [get_ports {CLOCK_50}] -divide_by 4 -master_clock {CLOCK_50} [get_registers {EE456_QAM_Transmitter:mainSig|clock_box:clocks|counter[1]}] 
create_generated_clock -name {sam_clk} -source [get_ports {CLOCK_50}] -divide_by 8 -master_clock {CLOCK_50} [get_registers {EE456_QAM_Transmitter:mainSig|clock_box:clocks|counter[2]}] 
create_generated_clock -name {sym_clk} -source [get_ports {CLOCK_50}] -divide_by 32 -master_clock {CLOCK_50} [get_registers {EE456_QAM_Transmitter:mainSig|clock_box:clocks|counter[4]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


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
#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

