# Narrative
# --------
# Deep finding items at any level
#

# Extracted from stzlisttest.ring, block #358.

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
#--> [ [ 1 ], [ 3, 2 ], [ 3, 3, 1 ], [ 5 ] ]

# Modernized to the canonical nested index-path format (engine-backed
# stz_list_deep_find):

# "you" is at top position 1, at 3.2, at 3.3.1, and at 5.
# The old [[1,1],[2,2],[3,1],[1,4]] was the superseded flat
# format (and mislabeled -- [2,2] points at "other").

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
