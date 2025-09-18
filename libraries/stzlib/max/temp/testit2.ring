# Designing a QML app SCRIPTABLE by Ring

QmlApp() {
	# Setting the window size
    	width = 400
    	height = 400
    	visible = 1

	# Creating a button

    	Button() {
        	text = "Say Hello from Ring!"
		onClick = SayHelloFromRing(This) # Calling Ring code
	}

	# Displaying the window

	exec()
}

# The Ring code

func SayHelloFromRing(oQMLApp)
	oQMLApp.Console().Print("HELLO FROM RING!")








load "../stzlib.ring"

#----------------#
#   STZ STRING   #
#----------------#

/*------- CONTAINING A SUBSTRING BOUNDED BY A GIVEN SUBSTRING

	o1 = new stzString("lorem__ipsum__lorem")
	? o1. ContainsSubStringBoundedBy("ipsum", "__") 		#--> TRUE
	? o1.ContainsSubStringBoundedByCS("IPSUM", "__", :CS = 0) 	#--> TRUE

	o1 = new stzString("lore_mmmipsuMmM_lorem")
	? o1.ContainsSubStringBoundedByCS("ipsu", "mmm", :CS = 0)	#--> TRUE
	? o1.ContainsSubStringBoundedByCS("IPSU", "mmm", :CS = 0)	#--> TRUE
	
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
		[ :RemoveThisSubStringBefore = "X", :RemoveThisSubStringAfter = "X", :CS = 0 ] )

	? o1.Content() #--> 123901

	# Extended form 4:
	#-----------------

	o1 = new stzString("123xyz567xYZ901")

	o1.RemoveSubStringAtXT(7, "567",
		[ :RemoveThisBound = "XyZ", :CS = 0 ] )

	? o1.Content() #--> 123901

#-------------------------#
#   STZ LIST OF STRINGS   #
#-------------------------#

/*------- FINDING A SUBSTRING INSIDE THE LIST OF STRINGS

profon()
	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])

	? @@( o1.FindSubstringCS("name", 1) )
	#--> [ [ 1, [ 13 ] ], [ 3, [ 6, 18 ] ] ]

proff()
# Executed in 0.03 second(s)

/*------- GETTING A SECTION OF A LIST OF STRINGS

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_" ])
	? @@( o1.SectionQ(2, 4).Content() ) #--> [ "_", "_", "B" ]

/*------- FINDING NEXT/PREVIOUS OCCURRENCE(S) OF A STRING

	o1 = new stzListOfStrings([ "A", "_", "_", "B", "_" ])
	? o1.FindNext("_", :StartingAt = 2)	 #--> 3
	? o1.FindPrevious("_", :StartingAt = 4)	 #--> 3
	
	? @@( o1.FindNextOccurrences(:Of = "_", :StartingAt = 3) ) #--> [ 3, 5 ]       
	? @@( o1.FindPreviousOccurrences(:Of = "_", :StartingAt = 4) ) #--> [ 2, 3 ]
	
/*------- REPLACING ALL STRINGS WITH A NEW STRING

	o1 = new stzListOfStrings([ "A", "B", "C" ])
	o1.ReplaceAllStrings(:With = "A")
	? o1.Content() #--> [ "A", "A", "A" ]

/*------- REPLACING ALL OCCURRENCES OF A STRING
*/
profon()

	o1 = new stzList([ "A", "*", "B", "*", "C" ])
	o1.ReplaceAllOccurrences(:of = "*", :With = "♥")
	? o1.Content() #--> [ "A", "♥", "B", "♥", "C" ]
	
	#-- CS

	o1 = new stzList([ "ring", "Ring", "RING" ])
	o1.ReplaceCS(:ring, :By@ = 'upper("ring")', :CaseSensitive = 0)
	? o1.Content() #--> [ "RING", "RING", "RING" ]

proff()

/*------- REPLACING MANY STRINGS AT THE SAME TIME
*/
profon()
	o1 = new stzList([ "blabla1", "One", "blabla2", "Two", "blabla3", "Three" ])
	o1.ReplaceMany([ "blabla1", "blabla2", "blabla3" ], :with = "♥" )
	? @@( o1.Content() ) #--> [ "♥", "One", "♥", "Two", "♥", "Three" ]

	#-- CS

	o1 = new stzList([ "Tunis", "CAIRO", "Bagdad" ])
	o1.ReplaceManyCS([ :tunis, :cairo, :bagdad ], :With = "♥", :CS = 0)
	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]
