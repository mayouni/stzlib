# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #67.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
? o1.SortingOrder()
#--> :Descending

? o1.IsSortedInDescending()
#--> TRUE

? o1.StringsAreSortedInDescending()
#--> TRUE

pf()
# Executed in 0.09 second(s)
