from cocotb.binary import BinaryValue

def control_unit_model(opcode):
	if(opcode == 0):
		# control_bus = BinaryValue(value=str(011000010))
		# return str(control_bus.binstr)
		return "011000010"
	elif(opcode == 35):
		# control_bus = BinaryValue(value=str(110100100))
		# return str(control_bus.binstr)
		return "110100100"
	elif(opcode == 43):
		# control_bus = BinaryValue(value=str(00X101X00))
		# return str(control_bus.binstr)
		return "00X101X00"
	elif(opcode == 4):
		# control_bus = BinaryValue(value=str(00X010X01))
		# return str(control_bus.binstr)
		return "00X010X01"
	elif(opcode == 5):
		# control_bus = BinaryValue(value=str(00X010X01))
		# return str(control_bus.binstr)
		return "00X010X01"
	else:
		# control_bus = BinaryValue(value=str(XXXXXXXXX))
		# return str(control_bus.binstr)
		return "XXXXXXXXX"