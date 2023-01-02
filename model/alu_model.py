from cocotb.binary import BinaryValue


def alu_model(a, b, op, g_width):
	if(op == 0 ):

		and_op = a & b
		and_op = BinaryValue(value=and_op,binaryRepresentation=0)
		return and_op.integer
	

	elif(op == 1):

		or_op = a | b;
		or_op = BinaryValue(value=or_op,binaryRepresentation=0)
		return or_op.integer


	elif(op == 2):
		a = BinaryValue(str(a),binaryRepresentation=0)
		b = BinaryValue(str(b),binaryRepresentation=0)
		res = (a.integer + b.integer) % 2**g_width
		c = BinaryValue(value=res,bigEndian=False,binaryRepresentation=0,n_bits=g_width)
		return c.integer


	elif(op == 6):
		B = 2**g_width - b.integer
		res = (a.integer + B) % 2**g_width
		c = BinaryValue(value=res,bigEndian=False,binaryRepresentation=0,n_bits=g_width)
		return c.integer


	elif(op == 7):
		a = BinaryValue(str(a),binaryRepresentation=0)
		b = BinaryValue(str(b),binaryRepresentation=0)
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

		nor_op = str(nor_op)
		nor_op = BinaryValue(value=nor_op,binaryRepresentation=0)
		return nor_op.integer