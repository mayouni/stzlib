# Narrative
# --------
# o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
#
# Extracted from stzlistofstringstest.ring, block #73.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.SortedInAscending() #--> [ "aaa", "bbb", "ccc" ]
#--> Content of the main lis is not sorted:
? o1.Content() #--> [ "ccc", "bbb", "aaa" ]

pf()
