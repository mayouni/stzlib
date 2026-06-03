# Narrative
# --------
# FINDING SUBSTRINGS
#
# Extracted from stzlistofstringstest.ring, block #33.

load "../../stzBase.ring"


o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

? @@( o1.FindSubString("ring") )
#--> [ [ 1, [ 5, 14 ] ], [ 2, [ 1, 10, 19 ] ], [ 3, [ 5 ] ] ]

? @@( o1.FindSubStringXT("ring") )
#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1 ], [ 2, 10 ], [ 2, 19 ], [ 3, 5 ] ]

? @@( o1.FindTheseOccurrencesOfSubString([1, 3, 5 ], "ring") )
#--> [ [ 1, 5 ], [ 2, 1 ], [ 2, 19 ] ]
