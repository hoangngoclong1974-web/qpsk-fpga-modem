`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Simple synthesizable QPSK intermediate-frequency transmitter.
// One QPSK symbol is represented by 16 carrier samples (one carrier period).
// The carrier lookup table amplitude is approximately 1024.
//
// s[n] = I*cos(w n) - Q*sin(w n), where I,Q are +1 or -1.
// This version is intended for education and coherent loopback simulation.
// -----------------------------------------------------------------------------
module qpsk_if_tx (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire [1:0]              symbol_in,
    input  wire                    symbol_valid,
    output reg                     ready,
    output reg signed [15:0]       sample_out,
    output reg                     sample_valid
);

    reg [1:0] symbol_reg;
    reg [3:0] phase_index;
    reg       active;

    reg signed [11:0] cos_value;
    reg signed [11:0] sin_value;
    reg signed [12:0] i_term;
    reg signed [12:0] q_term;

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

    always @(*) begin
        cos_value = cos_lut(phase_index);
        sin_value = sin_lut(phase_index);

        // bit[0] selects I sign, bit[1] selects Q sign.
        i_term = symbol_reg[0] ? -cos_value : cos_value;
        q_term = symbol_reg[1] ? -sin_value : sin_value;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            symbol_reg  <= 2'b00;
            phase_index <= 4'd0;
            active      <= 1'b0;
            ready       <= 1'b1;
            sample_out  <= 16'sd0;
            sample_valid <= 1'b0;
        end else begin
            sample_valid <= 1'b0;

            if (!active) begin
                ready <= 1'b1;

                if (symbol_valid) begin
                    symbol_reg  <= symbol_in;
                    phase_index <= 4'd0;
                    active      <= 1'b1;
                    ready       <= 1'b0;
                end
            end else begin
                sample_out   <= i_term - q_term;
                sample_valid <= 1'b1;

                if (phase_index == 4'd15) begin
                    phase_index <= 4'd0;
                    active      <= 1'b0;
                    ready       <= 1'b1;
                end else begin
                    phase_index <= phase_index + 4'd1;
                end
            end
        end
    end

endmodule
