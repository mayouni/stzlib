# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #66.

load "../../../stzBase.ring"


// Merging many lists in one list
o1 = new stzListOfLists([ 1:3, 4:7, 8:9, [10, 11:13] ])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
