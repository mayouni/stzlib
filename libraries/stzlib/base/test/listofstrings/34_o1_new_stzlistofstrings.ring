# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #34.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

? @@( o1.FindNFirstOccurrencesOfSubString(4, "ring") )
#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1], [ 2, 10 ] ]

? @@( o1.FindNLastOccurrencesOfSubString(3, "ring") )
#--> [ [ 2, 10 ], [ 2, 19 ], [ 3, 5 ] ]

pf()
