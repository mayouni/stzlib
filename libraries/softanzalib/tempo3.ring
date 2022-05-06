load "stzlib.ring"


/*==== REPLACING ALL OCCURRENCES OF A SUBSTRING IN THE LIST WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "My heart and", "your heart", "and their hearts" ])
	o1.ReplaceSubString("heart", :With = "♥")

	? @@( o1.Content() ) #--> [ "My ♥ and", "your ♥", "and their ♥s" ]


/*---- REPLACING MANY SUBSTRING IN THE LIST WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "My heart and", "your sun", "and their stars" ])
	o1.ReplaceSubStrings([ "heart", "sun", "star" ], :With = "♥")

	? @@( o1.Content() ) #--> [ "My ♥ and", "your ♥", "and their ♥s" ]

/*--- REPLACING A SUBSTRING AT POSITION N WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "Lorem", "Lorem heart ipsum", "Ipsum" ])
	o1.ReplaceSubStringAtPosition(2, "heart", :With = "♥")

	? @@( o1.Content() ) #--> [ "Lorem", "Lorem ♥ ipsum", "Ipsum" ]

/*--- REPLACING MANY SUBSTRINGS AT POSITION N WITH A NEW SUBSTRING 

	o1 = new stzListOfStrings([ "Lorem", "Lorem heart ipsum", "Ipsum" ])
	o1.ReplaceSubStringsAtPosition(2, [ "Lorem", "heart", "ipsum" ], :With = "♥")

	? @@( o1.Content() ) #--> [ "Lorem", "♥ ♥ ♥", "Ipsum" ]

/*--- REPLACING A SUBSTRING AT POSITIONS WITH A NEW SUBSTRING 

	o1 = new stzListOfStrings([ "Heart Lorem Ipsum", "Lorem ♥ Ipsum", "Lorem Ipsum Heart" ])
	o1.ReplaceSubStringAtPositions([1, 3], "Heart", :With = "♥")

	? @@( o1.Content() ) #--> [ "♥ Lorem Ipsum", "Lorem ♥ Ipsum", "Lorem Ipsum ♥" ]

/*--- REPLACING MANY SUBSTRINGS AT POSITIONS WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "Country Lorem Ipsum", "Lorem ♥ Ipsum", "Lorem Ipsum Nation" ])
	o1.ReplaceSubStringsAtPositions([1, 3], [ "Country", "Nation" ], :With = "♥")

	? @@( o1.Content() ) #--> [ "♥ Lorem Ipsum", "Lorem ♥ Ipsum", "Lorem Ipsum ♥" ]

/*--- REPLACING A SUBSTRING AT POSITIONS WITH MANY NEW SUBSTRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "This is a ___!", "This is a star!", "This is a ___!" ])
	o1.ReplaceSubStringAtPositionsOneByOne([ 1, 3 ], "___", :With = [ "♥", "🌞" ])
	
	? @@( o1.Content() ) #--> [ "This is a ♥!", "This is a star!", "This is a 🌞!" ]


/*--- REPLACING MANY SUBSTRINGS AT POSITIONS WITH MANY NEW SUBSTRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "This is a heart!", "This is a ★!", "This is a sun!" ])
	o1.ReplaceSubStringsAtPositionsOneByOne( [1, 3], [ "heart", "sun" ], :With = [ "♥", "🌞" ])
	
	? @@( o1.Content() ) #--> [ "This is a ♥!", "This is a ★!", "This is a 🌞!" ]

/*--- REPLACING A SUBSTRING AT POSITIONS WITH A NEW SUBSTRING BY ALTERNANCE

	o1 = new stzListOfStrings([ "This is a ___!", "This is a ___!", "This is a ___!" ])
	o1.ReplaceSubStringAtPositionsByAlternance([ 1, 2, 3 ], "___", :With = [ "🌞", "♥" ])
	
	? @@( o1.Content() ) #--> [ "This is a 🌞!", "This is a ♥!", "This is a 🌞!" ]


/*--- REPLACING MANY SUBSTRINGS AT POSITIONS WITH A NEW SUBSTRING BY ALTERNANCE

	o1 = new stzListOfStrings([ "This is a heart!", "This is a sun!", "This is a sun!" ])
	o1.ReplaceSubStringsAtPositionsByAlternance( [1, 2, 3], [ "heart", "sun" ], :With = [ "♥", "🌞" ])
	
	? @@( o1.Content() ) #--> [ "This is a ♥!", "This is a 🌞!", "This is a ♥!" ]

/*--- REPLACING A SUBSTRING BY MANY SUBSTRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "lorem heart", "heart ipsum", "heart ipsum heart" ])
	o1.ReplaceSubStringBySubStringsOneByOne("heart", [ "♥", "🌞", "★" ])

	? @@( o1.Content() ) #--> [ "lorem ♥", "🌞 ipsum", "★ ipsum ★" ]

/*--- REPLACING MANY SUBSTRINGS INSIDE THE STRING AT POSITION N BY MANY OTHER SUBSTRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "Who're you?", "Your heart is made of sun and stars, you'r the nearest to sun of all the stars", "You're the own light of sun and stars!"])
	o1.ReplaceSubStringsAtPositionNOneByOne( 2, [ "heart", "sun", "star" ], [ "♥", "🌞", "★" ] )

	? @@S( o1.Content() )	// "S" for Spacified, so the list is printed line by line ;)
	#--> [ 	"Who're you?",
	# 	"Your ♥ is made of 🌞 and ★s, you'r the nearest to 🌞 of all the ★s",
	# 	"You're the own light of sun and stars!"
	#    ]

/*--- FINDING THE POSITIONS OF A GIVEN SUBSTRING IN THE STRING AT POSITION N

	o1 = new stzListOfStrings([ "Who're you?", "Your heart is made of sun and stars, you're the sun, you're the star of all the stars", "You're the own light of sun and stars!"])
	? @@( o1.FindSubStringAtPositionN(2, "star") )
	#--> [ 31, 65, 81 ]

/*--- REPLACING A SUBSTRING AT POSITION N IN THE STRING AT POSITION N WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "<<", "heart lorem heart ipsum heart and heart", ">>" ])
	o1.ReplaceSubStringAtPositionN2InStringAtPositionN1(2, 13, "heart", "♥♥♥")

	? @@( o1.Content() ) #--> [ "<<", "heart lorem ♥♥♥ ipsum heart and heart", ">>" ]

/*--- REPLACING A SUBSTRING AT SOME POSITIONS IN THE STRING AT POSITION N WITH A NEW SUBSTRING

	o1 = new stzListOfStrings([ "<<", "heart lorem heart ipsum heart and heart", ">>" ])
	o1.ReplaceSubStringAtPositionsInStringAtPositionN(2, [ 13, 25 ], "heart", "♥♥♥")
	
	? @@( o1.Content() ) #--> [ "<<", "heart lorem ♥♥♥ ipsum ♥♥♥ and heart", ">>" ]

/*--- REPLACING A SUBSTRING INSIDE THE STRING AT POSITION N BY MANY OTHER SUBSTRINGS BY ALTERNANCE
*/
	o1 = new stzListOfStrings([ "<<", "heart lorem heart ipsum heart and heart", ">>" ])
	o1.ReplaceSubStringAtPositionNByALternance(2, "heart", :With = [ "#1", "#2" ])

	? @@( o1.Content() )
	#--> [ "<<", "#1 lorem #2 ipsum #1 and #2", ">>"  ]

