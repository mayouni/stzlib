# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #575.

load "../../../stzBase.ring"


o1 = new stzList([ 3, 6, 9, 12, "a", "b", [ "List0" ], [ "List1" ] ])
? o1.IsSortedInAscending()
#--> TRUE

pf()
# Executed in 0.02 second(s).
