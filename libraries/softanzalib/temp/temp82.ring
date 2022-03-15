load "stzlib.ring"

/*-------------
o1 = new stzString("ouled ayouni")
o1.InsertAfter(4, "***")
? o1.Content()

/*-------------

list = [ 1, 2, 3 ]
? StzListQ(list).InsertAfterQ(8, "thing").Content()

list = [ "a", "b", "c" ]
? StzListQ(list).InsertAfterQ(8, "thing").Content()

/*-------------
*/
o1 = new stzString("ya AREM sayda arem haya arem")

//? o1.FindAllOccurrencesCS("AREM", :CS = FALSE)

//? o1.FindFirstOccurrenceCS("arem", :CS = TRUE)

//? o1.FindAllCS("AREM", :CS = FALSE)

//? o1.FindNthOccurrenceCS(1, "AREM", :CS = FALSE)
? o1.FindNthOccurrence(2, "arem")

o1.InsertBeforeNthOccurrence("***" , 1, "arem")
? o1.Content()

o1.InsertBeforeFirstOccurrence("***", "arem")
? o1.Content()

? o1.FindNthOccurrence(2, "arem") # --> Gives 25
? o1.FindNthOccurrence("arem", 2) # --> Gives 25


/*--------------------

? StzListQ([ 1, 2, 3 ]).ExtendToNQ(5).Content()

/*-----------------

StzStringQ("ring language") {
	
	# Enforcing constraints

	EnforceConstraint('{
		@.IsLowercase() and
		@.ContainsNoNumbers()
	}')

	InsertAfter(6, "programming ")
	? Content()

	? "--> PASSED"

	UpdateWith("number x")
	? Content()

	
}

/*	# Activating rules

	ActivateRule('{
		if @.ContainsNumbers() @.RemoveNumbers() ok
		if @.Empty() @.Update("NULL") ok
	}')

*/
