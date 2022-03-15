load "stzlib.ring"

// This example has been included in stzListTest.ring file

o1 = new stzList([ 12, 24, 36, "A", "B", 12, "C", "D", "E", 24, "F", 25, "G", "H" ])
o1 {
	// Walking the list UNTIL a condition is verified
		aWalk1 = WalkUntil("@item = 'D'")
		?aWalk1 # --> 1:8
	
		aWalk2 = WalkUntil("isNumber(@item)")
		? aWalk2 # --> 1
	
		aWalk3 = WalkUntil("isNumber(@item) and @item > 30")
		? aWalk3 # --> 1:3
	
		aWalk4 = WalkUntil("isNumber(@item) and NumberIsDividorOf(@item,36)")
		? aWalk4 # --> 1

	// Walking the list WHILE a condition is verified
		aWalk5 = WalkWhile("CharIsLetter(@item)")
		? aWalk5 # --> NULL
	
		aWalk6 = WalkWhile("isNumber(@item) and NumberIsDividableBy(@item,12)")
		? aWalk6 # --> 1:3

	// Walking on each item verifying the provided condition
		aWalk7 = WalkEachW("isNumber(@item)")
		? aWalk7 # --> [ 1,2,3,6,10,12 ]

	// Walking the list forth and back
		aWalk8 = WalkForthAndBack()
		? aWalk8 # --> [ 1,2,3..., 14,13,12...,1 ]

	// Walking the list back and forth
		aWalk9 = WalkBackAndForth()
		? aWalk9  # --> [ 14,13,12...,1,2,3...,14 ]

	// Walking n steps forward and then n steps backward
		aWalk10 = WalkNStepsForwardNStepsBackward(3,1)
		? aWalk10 # --> [ 1, 4,3, 6,5, 8,7, 10,9, 12,11, 14,13 ]

	// Walking n steps from start and n steps from end
		aWalk11 = WalkNStepsFromStartNStepsFromEnd(1,2) 
		? aWalk11 # --> [ 1,14, 2,12, 3,10, 4,8, 5,6, 7,9, 11, 13 ]

	// Walking n steps forward
		aWalk12 = WalkNStepsForward(2)
		? aWalk12 # --> [ 1,3,5,7,9,11,13 ]

	// Walking n steps backward
		aWalk13 = WalkNStepsBackward(2)
		? aWalk13 # --> [ 14,12,10,8,6,4,2 ]

	// Walking n progressive steps forward
		aWalk14 = WalkNProgressiveStepsForward(2)
		? aWalk14 # --> [ 1,3,7,13 ]

	// Walking n progressive steps backward
		aWalk15 = WalkNProgressiveStepsBackward(2)
		? aWalk15 # --> [ 14, 12, 8, 2 ]

/*
1 2 3 4 5 6 7 8 9 10 11 12 13 14
/*	Implement theses syntaxes:

	aWalk8 = WalkWhile("Item.IsANumber() and Item.IsDividableBy(12)")
	? aWalk8

	aWalk10 = WalkFuncOfItemSteps("Position(Item)")
	? aWalk10

	Think of:

	       +--> Yield	: get an information about Item(s)
	Walk --+--> Harvest	: delete Item(s) form list
	       +--> Perform	: update Item(s)

*/

}


