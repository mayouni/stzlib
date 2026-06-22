# Narrative
# --------
# Demonstrates stzList.EachItemExistsIn() : returns TRUE only when
# every item of the host list is also present in a given other list.
#
# The host [ "A", "B", "C" ] is checked against the larger pool
# [ "1", "2", "A", "B", "C", "3", "4" ]. Since each of A, B and C
# is found in the pool, the host is a subset and the method yields
# TRUE. This is the "all-of" containment idiom: a one-shot subset
# test that reads in plain English at the call site, complementing
# the per-item ItemExistsIn / ContainsEach family.
#
# Extracted from stzlisttest.ring, block #520.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

? o1.EachItemExistsIn([ "1", "2", "A", "B", "C", "3", "4" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
