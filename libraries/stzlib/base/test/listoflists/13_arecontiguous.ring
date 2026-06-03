# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #13.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ])
? o1.AreContiguous()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.21
