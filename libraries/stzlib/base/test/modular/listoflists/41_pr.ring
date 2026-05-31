# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #41.

load "../../../stzBase.ring"


o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendXT(:Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.21
