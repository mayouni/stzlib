# Narrative
# --------
# AllItemsAreEqualTo(value): is the list uniform -- does EVERY item equal
# the given value?
#
# A quick homogeneity check. It compares by content (so sublists would
# match too), and an empty list is not considered uniform. Here all three
# items are 1, so the answer is TRUE.
#
# Extracted from stzlisttest.ring, block #648.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 1, 1 ])
? o1.AllItemsAreEqualTo(1)
#--> TRUE

pf()
# Executed in almost 0 second(s)
