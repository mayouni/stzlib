# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #34.

load "../../../stzBase.ring"


aMyLists = [
	[ "a", "ab", "b", "b" ],
	[ "a", "a", "ab", "abc", "b", "bc", "c" ],
	[ "ab", "xt", "b", "xt" ]
]

? @@( Intersection(aMyLists) ) # Same as CommonItems()
#--> [ "ab", "b" ]

pf()
# Executed in 0.07 second(s)
