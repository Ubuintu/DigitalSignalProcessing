project compileall
vsim -L cycloneive_ver -L altera_mf_ver -L altera_ver work.deliverable2_testbench
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /deliverable2_testbench/CLOCK_50
add wave -noupdate /deliverable2_testbench/sys_clk
add wave -noupdate /deliverable2_testbench/sam_clk_en
add wave -noupdate /deliverable2_testbench/sym_clk_en
update
WaveRestoreZoom {0 ps} {604092632 ps}
run -500
