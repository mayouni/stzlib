load "stzlib.ring"

/*------
*/
	o1 = new stzList([ "A", "B", "C", "D", "E" ])
	? o1.ContainsSome([ "B", "D", "V" ]) #--> TRUE


	o1 = new stzListOfStrings([ "A", "B", "C", "D", "E" ])
	? o1.ContainsSome([ "B", "D", "V" ]) #--> TRUE

/*------

	o1 = new stzList([ "from", 1, "to", 10, "step", 2 ])

	? o1.ListWithStringsUppercased()
	#--> [ "FROM", 1, "TO", 10, "STEP", 2 ]

	? o1.StringsUppercased()
	#--> [ "FROM","TO", "STEP" ]

/*------

	o1 = new stzList([ "FROM", 1, "TO", 10, "STEP", 2 ])
 
	? o1.ListWithStringsLowercased()
	#--> [ "from", 1, "to", 10, "step", 2 ]

	? o1.StringsLowercased()
	#--> [ "from","to", "step" ]

/*------

	o1 = new stzList([ "from", 1, "to", 10, "step", 2 ])

	? o1.ListWithStringsTitlecased()
	#--> [ "From", 1, "To", 10, "Step", 2 ]

	? o1.StringsTitlecased()
	#--> [ "From","To", "Step" ]

/*------

	o1 = new stzString("e28c98")
	o1.InsertEveryNChars(2, " ")
	? o1.Content()

/*------

	o1 = new stzString("ring programming language")
	? o1.Walk(:From = 6, :To = 16, :Step = 2, :Return = :WalkedChars)
	#--> [ "p", "o", "r", "m", "i", "g" ]

	? o1.WalkXT([])
	#--> [ 	"r","i","n","g"," ",
	# 	"p","r","o","g","r","a","m","m","i","n","g"," ",
	# 	"l","a","n","g","u","a","g","e" ]

	? o1.WalkXT([ :From = 6, :To = 16, :Step = 2, :Return = :WalkedPositions ])
	#--> [ 6, 8, 10, 12, 14, 16 ]

	? o1.WalkXT([ :From = 6, :To = 16, :Step = 2, :Return = :WalkedChars ])
	#--> [ "p", "o", "r", "m", "i", "g" ]

/*------

	? Q("⌘").CharName()		#--> PLACE OF INTEREST SIGN
	? Q("⌘").ToHex()		#--> e28c98
	? Q("⌘").NumberOfChars()	#--> 1
	? Q("⌘").NumberOfBytes()	#--> 3
	? Q("⌘").ToHexSpacified()	#--> e2 8c 98 

/*------

	SetHilightChar(Heart())

	? StzListOfCharsQ("TEXT").BoxedXT([
		:Line = :Thin,	# or :Dashed
		
		:AllCorners = :Round, # can also be :Rectangualr

		# Or you can specify evey corner like this:
		# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

		:Hilighted = [ 3 ] # The 3rd char is hilighted
		
	])

#--> 	╭───┬───┬───┬───╮
#	│ T │ E │ X │ T │
#	╰───┴───┴─♥─┴───╯

  #------------------------------#
 #   CONTAINMENT IN STZSTRING   #
#------------------------------#

Planets = [
	"earth", "venus", "mercury", "mars",
	"jupiter", "saturn", "uranus", "neptune"
]

o1 = new stzString("
	The farthest the Earth ever gets from the Sun is 152 million kilometers
	and the nearest Mars ever gets to the Sun is 207 million kilometers.
	So Earth and Mars could, very rarely, be a little less than 55 million
	kilometers (34 million miles) apart, when they are directly in line
	with the Sun. The closest recent distance was in 2003, when they
	were 56 million kilometers at closest approach.
")

? o1.ContainsSomeCS(Planets , :CS = FALSE) 	#--> TRUE
? o1.ContainsSomeCS(Planets , :CS = TRUE) 	#--> FALSE

? @@( o1.FindManyXT(Planets, [ :CS = FALSE, :RemoveEmpty = FALSE ]) ) + NL
#--> [
#	[ "earth", 	[ 20, 149 ] 	],
# 	[ "venus", 	[ ] 		],
# 	[ "mercury", 	[ ] 		],
# 	[ "mars", 	[ 92, 159 ] 	],
# 	[ "jupiter", 	[ ] 		],
# 	[ "saturn", 	[ ] 		],
# 	[ "uranus", 	[ ] 		],
# 	[ "neptune", 	[ ]		 ]
#   ]

? @@( o1.FindManyXT(Planets, [ :CS = FALSE, :RemoveEmpty = TRUE ]) ) + NL
#--> [ [ "earth", [ 20, 149 ] ], [ "mars", [ 92, 159 ] ] ]

  #-------------------------------------------------------------#
 #   CONTAINMENT IN STZTEXT & KNOWLEDGE PROGRAMMING (TODO)     #
#-------------------------------------------------------------#
/*---

StzEntityClassQ(
	:ClassName 	= :Planets,

	:EachEntityIsA  = :Planet,

	:ListOfEntities = [
		:Earth, :Venus, :Mercury, :Mars,
		:Jupiter, :Saturn, :Uranus, :Neptune
	]
])

StzEntityDataQ(
	:Earth 	  = [ :IsA = :Planet, :DiameterInKm = 12756,   :DistanceFromEarthInMKm = 0 ],
	:Venus 	  = [ :IsA = :Planet, :DiameterInKm = 12104,   :DistanceFromEarthInMKm = 170 ],
	:Mercury  = [ :IsA = :Planet, :DiameterInKm = 4880,    :DistanceFromEarthInMKm = 155 ],
	:Mars	  = [ :IsA = :Planet, :DiameterInKm = 6794,    :DistanceFromEarthInMKm = 253 ],
	:Jupiter  = [ :IsA = :Planet, :DiameterInKm = 142984,  :DistanceFromEarthInMKm = 0 ],
	:Saturn	  = [ :IsA = :Planet, :DiameterInKm = 120536,  :DistanceFromEarthInMKm = 0 ],
	:Uranus	  = [ :IsA = :Planet, :DiameterInKm = 51118,   :DistanceFromEarthInMKm = 0 ],
	:Neptune  = [ :IsA = :Planet, :DiameterInKm = 49532,   :DistanceFromEarthInMKm = 0 ],
	:Sun	  = [ :IsA = :Planet, :DiameterInKm = 1391000, :DistanceFromEarthInMKm = 149.6 ]
)

StzDefineFunction([
	:FunctionName	= "NearestToEarth()",

	:OnEnityClass 	= :Planets,
	:OnDataList	= [ :DistanceFromEarthInMKm ]

	:FunctionCode	= '{
		nMin = QR(@DataList, :stzListOfNumbers).Min()[1]
		return @DataList[nMin][1]
	}'
])

o1 = new stzText("
	The farthest the Earth ever gets from the Sun is 152 million kilometers
	and the nearest Mars ever gets to the Sun is 207 million kilometers.
	So Earth and Mars could, very rarely, be a little less than 55 million
	kilometers (34 million miles) apart, when they are directly in line
	with the Sun. The closest recent distance was in 2003, when they
	were 56 million kilometers at closest approach.
")

? o1.Contains(:Planets) 	#--> TRUE
? o1.ContainsN(3, :Planets) 	#!-->

? o1.ListOf(:Planets)
? o1.Nearest(:Planet).ToEarth()

/*====== OK

o1 = new stzList(["a","b", "C", "D", "e"])
? o1.FindW('isUpper(@item)') 		    #--> [3, 4]
? o1.FindW('') 				    #--> [1, 2, 3, 4, 5]

? @@(o1.YieldFromPositions([3,4,5] , ''))   #--> [ NULL, NULL, NULL ]

? @@( o1.YieldFromPositions([], '@item' ) ) #--> [ ]

/*===== VERIFYING A STATEMENT ON LISTS, LISTS OF STRINGS & STRINGS =========== OK

o1 = new stzList([ "A", "B", "C", "D", "E" ])

? o1.Check( :That = 'Q(@EachItem).IsUppercase()' )	#--> TRUE

o1 = new stzList("A":"E")
? o1.Check( :That = 'Q(@EachItem).IsUppercase()' )	#--> TRUE

#--

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E" ])

? o1.Check( :That = 'Q(@EachString).IsUppercase()' )	#--> TRUE

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E" ])
? o1.Check( :That = 'Q(@EachString).IsUppercase()' )	#--> TRUE

#-- OK

o1 = new stzString("RINGORIALAND")
? o1.Check( :That = 'Q(@EachItem).IsUppercase()' )	#--> TRUE

o1 = new stzString("ringorialand")
? o1.Check( :That = 'Q(@EachItem).IsLowercase()' ) 	#--> TRUE

/*----- OK

o1 = new stzList([ "BING", "BINGO", "BINGOO", "BINGOOO", "BINGOOOO" ])
? o1.Check( :That = '{ @NextItem = @item + "O" }' )	#--> TRUE

? o1.Check( :That = '{ @Item = @PreviousItem + "O" }')	#--> TRUE

o1 = new stzList([ 2, 4, 8, 16, 32, 64, 128, 256 ])
? o1.Check( :That = '{ Q(@NextItem).IsDoubleOf(@item) }') #--> TRUE

#-- OK

o1 = new stzString("0123456789")
? o1.Check( :That = '{ (0+ @NextChar) = (0+ @Char) + 1 }' )	#--> TRUE

? o1.Check( :That = '{ (0+ @PreviousChar) = (0+ @Char) - 1 }' ) #--> TRUE

o1 = new stzString("1248")
? o1.Check( :That = '{ Q( 0+@NextChar ).IsDoubleOf( 0+@char ) }') #--> TRUE

/*----- OK

o1 = new stzList([ "BING", "BINGO", "BINGOO", "BINGOOO", "BINGOOOO" ])
? o1.Check( :That = '{ @NextItem = @CurrentItem + "O" }' ) #--> TRUE
# Can also be expressed like this (but this too long):
? o1.Check( :That = '{ ItemAt(@NextPosition) = ItemAt(@CurrentPosition) + "O" }' ) #--> TRUE

o1 = new stzListOfStrings([ "BING", "BINGO", "BINGOO", "BINGOOO", "BINGOOOO" ])
? o1.Check( :That = '{ @NextString = @CurrentString + "O" }' ) #--> TRUE

/*----- OK

o1 = new stzString("0123456789")
? o1.Check( :That = '{ 0+@NextChar = 0+@CurrentChar + 1 }' ) #--> TRUE

o1 = new stzListOfStrings([ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ])
? o1.Check( :That = '{ 0+@NextChar = 0+@CurrentChar + 1 }' ) #--> TRUE

o1 = new stzString("AaBbCcDdEe")
? o1.Check( :That = '{ Q(@NextChar).HasDifferentCaseAs(@CurrentChar) }' ) #--> TRUE

o1 = new stzListOfStrings([ "A", "a", "B", "b", "C", "c", "D", "d", "E", "e" ])
? o1.Check( :That = '{ Q(@NextString).HasDifferentCaseAs(@CurrentString) }' ) #--> TRUE

/*----- CHECK ON POSITIONS (ON LISTS & STRINGS) ---- OK

o1 = new stzList([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])

? o1.CheckOnPositions([1, 3, 5], :That = 'Q(@item).IsLeftToRight()' ) 	#--> TRUE
? o1.CheckOnPositions([2, 4], :That = 'Q(@item).IsRightToLeft()' ) 	#--> TRUE
? o1.Check(:That = '{ Q(@item).Orientation() != Q(@NextItem).Orientation() }') #--> TRUE

#--

o1 = new stzListOfStrings([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])

? o1.CheckOn([1, 3, 5], :That = 'Q(@string).IsLeftToRight()' ) 	#--> TRUE
? o1.CheckOn([2, 4], :That = 'Q(@string).IsRightToLeft()' ) 	#--> TRUE
? o1.Check(:That = '{ Q(@string).Orientation() != Q(@NextString).Orientation() }') #--> TRUE

#-- OK

o1 = new stzString("aa3bb67dd0")
? o1.CheckOn([ 3, 6, 7, 10], :That = 'StzCharQ(@char).IsANumber()' ) #--> TRUE

o1 = new stzListOfStrings([ "a", "a", "3", "b", "b", "6", "7", "d", "d", "0" ])
? o1.CheckOn([ 3, 6, 7, 10], :That = 'StzCharQ(@char).IsANumber()' ) #--> TRUE

/*----- OK

o1 = new stzList([ [1,2], [5,6], [8,8] ])

? o1.IsListOfPairs() #--> TRUE
? o1.Check( :That = 'Q(@EachItem).IsPairOfNumbers()' ) #--> TRUE

/*----- OK

o1 = new stzList([ "UPP1", "UPP2", "low3", "low4", "UPP5", "UPP6", "low7", "UPP8" ])
? o1.CheckOnSections(
	[ [1,2], [5,6], [8,8] ], :That = 'Q(@EachItem).IsUppercase()' )	#--> TRUE

o1 = new stzListOfStrings([ "UPP1", "UPP2", "low3", "low4", "UPP5", "UPP6", "low7", "UPP8" ])
? o1.CheckOnSections(
	[ [1,2], [5,6], [8,8] ], :That = 'Q(@EachString).IsUppercase()' ) #--> TRUE

o1 = new stzString("aaaAAAAaaAAAaaA")
? o1.CheckOnSections([ [1,3], [8,9], [13,14] ], :That = 'Q(@EachChar).IsLowercase()') #--> TRUE

/*----- OK

o1 = new stzList([ ".", ".", ".", 8, 12, 10, ".", ".", ".", 7, 9 ,12, ".", ".", 56, 30, 12 ])

? o1.CheckOnSections(
	[ [ 4, 6], [10, 12], [15, 17] ],

	:That = 'Q(@EachItem).IsANumber()'
) #--> TRUE

? o1.CheckOnTheseSections(
	[ [1,3], [7,9], [13,14] ],
	
	:That = '{
	Q(@EachSection).IsMadeOf(["."])
	}'
) #--> TRUE

#--

o1 = new stzListOfStrings([
	".", ".", ".", "8", "12", "10", ".", ".", ".", "7",
	"9" ,"12", ".", ".", "56", "30", "12" ])

? o1.CheckOnSections(
	[ [ 4, 6], [10, 12], [15, 17] ], :That = 'Q( 0+@EachString ).IsANumber()' ) #--> TRUE

? o1.CheckOnTheseSections(
	[ [1,3], [7,9], [13,14] ],
	
	:That = '{
	Q(@EachSection).IsMadeOf(["."])
	}'
) #--> TRUE

#-- OK

o1 = new stzString("...456...012..567")
? o1.CheckOnSections(
	[ [ 4, 6], [10, 12], [15, 17] ], :That = 'StzCharQ(@EachItem).IsANumber()' ) #--> TRUE

? o1.CheckOnTheseSections(
	[ [1,3], [7,9], [13,14] ],
	
	:That = '{
	Q(@EachSection).IsMadeOf(["."])
	}'
) #--> TRUE

/*------

o1 = new stzListOfNumbers([ 12, 24, 48, 96, 192 ])
? o1.Check( :That = '@EachNumber = @NextNumber / 2') #--> TRUE

o1 = new stzListOfPairs([ [ "A1", 10 ], [ "A2", 20 ], [ "A3", 30 ], [ "A4", 40 ] ])
? o1.Check( :That = 'Q(@EachPair[1]).IsAString() and Q(@EachPair[2]).IsANumber()' ) #--> TRUE

/*==== YIELD FROM ALL ITEMS OF LIST =========== OK

o1 = new stzList([ "SUN", "EARTH", "Venus", "saturn", "mercury", "Mars", "NEPTUNE", "Jupiter" ])
? @@( o1.Yield('Q(@item).NumberOfChars()') )
#--> [ 3, 5, 5, 6, 7, 4, 7, 7 ]

? @@( o1.Yield('[ @item, Q(@item).NumberOfChars() ]') )
#--> [
# 	[ "SUN", 3 ], [ "EARTH", 5 ], [ "Venus", 5 ],
# 	[ "saturn", 6 ], [ "mercury", 7 ], [ "Mars", 4 ],
# 	[ "NEPTUNE", 7 ], [ "Jupiter", 7 ]
#    ]

#--

o1 = new stzListOfStrings([
	"SUN", "EARTH", "Venus", "saturn",
	"mercury", "Mars", "NEPTUNE", "Jupiter" ])

? @@( o1.Yield('Q(@item).NumberOfChars()') )
#--> [ 3, 5, 5, 6, 7, 4, 7, 7 ]

#--

o1 = new stzString("SOFTANZA")
? @@( o1.Yield('ascii(@char)') )
#--> [ 83, 79, 70, 84, 65, 78, 90, 65 ]

/*------- OK

o1 = new stzList([ 1, 2, 3, 4, 5, 6, 7 ])
? @@( o1.Yield('@NextItem') )		#--> [ 2, 3, 4, 5, 6, 7 ]
? @@( o1.Yield('@PreviousItem') ) 	#--> [ 1, 2, 3, 4, 5, 6 ]

#--

o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5, 6, 7 ])
? @@( o1.Yield('@NextNumber') )		#--> [ 2, 3, 4, 5, 6, 7 ]
? @@( o1.Yield('@PreviousNumber') ) 	#--> [ 1, 2, 3, 4, 5, 6 ]

? @@( o1.Yield('@CurrentNumber + @PreviousNumber') )
					#--> [ 3, 5, 7, 9, 11, 13 ]

/*--

o1 = new stzListOfStrings([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])
? @@( o1.Yield('@NextString') )		#--> [ "A2", "A3", "A4", "A5", "A6", "A7" ]
? @@( o1.Yield('@PreviousString') ) 	#--> [ "A1", "A2", "A3", "A4", "A5", "A6" ]

/*--

o1 = new stzString("1234567")
? @@( o1.Yield('@NextChar') )		#--> [ "2", "3", "4", "5", "6", "7" ]
? @@( o1.Yield('@PreviousChar') ) 	#--> [ "1", "2", "3", "4", "5", "6" ]

/*------- OK

o1 = new stzList([ "One", "Two", "Three", "Four", "Five" ])
? o1.YieldFromPositions([2, 3, 5], 'Q(@item).Uppercased()')
#--> [ "TWO", "THREE", "FIVE" ]

o1 = new stzListOfStrings([ "One", "Two", "Three", "Four", "Five" ])
? o1.YieldFromPositions([2, 3, 5], 'Q(@string).Uppercased()')
#--> [ "TWO", "THREE", "FIVE" ]

o1 = new stzString("abcde")
? o1.YieldFromPositions([2, 3, 5], 'Q(@char).Uppercased()')
#--> [ "B", "C", "E" ]

/*------- OK

o1 = new stzList([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])
? @@( o1.YieldFromSections([ [2,3], [5,6] ], '@item') )
#--> [ "A2", "A3", "A5", "A6" ]

? @@( o1.YieldFromSectionsOneByOne([ [2,3], [5,6] ], '@item') )
#--> [ [ "A2", "A3" ], [ "A5", "A6" ] ]

#--

o1 = new stzListOfStrings([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])
? @@( o1.YieldFromSections([ [2,3], [5,6] ], '@string') )
#--> [ "A2", "A3", "A5", "A6" ]

? @@( o1.YieldFromSectionsOneByOne([ [2,3], [5,6] ], '@string') )
#--> [ [ "A2", "A3" ], [ "A5", "A6" ] ]

#--

o1 = new stzString("_ab_cd_")
? @@( o1.YieldFromSections([ [2,3], [5,6] ], '@char') )
#--> [ "a", "b", "c", "d" ]

? @@( o1.YieldFromSectionsOneByOne([ [2,3], [5,6] ], '@char') )
#--> [ [ "a", "b" ], [ "c", "d" ] ]

/*------- OK

o1 = new stzList([ "one", "TWO", "THREE", "four", "FIVE" ])
? o1.YieldW('@item', :Where = 'Q(@item).IsUppercased()')
#--> [ "TWO", "THREE", "FIVE" ]

o1 = new stzListOfStrings([ "one", "TWO", "THREE", "four", "FIVE" ])
? o1.YieldW('@string', :Where = 'Q(@string).IsUppercased()')
#--> [ "TWO", "THREE", "FIVE" ]

o1 = new stzString("aaaAAAaaAAaA")
? @@(o1.YieldW('@position', :Where = 'Q(@char).IsUppercased()'))
#--> [ 4, 5, 6, 9, 10, 12 ]

  #------------------------#
 #  PERFORM ON ALL ITEMS  #
#------------------------#
/*---

o1 = new stzList([ 1, 2, 3, 4, 5 ])
o1.Perform('@item = @NextItem')
? o1.Content() #--> [ 2, 3, 4, 5, 5 ]

o1 = new stzList([ 1, 2, 3, 4, 5 ])
o1.Perform('@item = @PreviousItem')
? o1.Content() #--> [ 1, 1, 1, 1, 1 ]

#--

o1 = new stzString("12345")
o1.Perform('@char = @NextChar')
? o1.Content() #--> 23455

o1 = new stzString("12345")
o1.Perform('@char = @PreviousChar')
? o1.Content() #--> 11111

/*-----------

o1 = new stzList([ :one, :two, :three, :four, :five ])
o1.Perform('@item = Q(@item).Uppercased()')
? @@( o1.Content() ) #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]

o1.Perform('@item = len(@item)')
? @@( o1.Content() ) #--> [ 3, 3, 5, 4, 4 ]

/*-------

o1 = new stzListOfStrings([ :one, :two, :three, :four, :five ])
o1.Perform('@string = Q(@string).Uppercased()')
? @@(o1.Content()) #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]

#--

o1 = new stzListOfNumbers([ 1, 3, 5, 7, 9 ])
o1.Perform('@number *= 2')
? @@( o1.Content() ) #--> [ 2, 6, 10, 14, 18 ]

#--

o1 = new stzString("softanzalib")
o1.Perform('@char = Q(@char).Uppercased()')
? o1.Content() #--> SOFTANZALIB

#-------

o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])
o1.Perform('{ @string = Q(@string).RemoveQ(".txt").Content() }')

? o1.Content() # ---> [ "village", "town", "country" ]

/*----------

aWhatIs = [
	:Ring = "programming language",
	:Softanza = "Ring library",
	:Qt = "C++ framework"
]

o1 = new stzList([ "Ring", "Softanza", "Qt" ])
o1.Perform('{ @item += " is a " + aWhatIs[@item] }')

? o1.Content()
# ---> [ "Ring is a programming language", "Softanza is a Ring library", "Qt is a C++ framework" ]

  #------------------------#
 #  PERFORM ON POSITIONS  #
#------------------------#
/*---

o1 = new stzList([ "ONE", "two", "THREE", "four", "FIVE" ])
o1.PerformOnPositions([2, 4], '@item = upper(@item)')
? @@(o1.Content()) #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]

/*--

o1 = new stzListOfStrings([ "ONE", "two", "THREE", "four", "FIVE" ])
o1.PerformOn([2, 4], '@string = upper(@string)')
? @@(o1.Content()) #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]

/*--

o1 = new stzString("knowledge programming in softanzalib")
o1.PerformOn([1, 11, 26], '@char = upper(@char)')
? o1.Content() #--> Knowledge Programming in Softanzalib

/*--

o1 = new stzListOfNumbers([ 1, 1, 0, 1, 1, 0, 0, 1, 0, 1 ])
o1.PerformOnPositions( [ 3, 6, 7, 9 ], '@number += 1' )
? @@( o1.Content() ) #--> [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]

  #-------------------------#
 #   PERFORM ON SECTIONS   #
#-------------------------#
/*---

o1 = new stzList([ "file1", "file2", 12500, 1104, "file3", "file4", "file5", 5400 ])
o1.PerformOnSections([ [1,2], [5,7] ], '@item += ".txt"')
? o1.Content()
#--> [ "file1.txt", "file2.txt", 12500, 1104, "file3.txt", "file4.txt", 5400 ]

o1 = new stzListOfStrings([
		"file1", "file2",
		"file2.txt", "file.text",
		"file3", "file4", "file5",
		"file6.txt", "file7.txt" ])

o1.PerformOnSections([ [1,2], [5,7] ], '@string += ".txt"')
? @@( o1.Content() )
#--> [
# 	"file1.txt", "file2.txt", "file2.txt",
# 	"file.text", "file3.txt", "file4.txt",
# 	"file5.txt", "file6.txt", "file7.txt"
#    ]

/*---

o1 = new stzListOfNumbers([ 0, 0, 1, 1, 1, 0, 0, 0, 1 ])
o1.PerformOnSections([ [1, 2], [6, 8]], '@number = 1' )
? @@( o1.Content() )
#--> [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ]

/*---

o1 = new stzString("aaaAAAaaAAaaaa")
o1.PerformOnSections([ [1,3], [7,8], [11,14]], '@char = upper(@char)' )
? o1.Content() #--> AAAAAAAAAAAAAA

  #------------------------#
 #  PERFORM ON CONDITION  #
#------------------------#
/*---

o1 = new stzList(["a","b", "C", "D", "e"])
o1.PerformW( '@item = upper(@item)', :If = 'islower(@item)' )
? @@(o1.Content()) #--> [ "A", "B", "C", "D", "E" ]

/*-- 

o1 = new stzList([ "A", "C", "D", 4, 5 ])
o1 - o1.ItemsW('isNumber(@item)') 	# Could be written o1 - o1.Numbers()
? o1.Content() #--> [ "A", "C", "D" ]

o1 = new stzList([ "A", "C", "D", "e", "f" ])
o1 - o1.ItemsW("isLower(@item)")	# Could be written o1 - [ "e", "f" ]
? o1.Content() #--> [ "A", "C", "D" ]

/*--

o1 = new stzList(["AAA",1 , "BBB", 2, 3, "CCC" ])
? o1.ItemsW('isString(@item)') #--> [ "AAB","BBB", "CCC" ]

/*--

o1 = new stzListOfStrings(["aaa","bbb", "CCC", "DDD", "eee"])
? o1.StringsW('isLower(@string)') #--> [ "aaa","bbb", "eee" ]

o1 = new stzListOfNumbers([ 0, 0, 4, 3, 0, 7, 0, 0 ])
? o1.NumbersW('@number != 0') #--> [4, 3, 7 ]

/*--

o1 = new stzListOfStrings(["a","b", "C", "D", "e"])
o1.PerformW( '@string = upper(@string)', :If = 'islower(@string)' )
? @@(o1.Content()) #--> [ "A", "B", "C", "D", "E" ]

/*--

o1 = new stzListOfNumbers([ -10, -5, 6, -2, 13, -8 ])
o1.PerformW( '@number = -@number', :If = '@number < 0' )
? @@(o1.Content()) #--> [ 10, 5, 6, 2, 13, 8 ]

o1 = new stzString("abCDe")
o1.PerformW( '@item = upper(@item)', :If = 'islower(@item)' )
? o1.Content() #--> ABCDE

  #-----------------------------------------------------#
 #   SWAPING and MOVING STRINGS IN A LIST OF STRINGS   #
#-----------------------------------------------------#
/*---

o1 = new stzListOfStrings([ "A1", "A5", "A3", "A4", "A2" ])
o1.SwapBetween(2, 5)
? @@( o1.Content() ) #--> [ "A1", "A2", "A3", "A4", "A5" ]

/*------- OK

o1 = new stzListOfStrings([ "A1", "A5", "A3", "A4", "A2" ])
o1.MoveString(:AtPosition = 2, :ToPosition = 5)
o1.MoveString(:AtPosition = 4, :ToPosition = 2)
? @@( o1.Content() ) #--> [ "A1", "A2", "A3", "A4", "A5" ]

/*------- OK

o1 = new stzListOfStrings([ "A1", "A5", "A2", "A3", "A4" ])
o1.MoveString( :FromPosition = 2, :ToPosition = 5)
? @@( o1.Content() ) #--> [ "A1", "A2", "A3", "A4", "A5" ]

  #-------------------------#
 #   INSERTING IN STRING   #
#-------------------------#
/*---

o1 = new stzString("123456789")
o1.InsertBefore(4, "*")
? o1.Content() #--> "123*456789"

o1 = new stzString("123456789")
o1.InsertBefore(12, "*")
? o1.Content() #--> "123456789  *" (The string is extended with blank spaces! Qt behaviour?)

o1 = new stzString("123456789")
o1.InsertAfter(4, "*")
? o1.Content() #--> "1234*56789"

o1 = new stzString("123456789")
o1.InsertAfter(12, "*")
? o1.Content() #--> "123456789   *" (The string is extended with blank spaces! Qt behaviour?)

/*--------------- OK

o1 = new stzString("123456789")
o1.InsertAfterThesePositions([] , "*")
? o1.Content() #--> "123456789" (Nothing is inserted!)

o1 = new stzString("123456789")
o1.InsertAfterThesePositions([3, 5, 8] , "*")
? o1.Content() #--> "123*45*678*9"

o1 = new stzString("123456789")
o1.InsertBeforeThesePositions([3, 5, 8] , "*")
? o1.Content() #--> "12*34*567*89"

o1 = new stzString("123456789")
o1.InsertBeforeW('StzNumberQ(@char).IsEven()' , "*")
? o1.Content() #--> "1*23*45*67*89"

o1 = new stzString("123456789")
o1.InsertAfterW('StzNumberQ(@char).IsEven()' , "*")
? o1.Content() #--> "12*34*56*78*9"

/*--------------- OK

o1 = new stzString("RINGORIALAND")
o1.InsertAfterW('{ @i = 8 }', " ")
? o1.Content() #--> RINGORIA LAND

o1 = new stzString("RINGORIALAND")
o1.InsertAfterW('{ @i = @PreviousPosition + 1 }', " ")
? o1.Content() #--> R I N G O R I A L A N D

  #------------------------#
 #   SPACIFYING STRINGS   #
#------------------------#
/*--

o1 = new stzString("RINGORIALAND")
o1.Spacify()
? o1.Content() #--> R I N G O R I A L A N D

o1 = new stzString("RINGORIA LAND")
o1.Spacify() 
? o1.Content() #--> #--> R I N G O R I A   L A N D

o1 = new stzString("RIN   GOR   IALAN  D")
o1.Spacify()
? o1.Content() #--> R I N G O R I A L A N D

o1 = new stzString("IWantToTellYouWelcome!")
o1.SpacifyTheseSubStrings(["want", "to", "tell", "you"])
? o1.Content() #--> I Want To Tell You Welcome!

o1 = new stzString("IWantToTellYouWelcome!")
o1.SpacifyTheseSubstringsUsingCS(["want", "to", "tell", "you"], "_", :CS=FALSE)
? o1.Content() #--> I_Want_To_Tell_You_Welcome!

/*--------------- OK

o1 = new stzString("so       fta   nza    ")

o1.SpacifyUsing("  ")
? o1.Content() #--> s  o  f  t  a  n  z  a 

  #----------------------------------#
 #   ISEMPTY() IN STRING AND TEXT   #
#----------------------------------#
/*---

# As a string, "   " is not empty: it's filled with blank spaces!

? StzStringQ("   ").IsEmpty() #--> FALSE

# But as a text, it is empty, since it contains nothing meaningful:

? StzTextQ("   ").IsEmpty() #--> TRUE

  #---------------------------------------#
 #   MANAGING LEADING & TRAILING CHARS   #
#---------------------------------------#
/*---

o1 = new stzString("aaaAAARing")
o1.ReplaceThisRepeatedLeadingCharCS("a", :With = "o", :CaseSensitive = TRUE)
? o1.Content() #--> oooAAARing

/*---------- OK

o1 = new stzString("aaaAAARing")
? o1.NumberOfLeadingChars() #--> 3
? o1.LeadingChars() #--> aaa

? o1.NumberOfLeadingCharsCS(:CaseSensitive = FALSE) #--> 6
? o1.LeadingCharsCS(:CS = FALSE) #--> aaaAAA

/*---------- OK

o1 = new stzString("aaaAAAH RING!")
o1.ReplaceLeadingCharsCS(:With = "O", :CS = TRUE)
? o1.Content() #--> OOOAAAH RING!

o1 = new stzString("aaaAAAH RING!")
o1.ReplaceLeadingCharsCS(:With = "O", :CS = FALSE)
? o1.Content() #--> OOOOOOH RING!

/*---------- OK

o1 = new stzString("RINGaaaAAA")
o1.ReplaceTrailingCharsCS( :With = "O", :CS = TRUE)
? o1.Content()
#--> "RINGaaaOOO"

o1 = new stzString("RINGaaaAAA")
o1.ReplaceTrailingCharsCS( :With = "O", :CS = FALSE)
? o1.Content()
#--> "RINGOOOOOO"

/*----------- OK

o1 = new stzString("aaaAAARING!")
o1.ReplaceThisLeadingCharCS( "a", :With = "O", :CS = TRUE)
? o1.Content()
#--> "OOOAAARING!"

/*------------ OK

o1 = new stzString("♥Ring♥AAAaaa")
o1.RemoveThisTrailingCharCS("a", :CaseSensitive = TRUE)
? o1.Content() #--> ♥Ring♥AAA

o1 = new stzString("♥Ring♥AAAaaa")
o1.RemoveThisTrailingCharCS("a", :CaseSensitive = FALSE)
? o1.Content() #--> ♥Ring♥

/*----------- OK

o1 = new stzString("aaaAAA♥Ring♥")
o1.RemoveThisLeadingCharCS("a", :CaseSensitive = TRUE)
? o1.Content() #--> AAA♥Ring♥

o1 = new stzString("aaaAAA♥Ring♥")
o1.RemoveThisLeadingCharCS("a", :CaseSensitive = FALSE)
? o1.Content() #--> ♥Ring♥

/*----------- OK

o1 = new stzString("aaaAAAI ♥ Ring!AAAaaa")
o1.RemoveTheseLeadingAndTrailingCharsCS( "a", "a", :CS = TRUE)
? o1.Content()
#--> Gives: "AAAI ♥ Ring!AAA"

o1 = new stzString("aaaAAAI ♥ Ring!AAAaaa")
o1.RemoveTheseLeadingAndTrailingCharsCS( "a", "a", :CS = FALSE)
? o1.Content()
#--> Gives: "I ♥ Ring!"

/*---------- OK

StzStringQ("   clean code        ") {
	? @@( RepeatedLeadingChars() ) #--> "   "
	
	? @@( RepeatedLeadingChar() ) #--> " "
	
	RemoveThisRepeatedLeadingChar(" ")
	? @@( Content() ) #--> "clean code        "
	
	RemoveThisRepeatedTrailingChar(" ")
	? @@( Content() ) #--> "clean code"
}

/*---------- OK

StzStringQ("   clean code        ") {
	RemoveLeadingSpaces()
	? @@( Content() ) #--> "clean code        "

	RemoveTrailingSpaces()
	? @@( Content() ) #--> "clean code"
}

  #--------------------------------------------#
 #   VIZ-FINDING A SUBSTRING IN THE STRING    #
#--------------------------------------------#
/*---

# The VizFindXT function accepts these options

# 	:CaseSensitive	= TRUE or FALSE
#	--> TRUE by default (you can use the short form :CS)

#	:PositionChar	= any char indicating the found positions
#	--> "^" by default

#	:BlankChar	= any char different to :PositionChar
#	--> "-" by default

#	:Numbered	= The found chars are labeled with their positions
#	--> FALSE by default

#	:Spacified	= The string is enlarged by inserting a space after each char
#	--> FALSE by default

#	:Boxed		= TRUE or FALSE
#	--> FALSE by default

#	:BoxOptions	= Any options onforming to IsBoxOptionsNamedParam()
#	--> Works only if :Boxed = TRUE


o1 = new stzString("RINGoriaLAND")
? o1.VizFindXT("I", []) + NL

#-->
# 'RINGoriaLAND"
#  -^----------

? o1.VizFindXT("I", [ :CaseSensitive = FALSE ]) + NL
# 'RINGoriaLAND"
#  -^----^-----

? o1.VizFindXT("I", [ :CS = FALSE, :Numbered = TRUE ]) + NL
# 'RINGoriaLAND"
#  -^----^-----
#   2    7    

? o1.VizFindXT("I", [ :CS = FALSE, :Numbered = TRUE, :Spacified = TRUE ]) + NL
# 'R I N G o r i a L A N D"
#  --^---------^----------
#    2         7      

? o1.VizFindXT("I", [
	:CS = FALSE, :Numbered = TRUE, :Spacified = TRUE,
	:BlankSign = ".", :PositionSign = "♥" ])

#-->
# "R I N G o r i a L A N D"
#  ..♥.........♥..........
#    2         7      
return

/*------------- TODO

VizFindAsSection()

"R I N G o r i a L A N D"
 --[   ]-----[   ]------
   2   6     8   2

/*-------------------- TODO

o1 = new stzString("RINGing")
? o1.VizFindXT("I", [ :Boxed = TRUE ])

  #----------------------#
 #   BOXING A STRING    #
#----------------------#
/*---

StzStringQ("RING") {

	? BoxedRound()
	# ╭──────╮
	# │ RING │
	# ╰──────╯

	? EachCharBoxedRound()
	# ╭───┬───┬───┬───╮
	# │ R │ I │ N │ G │
	# ╰───┴───┴───┴───╯

}

  #----------------------------------------------------#
 #   ALINGING & JUSTIFYING A STRING IN A CONTAINER    #
#----------------------------------------------------#
/*---

StzStringQ("PARIS") {
	LeftAlign(15, "-")
	? Content()
}

StzStringQ("PARIS") {
	RightAlign(15, "-")
	? Content()
}

StzStringQ("PARIS") {
	CenterAlign(15, "-")
	? Content()
}

StzStringQ("PARIS") {
	Justify(15, "-")
	? Content()
}

#--> PARIS----------
#--> ----------PARIS
#--> -----PARIS-----
#--> P---A---R--I--S

  #-----------------------------------------------#
 #   FINDING A SUBSTRING IN A LIST OF STRINGS    #
#-----------------------------------------------#
/*---

o1 = new stzListOfStrings([
	"How many roads must a Man walk down",
	"Before you call him a Man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?",
	"And how many times must the cannonballs fly",
	"Before they're forever banned?",
	"The answer, my friend, is blowin' in the wind",
	"The answer is blowin' in the wind"
])

? o1.NumberOfOccurrenceOfSubStringCS("man", :CS = FALSE) #--> 5

? @@(o1.FindSubstringCS("man", :CS = FALSE))
# --> [
#	"1" = [ 5, 23 ],
#	"2" = [ 23 ],
#	"3" = [ 5 ],
#	"5" = [ 9 ]
#     ]

  #--------------------------------------------------------------#
 #   INSERTING A CHAR, AT, BEFORE, AND AFTER A GIVEN POSITION   #
#--------------------------------------------------------------#
/*---

o1 = new stzString("123ABC")
? o1.CharAt(4) 		#--> "A"

o1.InsertBefore(4, " ") 
? o1.Content()		#--> "123 ABC"
# NOTE --> InsertAt(n,substr) removes char at position n

/*---------- OK

o1 = new stzString("123ABC")
? o1.CharAt(4) 		#--> "A"

o1.InsertAfter(4, " ") 
? o1.Content()		#--> "123A BC"

/*---------- OK

o1 = new stzString("123ABC")
o1.RemoveCharAt(4)
? o1.Content() #--> 123BC

/*---------- OK

o1 = new stzString("123ABC")
? o1.CharAt(4) 		#--> "A"

o1.InsertAt(4, " ") 
? o1.Content()		#--> "123A BC"

/*--------- OK

o1 = new stzString("__WWW__WWW_WWW__")
? @@( o1.FindAsSections("WWW") )
#--> [ [3,5], [8,10], [12,14] ]

/*---------- OK

o1 = new stzString("RAMADAN")
? o1.NextNthChar(2, :StartingAt = 3)	 #--> D
? o1.PreviousNthChar(3, :StartingAt = 4) #--> R

  #-------------------------------------------#
 #   SPACIFYING CHARS AND GIVEN SUBSTRINGS   #
#-------------------------------------------#
/*---

o1 = new stzString("Please spacifythese wordssoIcan read them!")
o1.SpacifyChars()
? o1.Content()
#--> P l e a s e   s p a c i f y t h e s e   w o r d s s o I c a n   r e a d   t h e m !

/*--------- OK

o1 = new stzString("PleasespacifythesewordssoIcanreadthem!")
o1.SpacifySubstring("spacify")
? o1.Content() + NL #--> Please spacify thesewordssoIcanreadthem!

o1 = new stzString("PleasespacifythesewordssoIcanreadthem!")
o1.SpacifyTheseSubstrings( ["spacify", "words", "I", "read" ] )
? o1.Content() + NL #--> Please spacify these words so I can read them!

o1 = new stzString("PleasespacifythesewordssoIcanreadthem!")
o1.SpacifyTheseSubstringsUsing( ["spacify", "words", "I", "read" ], "_" )
? o1.Content() #--> Please_spacify_these_words_so_I_can_read_them!

/*------- OK

o1 = new stzString("هاهوحسينيقبّل أباهمنصورا")
o1.SpacifyTheseSubstrings( [ "هو", "حسين", "أباه" ] )
? o1.Content() #--> Please spacify these words so I can read them!
#-->o ها هو حسين يقبّل أباه منصورا

o1.SpacifyChars()
? o1.Content()
#-->o ه ا   ه و   ح س ي ن   ي ق ب ّ ل   أ ب ا ه   م ن ص و ر ا

  #-------------------------------------------#
 #   BOUNDING SUBSTRINGS INSIDE THE STRING   #
#-------------------------------------------#
/*---

o1 = new stzString("Let's bound this word, this word and this word!")
o1.BoundSubStringWith("word", "<<", ">>")
? o1.Content() #--> Let's bound this <<word>>, this <<word>> and this <<word>>!

o1 = new stzString("Let's bound this <<word>>, this Word and this WORD!")
o1.BoundSubStringWithCS("word", "<<", ">>", :CS = FALSE)
? o1.Content() #--> Let's bound this <<word>>, this Word and this WORD!

/*------- OK

o1 = new stzString("Let's bound this word1, this word2 and this word3!")
o1.BoundSubStringsWith([ "word1", "word2", "word3" ], "<<", ">>")
? o1.Content() #--> Let's bound this <<word1>>, this <<Word2>> and this <<WORD3>>!

o1 = new stzString("Let's bound this word1, this Word2 and this WORD3!")
o1.BoundSubStringsWithCS([ "word1", "word2", "word3" ], "<<", ">>", :CS = FALSE)
? o1.Content() #--> Let's bound this <<word1>>, this <<Word2>> and this <<WORD3>>!

/*=============================================== Retest after completing SplitXT()

? StzListQ(1:3).ToListInShortForm()
/*
? StzListOfListsQR([ 1:3, 3:5, 1:3, 6:8, 3:5 ]).
	RemoveDuplicatesQ().
	ToListInStringInShortForm()
# --> [ "1 : 3", "3 : 5", "6 : 8" ]

/*------------------------ TODO: Retest after completing SPlitXT()

o1 = new stzString("In these days, to be happy is a real challenge!
 I'm not sure how problems will leave us a window for this.
 Fortunately, hope will continue to be there.
 Quiet difficult but not impossible.")

? @@(o1.ToStzText().RemovePunctuationQ().

		LowercaseQ().
		SplitQR(" ", :stzListOfStrings).

		YieldQ('[ @str, Sentiment(@str) ]').
		RemoveDuplicatesQ().
		ToStzHashList().Classify() ) # ===> Dbug stzHashList.Classify()

//		Classify() )




//		ClassesAndTheirFrequencies()

//		DominantClass()
//		WeakestClass()

#--> [
# 	:Positive = 0.32
# 	:Neutral  = 0.16
# 	:Negative = 0.52
#    ]


func Sentiment(pcWord)
	# EXAMLE

	# ? Sentiment(:glad) 	#--> :Positive
	# ? Sentiment(:quiet) 	#--> :Neutral
	# ? Sentiment(:problem) 	#--> :Negative

	

	oHashList = new stzHashList([
		:Positive = [
			:happy, :nice, :glad, :beautiful, :wonderful,
			:fortunately, :hope, :sure, :continue ],

		:Neutral = [
			:in, :to, :be, :a, :is, :will, :can, :some,
			:these, :days, :quiet, :real, :us, :window,
			:for, :this, :there, :but
		],

		:Negative = [
			:no, :not, :must, :difficult, :problem, :leave,
			:impossible
		]
	])

	return oHashList.KeyByValueInList(pcWord)

  #---------#
 #  MISC.  #
#---------#
/*---

o1 = new stzListOfNumbers([ 5, 4, 3 ])
o1.SubstractFromEach(1)
? o1.Content()

/*----

o1 = new stzList([ 12, 7 ])
? o1.ExpandedIfPairOfNumbers() #--> [ 12, 11, 10, 9, 8, 7 ]

/*--- OK

o1 = new stzListOfNumbers([ -10, -5, 6, -2, 13, -8 ])
o1.Absolute()
? @@( o1.Content() ) #--> [ 10, 5, 6, 2, 13, 8 ]

o1 = new stzListOfNumbers([ 10, 5, 6, 2, 13, 8 ])
o1.Absolute()
? @@( o1.Content() ) #--> [ 10, 5, 6, 2, 13, 8 ]

/*---- OK

o1 = new stzListOfNumbers([ 2, 7, 18, 10, 25, 4 ])
? o1.NearestTo(12)	#--> 10
? o1.FarthestTo(12)	#--> 25

/*---- OK

o1 = new stzListOfStrings([ "Jameel", "Fedy", "Badr" ])
? o1.ContainsBothCS("JAMEEL", "BADR", :CS = FALSE) #--> TRUE
? o1.ContainsBothCS("JAMEEL", "BADR", :CS = TRUE)  #--> FALSE

o1 = new stzListOfNumbers([ 7, 17, 27 ])
? o1.AddedToEach(3) #--> [ 10, 20, 30 ]

/*------- OK

o1 = new stzListOfStrings([ "ONE", "TWO", "3", "FOUR", "FIVE" ])
o1.InsertAt(3, "THREE")
? o1.Content()	     #--> [ "ONE", "TWO", "THREE", "FOUR", "FIVE" ]
		
/*----- OK

o1 = new stzString("ring programming")

o1.Capitalize() # TODO: revisit its mother fucntion in stzLocale.toUppercase')
		# when stzText.Words() is finalized

? o1.Content() #--> Ring Programming

/*--------------- OK

o1 = new stzList([ 1:3, 3:5, 1:3, 6:8, 3:5 ])
? o1.Contains(3:5) #--> TRUE

/*--------------- OK

o1 = new stzList([ "str1", 14, [ "A", "B", "C"], 8, "str2" ])
? o1.ItemsStringified()
#--> [ "str1", "14", '[ "A", "B", "C" ]', "8", "str2" ]

/*--------------- OK

? @@( StzListQ([ 1:3, 3:5, 1:3, 6:8, 3:5 ]).DuplicatesRemoved() )
#--> [ [ 1, 2, 3 ], [ 3, 4, 5 ], [ 6, 7, 8 ] ]
