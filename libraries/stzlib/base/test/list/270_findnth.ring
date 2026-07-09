# Narrative
# --------
# FindNth(n, value) returns the position of the n-th occurrence of a
# given value inside a stzList.
# Here a small heterogeneous list (strings, numbers, a 1:3 range, and
# the "heart" emoji appearing twice) is grown to a million-plus items
# to show the lookup stays direct. Asking for the 2nd occurrence of
# the "heart" value walks the list and reports position 7 -- the index
# of the second matching element, not a zero-based or count value.
# This is the occurrence-aware sibling of Find(), letting you skip past
# earlier matches to address a specific repeat.
#
# Extracted from stzlisttest.ring, block #270 (Scenario form). The source
# built the object from the small list while the million-item loop was
# unused; here the object is built from the grown list so the "stays
# direct at scale" claim is actually exercised.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("FindNth locates the n-th occurrence of a value, even at scale")
	aLarge = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
	for i = 1 to 1_000_000
		aLarge + i
	next
	o1 = new stzList(aLarge)
	Then("FindNth(2, '♥') reports the position of the 2nd heart",
		o1.FindNth(2, "♥"), 7)
EndScenario()

Summary()
