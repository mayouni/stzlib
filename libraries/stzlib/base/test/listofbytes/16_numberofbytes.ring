# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #16.

load "../../stzBase.ring"

pr()

o1 = new stzListOfBytes("s㊱m")

o1 {
	? NumberOfBytes()
	#--> 5
	
	? @@( Bytecodes() )
	#--> [ 115, -29, -118, -79, 109 ]
	#TODO // Understand why some values are negative!

	? BytecodeOfByteN(5)
	#--> 109

	? NumberOfBytesInCharNumber(2)
	#--> 3

	? NumberOfBytesInChar("㊱")
	#--> 3

	? @@( BytesPerChar() )
	#--> [ [ "s", [ "s" ] ], [ "㊱", [ " ", " ", " " ] ], [ "m", [ "m" ] ] ]

	? @@( BytesOfCharNumber(2) )
	#--> [ " ", " ", " " ]

	? @@( BytesOfChar("㊱") )
	#--> [ " ", " ", " " ]

	# ? BitsPattern() // TODO

	? @@( NumberOfBytesPerChar() )
	#--> [ :s = 1, :㊱ = 3, :m = 1 ]

}

pf()
# Executed in 0.05 second(s) on Ring 1.21
# Executed in 0.12 second(s) on Ring 1.18
