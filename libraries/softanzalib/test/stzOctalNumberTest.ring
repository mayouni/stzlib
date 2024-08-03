load "stzlib.ring"

// Converting from octal de decimal, binary, and hexadecimal
o1 = new stzOctalNumber("o2007")
? o1.OctalNumber() 	# Gives o2007

? o1.ToDecimal()	# Gives 1031
? o1.ToBinary()		# Gives b10000000111
? o1.ToHex()		# Gives x407
 ? ""
o1 = new stzOctalNumber("o0")

// Converting back to octal from decimal, binary, and hexadecimal
o1.FromDecimal(1031)
? o1.OctalNumber()	# Gives o2007

o1.FromHex("x407")
? o1.OctalNumber()	# Gives o2007

o1.FromBinary("b10000000111")
? o1.OctalNumber()	# Gives o2007

