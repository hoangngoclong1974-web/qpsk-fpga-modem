`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Simple coherent QPSK IF receiver matched to qpsk_if_tx.
// It correlates 16 received samples with local cosine and sine references.
// Exact symbol timing and exact carrier phase are assumed.
// This block is synthesizable; multiplications normally infer FPGA DSP blocks.
// -----------------------------------------------------------------------------
module qpsk_if_rx (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire signed [15:0]      sample_in,
    input  wire                    sample_valid,
    output reg [1:0]               bits_out,
    output reg                     bits_valid,
    output reg signed [31:0]       i_metric,
    output reg signed [31:0]       q_metric
);

    reg [3:0] sample_count;
    reg signed [31:0] acc_i;
    reg signed [31:0] acc_q;

    wire signed [11:0] cos_ref;
    wire signed [11:0] sin_ref;
    wire signed [27:0] product_i;
    wire signed [27:0] product_q;
    wire signed [31:0] next_i;
    wire signed [31:0] next_q;

    function signed [11:0] cos_lut;
        input [3:0] index;
        begin
            case (index)
                4'd0:  cos_lut =  12'sd1024;
                4'd1:  cos_lut =  12'sd946;
                4'd2:  cos_lut =  12'sd724;
                4'd3:  cos_lut =  12'sd392;
                4'd4:  cos_lut =  12'sd0;
                4'd5:  cos_lut = -12'sd392;
                4'd6:  cos_lut = -12'sd724;
                4'd7:  cos_lut = -12'sd946;
                4'd8:  cos_lut = -12'sd1024;
                4'd9:  cos_lut = -12'sd946;
                4'd10: cos_lut = -12'sd724;
                4'd11: cos_lut = -12'sd392;
                4'd12: cos_lut =  12'sd0;
                4'd13: cos_lut =  12'sd392;
                4'd14: cos_lut =  12'sd724;
                default: cos_lut = 12'sd946;
            endcase
        end
    endfunction

    function signed [11:0] sin_lut;
        input [3:0] index;
        begin
            case (index)
                4'd0:  sin_lut =  12'sd0;
                4'd1:  sin_lut =  12'sd392;
                4'd2:  sin_lut =  12'sd724;
                4'd3:  sin_lut =  12'sd946;
                4'd4:  sin_lut =  12'sd1024;
                4'd5:  sin_lut =  12'sd946;
                4'd6:  sin_lut =  12'sd724;
                4'd7:  sin_lut =  12'sd392;
                4'd8:  sin_lut =  12'sd0;
                4'd9:  sin_lut = -12'sd392;
                4'd10: sin_lut = -12'sd724;
                4'd11: sin_lut = -12'sd946;
                4'd12: sin_lut = -12'sd1024;
                4'd13: sin_lut = -12'sd946;
                4'd14: sin_lut = -12'sd724;
                default: sin_lut = -12'sd392;
            endcase
        end
    endfunction

    assign cos_ref  = cos_lut(sample_count);
    assign sin_ref  = sin_lut(sample_count);
    assign product_i = sample_in * cos_ref;
    assign product_q = sample_in * sin_ref;

    assign next_i = acc_i + {{4{product_i[27]}}, product_i};
    assign next_q = acc_q + {{4{product_q[27]}}, product_q};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_count <= 4'd0;
            acc_i        <= 32'sd0;
            acc_q        <= 32'sd0;
            bits_out     <= 2'b00;
            bits_valid   <= 1'b0;
            i_metric     <= 32'sd0;
            q_metric     <= 32'sd0;
        end else begin
            bits_valid <= 1'b0;

            if (sample_valid) begin
                if (sample_count == 4'd15) begin
                    // Tx uses s = I*cos - Q*sin.
                    // Therefore acc_i has the sign of I, while acc_q has
                    // the opposite sign of Q.
                    bits_out   <= {(next_q > 0), (next_i < 0)};
                    bits_valid <= 1'b1;
                    i_metric   <= next_i;
                    q_metric   <= next_q;

                    sample_count <= 4'd0;
                    acc_i        <= 32'sd0;
                    acc_q        <= 32'sd0;
                end else begin
                    sample_count <= sample_count + 4'd1;
                    acc_i        <= next_i;
                    acc_q        <= next_q;
                end
            end
        end
    end

endmodule
