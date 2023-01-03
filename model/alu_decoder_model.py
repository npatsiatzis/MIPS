
def alu_decoder_model(op,func):
	if(op == 0):
		return "0010"
	elif(op == 1):
		return "0110"
	elif(op == 2):
		if(func == 32):
			return "0010"
		elif(func == 34):
			return "0110"
		elif(func == 36):
			return "0000"
		elif(func == 37):
			return "0001"
		elif(func == 42):
			return "0111"
		elif(func == 39):
			return "1100"
		else:
			return "XXXX"
	else:
		return "XXXX"