import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from cocotb.binary import BinaryValue
from alu_model import alu_model
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
import os

covered_XY = []
g_width = int(cocotb.top.g_width)


class crv_inputs(crv.Randomized):
	def __init__(self,x,y,op):
		crv.Randomized.__init__(self)
		self.x = x
		self.y = y 
		self.op = op
		self.add_rand("x",list(range(2**g_width)))
		self.add_rand("y",list(range(2**g_width)))
		self.add_rand("op",[0,1,2,6,7,12])

full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.a",xf = lambda A,B,op : A, bins = list(range(2**g_width)), at_least=1)
@CoverPoint("top.b",xf = lambda A,B,op : B, bins = list(range(2**g_width)), at_least=1)
@CoverPoint("top.op",xf = lambda A,B,op : op, bins = [0,1,2,6,7,12], at_least=1)
@CoverCross("top.cross", items = ["top.a","top.b","top.op"], at_least=1)
def io_cover(A,B,op):
	covered_XY.append((A,B,op))



@cocotb.test()
def alu_randomised_test(dut):
	"""Coverage driven test-generation. Full A-B-op cross-coverage, """
	
	inputs = crv_inputs(0,0,0)

	while(full != True):
		inputs.randomize()	
		A = inputs.x
		B = inputs.y
		op = inputs.op

		while (A,B) in covered_XY:
			inputs.randomize()	
			A = inputs.x
			B = inputs.y
			op = inputs.op

		dut.i_A.value = A
		dut.i_B.value = B
		dut.i_op.value = op
		
		yield Timer(2)
		io_cover(A,B,op)
		coverage_db["top.cross"].add_threshold_callback(notify_full, 100)
		assert not ((dut.o_out.value == 0) != (dut.o_zero.value == 1))
		assert not (dut.o_out.value != alu_model(dut.i_A.value,dut.i_B.value,op,g_width))
	coverage_db.export_to_xml(filename="coverage_alu.xml")