# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #172.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ 10, 20, 30, 40 ],
	[ "Ali", "Dania", "Ben", "ali" ],
	[ 35000, 28900, 25982, "Ali" ]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 2, 1 ], [ 3, 4 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]

pf()
# Executed in 0.03 second(s)
