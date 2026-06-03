# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #25.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([ 1:3, 1:3, 1:3 ])
? o1.IsMadeOfSameList()
#--> TRUE

? StzListOfListsQ([ 1:3, 1:2, 1:3 ]).AllListsAreEqual()
#--> FALSE

#TODO : Add to stzList
#	AllNumbersAreEqual()
#	AllStringsAreEqual()
#	AllListsAreEqual()
#	AllObjectsAreEqual()

pf()
# Executed in 0.02 second(s) in Ring 1.21
