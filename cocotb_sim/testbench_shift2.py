import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db


covered = []
g_width = 10

class crv_inputs(crv.Randomized):
	def __init__(self,x):
		crv.Randomized.__init__(self)
		self.x = x
		self.add_rand("x",list(range(2**g_width)))
full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.data",xf = lambda dut : dut.i_data.value, bins = list(range(2**g_width)), at_least=1)
def io_cover(dut):
	covered.append(dut.i_data.value)


@cocotb.test()
def adder_randomised_test(dut):
	"""Coverage driven test-generation. Full A-B cross-coverage, Full C coverage"""
	
	inputs = crv_inputs(0)

	while(full != True):
		inputs.randomize()	#randomize object
		data = inputs.x


		while data in covered:
			inputs.randomize()	#randomize object
			data = inputs.x


		dut.i_data.value = data
  
		
		yield Timer(2)
		io_cover(dut)
		assert not (data << 2 != dut.o_shifted.value)
		coverage_db["top.data"].add_threshold_callback(notify_full, 100)
	coverage_db.export_to_xml(filename="coverage_shift2.xml")