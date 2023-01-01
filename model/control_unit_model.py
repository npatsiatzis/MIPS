from cocotb.binary import BinaryValue

def control_unit_model(opcode):
	if(opcode == 0):
		return "011000010"
	elif(opcode == 35):
		return "110100100"
	elif(opcode == 43):
		return "00X101X00"
	elif(opcode == 4):
		return "00X010X01"
	elif(opcode == 5):
		return "00X010X01"
	else:
		return "XXXXXXXXX"