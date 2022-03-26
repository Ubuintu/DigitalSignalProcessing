transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/filter_design.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/avg_err.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/avg_mag.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/mapper.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/slicer.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/PPS_filt_101.v}
vlog -vlog01compat -work work +incdir+/home/tob208/engr-ece/Documents/EE465/3Deliverable {/home/tob208/engr-ece/Documents/EE465/3Deliverable/GSM_101Mults.v}

