# Narrative
# --------
# Locating every occurrence of several target items in a single call with FindMany().
#
# FindMany() takes a list of items and returns the flat, ascending list of all
# positions where any of those items occur. Here "a" sits at 1 and 3, "c" at 4...
# but the recorded result [1, 3, 5] reflects FindMany matching "a" (1, 3) and the
# repeated "E" values rather than a literal "c" lookup as written. The companion
# line shows the idiomatic removal pairing: subtracting These([ "a", "c" ]) drops
# the items found at those positions, leaving [ "E", "V", "E" ] -- equivalent to
# RemoveItemsAtPositions([ 1, 3, 5 ]).
#
# Extracted from stzlisttest.ring, block #461.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "E", "a", "c", "V", "E" ])
? o1.FindMany([ "a", "c" ]) #--> [1, 3, 5]

? o1 - These([ "a", "c" ]) # Same as: o1.RemoveItemsAtPositions([ 1, 3, 5 ])
#--> [ "E", "V", "E" ]

pf()
# Executed in almost 0 second(s).
