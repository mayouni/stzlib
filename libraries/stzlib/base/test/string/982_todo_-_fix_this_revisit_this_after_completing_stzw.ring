# Narrative
# --------
#
# NOTE (audit, 2026-07-04): DEFERRED -- the block documents a WalkUntil inconsistency between stzString (last position) and stzList (all positions) and defers itself to the stzWalker completion. Goes to the walker pass.
# TODO - FIX THIS : Revisit this after completing stzWalker
#
# Extracted from stzStringTest.ring, block #982.

load "../../stzBase.ring"

pr()

// WalkUntil has not same output in stzString and stzList!

# In stzString only the last position is returned

? StzStringQ("size()").WalkUntil('@char = "("') #--> 4
? StzStringQ("size()").WalkUntil('@char = "*"') #--> 0

# In stzList all the walked positions are returned

StzListQ([ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]) {
	? WalkUntil("@item = 'D'") #--> 1:5
	? WalkUntil('@item = "x"') #--> 0
}

pf()
