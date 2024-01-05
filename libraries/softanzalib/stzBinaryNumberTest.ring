load "stzlib.ring"


/*-------------------

pron()

decimals(10)

	# Creating a binary number from a binary form

	o1 = new stzBinaryNumber("0b01110111100111010.11101111")

	? o1.FractionalPartToDecimalForm()
	#--> 0.93359375
	
	? o1.ToDecimalForm()
	#--> 31356143.93359375

decimals(2)

proff()
# Executed in 0.11 second(s)

/*-------------------
*/
pron()

// Creating a binary number from a decimal form

o1 = new stzBinaryNumber("")

o1.FromDecimal(127)
? o1.BinaryNumber()
#--> 0b1111111

proff()
# Executed in 0.07 second(s)

/*-------------------

pron()

// Creating a binary number from a hex form
o1 = new stzBinaryNumber("")

o1.FromHex("0x127")
? o1.BinaryNumber()
#--> 0b100100111

proff()
# Executed in 0.11 second(s)

/*-------------------

pron()

// Creating a binary number from an octal form
o1 = new stzBinaryNumber("")

o1.FromOctal("0o127")
? o1.BinaryNumber()
#--> 0b1010111

proff()

/*-------------------

pron()

// Converting a binary number to a decimal form
o1 = new stzBinaryNumber("0b1010111")

? o1.ToDecimal()
#--> 87

? o1.ToOctal()
#--> 0o127

? o1.ToHex()
#--> 0x57

proff()
# Executed in 0.09 second(s)
