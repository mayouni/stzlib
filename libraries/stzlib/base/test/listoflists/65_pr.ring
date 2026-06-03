# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #65.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])


? o1.NthList(4)
#--> [3, 5]

? @@( o1.ItemsAtPositionN(2) )
#--> [ 2, 5, 0, 5, 6 ]

? @@( o1.ListsOfSize(2) )
#--> [ [9, 0], [3, 5] ]

? o1.PositionsOfListsOfSize(2)
#--> [ 3, 4 ]

? @@( o1.Sizes() )
#--> [ 3, 5, 2, 2, 3 ]

? o1.SmallestSize()
#--> 2

? o1.BiggestSize()
#--> 5

? @@( o1.SmallestLists() )
#--> [ [ 9, 0 ], [ 3, 5 ] ]

? o1.PositionsOfSmallestLists()
#--> [ 3, 4 ]

? @@( o1.ListsWXT('Q(@list).Size() <= 3') )
#--> [ [ 1, 2, 3 ], [ 9, 0 ], [ 3, 5 ], [ 5, 6, 7 ] ]

# Test this line after adding Yield() #TODO

//? @@( o1.Yield('{ len(@list) }') ) 	#--> [ 3, 5, 2, 2, 3 ]

pf()
# Executed in 0.05 second(s) in Ring 1.21
