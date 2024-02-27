load "stzlib.ring"

/*====

pron()

o1 = new stzList([ "_", "_", "3", "4", "5", "6", "7", "_", "_" ])

o1.ReplaceAtByManyXT(3:5, [ "-3", "-4", "-5" ])
? @@( o1.Content() )
#--> [ "_", "_", "-3", "-4", "-5", "6", "7", "_", "_" ]

proff()
# Executed in 0.07 second(s)



/*------

pron()

//? Intersection([ 1:3, 2:7, 10:12 ])

StzListQ([ "1":"3", "2":"7", "10":"12", 2:3 ]) {
	Flatten()
	Sort()

	Show()

	//ItemsOccuringNTimes(2)
	? @@( FindItems() )
	#-->[
	# 	[ "1", [ 1 ] ], [ "10", [ 2 ] ], [ "2", [ 3, 4 ] ],
	# 	[ "3", [ 5, 6 ] ], [ "4", [ 7 ] ], [ "5", [ 8 ] ],
	# 	[ "6", [ 9 ] ], [ "7", [ 10 ] ]
	# ]

	? @@( NumberOfOccurrenceOfEachItem() )
	#-->[
	# 	[ "1", 1 ], [ "10", 1 ], [ "2", 2 ],
	# 	[ "3", 2 ], [ "4", 1 ], [ "5", 1 ],
	# 	[ "6", 1 ], [ "7", 1 ]
	# ]
}

proff()

/*====

pron()

o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [ [ "A", [ ] ], [ "B", [ [ 2, 1 ] ] ], [ "C", [ [ 1, 1 ], [ 3, 1 ] ] ] ]

proff()



/*=====
*/
pron()

? Round(2.398)
#--> 2.4

? RoundXT(2.398) # Uses the current round (2 by default, defined by decimals())
		 # XT ~> To preserve the round, number is returned in a string!
#--> 2.40

? CurrentRound()
#--> 2

? RoundXT([ 2.398, :To = 3 ]) # XT ~> To preserve the round, number is returned in a string!

proff()

/*-----
*/
pron()

? Q(2.5).RoundedToXT(3)
#--> '2.500'

? Q(2.75).RoundedToXT(0)
#--> '3'

? Q(2).RoundedTo(3)
#--> '2'

? Q(2).RoundedToXT(3)
#--> '2.000'

? Q(12).RoundedToXT(0)
#--> "12"

proff()
# Executed in 0.05 second(s)
