load "../stzlib.ring"

/*------


pron()

? HexPrefixes()
#--> [ "x", "0x", "U+" ]

? StzStringQ("x167A").RepresentsNumberInHexForm()
#--> TRUE

? HexToDecimal("x167A")
#--> 5754

proff()
# Executed in 0.02 second(s).

/*-------
*/
pron()

StzHexNumberQ("x167A") {

	? Content()	# Same as WithoutPrefix()
	#--> 167A
	
	? WithPrefix()	# same as HexNumber()
	#--> 0x167A
	
	? ToDecimal()
	#--> 5754

	? ToBinary()
	#--> 0b1011001111010

	? ToOctal()
	#--> 0o13172

	SetHexPrefix("x")
	? WithPrefix()
	#--> x167A

	SetBinaryPrefix("b")
	? ToBinary()
	#--> b1011001111010
}

proff()
# Executed in 0.06 second(s).

/*---------------------

pron()

? IsUnicodeHex("U+214B")
#--> TRUE

? StringRepresentsNumberInHexform("xE82")
#--> TRUE

o1 = new stzHexNumber("xE82")
? o1.Content()
#--> E82

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzHexNumber("")

o1.FromBinary("b10011")
? o1.Content()
#--> 0x13

? o1.ToOctal() # TODO check correctness

proff()
# Executed in 0.02 second(s).
