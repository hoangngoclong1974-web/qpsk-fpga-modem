transcript on
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work

vlog -work work ../rtl/qpsk_mapper.v
vlog -work work ../rtl/qpsk_demapper.v
vlog -work work ../rtl/qpsk_baseband_modem.v
vlog -sv -work work ../tb/tb_qpsk_noiseless.sv

vsim -voptargs=+acc work.tb_qpsk_noiseless
add wave -divider "CONTROL"
add wave sim:/tb_qpsk_noiseless/clk
add wave sim:/tb_qpsk_noiseless/rst_n
add wave sim:/tb_qpsk_noiseless/in_valid
add wave -radix binary sim:/tb_qpsk_noiseless/in_bits
add wave -divider "MAPPER AND CHANNEL"
add wave -radix decimal sim:/tb_qpsk_noiseless/tx_i
add wave -radix decimal sim:/tb_qpsk_noiseless/tx_q
add wave -radix decimal sim:/tb_qpsk_noiseless/channel_i
add wave -radix decimal sim:/tb_qpsk_noiseless/channel_q
add wave -divider "DEMODULATOR"
add wave sim:/tb_qpsk_noiseless/out_valid
add wave -radix binary sim:/tb_qpsk_noiseless/out_bits
run -all
wave zoom full
