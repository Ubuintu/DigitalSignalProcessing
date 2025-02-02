#/home/tob208/engr-ece/Documents/EE465/Kickstarter

proc getScriptDirectory {} {
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}
set SIMULATION_LENGTH 100000ns
set SOURCE_DIR [getScriptDirectory]
#set TB_MODULE "filter_tb"
set TB_MODULE "tb_filter"
set MODULE "sine_filt"

puts $SOURCE_DIR

puts "Hello world"

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work

vmap work rtl_work

vlog -sv -work work ${SOURCE_DIR}/${MODULE}.v
vlog -sv -work work ${SOURCE_DIR}/${TB_MODULE}.sv

puts ${TB_MODULE}
vsim -t 1ns -L work ${TB_MODULE}

#do wave.do
do waave.do

run ${SIMULATION_LENGTH}
#run -all
