## Generated SDC file "filter_design.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version"

## DATE    "Thu Feb 11 11:24:48 2016"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {input_clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clock_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {system_clk} -source [get_ports {clock_50}] -divide_by 2 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[0]}] 
create_generated_clock -name {symbol_clk} -source [get_ports {clock_50}] -divide_by 32 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[4]}]
create_generated_clock -name {sample_clk} -source [get_ports {clock_50}] -divide_by 8 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[2]}]

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



#**************************************************************
# Set False Path
#**************************************************************



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

