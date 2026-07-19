transcript on
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work

vlog -work work ../rtl/qpsk_if_tx.v
vlog -work work ../rtl/qpsk_if_rx.v
vlog -work work ../rtl/qpsk_if_loopback.v
vlog -sv -work work ../tb/tb_qpsk_if.sv

vsim -voptargs=+acc work.tb_qpsk_if
add wave -divider "INPUT"
add wave sim:/tb_qpsk_if/clk
add wave sim:/tb_qpsk_if/rst_n
add wave sim:/tb_qpsk_if/ready
add wave sim:/tb_qpsk_if/symbol_valid
add wave -radix binary sim:/tb_qpsk_if/symbol_in
add wave -divider "IF WAVEFORM"
add wave sim:/tb_qpsk_if/tx_sample_valid
add wave -radix decimal sim:/tb_qpsk_if/tx_sample
add wave -divider "CORRELATOR OUTPUT"
add wave -radix decimal sim:/tb_qpsk_if/i_metric
add wave -radix decimal sim:/tb_qpsk_if/q_metric
add wave sim:/tb_qpsk_if/bits_valid
add wave -radix binary sim:/tb_qpsk_if/bits_out
run -all
wave zoom full
