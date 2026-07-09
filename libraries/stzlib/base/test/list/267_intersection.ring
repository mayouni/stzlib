# Narrative
# --------
# Computes the intersection of two lists: the items the host list shares
# with another list, preserving the host's order.
#
# o1.Intersection(:with = otherList) keeps each item of the host that also
# appears in the comparison list. Here [ "a", "ab", "b" ] meets
# [ "a", "ab", "abc", "b", "bc", "c" ], so "a", "ab" and "b" survive while
# the host has nothing else to contribute. CommonItems() is the readable
# alias. The named :with argument documents intent at the call site, a
# recurring Softanza idiom for binary set-style operations.
#
# Extracted from stzlisttest.ring, block #267.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "ab", "b" ])
? @@( o1.Intersection(:with = [ "a", "ab", "abc", "b", "bc", "c" ]) ) # Or CommonItems()
#--> [ "a", "ab", "b" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.05 second(s) in Ring 1.19 (64 bits)
# Executed in 0.03 second(s) in Ring 1.17
