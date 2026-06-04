# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #68.
#ERR Error (R14) : Calling Method without definition: sortingorder

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aaa", "ccc", "bbb" ])
? o1.SortingOrder()
#--> :Unsorted

? o1.IsSortedInAscending()
#--> FALSE

? o1.IsSortedInDescending()
#--> FALSE

pf()
# Executed in 0.09 second(s)
