load "stzlib.ring"

pron()

o1 = new stzList([ "A", "A", "B", "C", "A", "C" ])
? o1.ItemsOccurringNTimes(2)
#--> [ "A", "C" ]

? o1.ItemsOccurringExactlyNTimes(2)
#--> [ "C" ]

? o1.ItemsOccurringLessThanNTimes(3)
#--> [ "B", "C" ]

? o1.ItemsOccurringNTimesOrLess(3)
#--> [ "A", "B", "C" ]

? o1.ItemsOccurringNTimesOrMore(3)
#--> [ "A" ]

proff()

/*---

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? o1.ItemsOccuringNTimesCS(3, FALSE) # Note this is a misspelled form (one r instead of 2)
#--> [ "b" ]

proff()

/*===
*/
pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 3 ] ],
#	[ "B", [ 2, 6 ] ],
#	[ "C", [ 4 ] ],
#	[ "D", [ 5 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*---

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? @@( o1.IndexCS(FALSE) )
#--> [
#	[ "a", [ 1, 3 ] ],
#	[ "b", [ 2, 6, 7 ] ],
#	[ "c", [ 4 ] ],
#	[ "d", [ 5 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*====

pron()

? Intersection([ 1:3, 2:7, 2:3 ])
#--> [ 2, 3 ]

proff()
# Executed in 0.05 second(s)
/*====

pron()

o1 = new stzList([ "1", "A", "B", "A", "A", "C", "B", 1 ])
? @@( o1.Withoutduplication() )
#--> [ "1", "A", "B", "C", 1 ]

/*
? @@( o1.FindItems() ) + NL # Or ItemsZ()
#--> [ [ "A", [ 1, 3, 4 ] ], [ "B", [ 2, 6 ] ], [ "C", [ 5 ] ] ]

? @@( o1.ItemsCount() )
#--> [ [ "A", 3 ], [ "B", 2 ], [ "C", 1 ] ]

proff()
# Executed in 0.03 second(s)

/*====

pron()


StzListQ([ "1":"3", "2":"7", "10":"12" ]) {
	Flatten()
	Sort()

	Show()

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
# Executed in 0.06 second(s)

/*====

pron()

o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 2, 3 ] ],
#	[ "B", [ 1, 2, 3 ] ],
#	[ "C", [ 1, 3 ] ]
# ]

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
