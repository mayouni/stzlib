# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #43.

load "../../stzBase.ring"


o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥", "♥", "♥" ],
#	[ "C", "D", "E", "F", "♥", "♥" ],
#	[ "I", "♥", "♥", "♥", "♥", "♥" ]
# ]

pf()
# Executed in 0.10 second(s)
