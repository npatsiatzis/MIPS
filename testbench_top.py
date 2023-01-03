import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge,ClockCycles
from cocotb.binary import BinaryValue
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
import numpy as np


async def reset(dut,cycles=1):
	dut.i_rst.value = 1
	dut.i_PC.value = 0
	await RisingEdge(dut.i_clk)
	await ClockCycles(dut.i_clk,cycles)
	dut.i_rst.value = 0
	await RisingEdge(dut.i_clk)
	dut._log.info("the core was reset")



@cocotb.test()
async def memory_randomised_test(dut):
	"""Verify the behavior of the MIPS processor"""
	
	cocotb.start_soon(Clock(dut.i_clk, 5, units="ns").start())
	await reset(dut,1)

	await ClockCycles(dut.i_clk,50)
