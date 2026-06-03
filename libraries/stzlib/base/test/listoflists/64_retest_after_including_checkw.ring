# Narrative
# --------
# #TODO Retest after including CheckW()
#
# Extracted from stzlistofliststest.ring, block #64.
#ERR Error (R14) : Calling Method without definition: tolistinstring

load "../../stzBase.ring"


pr()

o1 = new stzListOfLists([ 1:3, 4:5, 6:7 ])
? @@( o1.ToListInString() )
#--> "[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7 ] ]"

? @@( o1.ToListInStringInShortForm() )
#--> [ "1:3", "4:5", "6:7" ]

pf()
