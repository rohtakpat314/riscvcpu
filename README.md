<p align="center">
<img src="banner.png" alt="RV32I Single-Cycle CPU">
</p>

<h1 align="center">RV32I Single-Cycle CPU</h1>

<p align="center">
A complete RV32I single-cycle CPU implemented from scratch in SystemVerilog.
</p>

<p align="center">
<img src="https://img.shields.io/badge/SystemVerilog-100%25-blue" alt="SystemVerilog">
<img src="https://img.shields.io/badge/license-MIT-green" alt="License">
<img src="https://img.shields.io/badge/status-complete-success" alt="Status">
<img src="https://img.shields.io/badge/FPGA-Cyclone%20V-orange" alt="Platform">
</p>

## Overview 

A single-cycle RISC-V CPU implementing the full RV32I base integer instruction 
set, built from ground up in SystemVerilog. Each instruction completes in one clock cycle.

The CPU implements a single-cycle datapath. Every instruction fetches, decodes, 
executes, and writes back within one clock cycle. All 47 RV32I base instructions 
are supported across all 6 instruction formats. Please refer to [rohtak-patwardhan-rv32i.pdf](rohtak-patwardhan-rv32i.pdf) for more.

## Synthesis

- **Board:** Quartus Cyclone V 5CGXFC7C7F23C8
- **Fmax:** 60.42 MHz
- **Critical-Path Delay:** 16.55ns
- **Combinational ALUT Ct.:** 1562 
- **Number of Adaptive Logic Modules (ALMs):** 2081 (~4% of board)
- **Dynamic Power:** 52mW

## Modules

| Module | Description |
|---|---|
| `pc.sv` | 32-bit program counter with synchronous reset |
| `instruction_mem.sv` | Read-only instruction memory, loads program from `.hex` file |
| `reg_file.sv` | 32x32 register file, 2 read ports, 1 write port, x0 hardwired to 0 |
| `alu.sv` | 32-bit ALU supporting all RV32I arithmetic, logical, and shift operations |
| `imm_gen.sv` | Immediate generator. Decodes all 5 immediate formats with sign extension |
| `control_unit.sv` | Decodes opcode/funct3/funct7 into datapath control signals |
| `data_mem.sv` | Data memory with full byte/half-word/word read and write support |
| `top.sv` | Top-level datapath, connects all modules and implements mux logic |

## Instruction Support

- **R-type:** ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, SLTU
- **I-type:** ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI, SLTIU, LB, LH, LW, LBU, LHU, JALR
- **S-type:** SB, SH, SW
- **B-type:** BEQ, BNE, BLT, BGE, BLTU, BGEU
- **U-type:** LUI, AUIPC
- **J-type:** JAL

## Resources

All code is written independently. The following resources were referenced 
throughout the design and implementation process:

- _Computer Organization and Design RISC-V Edition_ by Patterson & Hennessy —
  primarily Chapter 2 and 4, and Diagrams 4.9–4.11 for datapath design
- [HDLBits](https://hdlbits.01xz.net/wiki/Main_Page) - for SystemVerilog syntax
- [Chuck's Tech Talk](https://youtu.be/Z7LHCMTc0gI) - for Logisim diagrams and
  microarchitecture visualization
- [RISCV_CARD.pdf](RISCV_CARD.pdf) — used for instruction encoding and immediate format reference

Rohtak Patwardhan, 2026 
