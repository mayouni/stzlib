# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #69.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
o1.SortInAscending()
? o1.Content()
#--> [ "aaa", "bbb", "ccc" ]

pf()
# Executed in 0.04 second(s)
