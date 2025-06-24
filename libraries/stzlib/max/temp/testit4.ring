load "../stzlib.ring"

/*==== REMOVING ALL OCCURRENCE OF A GIVEN ITEM IN THE LIST   #

	o1 = new stzList([ "A", "_", "_", "B", "_", "C" ])
	o1.RemoveAll("_")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "C" ])
	o1.RemoveAll("_")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REMOVING GIVEN OCCURRENCES OF A GIVEN ITEM IN THE LIST

	o1 = new stzList([ "A", "_", "_", "B", "_", "C" ])
	o1.RemoveOccurrences([ 1, 3], :Of = "_")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "C" ])
	o1.RemoveOccurrences([ 1, 3], :Of = "_")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]


/*==== REMOVING MANY ITEMS AT THE SAME TIME

	o1 = new stzList([ "A", "_", "*", "B", "*", "-", "C", "_" ])
	o1.RemoveMany([ "_", "*", "-" ])
	
	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "_", "*", "B", "*", "-", "C", "_" ])
	o1.RemoveMany([ "_", "*", "-" ])
	
	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REMOVING THE NTH OCCURRENCE OF A GIVEN ITEM

	o1 = new stzList([ "A", "A", "B", "C" ])
	o1.RemoveNth(2, "A")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "A", "B", "C" ])
	o1.RemoveNth(2, "A")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REMOVING THE FIRST OCCURRENCE OF A GIVEN ITEM

	o1 = new stzList([ "A", "A", "B", "C" ])
	o1.RemoveFirst("A")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "A", "B", "C" ])
	o1.RemoveFirst("A")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REMOVING THE LAST OCCURRENCE OF A GIVEN ITEM

	o1 = new stzList([ "A", "B", "C", "C" ])
	o1.RemoveLast("C")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "B", "C", "C" ])
	o1.RemoveLast("C")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*=== def RemoveLast(pItem)

	o1 = new stzList([ "A", "B", "C", "C" ])
	o1.RemoveLast("C")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*---

	o1 = new stzListOfStrings([ "A", "B", "C", "C" ])
	o1.RemoveLast("C")

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REMOVING NEXT NTH OCCURRENCE OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveNextNthOccurrence(3, :Of = "♥", :StartingAt = 2)

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]
	#--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveNextNthOccurrence(3, :Of = "♥", :StartingAt = 2)

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]
	#--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING NEXT OCCURRENCE OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveNextOccurrence("♥", :StartingAt = 4)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveNextOccurrence("♥", :StartingAt = 4)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING MANY NEXT NTH OCCURRENCES OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥", "♥" ])
	o1.RemoveNextNthOccurrences([ 1, 3], "♥", :StartingAt = 4 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥", "♥" ])
	o1.RemoveNextNthOccurrences([ 1, 3], "♥", :StartingAt = 4 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING PREVIOUS NTH OCCURRENCE OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousNthOccurrence(2, :Of = "♥", :StartingAt = :LastItem)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousNthOccurrence(2, :Of = "♥", :StartingAt = :LastString)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING PREVIOUS OCCURRENCE OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousOccurrence( :Of = "♥", :StartingAt = 5 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousOccurrence( :Of = "♥", :StartingAt = 5 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING MANY PREVIOUS NTH OCCURRENCES OF A GIVEN ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzList([ "♥", "A", "♥", "♥", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousNthOccurrences( [6, 4, 3, 1], :Of = "♥", :StartingAt = 8 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "♥", "A", "♥", "♥", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemovePreviousNthOccurrences( [6, 4, 3, 1], :Of = "♥", :StartingAt = 8 )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING AN ITEM BY SPECIFYING ITS POSITION

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveItemAtPosition(5)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "C", "♥" ])
	o1.RemoveStringAtPosition(5)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*=== REMOVING FIRST ITEM IN THE LIST

	o1 = new stzList([ "♥", "A", "♥", "B", "♥", "C", "♥" ])
	o1.RemoveFirstItem()

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "♥", "A", "♥", "B", "♥", "C", "♥" ])
	o1.RemoveFirstString()

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING LAST ITEM IN THE LIST

	o1 = new stzList([ "A", "♥", "B", "♥", "C", "♥", "♥" ])
	o1.RemoveLastItem()

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "C", "♥", "♥" ])
	o1.RemoveLastString()

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING MANY ITEMS BY SPECIFYING THEIR POSITIONS

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥", "♥" ])
	o1.RemoveManyAt( [ 5, 6, 9 ] )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]
/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥", "♥" ])
	o1.RemoveManyAt( [ 5, 6, 9 ] )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING A RANGE OF ITEMS

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveRange(5, 2)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]
	
/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveRange(5, 2)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING MANY RANGES OF ITEMS

	? RangeToSection(5, 2) #--> [ 5, 6 ]
	? SectionToRange(5, 6) #--> [ 5, 2 ]

/*---

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥", "♥", "♥" ])
	o1.RemoveManyRanges([ [5, 2], [9, 3] ])
	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥", "C", "♥", "♥", "♥" ])
	o1.RemoveManyRanges([ [5, 2], [9, 3] ])
	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]


/*==== REMOVING A SECTION OF ITEMS

	o1 = new stzList([ "A", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveSection(5, 7)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveSection(5, 7)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REMOVING MANY SECTIONS OF ITEMS

	o1 = new stzList([ "A", "♥", "♥", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveManySections([ [3, 4], [7, 9] ])

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "♥", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveManySections([ [3, 4], [7, 9] ])

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]


/*==== REMOVING ALL ITEMS IN THE LIST

	o1 = new stzList([ "A", "♥", "♥", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveAllItems()

	? @@( o1.Content() ) #--> [ ]

/*---

	o1 = new stzListOfStrings([ "A", "♥", "♥", "♥", "B", "♥", "♥", "♥", "♥", "C", "♥" ])
	o1.RemoveAllStrings()

	? @@( o1.Content() ) #--> [ ]

/*---- REMOVING ITEMS UNDER A GIVEN CONDITION

	o1 = new stzList([ "1", "♥", "2", "♥", "3", "♥" ])
	o1.RemoveItemsW(:Where = '{ StzCharQ(@item).IsANumber() }')

	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]

/*---

	o1 = new stzListOfStrings([ "1", "♥", "2", "♥", "3", "♥" ])
	o1.RemoveItemsW(:Where = '{ StzCharQ(@string).IsANumber() }')

	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]
