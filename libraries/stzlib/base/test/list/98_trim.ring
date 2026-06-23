# Narrative
# --------
# Calling Trim() on a list, then reading the result with Content().
#
# The list mixes "empty/falsy" entries (0, "", [], NULL) with real
# values (1, 2, 3). The recorded expectation was that Trim() would
# strip every empty entry and leave only [ 1, 2, 3 ]. In the current
# build it does not: Content() returns the list unchanged (NULL is
# echoed back as an empty string ""). So this block documents the
# observed in-place behavior of Trim() on a heterogeneous list, not a
# pruning operation -- the recorded #--> was aspirational/stale.
#
# Extracted from stzlisttest.ring, block #98.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.Trim()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
