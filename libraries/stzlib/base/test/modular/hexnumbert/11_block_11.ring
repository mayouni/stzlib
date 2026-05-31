# Narrative
# --------
# */
#
# Extracted from stzhexnumbertTest.ring, block #11.

load "../../../stzBase.ring"

pr()

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

pf()
# Executed in 0.06 second(s).
