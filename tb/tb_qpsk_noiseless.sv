`timescale 1ns/1ps

module tb_qpsk_noiseless;

    localparam int WIDTH = 16;
    localparam int AMP   = 8192;

    logic clk;
    logic rst_n;
    logic in_valid;
    logic [1:0] in_bits;
    logic signed [WIDTH-1:0] noise_i;
    logic signed [WIDTH-1:0] noise_q;

    wire signed [WIDTH-1:0] tx_i;
    wire signed [WIDTH-1:0] tx_q;
    wire signed [WIDTH:0] channel_i;
    wire signed [WIDTH:0] channel_q;
    wire tx_valid;
    wire [1:0] out_bits;
    wire out_valid;

    int errors;

    qpsk_baseband_modem #(
        .WIDTH(WIDTH),
        .AMPLITUDE(AMP)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_bits(in_bits),
        .noise_i(noise_i),
        .noise_q(noise_q),
        .tx_i(tx_i),
        .tx_q(tx_q),
        .channel_i(channel_i),
        .channel_q(channel_q),
        .tx_valid(tx_valid),
        .out_bits(out_bits),
        .out_valid(out_valid)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic send_and_check(input logic [1:0] symbol);
        begin
            @(negedge clk);
            in_bits  = symbol;
            noise_i  = '0;
            noise_q  = '0;
            in_valid = 1'b1;

            @(negedge clk);
            in_valid = 1'b0;

            wait (out_valid === 1'b1);
            #1;

            if (out_bits !== symbol) begin
                $error("Mismatch: sent=%b received=%b", symbol, out_bits);
                errors++;
            end else begin
                $display("PASS: bits=%b  I=%0d  Q=%0d", symbol, tx_i, tx_q);
            end

            @(negedge clk);
        end
    endtask

    initial begin
        rst_n    = 1'b0;
        in_valid = 1'b0;
        in_bits  = 2'b00;
        noise_i  = '0;
        noise_q  = '0;
        errors   = 0;

        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        send_and_check(2'b00);
        send_and_check(2'b01);
        send_and_check(2'b11);
        send_and_check(2'b10);

        if (errors == 0)
            $display("NOISELESS TEST PASSED");
        else
            $fatal(1, "NOISELESS TEST FAILED: %0d errors", errors);

        #20;
        $finish;
    end

endmodule
