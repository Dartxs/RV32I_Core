# RV32I Pipelined Processor

## Overview

Extends the single-cycle RV32I implementation into a classic 5-stage pipeline: Fetch, Decode, Execute, Memory, and Writeback. The design includes a complete hazard unit handling RAW data hazards through forwarding, load-use hazards through stall detection, and control hazards through predict not-taken branch prediction with pipeline flush on taken branches and unconditional jumps.

Compared to the single-cycle implementation, the pipelined design achieves a 2x improvement in clock frequency — from 50MHz to 100MHz.

## Architecture

### Pipeline Stages

| Stage | Module | Description |
|---|---|---|
| Fetch (F) | PC_Reg, PC_MUX, Instruction_Memory | Fetches instruction at current PC, computes PC+4 |
| Decode (D) | Instruction_Decoder, Imm_Gen, Register_File, Control_Unit, ALU_Branch_Control | Decodes instruction, reads registers, generates control signals and immediate |
| Execute (E) | ALU, Branch_Unit, Forwarding_MUX | Executes ALU operation, evaluates branches, applies forwarding |
| Memory (M) | Data_Memory, Mem_Aligner | Reads or writes data memory |
| Writeback (W) | Writeback_MUX, Register_File | Selects result and writes back to register file |

### Pipeline Registers

| Register | Carries |
|---|---|
| IF/ID | Instruction, PC, PC+4 |
| ID/EX | Register reads, immediate, PC, PC+4, rd, rs1, rs2, control signals |
| EX/MEM | ALU result, write data, rd, PC+4, control signals |
| MEM/WB | Read data, ALU result, rd, PC+4, control signals |

### Hazard Handling

**RAW Data Hazards — Forwarding**
The Hazard Unit detects when an instruction in EX needs a value being produced by an instruction in MEM or WB stage, and selects the correct forwarded value via MUXes at the ALU inputs. MEM forwarding takes priority over WB forwarding to ensure the most recent value is used.

**Load-Use Hazards — Stall**
When a load instruction is in EX stage and the immediately following instruction reads the loaded register, the hazard unit inserts one stall cycle: the PC and IF/ID register are held, and a bubble is inserted into ID/EX. After the stall, the data from memory is resolved and forwarded using previously mentioned RAW data hazard logic from the WB stage to the EX stage. 

**Control Hazards — Predict Not-Taken**
Branches and jumps are resolved in the EX stage. The pipeline assumes branches are not taken for simplicity and continues fetching sequentially. If a branch or jump is taken, the two incorrectly fetched instructions in IF and ID are flushed and the PC is redirected to the correct target. Not-taken branches incur no penalty cycles.

## Verification

Hazard unit and core verified using cocotb with Verilator. Most modules were copied from the single cycle with little to no modifications.

Integration test used three different programs to reflect the progression from no hazards -> RAW hazards only -> full hazards covered.

## Synthesis

Synthesized and implemented in Vivado 2025.2 targeting the **Nexys A7 (XC7A100T-CSG324)**.

### Timing

| Metric | Value |
|---|---|
| Clock | 100 MHz |
| Worst Negative Slack (WNS) | +0.122 ns |
| Worst Hold Slack (WHS) | +0.034 ns |
| Timing | All constraints met ✅ |

The critical path runs through the forwarding MUX select logic into the ALU adder chain — characteristic of a pipelined design with data forwarding. The 2x clock frequency improvement over the single-cycle design (50MHz → 100MHz) demonstrates the benefit of pipelining.

### Resource Utilization

| Resource | Used | Available | Utilization |
|---|---|---|---|
| LUTs (logic) | 2,111 | 63,400 | 3.33% |
| LUTs (memory) | 1,025 | 19,000 | 5.39% |
| Flip Flops | 1,678 | 126,800 | 1.32% |
| DSPs | 0 | 240 | 0.00% |

All memory implemented with distributed LUT RAM. Higher FF count compared to single-cycle to reflect the addition of pipeline registers.