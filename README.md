# FPGA-Based QPSK Modem

This repository contains the design and simulation of a Gray-coded
Quadrature Phase Shift Keying (QPSK) modem using Verilog/SystemVerilog
and ModelSim.

## Main Features

- QPSK baseband mapper and demapper
- Gray-coded QPSK mapping
- Additive noise on the I and Q channels
- QPSK intermediate-frequency transmitter
- Coherent correlation-based QPSK receiver
- Self-checking ModelSim testbenches
- BER evaluation through an AWGN channel
- Research paper and simulation results

## QPSK Mapping

| Input bits | I | Q | Relative phase |
|---|---:|---:|---:|
| `00` | `+A` | `+A` | 45° |
| `01` | `-A` | `+A` | 135° |
| `11` | `-A` | `-A` | 225° |
| `10` | `+A` | `-A` | 315° |

The default baseband amplitude is `A = 8192`.

## Repository Structure

```text
rtl/        Synthesizable Verilog RTL modules
tb/         SystemVerilog testbenches
sim/        ModelSim simulation scripts
docs/       Research paper and documentation
results/    BER data and waveform figures
```

## RTL Modules

| File | Description |
|---|---|
| `qpsk_mapper.v` | Maps two input bits to signed I/Q values |
| `qpsk_demapper.v` | Recovers the two bits using hard-decision detection |
| `qpsk_baseband_modem.v` | Integrates the mapper, noise channel, and demapper |
| `qpsk_if_tx.v` | Generates QPSK IF samples |
| `qpsk_if_rx.v` | Recovers symbols using coherent correlation |
| `qpsk_if_loopback.v` | Connects the IF transmitter directly to the receiver |

## Testbenches

### 1. Noiseless baseband test

File:

```text
tb_qpsk_noiseless.sv
```

Purpose:

- Tests all four QPSK symbols
- Verifies mapper and demapper operation
- Uses zero noise
- Expected result: zero errors

Run in ModelSim:

```tcl
vsim work.tb_qpsk_noiseless
add wave -r sim:/tb_qpsk_noiseless/*
run -all
```

### 2. QPSK IF loopback test

File:

```text
tb_qpsk_if.sv
```

Purpose:

- Tests the QPSK IF transmitter and receiver
- Generates 16 samples per symbol
- Uses coherent correlation at the receiver
- Expected result: zero errors

Run in ModelSim:

```tcl
vsim work.tb_qpsk_if
add wave -r sim:/tb_qpsk_if/*
run -all
```

### 3. BER noise-sweep test

File:

```text
tb_qpsk_noise_sweep.sv
```

Purpose:

- Generates random QPSK symbols
- Adds approximate Gaussian noise to the I and Q channels
- Counts bit errors
- Calculates BER at several Eb/N0 values
- Writes the results to `ber_results.csv`

Run in ModelSim:

```tcl
vsim work.tb_qpsk_noise_sweep
run -all
```

## Simulation Results

The simulations verify:

- Correct Gray-coded QPSK mapping
- Correct recovery of all four QPSK symbols
- Correct IF transmitter and receiver operation
- Zero errors in the ideal loopback tests
- BER decreases as Eb/N0 increases

The BER results are stored in:

```text
results/ber_results.csv
```

Recommended waveform images:

```text
results/figures/qpsk_noiseless.png
results/figures/qpsk_if.png
results/figures/qpsk_noise.png
```

## Research Paper

The complete research paper should be stored in:

```text
docs/QPSK_FPGA_Paper.pdf
```

## Current Limitations

The current IF model assumes:

- Perfect carrier synchronization
- Perfect symbol timing
- No carrier-frequency offset
- No phase noise
- No pulse-shaping filter
- No RF front-end

Future work may include RRC filtering, carrier recovery, symbol timing
recovery, FPGA synthesis, and implementation on a physical FPGA board.

## Author

LKDD

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
