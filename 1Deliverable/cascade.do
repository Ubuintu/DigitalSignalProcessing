#/home/tob208/engr-ece/Documents/EE465/1Deliverable

#procedure call
proc getScriptDirectory {} {
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set SIM_LEN 8000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "cascade_tb"
#set TX "TX_filt_MF"
set TX "TX_filt"
set RCV "RCV_filt"

puts [info script]
#puts "Hello world"
puts [file normalize [info script]]
set string "script is: cascade.do"
puts $string
set string "TX is: "
append string ${TX}
puts $string
set string "RCV is: "
append string ${RCV}
puts $string
set string "TB is: "
append string ${TB_MOD}
puts $string

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB_MOD}.sv
vlog -sv -work work ${SRC_DIR}/${TX}.v
vlog -sv -work work ${SRC_DIR}/${RCV}.v

vsim -t 1ns -L work ${TB_MOD}
do wave2.do

run ${SIM_LEN}
