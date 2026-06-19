# Narrative
# --------
# Deep finding items at any level
#
# Extracted from stzlisttest.ring, block #358.
#ERR Error (R14) : Calling Method without definition: numberoflevels

load "../../stzBase.ring"


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
# Modernized to the canonical nested index-path format (engine-backed
# stz_list_deep_find): "you" is at top position 1, at 3.2, at 3.3.1, and
# at 5. The old [[1,1],[2,2],[3,1],[1,4]] was the superseded flat format
# (and mislabeled -- [2,2] points at "other").
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]

#~> the item "you" is found at:
#	- posisitons 1 and 4 in level 1
#	- position 2 in level 2
#	- position 1 in level 4

pf()
# Executed in 0.03 second(s).
