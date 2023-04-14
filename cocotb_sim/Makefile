# Makefile

# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl
EXTRA_ARGS += --std=08
SIM_ARGS += --wave=wave.ghw

VHDL_SOURCES += $(PWD)/../rtl/alu.vhd
VHDL_SOURCES += $(PWD)/../rtl/d_memory.vhd
VHDL_SOURCES += $(PWD)/../rtl/i_memory.vhd
VHDL_SOURCES += $(PWD)/../rtl/reg_file.vhd
VHDL_SOURCES += $(PWD)/../rtl/adder_32.vhd
VHDL_SOURCES += $(PWD)/../rtl/mux2.vhd
VHDL_SOURCES += $(PWD)/../rtl/mux2_bit.vhd
VHDL_SOURCES += $(PWD)/../rtl/shift2.vhd
VHDL_SOURCES += $(PWD)/../rtl/sign_extend.vhd
VHDL_SOURCES += $(PWD)/../rtl/control_unit.vhd
VHDL_SOURCES += $(PWD)/../rtl/alu_decoder.vhd
VHDL_SOURCES += $(PWD)/../rtl/top.vhd
VHDL_SOURCES += $(PWD)/../rtl/if_id.vhd
VHDL_SOURCES += $(PWD)/../rtl/id_ex.vhd
VHDL_SOURCES += $(PWD)/../rtl/ex_mem.vhd
VHDL_SOURCES += $(PWD)/../rtl/mem_wb.vhd
VHDL_SOURCES += $(PWD)/../rtl/forwarding_unit.vhd
VHDL_SOURCES += $(PWD)/../rtl/hazard_detection_unit.vhd
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
# MODULE is the basename of the Python test file

#PYTHPNPATH is an environment variable that can be set to additional directories
#where python will look for modules and packages
export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)

top:
		$(MAKE) sim MODULE=testbench_top TOPLEVEL=top

alu:
		$(MAKE) sim MODULE=testbench_alu TOPLEVEL=alu
		mv coverage_alu.xml coverage_results/coverage_alu.xml
memory:
		$(MAKE) sim MODULE=testbench_memory TOPLEVEL=d_memory
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

shift2:
		$(MAKE) sim MODULE=testbench_shift2 TOPLEVEL=shift2
		mv coverage_shift2.xml coverage_results/coverage_shift2.xml

sign_extend:
		$(MAKE) sim MODULE=testbench_sign_extend TOPLEVEL=sign_extend
		mv coverage_sign_extend.xml coverage_results/coverage_sign_extend.xml

control_unit:
		$(MAKE) sim MODULE=testbench_control_unit TOPLEVEL=control_unit
		mv coverage_control_unit.xml coverage_results/coverage_control_unit.xml

alu_decoder:
		$(MAKE) sim MODULE=testbench_alu_decoder TOPLEVEL=alu_decoder
		mv coverage_alu_decoder.xml coverage_results/coverage_alu_decoder.xml

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim