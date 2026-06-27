TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../../RTL/Program_Counter.v 
TOPLEVEL = Program_Counter
COCOTB_TEST_MODULES = test_PC

export PYTHONPATH := $(abspath ../..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim