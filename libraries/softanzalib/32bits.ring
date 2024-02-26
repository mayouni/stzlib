load "stzlib.ring"

pron()

o1 = new stzList([ "_", "_", "3", "4", "5", "6", "7", "_", "_" ])
//? o1.IsListOfNumbers()

o1.ReplaceAnyItemsAtPositionsByManyXT(3:7, [ "-3", "-4", "-5", "_", "_" ])
? @@( o1.Content() )

proff()

/*====

pron()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.Randomize()
? @@( o1.Content() )
#--> [ 1, "A", 4, 3, "D", "C", "B", 2 ]
#--> [ 1, "B", 2, "A", "C", 4, "D", 3 ]
#--> [ "B", "D", 2, 3, 4, 1, "A", "C" ]

proff()



/*====

pron()

o1 = new stzList([ "A", "B", 30, 40, 50, 60, "A", "B", "C" ])
o1.RandomizeNumbers()
? @@( o1.Content() )

proff()

#--
/*
pron()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeStrings()
? o1.Content()

proff()

#--
*/
pron()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeSection(1, 4)
? o1.Content()

proff()

/*--

pron()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeSections()
? o1.Content()

proff()

/*----
pron()

Q("123456789") {

	? @@( ARandomSection() ) + NL # Or ASection() or ASubString etc.
	#--> "234"

	? @@( ARandomSectionZ() ) + NL
	#--> [ "678", [ 6, 8 ] ]

	? @@( SomeRandomSections() ) + NL
	#--> [ "345678", "4567" ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [ [ "3456", 3 ], [ "45", 4 ] ]

	? @@( SomeRandomSectionsZZ() )
	#--> [
	# 	[ "23456", [ 2, 6 ] ],
	# 	[ "12", [ 1, 2 ] ],
	# 	[ "78", [ 7, 8 ] ],
	# 	[ "34", [ 3, 4 ] ],
	# 	[ "89", [ 8, 9 ] ],
	# 	[ "4567", [ 4, 7 ] ],
	# 	[ "56", [ 5, 6 ] ]
	# ]
}

proff()

/*---

pron()

Q([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]) {

	? @@( ARandomSection() ) + NL
	#--> [ "7", "8" ]

	? @@( ARandomSectionZ() ) + NL
	#--> [ [ "3", "4", "5", "6", "7", "8" ], 3 ]

	? @@( ARandomSectionZZ() ) + NL
	#--> [ [ "1", "2", "3", "4", "5", "6" ], [ 1, 6 ] ]


	? @@( SomeRandomSections() ) + NL
	#--> [
	# 	[ "1", "2", "3", "4", "5", "6" ],
	# 	[ "5", "6", "7", "8", "9" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8", "9" ],
	# 	[ "8", "9" ], [ "4", "5", "6" ]
	# ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [
	# 	[ [ "5", "6", "7", "8" ], 5 ],
	# 	[ [ "1", "2", "3", "4", "5", "6", "7" ], 1 ]
	# ]

	? @@( SomeRandomSectionsZZ() ) + NL
	#--> [
	# 	[ [ "6", "7", "8" ], [ 6, 8 ] ],
	# 	[ [ "7", "8" ], [ 7, 8 ] ]
	# ]

	? @@( NRandomSections(2) ) + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ "4", "5", "6" ] ]

	? @@( NRandomSectionsZ(2) ) + NL
	#--> [ [ [ "3", "4", "5", "6" ], 3 ], [ [ "8", "9" ], 8 ] ]

	? @@( NRandomSectionsZZ(2) )
	#--> [
	# 	[ [ "4", "5" ], [ 4, 5 ] ],
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	# ]
}

proff()
# Executed in 0.05 second(s)

/*---

pron()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? NRandomItems(3)
	#--> [ "A", "S", "Z" ]

	? @@( NRandomItemsZ(3) )
	#--> [ [ "S", 1 ], [ "A", 8 ], [ "N", 6 ] ]
}

proff()

/*----

pron()

Q("SOFTANZA") {

	? ARandomPosition()
	#--> 8

	? ARandomChar()
	#--> T

	? ARandomPositionGreaterThan(4)
	#--> 8

	? ARandomCharAfterPosition(4)
	#--> A

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomCharExcept("A")
	#--> S

	? ARandomPositionLessThan(4)
	#--> 2

	? ARandomCharBefore(4)
	#--> S

	? ARandomCharAfter("T")
	#--> N

	? ARandomCharBefore("T")
	#--> S

}

proff()
# Executed in 0.05 second(s)

/*-------

pron()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? ARandomPosition()
	#--> 3

	? ARandomItem()
	#--> S

	? ARandomPositionGreaterThan(4)
	#--> 5

	? ARandomItemAfterPosition(4)
	#--> N

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomItemExcept("A")
	#--> Z

	? ARandomPositionLessThan(4)
	#--> 3

	? ARandomItemBeforePosition(4)
	#--> O

	? ARandomItemAfter("T")
	#--> A

	? ARandomItemBefore("T")
	#--> O

}

proff()
# Executed in 0.04 second(s)

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
