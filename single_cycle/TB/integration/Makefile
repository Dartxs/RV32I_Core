TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../RTL/RV32I_Core.v \
                  ../../RTL/Program_Counter.v \
                  ../../RTL/Instruction_Memory.v \
                  ../../RTL/Instruction_Decoder.v \
                  ../../RTL/Imm_Gen.v \
                  ../../RTL/Register_File.v \
                  ../../RTL/Control_Unit.v \
                  ../../RTL/ALU_Branch_Control.v \
                  ../../RTL/ALU.v \
                  ../../RTL/Branch_Unit.v \
                  ../../RTL/Data_Memory.v \
                  ../../RTL/Mem_Aligner.v \
                  ../../RTL/Writeback_MUX.v

TOPLEVEL = RV32I_Core
COCOTB_TEST_MODULES = test_core

export PYTHONPATH := $(abspath ..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim