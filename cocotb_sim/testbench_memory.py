import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge,ClockCycles
from cocotb.binary import BinaryValue
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
import numpy as np


covered_XY = []
g_depth = int(cocotb.top.g_depth)
g_width = int(cocotb.top.g_width)


class crv_inputs(crv.Randomized):
	def __init__(self,we,addr,data):
		crv.Randomized.__init__(self)
		self.we = we
		self.addr = addr
		self.data = data
		self.add_rand("we",[0,1])
		self.add_rand("addr",list(range(2**g_depth)))
		self.add_rand("data",list(range(2**g_width)))

full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.we",xf = lambda we,addr,data : we, bins = [0,1], at_least=1)
@CoverPoint("top.addr",xf = lambda we,addr,data : addr, bins = list(range(2**g_depth)), at_least=1)
@CoverPoint("top.data",xf = lambda we,addr,data : data, bins = list(range(2**g_width)), at_least=1)
@CoverCross("top.cross", items = ["top.we","top.addr","top.data"], at_least=1)
def io_cover(we,addr,data):
	covered_XY.append((we,addr,data))

async def reset(dut,cycles=1):
	dut.i_en.value = 0
	dut.i_we.value = 0
	dut.i_addr.value = 0
	dut.i_data.value = 0
	await ClockCycles(dut.i_clk,cycles)
	dut._log.info("the core was reset")

def randomize_ibus(inputs):
	inputs.randomize()	
	we = inputs.we
	addr = inputs.addr
	data = inputs.data
	return(we,addr,data)

def write_first_mem_model(mem,we,addr,data):
	if(we == 1):
		mem[addr] = data
		data_out = data 
	else:
		data_out = mem[addr]
	return data_out

@cocotb.test()
async def memory_randomised_test(dut):
	"""Verify the behavior of the memory"""
	
	cocotb.start_soon(Clock(dut.i_clk, 5, units="ns").start())
	await reset(dut,5)


	mem = np.zeros(2**g_depth,dtype=int)
	inputs = crv_inputs(0,0,0)
	data_out = 0
	dut.i_en.value = 1


	(we,addr,data) = randomize_ibus(inputs)
	dut.i_we.value = we
	dut.i_addr.value = addr
	dut.i_data.value = data
	await RisingEdge(dut.i_clk)
	data_out = write_first_mem_model(mem,we,addr,data)	
	io_cover(we,addr,data)
	coverage_db["top.cross"].add_threshold_callback(notify_full, 100)


	while(full != True):
		(we,addr,data) = randomize_ibus(inputs)

		while (we,addr,data) in covered_XY:
			(we,addr,data) = randomize_ibus(inputs)

		dut.i_we.value = we
		dut.i_addr.value = addr
		dut.i_data.value = data
		
		await RisingEdge(dut.i_clk)
		io_cover(we,addr,data)
		coverage_db["top.cross"].add_threshold_callback(notify_full, 100)

		old_data_out = data_out
		data_out = write_first_mem_model(mem,we,addr,data)

		assert not (old_data_out != int(dut.o_data.value))

	# coverage_db.report_coverage(cocotb.log.info,bins=True)
	coverage_db.export_to_xml(filename="coverage_memory.xml")