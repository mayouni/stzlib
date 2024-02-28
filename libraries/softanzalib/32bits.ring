load "stzlib.ring"

/*=====

? 0 = ""

? "" = 0

? "0" = 0

? "1" = 1
#--> TRUE

? 1 = "01.0"
#--> TRUE

/*----

pron()

? BothAreEqual(0, "")
#--> FALSE

? BothAreEqual(1, "1")
#--> FALSE

? BothAreEqual([], "")
#--> FALSE

? BothAreEqual(1:3, [1, 2, 3])
#--> TRUE

? BothAreEqual("ring", "ring")
#--> TRUE

 ? BothAreEqual("RING", "ring")
#--> FALSE

? BothAreEqualCS("RING", "ring", FALSE)
#--> TRUE

? BothAreEqual("A":"C", "a":"c")
#--> FALSE

? BothAreEqualCS("A":"C", "a":"c", FALSE)
#--> TRUE

proff()
#--> Executed in 0.04 second(s)

/*----

pron()

? AllHaveSameType([1, "1", 1])
#--> FALSE

proff()

/*----
*/
pron()

? AreEqual([1, 1, 1])
#--> TRUE

? AreEqual([1, "1", 1])
#--> FALSE

? AreEqual([ "ring", "Ring", "RING" ])
#--> FALSE

? AreEqualCS([ "ring", "Ring", "RING" ], FALSE)
#--> TRUE

proff()

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
*/
pron()


StzListQ([ "1":"3", "2":"7", "10":"12" ]) {
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
# Executed in 0.06 second(s)

/*====
*/
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
