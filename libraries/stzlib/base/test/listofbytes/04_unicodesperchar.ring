# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzListOfBytes("RING")
? @@( o1.UnicodesPerChar() )
#--> [ [ "R", [ 82 ] ], [ "I", [ 73 ] ], [ "N", [ 78 ] ], [ "G", [ 71 ] ] ]

pf()
# Executed in 0.04 second(s)
