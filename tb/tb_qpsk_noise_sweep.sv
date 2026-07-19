`timescale 1ns/1ps

// Simulation-only AWGN-like testbench.
// Gaussian noise is approximated by summing 12 uniform random variables.
// The RTL design remains fully synthesizable; only this testbench is not.
module tb_qpsk_noise_sweep;

    localparam int WIDTH = 16;
    localparam int AMP   = 8192;
    localparam int SYMBOLS_PER_POINT = 20000;

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

    integer bit_errors;
    integer total_bits;
    integer csv_file;
    integer k;
    integer sigma;
    integer ni;
    integer nq;
    logic [1:0] current_symbol;
    real ber;
    real ebn0_db;

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

    function automatic integer gaussian_noise(input integer sigma_value);
        integer j;
        integer uniform_sum;
        integer centered;
        begin
            // Sum of 12 U[0,1023] values: mean=6138, std.dev. approximately 1024.
            uniform_sum = 0;
            for (j = 0; j < 12; j = j + 1)
                uniform_sum = uniform_sum + $urandom_range(1023, 0);

            centered = uniform_sum - 6138;
            gaussian_noise = (centered * sigma_value) / 1024;
        end
    endfunction

    function automatic signed [WIDTH-1:0] clip_to_width(input integer value);
        integer max_value;
        integer min_value;
        begin
            max_value = (1 << (WIDTH-1)) - 1;
            min_value = -(1 << (WIDTH-1));

            if (value > max_value)
                clip_to_width = max_value;
            else if (value < min_value)
                clip_to_width = min_value;
            else
                clip_to_width = value;
        end
    endfunction

    task automatic send_symbol_with_noise(
        input logic [1:0] symbol,
        input integer sigma_value
    );
        begin
            ni = gaussian_noise(sigma_value);
            nq = gaussian_noise(sigma_value);

            @(negedge clk);
            in_bits  = symbol;
            noise_i  = clip_to_width(ni);
            noise_q  = clip_to_width(nq);
            in_valid = 1'b1;

            @(negedge clk);
            in_valid = 1'b0;

            // Keep noise stable until the corresponding symbol is demapped.
            wait (out_valid === 1'b1);
            #1;

            bit_errors = bit_errors + (out_bits[1] != symbol[1]);
            bit_errors = bit_errors + (out_bits[0] != symbol[0]);
            total_bits = total_bits + 2;

            @(negedge clk);
        end
    endtask

    task automatic run_point(input integer sigma_value);
        begin
            bit_errors = 0;
            total_bits = 0;

            for (k = 0; k < SYMBOLS_PER_POINT; k = k + 1) begin
                current_symbol = $urandom_range(3, 0);
                send_symbol_with_noise(current_symbol, sigma_value);
            end

            ber = bit_errors * 1.0 / total_bits;
            // For each I/Q branch: BER = Q(A/sigma), and Eb/N0 = A^2/(2 sigma^2).
            ebn0_db = 10.0 * $ln((AMP * 1.0 * AMP) /
                       (2.0 * sigma_value * sigma_value)) / $ln(10.0);

            $display("sigma=%0d  Eb/N0=%0.3f dB  errors=%0d/%0d  BER=%0.8f",
                     sigma_value, ebn0_db, bit_errors, total_bits, ber);
            $fdisplay(csv_file, "%0d,%0.6f,%0d,%0d,%0.10f",
                      sigma_value, ebn0_db, bit_errors, total_bits, ber);
        end
    endtask

    initial begin
        rst_n    = 1'b0;
        in_valid = 1'b0;
        in_bits  = 2'b00;
        noise_i  = '0;
        noise_q  = '0;

        csv_file = $fopen("ber_results.csv", "w");
        if (csv_file == 0)
            $fatal(1, "Cannot create ber_results.csv");
        $fdisplay(csv_file, "sigma,ebn0_db,bit_errors,total_bits,ber");

        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        // Approximate Eb/N0 points: 0, 2, 4, 6 and 8 dB for AMP=8192.
        run_point(5793);
        run_point(4601);
        run_point(3655);
        run_point(2903);
        run_point(2306);

        $fclose(csv_file);
        $display("BER SWEEP COMPLETE. Results written to ber_results.csv");
        #20;
        $finish;
    end

endmodule
