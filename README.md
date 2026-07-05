# SDR SDRAM Controller on FPGA (Zybo)

A finite state machine (FSM) based SDR-SDRAM controller written in Verilog, targeting the Digilent Zybo (Zynq) board and verified through behavioral simulation in Vivado 2018.2.

## Overview

The controller drives an SDR-SDRAM device end-to-end: initialization (precharge, refresh, mode register load), burst write, burst read, and refresh. Once initialized, it idles until a read or write request is triggered by an on-board push button.

- **Burst Write:** Deterministic test data (`sdram_dq = f_addr + burst_index`) is written across SDRAM banks, with a column counter tracking write progress.
- **Burst Read:** Data read back from SDRAM is compared against the expected value; any mismatch increments an error counter.
- **Supporting Logic:** Button debouncing, a binary-to-BCD converter for displaying the error count, and LED status indicators.
- **Testbench:** A self-checking testbench with an internal SDRAM memory model that emulates ACTIVATE, WRITE, READ, PRECHARGE, and burst operations.

## Repository Structure

| File | Description |
|---|---|
| `sdram_top.v` | Top-level module — instantiates the controller, debounce, BCD, and clock-generator (`clk_wiz_0`) modules; contains the key-driven write/read FSM |
| `sdram_controller.v` | Core SDRAM controller FSM (init, activate, read/write burst, precharge, refresh) |
| `debounce_explicit.v` | Push-button debounce module |
| `bin2bcd.v` | Binary-to-BCD converter (used to display the error count on the seven-segment display) |
| `sdram_tb.v` | Testbench for the SDRAM controller with a behavioral SDRAM memory model |
| `top_tb.v` | Testbench for the top-level module |
| `sdram.xdc` | Xilinx constraints file (pin mapping / timing for the Zybo board) |
| `SDRAM_Controller_Simulation_Report.docx` | Simulation report with waveform analysis |

## Top-Level Interface (`sdram_top`)

```verilog
module sdram_top(
    input  clk, rst_n,
    input  [2:0] key,          // key[0]=write trigger, key[1]=read trigger, key[2]=data pattern select
    output [3:0] led,          // status LEDs

    // FPGA <-> SDRAM
    output sdram_clk,
    output sdram_cke,
    output sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n,
    output [12:0] sdram_addr,
    output [1:0]  sdram_ba,
    output [1:0]  sdram_dqm,
    inout  [15:0] sdram_dq
);
```

- `key[0]` (debounced) starts a burst write; `key[1]` starts a burst read; `key[2]` selects between two fixed data patterns (`0xAAAA` / `0x5555`) written during the write burst.
- `led[1:0]` indicate write status, `led[2]` read status, `led[3]` indicates a read-data mismatch (error).
- A clock-generator IP (`clk_wiz_0`) derives the internal operating clock (`CLK_OUT`) from the board clock and provides a `LOCKED` signal used to hold the design in reset until the PLL locks.

## Requirements

- Xilinx Vivado (2018.2 or later)
- Digilent Zybo (Zynq-7000) board — pin mapping defined in `sdram.xdc`
- An SDR-SDRAM chip (e.g. IS42S16400N ) — required only for hardware bring-up; not needed for simulation, since the testbench uses a behavioral memory model
- A Xilinx Clocking Wizard IP instance named `clk_wiz_0` (generate this in your Vivado project; it is not included as source)

## Simulation

1. Open the project in Vivado (or add all `.v` files to a new project).
2. Set `sdram_tb.v` or `top_tb.v` as the simulation top module.
3. Run behavioral simulation and inspect the waveform viewer for:
   - `sdram_addr`, `sdram_ba` — address/bank sequencing during activate, write, and precharge
   - `sdram_dq` — burst data transfer (`ZZZZ` = high-impedance, valid hex = active transfer)
   - `led` — write/read/error status
4. See `SDRAM_Controller_Simulation_Report.docx` for detailed waveform-by-waveform analysis of the initialization, burst-write, and precharge/bank-transition behavior.

## Hardware Bring-Up (Zybo)

1. Generate a Clocking Wizard IP core named `clk_wiz_0` matching the reference used in `sdram_top.v`.
2. Add `sdram.xdc` as the constraints file for pin assignment.
3. Synthesize, implement, and program the Zybo board.
4. Press the write key to run a burst write, then the read key to run a burst read and verify via the status LEDs (and error count on the display, if attached).
