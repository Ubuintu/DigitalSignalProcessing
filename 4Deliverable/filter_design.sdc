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
create_clock -name {clk_en:EN_clk|sys_clk} -period 40.000 [get_registers {clk_en:EN_clk|sys_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

#create_generated_clock -name {system_clk} -source [get_ports {clock_50}] -divide_by 2 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[0]}] 
#create_generated_clock -name {symbol_clk} -source [get_ports {clock_50}] -divide_by 32 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[4]}]
#create_generated_clock -name {sample_clk} -source [get_ports {clock_50}] -divide_by 8 -master_clock {input_clock} [get_registers {EE465_filter_test:SRRC_test|clock_box:cb1|counter[2]}]

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
set_false_path -from [get_ports {ADC_DA[0] ADC_DA[1] ADC_DA[2] ADC_DA[3] ADC_DA[4] ADC_DA[5] ADC_DA[6] ADC_DA[7] ADC_DA[8] ADC_DA[9] ADC_DA[10] ADC_DA[11] ADC_DA[12] ADC_DA[13]}]
set_false_path -from [get_ports {ADC_DB[0] ADC_DB[1] ADC_DB[2] ADC_DB[3] ADC_DB[4] ADC_DB[5] ADC_DB[6] ADC_DB[7] ADC_DB[8] ADC_DB[9] ADC_DB[10] ADC_DB[11] ADC_DB[12] ADC_DB[13]}]
set_false_path -from [get_ports {KEY[0] KEY[1] KEY[2] KEY[3]}]
set_false_path -from [get_ports {SW[0] SW[1] SW[2] SW[3] SW[4] SW[5] SW[6] SW[7] SW[8] SW[9] SW[10] SW[11] SW[12] SW[13] SW[14] SW[15] SW[16] SW[17]}]

set_false_path -to [get_ports {ADC_CLK_A ADC_CLK_B DAC_CLK_A DAC_CLK_B DAC_DA[0] DAC_DA[1] DAC_DA[2] DAC_DA[3] DAC_DA[4] DAC_DA[5] DAC_DA[6] DAC_DA[7] DAC_DA[8] DAC_DA[9] DAC_DA[10] DAC_DA[11] DAC_DA[12] DAC_DA[13] DAC_DB[0] DAC_DB[1] DAC_DB[2] DAC_DB[3] DAC_DB[4] DAC_DB[5] DAC_DB[6] DAC_DB[7] DAC_DB[8] DAC_DB[9] DAC_DB[10] DAC_DB[11] DAC_DB[12] DAC_DB[13] DAC_WRT_A DAC_WRT_B LEDG[0] LEDG[1] LEDG[2] LEDG[3] LEDR[0] LEDR[1] LEDR[2] LEDR[3] LEDR[4] LEDR[5] LEDR[6] LEDR[7] LEDR[8] LEDR[9] LEDR[10] LEDR[11] LEDR[12] LEDR[13] LEDR[14] LEDR[15] LEDR[16] LEDR[17]}]


set_false_path -from [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_false_path -to [get_ports {altera_reserved_tdo}]
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

