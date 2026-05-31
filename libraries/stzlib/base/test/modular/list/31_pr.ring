# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #31.

load "../../../stzBase.ring"


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

? o1.TypesU()
#--> [ "NUMBER", "STRING", "LIST", "OBJECT" ]

? @@XT( o1.ItemsAndTheirTypes(), NL, ("#" + TAB) ) + NL
#--> [
#	[ 1, "NUMBER" ],
#	[ 2, "NUMBER" ],
#	[ 3, "NUMBER" ],
#	[ "A", "STRING" ],
#	[ "B", "STRING" ],
#	[ "C", "STRING" ],
#	[ 7, "NUMBER" ],
#	[ 8, "NUMBER" ],
#	[ [ 1, 2, 3 ], "LIST" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ [ 9, 10, 11, 12 ], "LIST" ],
#	[ "D", "STRING" ],
#	[ "E", "STRING" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ 11, "NUMBER" ],
#	[ 12, "NUMBER" ],
#	[ @nullobject, "OBJECT" ],
#	[ @trueobject, "OBJECT" ],
#	[ @falseobject, "OBJECT" ]
# ]

? @@NL( o1.TypesAndTheirSections() ) # same as TypesZZ()
#--> [
#	[ "NUMBER", [ [ 1, 3 ], [ 7, 8 ], [ 15, 16 ] ] ],
#	[ "STRING", [ [ 4, 6 ], [ 12, 13 ] ] ],
#	[ "LIST", [ [ 9, 11 ], [ 14, 14 ] ] ],
#	[ "NUMBER", [ [ 17, 19 ] ] ]
# ]

pf()
# Executed in 0.02 second(s)
