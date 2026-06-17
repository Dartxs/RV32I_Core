TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../../RTL/Branch_Unit.v
TOPLEVEL = Branch_Unit
COCOTB_TEST_MODULES = test_branch

export PYTHONPATH := $(abspath ../..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim