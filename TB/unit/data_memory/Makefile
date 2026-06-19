TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../../RTL/Data_Memory.v ../../../RTL/Mem_Aligner.v
TOPLEVEL = Data_Memory
COCOTB_TEST_MODULES = test_mem

export PYTHONPATH := $(abspath ../..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim