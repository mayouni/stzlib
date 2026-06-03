# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #30.
#ERR Error (R14) : Calling Method without definition: findnumbersassections

load "../../stzBase.ring"

pr()

o1 = new stzList([
	1, 2, 3,
	"A", "B", "C",
	7, 8,
	1:3, 4:8, 9:12,
	"D", "E",
	4:8,
	11, 12,
	NullObject(),
	TrueObject(),
	FalseObject()
])

? @@( o1.FindNumbersAsSections() ) # or FindNumbersZZ()
#--> [ [ 1, 3 ], [ 7, 8 ], [ 15, 16 ] ]

? @@( o1.FindStringsZZ() )
#--> [ [ 4, 6 ], [ 12, 13 ] ]

? @@( o1.FindListsZZ() )
#--> [ [ 9, 11 ], [ 14, 14 ] ]

? @@( o1.FindObjectsZZ() )
#--> [ [ 17, 19 ] ]

pf()
# Executed in 0.02 second(s)
