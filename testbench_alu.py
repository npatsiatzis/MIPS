# Simple tests for an adder module
import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
from cocotb.binary import BinaryValue
from alu_model import alu_model
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
import enum


covered_XY = []
g_width = int(cocotb.top.g_width)


# @enum.unique
# class Ops(enum.IntEnum):
#     """Legal ops for the TinyALU"""
#     AND = 0
#     OR  = 1
#     ADD = 2
#     SUB = 6
#     SLT = 7
#     NOR = 12

class crv_inputs(crv.Randomized):
	def __init__(self,x,y,op):
		crv.Randomized.__init__(self)
		self.x = x
		self.y = y 
		self.op = op
		self.add_rand("x",list(range(-2**(g_width-1),2**(g_width-1))))
		self.add_rand("y",list(range(-2**(g_width-1),2**(g_width-1))))
		self.add_rand("op",[0,1,2,6,7,12])

full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.a",xf = lambda A,B,op : A, bins = list(range(-2**(g_width-1),2**(g_width-1))), at_least=1)
@CoverPoint("top.b",xf = lambda A,B,op : B, bins = list(range(-2**(g_width-1),2**(g_width-1))), at_least=1)
@CoverPoint("top.op",xf = lambda A,B,op : op, bins = [0,1,2,6,7,12], at_least=1)
@CoverCross("top.cross", items = ["top.a","top.b","top.op"], at_least=1)
def io_cover(A,B,op):
	covered_XY.append((A,B,op))


# @cocotb.test()
# async def test_add_sub(dut):
# 	A = -4 
# 	B = -5
# 	op = 12	
# 	for i in range(-2**(g_width-1),2**(g_width-1)):
# 		for j in range(-2**(g_width-1),2**(g_width-1)):

# 			dut.i_A.value = i
# 			dut.i_B.value = j
# 			dut.i_op.value = op
# 			await Timer(2)	
# 			o_out = BinaryValue(value=str(dut.o_out.value),binaryRepresentation=2)
# 			assert not (o_out.integer != alu_model(dut.i_A.value,dut.i_B.value,op,g_width))
# 			# print(o_out.integer)
# 			# print(alu_model(i,j,op))


@cocotb.test()
def alu_randomised_test(dut):
	"""Coverage driven test-generation. Full A-B cross-coverage, Full C coverage"""
	
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
		o_out = BinaryValue(value=str(dut.o_out.value),binaryRepresentation=2)
		assert not (o_out.integer != alu_model(dut.i_A.value,dut.i_B.value,op,g_width))
	coverage_db.report_coverage(cocotb.log.info,bins=True)
	coverage_db.export_to_xml(filename="coverage.xml")