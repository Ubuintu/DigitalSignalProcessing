proc getScriptDirectory {} {
    #set var via cmd sub; file gets abs path of cur script
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

#set SIM_LEN 50000000ns
set SIM_LEN 5000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "avg_err_tb"
set LFSR "LFSR"
set CLKEN "clk_en"
set AVGERR "avg_err"

puts [info script]

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB_MOD}.sv
vlog -sv -work work ${SRC_DIR}/${LFSR}.v
vlog -sv -work work ${SRC_DIR}/${CLKEN}.v
vlog -sv -work work ${SRC_DIR}/${AVGERR}.v

vsim -t 1ns -L work ${TB_MOD}
do wAVGERR.do
set string "testing average error circuit "

run ${SIM_LEN}
