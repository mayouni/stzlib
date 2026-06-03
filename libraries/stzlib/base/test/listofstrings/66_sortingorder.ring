# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #66.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortingOrder()
#--> :Ascending

? o1.IsSortedInAscending()
#--> TRUE

? o1.StringsAreSortedInAscending()
#--> TRUE

pf()
# Executed in 0.08 second(s)
