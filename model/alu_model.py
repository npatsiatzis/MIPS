from cocotb.binary import BinaryValue


def alu_model(a, b, op, g_width):
	if(op == 0 ):

		and_op = a & b
		# a = bin(a)[2:]
		# if(len(a)< g_width):
		# 	diff = g_width - len(a)
		# 	a = '0'*diff + a


		# b = bin(b)[2:]
		# if(len(b)< g_width):
		# 	diff = g_width - len(b)
		# 	b = '0'*diff + b

		# and_op = ''
		# for i in range(len(a)):
		# 	and_op += str(int(a[i]) & int(b[i]))

		# and_op = '0'+str(and_op)
		and_op = BinaryValue(value=and_op,binaryRepresentation=0)
		return and_op.integer
	

	elif(op == 1):

		or_op = a | b;
		# a = bin(a)[2:]
		# if(len(a)< g_width):
		# 	diff = g_width - len(a)
		# 	a = '0'*diff + a


		# b = bin(b)[2:]
		# if(len(b)< g_width):
		# 	diff = g_width - len(b)
		# 	b = '0'*diff + b

		# or_op = ''
		# for i in range(len(a)):
		# 	or_op += str(int(a[i]) | int(b[i]))

		# or_op = '0'+str(or_op)
		or_op = BinaryValue(value=or_op,binaryRepresentation=0)
		return or_op.integer


	elif(op == 2):
		a = BinaryValue(str(a),binaryRepresentation=2)
		b = BinaryValue(str(b),binaryRepresentation=2)
		return a.integer + b.integer


	elif(op == 6):
		a = BinaryValue(str(a),binaryRepresentation=2)
		b = BinaryValue(str(b),binaryRepresentation=2)
		return a - b


	elif(op == 7):
		a = BinaryValue(str(a),binaryRepresentation=2)
		b = BinaryValue(str(b),binaryRepresentation=2)
		if(a.integer <b.integer):
			return 1
		else:
			return 0
	

	elif(op == 12):


		a = bin(a)[2:]
		if(len(a)< g_width):
			diff = g_width - len(a)
			a = '0'*diff + a


		b = bin(b)[2:]
		if(len(b)< g_width):
			diff = g_width - len(b)
			b = '0'*diff + b

		nor_op = ''
		for i in range(len(a)):
			nor = int(a[i]) | int(b[i])
			if(nor == 1):
				nor_op += '0'
			else:
				nor_op += '1'

		nor_op = '0'+str(nor_op)
		nor_op = BinaryValue(value=nor_op,binaryRepresentation=0)
		return nor_op.integer