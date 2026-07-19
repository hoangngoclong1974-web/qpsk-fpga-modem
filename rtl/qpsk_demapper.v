`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Coherent hard-decision QPSK baseband demapper.
// The decision boundaries are I = 0 and Q = 0.
// It uses the same Gray mapping as qpsk_mapper.
// This block is synthesizable.
// -----------------------------------------------------------------------------
module qpsk_demapper #(
    parameter integer WIDTH = 17
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         in_valid,
    input  wire signed [WIDTH-1:0]      in_i,
    input  wire signed [WIDTH-1:0]      in_q,
    output reg  [1:0]                   out_bits,
    output reg                          out_valid
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_bits  <= 2'b00;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;

            if (in_valid) begin
                // Sign of Q becomes MSB; sign of I becomes LSB.
                out_bits <= {in_q[WIDTH-1], in_i[WIDTH-1]};
            end
        end
    end

endmodule
