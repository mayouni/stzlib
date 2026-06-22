# Narrative
# --------
# Locating every occurrence of several values in one pass.
#
# FindMany() takes a list of search values and returns a single flat,
# position-sorted list of all the indices where ANY of them appear --
# here "a" sits at 1 and 4, "e" at 3 and 7, merged into [ 1, 3, 4, 7 ].
# When you need to keep the matches grouped per value instead of flattened,
# TheseItemsZ() returns the structured (Z) view: one [ value, [ positions ] ]
# pair for each searched item, preserving which index belongs to which value.
#
# Extracted from stzlisttest.ring, block #460.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])

? o1.FindMany([ "a", "e" ])
#--> [ 1, 3, 4, 7 ]

? @@NL( o1.TheseItemsZ([ "a", "e" ]) )
#--> [
#	[ "a", [ 1, 4 ] ],
#	[ "e", [ 3, 7 ] ]
# ]

pf()
# Executed in almost 0 second(s).
