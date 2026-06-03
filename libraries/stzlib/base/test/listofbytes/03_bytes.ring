# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzListOfBytes("مرحبا")

? @@( o1.Bytes() )
#--> [ " ", " ", " ", " ", " ", " ", " ", " ", " ", " " ]

? @@( o1.Bytecodes() )
#--> [ -39, -123, -40, -79, -40, -83, -40, -88, -40, -89 ]

? @@( o1.BytesPerChar() )
#--> [ [ "م", [ " ", " " ] ], [ "ر", [ " ", " " ] ], [ "ح", [ " ", " " ] ], [ "ب", [ " ", " " ] ], [ "ا", [ " ", " " ] ] ]

? @@( o1.BytecodesPerChar() )
#--> [ [ "م", [ -39, -123 ] ], [ "ر", [ -40, -79 ] ], [ "ح", [ -40, -83 ] ], [ "ب", [ -40, -88 ] ], [ "ا", [ -40, -89 ] ] ]

pf()
# Executed in 0.05 second(s)