/*--- REPLACING MANY SUBSTRINGS INSIDE THE STRING AT POSITION N BY MANY OTHER SUBSTRINGS BY ALTERNANCE

	o1 = new stzListOfStrings([ "Who're you?", "Your heart is made of sun and stars, you're the sun, you're the star of all the stars", "You're the own light of sun and stars!"])
	o1.ReplaceSubStringsAtPositionNByAlternance( 2, [ "heart", "sun", "star" ], [ "#1", "#2" ] )

	? @@S( o1.Content() )	// "S" for Spacified, so the list is printed line by line ;)
	#--> [ 	"Who're you?",
	# 	"Your #1 is made of #1 and #1s, you're the #2, you're the #2 of all the #3",
	# 	"You're the own light of sun and stars!"
	#    ]

/*--- REPLACING MANY SUBSTRINGS BY MANY OTHER SUBSTRINGS ONE BY ONE

	o1 = new stzListOfStrings([ "lorem heart ipsum sun", "heart and sun", "lorem ipsum heart" ])
	o1.ReplaceSubStringsByManySubStringsOneByOne([ "heart", "sun" ], :By = [ "♥", "🌞" ])

	? @@( o1.Content() ) #--> [ "lorem ♥ ipsum 🌞", "♥ and 🌞", "lorem ipsum ♥" ]

/*--- REPLACING A SUBSTRING BY MANY SUBSTRINGS BY ALTERNANCE   #

	o1.ReplaceSubStringByManySubStringsByAlternance(pcSubStr, pacNewSubStr)


/*--- REPLACING MANY SUBSTRINGS BY MANY OTHER SUBSTRINGS BY ALTERNANCE   #


	o1.ReplaceSubStringsByManySubStringsByAlternance(pacSubStr, pacNewSubStr)



