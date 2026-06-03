# Narrative
# --------
# SHRINKING A LIST OF LISTS
#
# Extracted from stzlistofliststest.ring, block #45.

load "../../stzBase.ring"


pr()

o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.Shrink()

? @@( o1.Content() )
#--> [ [ "A", "B" ], [ "D", "E" ], [ "H", "I" ] ]

pf()
# Executed in 0.09 second(s)
