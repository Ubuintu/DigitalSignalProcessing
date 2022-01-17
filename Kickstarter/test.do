# EE 465 Modelsim compilation script
# Instructions: 1.  Set the variables below to values appropriate for your design.
#                   The rest of the script should work correctly without any modifications.
#               2.  In Modelsim, navigate to the location of this script.
#                   (File menu -> Change Directory) or use 'cd' commands.
#               3.  Run 'do compile.do' on the Modelsim console.
#               4.  Add signals to waveform viewer as desired.
#               5.  Save waveform set up file as 'wave.do' using 'Save format...' from the file menu.
#                   Place it in the same directory as the compile.do file (this file).
#               6.  After adding signals, you may need to rerun 'do compile.do' to get the values to show up.
#               7.  Use the waveform window to debug your design as desired.

# Variables to configure
set SIMULATION_LENGTH 10ms
# this variable should held the path to where you saved your source files
set SOURCE_DIR "/home/tob208/engr-ece/Documents/EE465/Kickstarter"
set TB_DIR "/home/tob208/engr-ece/Documents/EE465/Kickstarter"
# specify name of tb module to run as the top level simulation
set TB_MODULE "test_tb"

# End of variables to configure

# continue running if an error occurs
onerror {resume}
# save output from modelsim console window into a transcript file
transcript on

# set up compilation library; if the rtl_library already exists, delete it
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
# recreate the library
vlib rtl_work
# map the virtual library
vmap work rtl_work

# compile source files
vlog -sv -work work ${SOURCE_DIR}/sine_filt.v

# compile tb file
vlog -sv -work work ${TB_DIR}/${TB_MODULE}.v

# initialize simulation
# add other libraries if necessary with -L lib_name
# -t sets up the timescale
# if simulating megafunctions, add libraries specified by Quartus
vsim -t 1ns -L work ${TB_MODULE}

# open waveform viewer and populate with saved list of signals
do waaave.do

# run simulation for specified amount of time
run ${SIMULATION_LENGTH}
