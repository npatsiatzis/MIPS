import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from mux_model import mux_model
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db


covered_XY = []
g_width = int(cocotb.top.g_width)

class crv_inputs(crv.Randomized):
	def __init__(self,x,y,sel):
		crv.Randomized.__init__(self)
		self.x = x
		self.y = y 
		self.sel = sel
		self.add_rand("x",list(range(2**g_width)))
		self.add_rand("y",list(range(2**g_width)))
		self.add_rand("sel",[0,1])

full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.a",xf = lambda dut : dut.i_A.value, bins = list(range(2**g_width)), at_least=1)
@CoverPoint("top.b",xf = lambda dut : dut.i_B.value, bins = list(range(2**g_width)), at_least=1)
@CoverPoint("top.sel",xf = lambda dut : dut.i_sel.value, bins = [0,1], at_least=1)
@CoverPoint("top.c",xf = lambda dut : dut.o_out.value, bins = list(range(2**g_width)), at_least=1)
@CoverCross("top.cross", items = ["top.sel","top.a","top.b"], at_least=1)
def io_cover(dut):
	covered_XY.append((dut.i_sel,dut.i_A.value,dut.i_B.value))


@cocotb.test()
def adder_randomised_test(dut):
	"""Coverage driven test-generation. Full A-B cross-coverage, Full C coverage"""
	
	inputs = crv_inputs(0,0,0)

	while(full != True):
		inputs.randomize()	#randomize object
		A = inputs.x
		B = inputs.y
		sel = inputs.sel

		while (sel,A,B) in covered_XY:
			inputs.randomize()	#randomize object
			A = inputs.x
			B = inputs.y
			sel = inputs.sel

		dut.i_A.value = A
		dut.i_B.value = B
		dut.i_sel.value = sel
  
		
		yield Timer(2)
		io_cover(dut)
		assert not (mux_model(sel,A,B) != dut.o_out.value)
		coverage_db["top.cross"].add_threshold_callback(notify_full, 100)
	coverage_db.export_to_xml(filename="coverage_mux2.xml")