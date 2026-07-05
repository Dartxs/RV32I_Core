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

### Supported Instructions

| Type | Instructions |
|---|---|
| R | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND |
| I (ALU) | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI |
| I (Load) | LW, LH, LHU, LB, LBU |
| S | SW, SH, SB |
| B | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| J | JAL, JALR |
| U | LUI, AUIPC |

## Verification

All modules were verified using [cocotb](https://www.cocotb.org/) with Verilator as the simulator.

## Synthesis

Synthesized and implemented in Vivado 2025.2 targeting the **Nexys A7 (XC7A100T-CSG324)**. 

| Metric | Value |
|---|---|
| Clock | 50 MHz |
| LUTs | 2,222 (~3.5% of available) |
| Timing | All constraints met (WNS = +0.271 ns) |
| Memory | Distributed RAM (combinational read) |

### FPGA Demo

The synthesized design includes a debug interface that allows register inspection directly on the board:

- **8-digit 7-segment display** shows the 32-bit value of the selected register in hexadecimal
- **LEDs [4:0]** show the currently selected register number in binary
- **Two buttons** cycle forward and backward through all 32 registers
- **CPU_RESETN** resets the processor

All register values were verified on hardware against the expected output of the test program.