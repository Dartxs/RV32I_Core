# RV32I Core
 
A progression of RV32I processor implementations in Verilog, starting from a single-cycle design and advancing to a fully pipelined implementation with hazard handling. Both designs are verified with cocotb testbenches and synthesized on a Nexys A7 FPGA.


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

## Implementations
 
### [Single-Cycle](./single_cycle/README.md)
A complete single-cycle RV32I processor where every instruction executes in one clock cycle. Verified with module-level unit tests and a full integration test covering 37 integer instructions. Synthesized at 50MHz on the Nexys A7.
 
### [Pipelined](./pipelined/README.md)
A 5-stage pipelined extension of the single-cycle design with full hazard handling — RAW data forwarding, load-use stall detection, and predict not-taken branch prediction with pipeline flush on taken branches and unconditional jumps. Synthesized at 100MHz on the Nexys A7, achieving a 2x clock frequency improvement over the single-cycle design.
 
## Comparison
 
| Metric | Single-Cycle | Pipelined |
|---|---|---|
| Clock | 50 MHz | 100 MHz |
| WNS | +0.339 ns | +0.122 ns |
| LUTs (logic) | 2,021 | 2,111 |
| Flip Flops | 1,116 | 1,678 |
| Hazard Handling | N/A | Forwarding, stall, flush |
 
## Toolchain
 
| Tool | Purpose |
|---|---|
| Verilog | RTL implementation |
| [cocotb](https://www.cocotb.org/) | Python-based testbenches |
| [Verilator](https://www.veripool.org/verilator/)| Simulation |
| Vivado 2025.2 | Synthesis and implementation |
| Nexys A7 (XC7A100T) | Target FPGA |
| RISC-V GCC | Assembly and linking |
| [Venus](https://venus.kvakil.me/) | RISC-V assembly simulation |


### FPGA Demo

The synthesized design includes a debug interface that allows register inspection directly on the board. A subdirectory in each of the RTL directories holds required modules along with the topper to allow the following functionalities:

- **8-digit 7-segment display** shows the 32-bit value of the selected register in hexadecimal
- **LEDs [4:0]** show the currently selected register number in binary
- **Two buttons** cycle forward and backward through all 32 registers
- **CPU_RESETN** resets the processor

IO ports are constrained as false paths so the timing results reflect the core logic for the respective implementations rather than board-level IO delays.