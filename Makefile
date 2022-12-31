# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
EXTRA_ARGS += --std=08
SIM_ARGS += --wave=wave.ghw

VHDL_SOURCES += $(PWD)/alu.vhd
VHDL_SOURCES += $(PWD)/memory.vhd
VHDL_SOURCES += $(PWD)/reg_file.vhd
VHDL_SOURCES += $(PWD)/adder_32.vhd
VHDL_SOURCES += $(PWD)/mux2.vhd
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# MODULE is the basename of the Python test file

#PYTHPNPATH is an environment variable that can be set to additional directories
#where python will look for modules and packages
export PYTHONPATH := $(PWD)/model:$(PYTHONPATH)

alu:
		$(MAKE) sim MODULE=testbench_alu TOPLEVEL=alu
		mv coverage_alu.xml coverage_results/coverage_alu.xml
memory:
		$(MAKE) sim MODULE=testbench_memory TOPLEVEL=memory
		mv coverage_memory.xml coverage_results/coverage_memory.xml
regfile:
		$(MAKE) sim MODULE=testbench_regfile TOPLEVEL=reg_file
		mv coverage_regfile.xml coverage_results/coverage_regfile.xml
adder32:
		$(MAKE) sim MODULE=testbench_adder32 TOPLEVEL=adder_32
		mv coverage_adder32.xml coverage_results/coverage_adder32.xml
mux2:
		$(MAKE) sim MODULE=testbench_mux2 TOPLEVEL=mux2
		mv coverage_mux2.xml coverage_results/coverage_mux2.xml

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim