proc getScriptDirectory {} {
    #set var via cmd sub; file gets abs path of cur script
    set dispScriptFile [file normalize [info script]]
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set SIM_LEN 50000000ns
#set SIM_LEN 50000ns
set SRC_DIR [getScriptDirectory]
set TB_MOD "LFSR_tb"
set CLKEN "clk_en"
set MOD "LFSR"

puts [info script]

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog -sv -work work ${SRC_DIR}/${TB_MOD}.sv
vlog -sv -work work ${SRC_DIR}/${CLKEN}.v
vlog -sv -work work ${SRC_DIR}/${MOD}.v

vsim -t 1ns -L work ${TB_MOD}
do wLFSR.do
set string "MOD is: "
append string ${MOD}
puts $string
set string "TB is: "
append string ${TB_MOD}
puts $string
set string "SIM LENGTH is: "
append string ${SIM_LEN}
puts $string
run ${SIM_LEN}

