import cocotb
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
from alu_decoder_model import alu_decoder_model

covered = []
g_width_op = 2
g_width_func = 6

class crv_inputs(crv.Randomized):
	def __init__(self,alu_op,func):
		crv.Randomized.__init__(self)
		self.alu_op = alu_op
		self.func = func
		self.add_rand("alu_op",list(range(2**g_width_op)))
		self.add_rand("func",list(range(2**g_width_func)))


full = False
def notify_full():
	global full 
	full = True

#at_least = value is superfluous, just shows how you can determine the amount of times that
#a bin must be hit to considered covered
@CoverPoint("top.i_alu_op",xf = lambda dut : dut.i_alu_op.value, bins = list(range(2**g_width_op)), at_least=1)
@CoverPoint("top.i_func",xf = lambda dut : dut.i_func.value, bins = list(range(2**g_width_func)), at_least=1)
@CoverCross("top.cross", items = ["top.i_alu_op","top.i_func"], at_least=1)
def io_cover(dut):
	covered.append((dut.i_alu_op.value,dut.i_func.value))


@cocotb.test()
def adder_randomised_test(dut):
	"""Coverage driven test-generation. Full A-B cross-coverage, Full C coverage"""
	
	inputs = crv_inputs(0,0)

	while(full != True):
		inputs.randomize()	#randomize object
		op = inputs.alu_op
		func = inputs.func


		while (op,func) in covered:
			inputs.randomize()	#randomize object
			op = inputs.alu_op
			func = inputs.func


		dut.i_alu_op.value = op 
		dut.i_func.value = func
  
		
		yield Timer(2)
		io_cover(dut)
		assert not (alu_decoder_model(dut.i_alu_op.value,dut.i_func.value) != str(dut.o_alu_control.value))
		coverage_db["top.cross"].add_threshold_callback(notify_full, 100)
	coverage_db.export_to_xml(filename="coverage_alu_decoder.xml")