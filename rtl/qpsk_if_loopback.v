`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Coherent IF QPSK loopback used by the ModelSim demonstration.
// A real system would insert DAC/channel/ADC and synchronization blocks between
// the transmitter and receiver.
// -----------------------------------------------------------------------------
module qpsk_if_loopback (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire [1:0]              symbol_in,
    input  wire                    symbol_valid,
    output wire                    ready,
    output wire signed [15:0]      tx_sample,
    output wire                    tx_sample_valid,
    output wire [1:0]              bits_out,
    output wire                    bits_valid,
    output wire signed [31:0]      i_metric,
    output wire signed [31:0]      q_metric
);

    qpsk_if_tx u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .symbol_in(symbol_in),
        .symbol_valid(symbol_valid),
        .ready(ready),
        .sample_out(tx_sample),
        .sample_valid(tx_sample_valid)
    );

    qpsk_if_rx u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .sample_in(tx_sample),
        .sample_valid(tx_sample_valid),
        .bits_out(bits_out),
        .bits_valid(bits_valid),
        .i_metric(i_metric),
        .q_metric(q_metric)
    );

endmodule
