TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../../RTL/Control_Unit.v
TOPLEVEL = Control_Unit
COCOTB_TEST_MODULES = test_control

export PYTHONPATH := $(abspath ../..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim