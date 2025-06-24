load "../stzlib.ring"

/*----------

	? @@( "A" : "D" ) # Computable form of the list
	#--> [
	# 	"A",
	# 	"B",
	# 	"C",
	# 	"D"
	#     ]

	? @@( "A" : "D" ) # Computable form without spaces
	#--> [ "A", "B", "C", "D" ]

/*----------

	o1 = new stzList([ "ONE", "two" ])
	o1.ReplaceAnyItemAtPosition(2, :With = "TWO")
	? o1.Content()	#--> [ "ONE", "TWO" ]

/*----------

	StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
		ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
		? Content() # !--> [ "A" , "B", "A", "C", "*", "D", "*" ]
	}	

/*----------

	StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
		ReplacePreviousNthOccurrence(3, :of = "A", :with = "*",  :StartingAt = 5)
		? Content() # !--> [ "A" , "B", "*", "C", "*", "D", "A" ]
	}
	
/*----------

	StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
		ReplacePreviousNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 5)
		? @@(Content()) # !--> [ "*" , "B", "*", "C", "A", "D", "A" ]
	}	

/*----------

	o1 = new stzList([ "A", "B", "_", "_", "_", "D" ])
	o1.RemoveSection(3, 5)
	? @@( o1.Content() )	#--> [ "A", "B", "D" ]
	
	o1.InsertBefore(3, "C")
	? @@( o1.Content() )	#--> [ "A", "B", "C", "D" ]

/*----------

	o1 = new stzList([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceSection(3, 5, :With = "C")
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D" ]

/*----------

	o1 = new stzList([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachItemInSection(3, 5, :With = "C")
	? o1.Content() #--> [ "A", "B", "C", "C", "C", "D" ]

