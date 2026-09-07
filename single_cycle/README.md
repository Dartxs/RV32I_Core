# RV32I Single Cycle Processor

## Overview
 
This project implements the RV32I base integer instruction set architecture as a single-cycle processor. Every instruction is executed in one clock cycle, with a Harvard architecture separating instruction and data memory. The design was verified at both the module level and full CPU level before being synthesized and demonstrated on hardware.

## Architecture

- **Program Counter** — selects next PC from sequential, branch/JAL, or JALR sources
- **Instruction Memory** — 4KB byte-addressed ROM loaded from a `.mem` file
- **Instruction Decoder** — extracts opcode, funct3, funct7, rs1, rs2, rd, and immediate
- **Immediate Generator** — sign-extends immediates for I, S, B, U, and J-type instructions
- **Register File** — 32 x 32-bit registers with two read ports and one write port, x0 hardwired to 0
- **Control Unit** — generates control signals from opcode and branch_taken
- **ALU Branch Control** — maps funct3/funct7/opcode to ALU operation and branch condition
- **ALU** — supports ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- **Branch Unit** — evaluates BEQ, BNE, BLT, BGE, BLTU, BGEU conditions
- **Data Memory** — 8KB byte-addressed RAM with byte/halfword/word read and write support
- **Memory Aligner** — decodes funct3 and address offset into byte enables, alignment check, and sign flag
- **Writeback MUX** — selects writeback data from ALU result, memory, PC+4, or immediate

## Verification

Complex modules and core verified using cocotb with Verilator. 

## Synthesis

Synthesized and implemented in Vivado 2025.2 targeting the **Nexys A7 (XC7A100T-CSG324)**. 

### Timing
 
| Metric | Value |
|---|---|
| Clock | 50 MHz |
| Worst Negative Slack (WNS) | +0.339 ns |
| Worst Hold Slack (WHS) | +0.095 ns |
| Timing | All constraints met ✅ |
 
The critical path runs from the Program Counter through instruction memory, instruction decode, register file read, data memory, and writeback — as required by load instructions. 50MHz was required to meet timing due to this long path.

### Resource Utilization
 
| Resource | Used | Available | Utilization |
|---|---|---|---|
| LUTs (logic) | 2,021 | 63,400 | 3.19% |
| LUTs (memory) | 1,025 | 19,000 | 5.39% |
| Flip Flops | 1,116 | 126,800 | 0.88% |
| DSPs | 0 | 240 | 0.00% |

All memory implemented with distributed LUT RAM. 
