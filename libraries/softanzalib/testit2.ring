load "stzlib.ring"

#----------------#
#   STZ STRING   #
#----------------#

/*------- CONTAINING A SUBSTRING BOUNDED BY A GIVEN SUBSTRING
*/
	o1 = new stzString("lorem__ipsum__lorem")
	? o1. ContainsSubStringBoundedBy("ipsum", "__") 		#--> TRUE
	? o1.ContainsSubStringBoundedByCS("IPSUM", "__", :CS = FALSE) 	#--> TRUE

	o1 = new stzString("lore_mmmipsuMmM_lorem")
	? o1.ContainsSubStringBoundedByCS("ipsu", "mmm", :CS = FALSE)	#--> TRUE
	? o1.ContainsSubStringBoundedByCS("IPSU", "mmm", :CS = FALSE)	#--> TRUE
	
/*------- CONTAINING A SUBSTRING AT A GIVEN POSITION INSIDE THE STRING

	o1 = new stzString("123x567x901")

	? o1.ContainsSubStringAtPosition(1, "123") #--> TRUE
	? o1.ContainsSubStringAtPosition(5, "567") #--> TRUE
	? o1.ContainsSubStringAtPosition(9, "901") #--> TRUE

	# Short form:
	#------------

	? o1.ContainsAt(1, "123") #--> TRUE

/*------- CONTAINING A SUBSTRING AT GIVEN POSITIONS

	o1 = new stzString("123x123x123")
	? o1.ContainsSubStringAtPositions([1, 5, 9], "123") #--> TRUE

	# Short form:
	#------------

	? o1.ContainsAtPositions([1, 5, 9], "123") #--> TRUE

/*------- CONTAINING SUBSTRINGS AT GIVEN POSITIONS

	o1 = new stzString("123x567x901")
	? o1.ContainsSubStringsAt([ 1, 5, 9 ], [ "123", "567", "901" ])

	# Short form:
	#------------

	? o1.ContainsManyAt([ 1, 5, 9 ], [ "123", "567", "901" ])

/*------- REMOVING A SUBSTRING AT A GIVEN POSITION

	o1 = new stzString("123x567x901")
	o1.RemoveSubStringAtPosition(5, "567")
	? o1.Content() #--> 123xx901

	# Short form:

	o1 = new stzString("123x567x901")
	o1.RemoveSubStringAt(5, "567")
	? o1.Content() #--> 123xx901

	# Extended form 1:
	#-----------------

	o1 = new stzString("123x567x901")

	o1.RemoveSubStringAtXT(5, "567",
		[ :RemoveNCharsBefore = 1, :RemoveNCharsAfter = 1 ] )

	? o1.Content() #--> 123901

	# Extended form 2:
	#-----------------

	o1 = new stzString("123x567x901")

	o1.RemoveSubStringAtXT(5, "567",
		[ :RemoveThisSubStringBefore = "x", :RemoveThisSubStringAfter = "x" ] )

	? o1.Content() #--> 123901
	
	# Extended form 3:
	#-----------------

	o1 = new stzString("123x567x901")

	o1.RemoveSubStringAtXT(5, "567",
		[ :RemoveThisSubStringBefore = "X", :RemoveThisSubStringAfter = "X", :CS = FALSE ] )

	? o1.Content() #--> 123901

	# Extended form 4:
	#-----------------

	o1 = new stzString("123xyz567xYZ901")

	o1.RemoveSubStringAtXT(7, "567",
		[ :RemoveThisBound = "XyZ", :CS = FALSE ] )

	? o1.Content() #--> 123901

#-------------------------#
#   STZ LIST OF STRINGS   #
#-------------------------#

/*------- FINDING A SUBSTRING INSIDE THE LIST OF STRINGS

	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])

	? @@( o1.FindSubstringCS("name", :CaseSensitive = TRUE) )
		#--> [ "1" = [ 13 ], "3" = [ 6, 18 ] ]

/*------- GETTING A SECTION OF A LIST OF STRINGS

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_" ])
	? @@( o1.SectionQ(2, 4).Content() ) #--> [ "_", "_", "B" ]

/*------- FINDING NEXT/PREVIOUS OCCURRENCE(S) OF A STRING

	? o1.FindNext("_", :StartingAt = 2)	 #--> 3
	? o1.FindPrevious("_", :StartingAt = 4)	 #--> 3
	
	? @@( o1.FindNextOccurrences(:Of = "_", :StartingAt = 3) ) #--> [ 3, 5 ]       
	? @@( o1.FindPreviousOccurrences(:Of = "_", :StartingAt = 4) ) #--> [ 2, 3 ]
	
/*------- REPLACING ALL STRINGS WITH A NEW STRING

	o1 = new stzListOfStrings([ "A", "B", "C" ])
	o1.ReplaceAllStrings(:With = "A")
	? o1.Content() #--> [ "A", "A", "A" ]

/*------- REPLACING ALL OCCURRENCES OF A STRING

	o1 = new stzListOfStrings([ "A", "*", "B", "*", "C" ])
	o1.ReplaceAllOccurrencesOfString("*", :With = "♥")
	? o1.Content() #--> [ "A", "♥", "B", "♥", "C" ]
	
	#-- CS

	o1 = new stzListOfStrings([ "ring", "Ring", "RING" ])
	o1.ReplaceCS(:ring, :By@ = 'upper("ring")', :CaseSensitive = FALSE)
	? o1.Content() #--> [ "RING", "RING", "RING" ]

/*------- REPLACING MANY STRINGS AT THE SAME TIME

	o1 = new stzListOfStrings([ "blabla1", "One", "blabla2", "Two", "blabla3", "Three" ])
	o1.ReplaceMany([ "blabla1", "blabla2", "blabla3" ], :with = "♥" )
	? @@( o1.Content() ) #--> [ "♥", "One", "♥", "Two", "♥", "Three" ]

	#-- CS

	o1 = new stzListOfStrings([ "Tunis", "CAIRO", "Bagdad" ])
	o1.ReplaceManyCS([ :tunis, :cairo, :bagdad ], :With = "♥", :CS = FALSE)
	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]

/*------- REPLACING MANY STRINGS AT THE SAME TIME

	o1 = new stzListOfStrings([ "Tunis", "CAIRO", "Bagdad" ])
	o1.ReplaceManyXT([ :tunis, :cairo, :bagdad ], :With = "♥")
	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]

/*------- REPLACING MANY STRINGS BY MANY OTHERS ONE BY ONE

	o1 = new stzListOfStrings([ :tunis, "ALGERIA", :cairo, "LIBYA", :bagdad ])
	
	o1.ReplaceManyOneByOne([ :tunis,   :cairo, :bagdad ],
			:By  = [ "TUNISIA", "EGYPT", "IRAQ"  ])
	
	? o1.Content() #--> [ "TUNISIA", "ALGERIA", "EGYPT", "LIBYA", "IRAQ" ]


/*------- REPLACING A STRING BY ALTERNANCE


	o1 = new stzListOfStrings([ "A", "A", "A", "A", "A" ])
	o1.ReplaceStringByAlternance("A", :With = [ "#1", "#2" ])
	? @@( o1.Content() )
	# --> [ "#1", "#2", "#1", "#2", "#1" ]

/*------- REPLACING NTH OCCURRENCE OF A STRING

	o1 = new stzListOfStrings([ "___", "Moon", "___", "Star", "___" ])
	o1.ReplaceNthOccurrence(2, :Of = "___", :With = "Sun")
	? @@( o1.Content() ) #--> [ "___", "Moon", "Sun", "Star", "___" ]

	o1.ReplaceFirstOccurrence(:Of = "___", :With = "Earth")
	? @@( o1.Content() ) #--> [ "Earth", "Moon", "Sun", "Star", "___" ]

	o1.ReplaceLastOccurrence(:Of = "___", :With = "Mars")
	? @@( o1.Content() ) #--> [ "Earth", "Moon", "Sun", "Star", "Mars" ]

/*------- REPLACING NEXT NTH OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION

	o1 = new stzListOfStrings([ "_", "_", "C", "_", "E", "_", "G", "_", "_" ])
	o1.ReplaceNextOccurrence(:Of = "_", :With = "H", :StartingAt = 7)
	//? @@( o1.Content() )
	#--> [ "_", "_", "C", "_", "E", "_", "G", "H", "_" ]

#--

	o1.ReplacePreviousOccurrence(:Of = "_", :With = "D", :StartingAt = 5)
	//? @@( o1.Content() )
	#--> [ "_", "_", "C", "D", "E", "_", "G", "H", "_" ]
#--

	o1.ReplaceNextNthOccurrence(2, :Of = "_", :With = "F", :StartingAt = 3 )
	//? @@( o1.Content() ) #--> [ "_", "_", "C", "_", "E", "F", "G", "_" ]
	#--> [ "_", "_", "C", "D", "E", "_", "G", "H", "F" ]
#--

	o1.ReplacePreviousNthOccurrence(2, :Of = "_", :With = "B", :StartingAt = 5 )
	//? @@( o1.Content() ) #--> [ "_", "B", "C", "_", "E", "F", "G", "_" ]
	#--> [ "B", "_", "C", "D", "E", "_", "G", "H", "F" ]
#--

	o1.ReplaceNextOccurrences( :Of = "_", :With = "*", :StartingAt = 1 )
	? @@( o1.Content() )
	#--> [ "B", "*", "C", "D", "E", "*", "G", "H", "F" ]

	o1.ReplacePreviousOccurrences( :Of = "*", :With = Heart(), :StartingAt = :LastString )
	? @@( o1.Content() )
	#--> [ "B", "♥", "C", "D", "E", "♥", "G", "H", "F" ]
