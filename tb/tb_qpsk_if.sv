`timescale 1ns/1ps

module tb_qpsk_if;

    logic clk;
    logic rst_n;
    logic [1:0] symbol_in;
    logic symbol_valid;

    wire ready;
    wire signed [15:0] tx_sample;
    wire tx_sample_valid;
    wire [1:0] bits_out;
    wire bits_valid;
    wire signed [31:0] i_metric;
    wire signed [31:0] q_metric;

    integer errors;
    integer n;
    logic [1:0] random_symbol;

    qpsk_if_loopback dut (
        .clk(clk),
        .rst_n(rst_n),
        .symbol_in(symbol_in),
        .symbol_valid(symbol_valid),
        .ready(ready),
        .tx_sample(tx_sample),
        .tx_sample_valid(tx_sample_valid),
        .bits_out(bits_out),
        .bits_valid(bits_valid),
        .i_metric(i_metric),
        .q_metric(q_metric)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic send_and_check(input logic [1:0] symbol);
        begin
            wait (ready === 1'b1);
            @(negedge clk);
            symbol_in    = symbol;
            symbol_valid = 1'b1;

            @(negedge clk);
            symbol_valid = 1'b0;

            wait (bits_valid === 1'b1);
            #1;

            if (bits_out !== symbol) begin
                $error("IF mismatch: sent=%b received=%b I_metric=%0d Q_metric=%0d",
                       symbol, bits_out, i_metric, q_metric);
                errors++;
            end else begin
                $display("IF PASS: sent=%b received=%b I_metric=%0d Q_metric=%0d",
                         symbol, bits_out, i_metric, q_metric);
            end

            @(negedge clk);
        end
    endtask

    initial begin
        rst_n       = 1'b0;
        symbol_in   = 2'b00;
        symbol_valid = 1'b0;
        errors      = 0;

        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        send_and_check(2'b00);
        send_and_check(2'b01);
        send_and_check(2'b11);
        send_and_check(2'b10);

        for (n = 0; n < 50; n = n + 1) begin
            random_symbol = $urandom_range(3, 0);
            send_and_check(random_symbol);
        end

        if (errors == 0)
            $display("IF QPSK TEST PASSED");
        else
            $fatal(1, "IF QPSK TEST FAILED: %0d errors", errors);

        #20;
        $finish;
    end

endmodule
