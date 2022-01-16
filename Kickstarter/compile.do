proc getResourceDirectory {} {
    variable myLocation
    return [file dirname $myLocation]
}

set SIMULATION_LENGTH 100ms
#set SOURCE_DIR [getResourceDirectory]
set SOURCE_DIR /home/tob208/engr-ece/Documents/EE465/Kickstarter
set TB_MODULE "filter_tb"

puts $SOURCE_DIR

puts "Hello world"

onerror {resume}
transcript on

if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work

vmap work rtl_work

vlog -sv -work work ${SOURCE_DIR}/*.v
vlog -sv -work work ${SOURCE_DIR}/*.sv

vsim -t 1ns -L work ${TB_MODULE}

do wave.do

run ${SIMULATION_LENGTH}
