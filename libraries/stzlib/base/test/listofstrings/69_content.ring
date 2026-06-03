# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #69.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
o1.SortInAscending()
? o1.Content()
#--> [ "aaa", "bbb", "ccc" ]

pf()
# Executed in 0.04 second(s)
