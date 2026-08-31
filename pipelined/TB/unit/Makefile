TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = ../../RTL/Hazard_Unit.v 
TOPLEVEL = Hazard_Unit
COCOTB_TEST_MODULES = test_hazard

export PYTHONPATH := $(abspath ..):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim