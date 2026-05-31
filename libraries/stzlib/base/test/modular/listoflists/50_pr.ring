# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #50.

load "../../../stzBase.ring"


# You can even extend to n items and specify
# the value of the item to extend them with, like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT(4, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> TRUE

pf()
# Executed in 0.06 second(s)
