#/home/tob208/engr-ece/Documents/EE465/3Deliverable

#procedure call
proc getScriptDirectory {} {
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set SIM_LEN 20000ns
#set SIM_LEN 9000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "GSM_tb"
set TB_Nam "filter_TB"
set EN "clk_en"
set MOD "GSM_101Mults"

pwd
puts [info script]
puts "Hello world"
puts [file normalize [info script]]
set string "script is: compileFilt.do"
puts $string
set string "MOD is: "
append string ${MOD}
puts $string
set string "TB is: "
append string $TB_MOD
puts $string

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB_MOD}.v
vlog -sv -work work ${SRC_DIR}/../../${MOD}.v
vlog -sv -work work ${SRC_DIR}/${EN}.v

vsim -t 1ns -L work ${TB_Nam}
do filtWave.do

run ${SIM_LEN}

