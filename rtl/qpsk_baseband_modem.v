`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Complete educational baseband QPSK modem:
// input bits -> mapper -> additive I/Q channel -> hard-decision demapper.
//
// noise_i and noise_q are signed samples. In real hardware they may come from
// an ADC/channel model; in ModelSim they are driven by the testbench.
// This complete RTL block is synthesizable.
// -----------------------------------------------------------------------------
module qpsk_baseband_modem #(
    parameter integer WIDTH     = 16,
    parameter integer AMPLITUDE = 8192
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         in_valid,
    input  wire [1:0]                   in_bits,
    input  wire signed [WIDTH-1:0]      noise_i,
    input  wire signed [WIDTH-1:0]      noise_q,

    output wire signed [WIDTH-1:0]      tx_i,
    output wire signed [WIDTH-1:0]      tx_q,
    output wire signed [WIDTH:0]        channel_i,
    output wire signed [WIDTH:0]        channel_q,
    output wire                         tx_valid,

    output wire [1:0]                   out_bits,
    output wire                         out_valid
);

    qpsk_mapper #(
        .WIDTH(WIDTH),
        .AMPLITUDE(AMPLITUDE)
    ) u_mapper (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_bits(in_bits),
        .out_i(tx_i),
        .out_q(tx_q),
        .out_valid(tx_valid)
    );

    // One extra bit prevents overflow when two WIDTH-bit signed values are added.
    assign channel_i = {tx_i[WIDTH-1], tx_i} + {noise_i[WIDTH-1], noise_i};
    assign channel_q = {tx_q[WIDTH-1], tx_q} + {noise_q[WIDTH-1], noise_q};

    qpsk_demapper #(
        .WIDTH(WIDTH + 1)
    ) u_demapper (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(tx_valid),
        .in_i(channel_i),
        .in_q(channel_q),
        .out_bits(out_bits),
        .out_valid(out_valid)
    );

endmodule
