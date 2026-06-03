# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #2.

load "../../stzBase.ring"


o1 = new stzListOfBytes("s㊱m")

? @@( o1.Bytes() )
#--> [ "s", " ", " ", " ", "m" ]

? @@( o1.Bytecodes() )
#--> [ 115, -29, -118, -79, 109 ]

? @@( o1.BytesPerChar() )
#--> [ [ "s", [ "s" ] ], [ "㊱", [ " ", " ", " " ] ], [ "m", [ "m" ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]

pf()
# Executed in 0.05 second(s)
