`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Gray-coded QPSK baseband mapper
// Mapping:
//   bits  I       Q       phase
//   00    +A      +A       45 deg
//   01    -A      +A      135 deg
//   11    -A      -A      225 deg
//   10    +A      -A      315 deg
//
// bit[0] controls the sign of I; bit[1] controls the sign of Q.
// This block is synthesizable.
// -----------------------------------------------------------------------------
module qpsk_mapper #(
    parameter integer WIDTH     = 16,
    parameter integer AMPLITUDE = 8192
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         in_valid,
    input  wire [1:0]                   in_bits,
    output reg  signed [WIDTH-1:0]      out_i,
    output reg  signed [WIDTH-1:0]      out_q,
    output reg                          out_valid
);

    localparam signed [WIDTH-1:0] AMP = AMPLITUDE;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_i     <= {WIDTH{1'b0}};
            out_q     <= {WIDTH{1'b0}};
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;

            if (in_valid) begin
                out_i <= in_bits[0] ? -AMP : AMP;
                out_q <= in_bits[1] ? -AMP : AMP;
            end
        end
    end

endmodule
