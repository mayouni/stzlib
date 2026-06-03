# Narrative
# --------
# #narration CHARS, BYTES, UNICODE CODEPOINTS, AND BYTCODES
#
# Extracted from stzStringTest.ring, block #719.
#ERR exit 1: Line 79 Bad parameters value, error in length!

load "../../stzBase.ring"


pr()

# Are you confused between chars, bytes, unicodes (or unicode code points), and bytecodes?!
# Here how Softanza can help you see them all in clarity:

StzStringQ("s㊱m") {

	? Chars()
	#--> [ "s", "㊱", "m" ]

	? Unicodes()
	#--> [ 115, 12977, 109 ]

	? UnicodesPerChar()
	#--> [ [ "s", 115 ], [ "㊱", 12977 ], [ "m", 109 ] ]

	? SizeInBytes() #--> 435

	? @@( SizeInBytesPerChar() ) + NL
	#--> [ [ "s", 33 ], [ "㊱", 35 ], [ "m", 33 ] ]

	#--

	? Bytes()
	#--> [ "s", " ", " ", " ", "m" ]

	? @@( BytesPerChar() ) + NL
	#--> [ [ "s", [ "s" ] ], [ "㊱", [ " ", " ", " " ] ], [ "m", [ "m" ] ] ]

	? @@( NumberOfBytesPerChar() ) + NL
	#-->  [ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ]

	#--

	? Bytecodes()
	#--> [ 115, -29, -118, -79, 109 ]

	? @@( BytecodesPerChar() )
	#--> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]
}

pf()
# Executed in 0.07 second(s).
