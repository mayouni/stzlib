# Narrative
# --------
# The ...AsSections / ...ZZ family: runs of each TYPE as [start, end]
# sections.
#
# On a richly mixed list (numbers, strings, sublists, and objects), each
# finder groups the consecutive positions of one type:
#   FindNumbersAsSections (= FindNumbersZZ) -> [ [1,3], [7,8], [15,16] ]
#   FindStringsZZ -> [ [4,6], [12,13] ]
#   FindListsZZ   -> [ [9,11], [14,14] ]   (the ranges 1:3, 4:8, 9:12, 4:8)
#   FindObjectsZZ -> [ [17,19] ]            (Null/True/False objects)
#
# Extracted from stzlisttest.ring, block #30.

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
# Executed in almost 0 second(s)
