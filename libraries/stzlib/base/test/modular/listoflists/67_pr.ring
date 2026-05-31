# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #67.

load "../../../stzBase.ring"


o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? @@( o1.ListsOfSizeN(2) )
#--> [ [ 9, 0 ], [ 3, 5 ] ]

? pf()
# Executed in 0.01 second(s) in Ring 1.21
