TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../../RTL/ALU.v
TOPLEVEL = ALU
COCOTB_TEST_MODULES = test_alu

export PYTHONPATH := $(abspath ../..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim