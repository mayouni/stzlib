load "stzlib.ring"


/*==== CREATING CONTIGUOUS LISTS USING A SHORT FORM OF A LIST PROVIDED IN A STRING

	? BothAreStringsInComputableForm("'str1'" , '"str2"') #--> TRUE
	
	? StzStringQ(' 2 : 5 ').ToList()
	#--> [ 2, 3, 4, 5 ]

	? StzStringQ(' "A" : "C" ').ToList()
	#--> [ "A", "B", "C" ]

	? StzStringQ(' "@name1" : "@name3" ').ToList()
	#--> [ "@name1", "@name2", "@name3" ]
	
	? StzListQ(' 2 : 5 ').Content()
	#--> [ 2, 3, 4, 5 ]

	? StzListQ(' "A" : "C" ').Content()
	#--> [ "A", "B", "C" ]

	? StzListQ(' "@name1" : "@name3" ').Content()
	#--> [ "@name1", "@name2", "@name3" ]
	
	? StzListOfNumbersQ(' 2 : 5 ').Content()
	#--> [ 2, 3, 4, 5 ]

	? StzListOfCharsQ(' "A" : "C" ').Content()
	#--> [ "A", "B", "C" ]

	? StzListQ(' "@name1" : "@name3" ').Content()
	#--> [ "@name1", "@name2", "@name3" ]
	
/*==== REPLACING ALL STRINGS WITH A NEW STRING

	o1 = new stzListOfStrings([ "A", "B", "C" ])
	o1.ReplaceAllStrings(:With = Heart() )
	
	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]

/*==== REPLACING ALL OCCURRENCES OF A STRING

	o1 = new stzListOfStrings([ "A", :Heart, "B", :Heart, "C" ])
	o1.ReplaceAllOccurrencesOfString(:Heart, :With = "♥")
			
	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C" ]

/*==== REPLACING MANY STRINGS AT THE SAME TIME

	o1 = new stzListOfStrings([ "A", :Small, "B", :Medium, "C", :Medium, "D", :Large ])
	o1.ReplaceManyStrings( [ :Small, :Medium, :Large ], "♥" )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥", "D", "♥" ]

/*==== REPLACING MANY STRINGS BY MANY OTHERS ONE BY ONE

	o1 = new stzListOfStrings([ "A", :Heart, "B", :Smile, "C", :Sun, "D", :Star ])
	o1.ReplaceManyOneByOne( [ :Heart, :Smile, :Sun, :Star ], [ "♥", "😆", "🌞", "★" ] )

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "😆", "C", "🌞", "D", "★" ]

/*==== REPLACING A STRING BY MANY OTHERS BY ALTERNANCE

	o1 = new stzListOfStrings([ "A", "A", "A", "A", "A" ])
	o1.ReplaceStringByAlternance("A", :With = [ "#1", "#2" ])
	
	? @@( o1.Content() ) #--> [ "#1", "#2", "#1", "#2", "#1" ]	

/*==== REPLACING THE NEXT OCCURRENCES OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION

	o1 = new stzListOfStrings([ "♥", "♥", "_", "_", "♥", "_" ])
	o1.ReplaceNextOccurrences( :Of = "_", :With = "♥", :StartingAt = o1.FirstOccurrence(:Of = "_") )

	? @@( o1.Content() ) #--> [ "♥", "♥", "♥", "♥", "♥", "♥" ]

/*==== REPLACING THE PREVIOUS OCCURRENCES OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION

	o1 = new stzListOfStrings([ "♥", "♥", "_", "_", "♥", "_" ])
	o1.ReplacePreviousOccurrences( :Of = "_", :With = "♥", :StartingAt = o1.LastOccurrence(:Of = "_") )

	? @@( o1.Content() ) #--> [ "♥", "♥", "♥", "♥", "♥", "♥" ]

/*==== REPLACING NTH OCCURRENCE OF A STRING-ITEM

	o1 = new stzListOfStrings([ "A", "♥", "A", "♥", "C", "♥" ]) 
	o1.ReplaceNthOccurrence(2, :Of = "A", :With = "B")

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REPLACING FIRST OCCURRENCE OF A STRING

	o1 = new stzListOfStrings([ "B", "♥", "B", "♥", "C", "♥" ]) 
	o1.ReplaceFirstOccurrence(:Of = "B", :With = "A")

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REPLACING LAST OCCURRENCE OF A STRING     #

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "B", "♥" ]) 
	o1.ReplaceLastOccurrence(:Of = "B", :With = "C")

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]


/*==== REPLACING NEXT NTH OCCURRENCE OF A STRING
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥" ])
	o1.ReplaceNextNthOccurrence(2, :Of = "♥", :With = "C", :StartingAt = 2)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REPLACING NEXT OCCURRENCE OF A STRING
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A", "♥", "B", "♥", "♥", "♥" ])
	//o1.ReplaceNextNthOccurrence(1, :Of = "♥", :With = "C", :StartingAt = 4)
	o1.ReplaceNextOccurrence(:Of = "♥", :With = "C", :StartingAt = 4)

	? @@( o1.Content() ) #--> [ "A", "♥", "B", "♥", "C", "♥" ]

/*==== REPLACING MANY NEXT NTH OCCURRENCES OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A" , "B", "A", "C", "A", "D", "A" ])
	o1.ReplaceNextNthOccurrences([2, 3], :Of = "A", :With = "♥",  :StartingAt = 3)
	? @@( o1.Content() ) #--> [ "A", "B", "A", "C", "♥", "D", "♥" ]

/*==== REPLACING PREVIOUS NTH OCCURRENCE OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A" , "B", "A", "C", "A", "D", "A" ])
	o1.ReplacePreviousNthOccurrences([3, 1], :Of = "A", :With = "♥",  :StartingAt = 5)
	? @@( o1.Content() ) #--> [ "♥", "B", "A", "C", "♥", "D", "A" ]

/*==== REPLACING PREVIOUS OCCURRENCE OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A", "_", "C", "D" ])
	o1.ReplacePreviousOccurrence(:Of = "_", :With = "B", :StartingAt = 3)

	? @@( o1.Content() ) #--> [ "A", "B", "C", "D" ]

/*==== REPLACING MANY PREVIOUS NTH OCCURRENCES OF A STRING-ITEM
/*==== STARTING AT A GIVEN POSITION IN THE LIST

	o1 = new stzListOfStrings([ "A" , "B", "A", "C", "A", "D", "A" ])
	o1.ReplacePreviousNthOccurrences([2, 3], :Of = "A", :With = "*",  :StartingAt = 5)

	? @@( o1.Content() ) #--> [ "*", "B", "*", "C", "A", "D", "A" ]

/*==== REPLACING STRING-ITEM BY POSITION

	o1 = new stzListOfStrings([ "A", "b", "C" ])
	o1.ReplaceStringAtPosition(2, :With = "♥" )

	? @@( o1.Content() ) #--> [ "A", "♥", "C" ]

#--

	o1 = new stzListOfStrings([ "A", "b", "C" ])
	o1.ReplaceStringAtPosition(2, :With@ = 'upper(@string)' )

	? @@( o1.Content() ) #--> [ "A", "B", "C" ]

/*==== REPLACING MANY STRINGS BY POSITION

	o1 = new stzListOfStrings([ "A", "b", "C", "d" ])
	o1.ReplaceStringsAtPositions([ 2, 4 ], :With = "♥" )

	? @@( o1.Content() ) #--> [ "A", "♥", "C", "♥" ]

#--

	o1 = new stzListOfStrings([ "ONE", "two", "THREE", "four" ])
	o1.ReplaceStringsAtPositions([ 2, 4 ], :With@ = 'upper(@string)' )

	? @@( o1.Content() ) #--> [ "ONE", "TWO", "THREE", "FOUR" ]

/*==== REPLACING STRINGS AT GIVEN POSITIONS BY OTHER GIVEN STRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "Heart", "_", "Star", "_", "Sun", "_" ])
	o1.ReplaceStringsAtPositionsOneByOne([ 2, 4, 6], :With = [ "♥", "★", "🌞" ])
	#--> Short form: ReplaceStringsAtPositions1B1()

	? @@( o1.Content() ) #--> [ "Heart", "♥", "Star", "★", "Sun", "🌞" ]

/*==== REPLACING STRINGS AT GIVEN POSITIONS BY OTHER GIVEN STRINGS BY ALTERNANCE

	o1 = new stzListOfStrings([ "A", "_", "B", "_", "C", "_", "D" ])
	o1.ReplaceStringsAtPositionsByAlternance([ 2, 4, 6], :With = [ "#1", "#2" ])
	# Short form: ReplaceStringsAtPositions1B0()

	? @@( o1.Content() ) #--> [ "A", "#1", "B", "#2", "C", "#1", "D" ]
#____________________________________________________________________________________

/*==== REPLACING A SECTION OF STRINGS BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceSection(3, 5, :With = "C")
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D" ]
	
#--
	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceRange(3, 3, :With = "C")
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D" ]


/*---- REPLACING MANY SECTIONS OF STRINGS BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "C" ])
	o1.ReplaceManySections([ [2, 3], [5, 7] ], :With = "♥")
	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "C" ]

/*--

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "C" ])
	o1.ReplaceManyRanges([ [2, 2], [5, 3] ], :With = "♥")
	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "C" ]

/*---- REPLACING EACH STRING IN SECTION BY ONE GIVEN STRING

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInSection(3, 5, "♥")
	? @@( o1.Content() ) #--> [ "A", "B", "♥", "♥", "♥", "D" ]
#--
	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInRange(3, 3, "♥")
	? @@( o1.Content() ) #--> [ "A", "B", "♥", "♥", "♥", "D" ]

/*---- REPLACING EACH STRING IN MANY SECTIONS BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInManySections([ [2, 3], [5, 7] ], "♥")
	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "D" ]
#--
	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInManyRanges([ [2, 2], [5, 3] ], "♥")
	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "D" ]

/*---- REPLACING A SECTION OF STRINGS IN THE LIST
/*---- BY MANY STRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_" ])
	o1.ReplaceSectionOneByOne(3, 5, [ "C", "D", "E" ])
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D", "E", "E" ]
	
#--
	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_" ])
	o1.ReplaceRangeOneByOne(3, 3, [ "C", "D", "E" ])
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D", "E", "E" ]

/*---- REPLACING A RANGE OF STRINGS IN THE LIST
/*---- BY MANY STRINGS BY ALTERNANCE

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "_", "_", "C" ])
	o1.ReplaceSectionByAlternance(3, 7, [ "#1", "#2", "#3" ])

	? @@( o1.Content() ) #--> [ "A", "B", "#1", "#2", "#3", "#1", "#2", "C" ]
	
#--
	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "_", "_", "C" ])
	o1.ReplaceRangeByAlternance(3, 5, [ "#1", "#2", "#3" ])

	? @@( o1.Content() ) #--> [ "A", "B", "#1", "#2", "#3", "#1", "#2", "C" ]

/*---- REPLACING MANY SECTIONS OF STRINGS IN THE LIST
/*---- BY MANY STRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManySectionsOneOnyOne([ [2, 3], [5, 7] ], [ "#1", "#2", "#3", "#4", "#5" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#4", "#5", "D" ]
#--

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManyRangesOneOnyOne([ [2, 2], [5, 3] ], [ "#1", "#2", "#3", "#4", "#5" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#4", "#5", "D" ]

/*---- REPLACING MANY SECTIONS OF STRINGS IN THE LIST
/*---- BY MANY STRINGS BY ALTERNANCE 
*/
	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManySectionsByAlternance([ [2, 3], [5, 7] ], [ "#1", "#2", "#3" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#1", "#2", "D" ]

#--

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManyRangesByAlternance([ [2, 2], [5, 3] ], [ "#1", "#2", "#3" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#1", "#2", "D" ]

#____________________________________________________________________________________


/*==== REPLACING ALL STRINGS IN THE LIST WITH A GIVEN NEW STRING

	def ReplaceAllStringsWith(pcOtherString)


/*==== REPLACING STRINGS UNDER A GIVEN CONDITION

	def ReplaceStringsW(pCondition, pcOtherString)

/*==== REPLACING A RANGE OF STRINGS BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceRange(3, 3, :With = "C")
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D" ]

/*---- REPLACING MANY RANGES OF STRINGS BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "C" ])
	o1.ReplaceManyRanges([ [2, 2], [5, 3] ], :With = "♥")

	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "C" ]

/*---- REPLACING EACH STRING IN RANGE BY ONE GIVEN STRING

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInRange(3, 3, :With = "♥")
	? @@( o1.Content() ) #--> [ "A", "B", "♥", "♥", "♥", "D" ]

/*---- REPLACING EACH STRING IN MANY RANGES BY A GIVEN STRING

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceEachStringInManyRanges([ [2, 2], [5, 3] ], "♥")
	? @@( o1.Content() ) #--> [ "A", "♥", "♥", "B", "♥", "♥", "♥", "D" ]

/*---- REPLACING A RANGE OF STRINGS IN THE LIST
/*---- BY MANY STRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "A", "B", "_", "_", "_" ])
	o1.ReplaceRangeOneByOne(3, 3, [ "C", "D", "F" ])
	? @@( o1.Content() ) #--> [ "A", "B", "C", "D", "E", "F" ]

/*---- REPLACING A RANGE OF STRINGS BY MANY OTHER STRINGS BY ALTERNANCE

	o1 = new stzListOfStrings([ "A", "_", "_", "_", "_", "_", "C" ])
	o1.ReplaceRangeByAlternance(2, 5, :With = [ "#1", "#2", "#3" ])
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "#3", "#1", "#2", "C" ]

/*---- REPLACING MANY RANGES OF STRINGS IN THE LIST
/*---- BY MANY STRINGS ONE BY ONE
	
	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManyRangesOneOnyOne([ [2, 2], [5, 3] ], [ "#1", "#2", "#3", "#4", "#5" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#4", "#5", "D" ]

/*---- REPLACING MANY RANGES OF STRINGS IN THE LIST
/*---- BY MANY STRINGS BY ALTERNANCE 

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_", "_", "_", "D" ])
	o1.ReplaceManyRangesByAlternance([ [2, 2], [5, 3] ], [ "#1", "#2", "#3" ] )
	? @@( o1.Content() ) #--> [ "A", "#1", "#2", "B", "#3", "#1", "#2", "D" ]

/*==== REPLACING SUBSTRINGS IN EACH STRING IN THE LIST OF STRINGS

	def ReplaceSubStringCS(pcSubStr, pcNewStr, pCaseSensitive)

/*---- REPLACING MANY SUBSTRINGS FROM EACH STRING IN THE LIST OF STRINGS

	def ReplaceSubStringsCS(pacSubStr, pcNewStr, pCaseSensitive)


/*---- REPLACING MANY SUBSTRINGS BY MANY OTHERS ONE BY ONE

	def ReplaceManySubStringsOneByOneCS(pacSubStr, pacNewStr, pCaseSensitive)


/*---- REPLACING NEXT NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION  #

	def ReplaceNextNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)

/*---- REPLACING NEXT OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION

	def ReplaceNextSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)


/*---- REPLACING PREVIOUS NTH OCCURRENCE OF A SUBSTRING STARTING AT A GIVEN POSITION

	def ReplacePreviousNthSubStringCS(n, pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)


/*---- REPLACING PREVIOUS OCCURRENCE OF SUBSTRING STARTING AT A GIVEN POSITION

	def ReplacePreviousSubStringCS(pcSubStr, pcNewSubStr, pnStartingAt, pCaseSensitive)


/*---- REPLACING SUBSTRINGS VERIYING A GIVEN CONDITION

	def ReplaceSubStringsW(pcCondition, pcNewStr)

? StzListQ([ [2,5], [7, 10], [12, 15] ]).IsListOfPairsOfNumbers() #--> TRUE
