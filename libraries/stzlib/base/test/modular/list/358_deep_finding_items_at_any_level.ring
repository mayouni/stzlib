# Narrative
# --------
# Deep finding items at any level
#
# Extracted from stzlisttest.ring, block #358.

load "../../../stzBase.ring"


pr()

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? o1.NumberOfLevels()
#--> 3

? @@( o1.DeepFind("you") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 1 ], [ 1, 4 ] ]

#~> the item "you" is found at:
#	- posisitons 1 and 4 in level 1
#	- position 2 in level 2
#	- position 1 in level 4

pf()
# Executed in 0.03 second(s).