proff()
# Executed in 0.02 second(s)

/*------- REPLACING MANY STRINGS AT THE SAME TIME
*/
profon()

	o1 = new stzList([ "TUNIS", "CAIRO", "bagdad" ])
	o1.ReplaceMany([ "Tunis", "Cairo", "Bagdad" ], :With = "♥")
	? @@( o1.Content() ) #--> [ "Tunis", "CAIRO", "Bagdad" ]

	o1.ReplaceManyCS([ "Tunis", "Cairo", "Bagdad" ], :With = "♥", :CS = 0)
	? @@( o1.Content() ) #--> [ "♥", "♥", "♥" ]

proff()

/*------- REPLACING MANY STRINGS BY MANY OTHERS (ONE BY ONE)
*/
profon()
	o1 = new stzList([ :tunis, "ALGERIA", :cairo, "LIBYA", :bagdad ])
	
	o1.ReplaceManyByMany([ :tunis,   :cairo, :bagdad ],
			:By  = [ "TUNISIA", "EGYPT", "IRAQ"  ])
	
	? o1.Content() #--> [ "TUNISIA", "ALGERIA", "EGYPT", "LIBYA", "IRAQ" ]

proff()

/*------- REPLACING A STRING BY ALTERNANCE


	o1 = new stzListOfStrings([ "A", "A", "A", "A", "A" ])
	o1.ReplaceStringByAlternance("A", :With = [ "#1", "#2" ])
	? @@( o1.Content() )
	#--> [ "#1", "#2", "#1", "#2", "#1" ]

/*------- REPLACING NTH OCCURRENCE OF A STRING

	o1 = new stzListOfStrings([ "___", "Moon", "___", "Star", "___" ])
	o1.ReplaceNthOccurrence(2, :Of = "___", :With = "Sun")
	? @@( o1.Content() ) + NL #--> [ "___", "Moon", "Sun", "Star", "___" ]

	o1.ReplaceFirstOccurrence(:Of = "___", :With = "Earth")
	? @@( o1.Content() ) + NL #--> [ "Earth", "Moon", "Sun", "Star", "___" ]

	o1.ReplaceLastOccurrence(:Of = "___", :With = "Mars")
	? @@( o1.Content() ) #--> [ "Earth", "Moon", "Sun", "Star", "Mars" ]

/*------- REPLACING NEXT NTH OCCURRENCE OF A STRING STARTING AT A GIVEN POSITION

	o1 = new stzListOfStrings([ "_", "_", "C", "_", "E", "_", "G", "_", "_" ])
	o1.ReplaceNextOccurrence(:Of = "_", :With = "H", :StartingAt = 7)
	? @@( o1.Content() ) + NL
	#--> [ "_", "_", "C", "_", "E", "_", "G", "H", "_" ]

#--

	o1.ReplacePreviousOccurrence(:Of = "_", :With = "D", :StartingAt = 5)
	? @@( o1.Content() ) + NL
	#--> [ "_", "_", "C", "D", "E", "_", "G", "H", "_" ]
#--

	o1.ReplaceNextNthOccurrence(2, :Of = "_", :With = "F", :StartingAt = 3 )
	? @@( o1.Content() ) + NL #--> [ "_", "_", "C", "_", "E", "F", "G", "_" ]
	#--> [ "_", "_", "C", "D", "E", "_", "G", "H", "F" ]
#--

	o1.ReplacePreviousNthOccurrence(2, :Of = "_", :With = "B", :StartingAt = 5 )
	? @@( o1.Content() ) + NL #--> [ "_", "B", "C", "_", "E", "F", "G", "_" ]
	#--> [ "B", "_", "C", "D", "E", "_", "G", "H", "F" ]
#--

	o1.ReplaceNextOccurrences( :Of = "_", :With = "*", :StartingAt = 1 )
	? @@( o1.Content() ) + NL
	#--> [ "B", "*", "C", "D", "E", "*", "G", "H", "F" ]

	o1.ReplacePreviousOccurrences( :Of = "*", :With = Heart(), :StartingAt = :LastString )
	? @@( o1.Content() )
	#--> [ "B", "♥", "C", "D", "E", "♥", "G", "H", "F" ]
