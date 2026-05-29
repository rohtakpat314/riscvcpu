# RV32I Single-Cycle CPU

A single-cycle RISC-V CPU implementing the full RV32I base integer instruction 
set, built from ground up in SystemVerilog. 

## Architecture

The CPU implements a single-cycle datapath. Every instruction fetches, decodes, 
executes, and writes back within one clock cycle. All 47 RV32I base instructions 
are supported across all 6 instruction formats. Please refer to rohtak-patwardhan-rv32i.pdf for more. 

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

## File Structure

```
riscv32i/
├── src/          # RTL source files
├── tb/           # Testbenches
├── sim/          # Simulation output
└── docs/         # Reference documents
```

## Resources

All code is written independently. The following resources were referenced 
throughout the design and implementation process:

- _Computer Organization and Design RISC-V Edition_ by Patterson & Hennessy —
  primarily Chapter 2 and 4, and Diagrams 4.9–4.11 for datapath design
- [HDLBits](https://hdlbits.01xz.net/wiki/Main_Page) — for SystemVerilog syntax
- [Chuck's Tech Talk](https://youtu.be/Z7LHCMTc0gI) — for Logisim diagrams and
  microarchitecture visualization
- RV32I Reference Card — available in `docs/`, used for instruction encoding and
  immediate format reference

Rohtak Patwardhan, 2026 
