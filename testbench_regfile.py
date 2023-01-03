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
	def __init__(self,we,data,addrA,addrB,waddr):
		crv.Randomized.__init__(self)
		self.we = we
		self.data = data
		self.addrA = addrA
		self.addrB = addrB
		self.waddr = waddr
		self.add_rand("we",[0,1])
		self.add_rand("data",list(range(2**g_width)))
		self.add_rand("addrA",list(range(2**g_depth)))
		self.add_rand("addrB",list(range(2**g_depth)))
		self.add_rand("waddr",list(range(2**g_depth)))

full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.we",xf = lambda we,data,addrA,addrB,waddr : we, bins = [0,1], at_least=1)
@CoverPoint("top.data",xf = lambda we,data,addrA,addrB,waddr : data, bins = list(range(2**g_width)), at_least=1)
# @CoverPoint("top.addrA",xf = lambda we,data,addrA,addrB,waddr : addrA, bins = list(range(2**g_depth)), at_least=1)
# @CoverPoint("top.addrB",xf = lambda we,data,addrA,addrB,waddr : addrB, bins = list(range(2**g_depth)), at_least=1)
@CoverPoint("top.waddr",xf = lambda we,data,addrA,addrB,waddr : waddr, bins = list(range(2**g_depth)), at_least=1)
@CoverCross("top.cross", items = ["top.waddr","top.data"], at_least=1)
def io_cover(we,data,addrA,addrB,waddr):
	covered_XY.append(((we,data,addrA,addrB,waddr)))

async def reset(dut,cycles=1):
	dut.i_rst.value = 1
	dut.i_we.value = 0
	dut.i_waddr.value=0
	dut.i_raddr_A.value = 0
	dut.i_raddr_B.value = 0
	dut.i_data.value = 0
	await ClockCycles(dut.i_clk,cycles)
	dut.i_rst.value = 0
	await RisingEdge(dut.i_clk)
	dut._log.info("the core was reset")

def randomize_ibus(inputs):
	inputs.randomize()	
	we = inputs.we
	addrA = inputs.addrA
	addrB = inputs.addrB
	data = inputs.data
	waddr = inputs.waddr
	return(we,data,addrA,addrB,waddr)

def write_first_mem_model(mem,we,data,waddr,addrA,addrB):
	
	data_outA = mem[addrA]
	data_outB = mem[addrB]

	if(we == 1):
		mem[waddr] = data
	return (data_outA,data_outB)

@cocotb.test()
async def memory_randomised_test(dut):
	"""Verify the behavior of the memory"""
	
	cocotb.start_soon(Clock(dut.i_clk, 5, units="ns").start())
	await reset(dut,5)


	# change accordingly if initialization of reg file changes
	mem = np.zeros(2**g_depth,dtype=int)
	for i in range(2**g_depth):
		mem[i] = i

	inputs = crv_inputs(0,0,0,0,0)
	data_outA = 0
	data_outB = 0


	(we,data,addrA,addrB,waddr) = randomize_ibus(inputs)
	dut.i_we.value = we
	dut.i_raddr_A.value = addrA
	dut.i_raddr_B.value = addrB
	dut.i_data.value = data
	dut.i_waddr.value = waddr
	await RisingEdge(dut.i_clk)
	io_cover(we,data,addrA,addrB,waddr)
	coverage_db["top.cross"].add_threshold_callback(notify_full, 100)
	(data_outA,data_outB) = write_first_mem_model(mem,we,data,waddr,addrA,addrB)	

	
	while(full != True):
		(we,data,addrA,addrB,waddr) = randomize_ibus(inputs)

		while (we,data,addrA,addrB) in covered_XY:
			(we,data,addrA,addrB,waddr) = randomize_ibups(inputs)

		dut.i_we.value = we
		dut.i_raddr_A.value = addrA
		dut.i_raddr_B.value = addrB
		dut.i_data.value = data
		dut.i_waddr.value = waddr
		
		await RisingEdge(dut.i_clk)
		io_cover(we,data,addrA,addrB,waddr)
		coverage_db["top.cross"].add_threshold_callback(notify_full, 100)

		old_data_outA = data_outA
		old_data_outB = data_outB
		(data_outA,data_outB) = write_first_mem_model(mem,we,data,waddr,addrA,addrB)

		assert not(data_outA != int(dut.o_data_A.value))
		assert not (data_outB != int(dut.o_data_B.value))

	# coverage_db.report_coverage(cocotb.log.info,bins=True)
	coverage_db.export_to_xml(filename="coverage_regfile.xml")