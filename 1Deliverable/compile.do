#/home/tob208/engr-ece/Documents/EE465/1Deliverable

#procedure call
proc getScriptDirectory {} {
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set SIM_LEN 4000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "filter_tb"
set MOD "TX_filt_MF"
#set MOD "TX_filt"
#set MOD "RCV_filt"

puts [info script]
puts "Hello world"
puts [file normalize [info script]]

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB_MOD}.sv
vlog -sv -work work ${SRC_DIR}/${MOD}.v

vsim -t 1ns -L work ${TB_MOD}
do wave.do

run ${SIM_LEN}
