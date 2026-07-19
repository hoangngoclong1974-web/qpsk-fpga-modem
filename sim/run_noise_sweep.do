transcript on
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work

vlog -work work ../rtl/qpsk_mapper.v
vlog -work work ../rtl/qpsk_demapper.v
vlog -work work ../rtl/qpsk_baseband_modem.v
vlog -sv -work work ../tb/tb_qpsk_noise_sweep.sv

vsim -voptargs=+acc work.tb_qpsk_noise_sweep
run -all
