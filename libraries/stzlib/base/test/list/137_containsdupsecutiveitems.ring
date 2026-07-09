# Narrative
# --------
# ContainsDupSecutiveItems() reports whether any two side-by-side items
# in the list are equal.
#
# It is a strictly positional check: it walks the list from the second
# item onward and returns TRUE the moment an item equals the one just
# before it. This differs from ContainsDuplicatedItems(), which spots
# repeats anywhere in the list regardless of position. Here ["A","B","C"]
# has no neighbour matching its predecessor, so the answer is FALSE.
# The fluent alias ContainsConsecutiveDuplicates() reads the same intent.
#
# Extracted from stzlisttest.ring, block #137.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("ContainsDupSecutiveItems() reports whether any two side-by-side items in the list are equa")

	o1 = new stzList([ "A", "B", "C" ])
	Then("containsdupsecutiveitems example 1", @@( o1.ContainsDupSecutiveItems() ), @@( FALSE ))
EndScenario()

Summary()
