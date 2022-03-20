load "stzlib.ring"

/*
? HexPrefixes()
? StzStringQ("x167A").RepresentsNumberInHexForm()
? HexToDecimal("x167A") # you get --> 5754
*/


StzHexNumberQ("x167A") {

	? Content()	#--> 167A
	# Same as WithoutPrefix()

	? WithPrefix()	#--> 0x167A
	# same as HexNumber()

	? ToDecimal() 	#--> 5754
	? ToBinary()	#--> 0b1011001111010
	? ToOctal()	#--> 0o13172

	SetHexPrefix("x")
	? WithPrefix()	#--> x167A

	//SetBinaryPrefix("b")
	? ToBinary()

}
/*---------------------

? IsUnicodeHex("U+214B")

? StringRepresentsNumberInHexform("E82")
o1 = new stzHexNumber("xE82")
? o1.Content()

/*---------------------

o1 = new stzHexNumber("")
o1.FromBinary("b10011")
? o1.Content()

? o1.ToOctal()
