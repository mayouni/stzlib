load "softanzalib.ring"

/*-------------------------

o1 = new Person
//myList = "A":"J"
myList = [ "A", 1, "BB", 2, [ "W", 12, "V" ], "C", 10, o1, "D", o1]

#myList = [ "Tunis", "Cairo", "Niamey", "Paris", "Rome", "Mosko" ]
o1 = new stzList(myList)

// Working with walkers...

o1 {
	AddWalker( Named(:Walker1), StartingAt(1), EndingAt(10), NStepsATime(1) )

	AddWalker( :Walker2, 6, 10,   [ :NStepsATime , 3 ] )

	AddWalker( Named(:Walker3), StartingAt(1), EndingAt(10), TakingNEqualMoves(3) )

	? Walkers()

	? Yield( '{ StzLen(item) }', WhileWalking(:Walker1) )
	? Yield( '{ type(item) }', WhileWalking(:Walker1) )
	? Yield( '{ [ UPPER(Item), StringContains(Item,"o") ] }', WhileWalking(:Walker1) )

	? Yield( '{ [ UPPER(Item), StringNumberOfOccurrence(Item,"o") ] }', WhileWalking(:Walker1) )

	//? Content()
}

class Person
