# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #7.

load "../../stzBase.ring"

pr()

o1 = new stzListOfBytes("mЖ丽")
? o1.NumberOfBytes()
#--> 6

? @@( o1.Bytecodes() )
#--> [ 109, -48, -106, -28, -72, -67 ]
	
? @@( o1.NumberOfBytesPerChar() )
#--> [ [ "m", 1 ], [ "Ж", 2 ], [ "丽", 3 ] ]

? o1.NLeftBytes(3) # Or 3LeftBytes()
#--> mЖ

? o1.NRightBytes(3) # Or 3RightBytes()
#--> 丽

pf()
#--> Executed in 0.03 second(s) in Ring 1.21
#--> Executed in 0.08 second(s) in Ring 1.19
