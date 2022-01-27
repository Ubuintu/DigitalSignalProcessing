#procedure call
proc getScriptDirectory{} {
    set dispScriptFile [file normalize [info script]]
    puts info script
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}
set SIM_LEN 100000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "filter_tb"
set MOD "RCV_filt"

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB}.sv
vlog -sv -work work ${SRC_DIR}/${TB_MOD}.v

vsim -t 1ns -L work ${TB_MOD}
do wave.do

run ${SIM_LEN}
