# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #51.

load "../../stzBase.ring"


# If the lists are to be extended to a number
# smaller then the largest size in the list,
# then only the smaller lists extended:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> FALSE

o1.ExtendToXT(3, :Using = AHeart())
# Only the 1st and 3d lists are extended

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> FALSE

pf()
# Executed in 0.06 second(s)
