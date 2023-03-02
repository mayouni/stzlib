load "stzlib.ring"

/*------

? Q([ "I", "believe", "in","Ring!" ]).ReduceXT('@string + " "')
#--> I believe in Ring!

proff()
#--> Executed in 0.93

/*------

pron()

# To return the ascii code of each letter we say:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldXT('ascii(@item) - 65')
#--> [ 17, 8, 13, 6, 8, 18, 14, 22, 18, 14, 12, 4 ]

# To return the letter along with the asscii code, we write:
? Q("ring is owsome!").UppercaseQ().LettersQ().YieldXT('[ @item, ascii(@item) - 65 ]')
#--> [
#	[ "R", 17 ], [ "I", 17 ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]

proff()
# Executed in 3.02 second(s)

/*------

pron()

? Q(["A", "B", "C"]).YieldXT('[ @item, ascii(@item) - 64 ]')

proff()

/*------

pron()

? @@S( Q("ring is owsome!").UppercaseQ().LettersQ().YieldXT('[ @item, ascii(@item) - 65 ]') )
#--> [
#	[ "R", 17 ], [ "I", 8  ], [ "N", 13 ],
#	[ "G", 6  ], [ "I", 8  ], [ "S", 18 ],
#	[ "O", 14 ], [ "W", 22 ], [ "S", 18 ],
#	[ "O", 14 ], [ "M", 12 ], [ "E", 4  ]
# ]
proff()

/*=======

pron()
#                   1  4 6  9 1   567      456
o1 = new stzString("...<<ring>>...<<softanza>>...")

? @@S( o1.FindBetween("<<",">>") )
#--> [6, 17]

? @@S( o1.FindBetweenAsSections("<<",">>") )
#--> [ [6, 9], [17, 24] ]

? @@S( o1.Between("<<",">>") )
#--> ["ring", "softanza"]

? @@S( o1.FindBetweenXT("<<",">>") )
#--> [4, 15]

? @@S( o1.FindBetweenAsSectionsXT("<<",">>") )
#--> [ [4, 11], [15, 26] ]

? @@S( o1.BetweenXT("<<",">>") )
#--> ["<<ring>>", "<<softanza>>"]

proff()
# Executed in 0.25 second(s)

/*------------

pron()
#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindFirst("<<<")
#--> 4

? @@S( o1.FindFirstAsSection("<<<") )
#--> [4, 6]

proff()
# Executed in 0.02 second(s)

/*------------

pron()

#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindLast("<<<")
#--> 9

? @@S( o1.FindLastAsSection("<<<") )
#--> [9, 11]

proff()
# Executed in 0.03 second(s)

/*------------

pron()

o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
? o1.FindPrevious("<<<", :StartingAt = 11)
#--> 4

? o1.Between("<<<", ">>>")
#--> ["ring", "softanza"]

proff()
# Executed in 0.07 second(s)

/*------------

StartProfiler()

o1 = new stzString('This[@i] = This[@i + 1] + @i - 2')
? o1.NumbersAfter("@i")
#--> [ "+1", "-2" ]

StopProfiler()
# Executed in 0.14 second(s)

/*------------

pron()

o1 = new stzString(" @i + 10, @i- 125, e11")
? o1.NumbersComingAfter("@i")
#--> [ "+10", "-125", "11" ]

proff()
# Executed in 0.11 second(s)

/*------------

pron()

o1 = new stzString("emm +   12_456.50 emm 11. and -   4.12_")
? o1.Numbers()
#--> [ "+12_456.50", "11", "-4.12" ]

proff()
# Executed in 0.19 second(s)

/*------------

pron()

o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
? @@S( o1.ExtractNumbers() )
#--> [ "18", "16", "17.80" ]

? o1.Content()
#--> Math: , Geo: , :Physics: 

proff()
# Executed in 0.17 second(s)

/*------------

StartProfiler()

o1 = new stzString([
	"I__",
	"♥",
	Q("_").Repeated(3),
	'{ Q("ring").Uppercased() }',
	"!"
])

? o1.Content()
#--> <<__♥___RING___>>

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.NumberOfChars()
#--> 1_897_793
# Executed in 0.02 second(s)

? oLargeStr.NumberOfLines()
#--> 34_627
# Executed in 0.02 second(s)

? oLargeStr.SplitQ(NL).NumberOfItems()
#--> 34_627
#--> Executed in 0.45 second(s)

StopProfiler()
# Executed in 0.85 second(s)

/*-----------
# WARNING: takes 14 seconds to complete!

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.Reverse()
? oLargeStr.Content()

StopProfiler()
# Executed in 14.56 second(s)

/*-----------
	
# Testing extreme cases in FindNthNext()/FindNthPrevious on a small string

StartProfiler()
#                   .2....7.9
o1 = new stzString("•••••••••")

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("x", :StartingAt = 1)
#--> 0

? o1.FindNthNext(6, "•", :StartingAt = 3)
#--> 9

? o1.FindNthNext(5, "•", :StartingAt = 1)
#--> 6


? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

? o1.FindNthPrevious(8, "•", :StartingAt = 9)
#--> 1

? o1.FindNthPrevious(3, "•", :StartingAt = 4)
#--> 1

StopProfiler()
# Executed in 0.12 second(s)

/*-----------

# Testing FindNthNext()/FindNthPrevious
# on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("ARABIC HA", :StartingAt = 1)
#--> 110819

? o1.FindNthNext(6, "ARABIC", :StartingAt = 3)
#--> 106563

? o1.FindNthNext(12, "HAN", :StartingAt = 250_000)
#--> 300537


? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 1)
#--> 0

StopProfiler()
# Executed in 0.08 second(s)

/*-----------

# Testing FindLast() on a small string

StartProfiler()
#                    2    7
o1 = new stzString("•♥••••♥••")
? o1.FindLast("♥")
#--> 7

? o1.FindLast("_")
#--> 0

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

# Testing FindLast() on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars
? o1.Contains("جميل")
#--> FALSE

? o1.FindLast("جميل")
#--> FALSE

StopProfiler()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzString("123456789")

? o1.FirstHalf()
#--> 1234
? o1.SecondHalf()
#--> 56789

? o1.Halves() # Or Bisect()
#--> [ "1234", "56789" ]

? o1.FirstHalfXT()
#--> 12345
? o1.SecondHalfXT()
#--> 6789

? o1.HalvesXT() # Or BisectXT()
#--> [ "12345", "6789" ]


proff()
# Executed in 0.02 second(s)

/*============

pron()
   
o1 = new stzString("123456789")

# FIRST HALF

	? o1.FirstHalf()
	#--> 1234
	? o1.FirstHalfXT()
	#--> 12345
	
	? @@S( o1.FirstHalfAndItsPosition() )
	#--> [ "1234", 1 ]
	? @@S( o1.FirstHalfAndItsSection() )
	#--> [ "1234", [ 1, 4 ] ]
	
	? @@S( o1.FirstHalfAndItsPositionXT() )
	#--> [ "12345", 1 ]
	? @@S( o1.FirstHalfAndItsSectionXT() )
	#--> [ "12345", [ 1, 5 ] ]

# SECOND HALF

	? o1.SecondHalf()
	#--> 56789
	? o1.SecondHalfXT()
	#--> 6789
	
	? @@S( o1.SecondHalfAndItsPosition() )
	#--> [ "56789", 5 ]
	? @@S( o1.SecondHalfAndItsSection() )
	#--> [ "56789", [ 5, 9 ] ]
	
	? @@S( o1.SecondHalfAndItsPositionXT() )
	#--> [ "6789", 6 ]
	? @@S( o1.SecondHalfAndItsSectionXT() )
	#--> [ "6789",  [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@S( o1.Halves() )
	#--> [ "1234", "56789" ]

	? @@S( o1.HalvesXT() )
	#--> [ "12345", "6789" ]

	? @@S( o1.HalvesAndPositions() )
	#--> [ [ "1234", 1 ], [ "56789", 5 ] ]

	? @@S( o1.HalvesAndPositionsXT() )
	#--> [ [ "12345", 1 ], [ "6789", 6 ] ]

	? @@S( o1.HalvesAndSections() )
	#--> [ [ "1234", [ 1, 4 ] ], [ "56789", [ 5, 9 ] ] ]

	? @@S( o1.HalvesAndSectionsXT() )
	#--> [ [ "12345", [ 1, 5 ] ], [ "6789", [ 6, 9 ] ] ]

proff()

/*==============

pron()

#                      4     0     6    1
o1 = new stzString("---***---***---***---")

? o1.HowMany("***")
#--> 3

? o1.Nth(3, "***")
#--> 16

? o1.FindLast("***")
#--> 16

proff()
# Executed in 0.02 second(s)

/*=============

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.FindLast(";")
#--> 1897793

StopProfiler()
# Executed in 12.99 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? @@S( oLargeStr.FindAll("ALIF") )

? oLargeStr.Contains("ALIF")
#--> TRUE

? oLargeStr.FindFirst("ALIF")
#--> 130655

? oLargeStr.NumberOfOccurrence("ALIF")
#--> 4

? oLargeStr.FindNth(4, "ALIF")
#--> 1703275

? oLargeStr.FindLast("ALIF")
#--> 1703275

StopProfiler()
# Executed in 0.06 second(s)

/*-----------

StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars

? oLargeStr.Contains("Plane 15 Private Use")
#--> TRUE
# Executed in 0.02 second(s)

? oLargeStr.HowMany("Plane 15 Private Use")
#--> 2
# Executed in 0.03 second(s)

? oLargeStr.FindAll("Plane 15 Private Use")
#--> [ 1_897_586, 1_897_640 ]
# Executed in 0.02 second(s)

? oLargeStr.FindFirst("Plane 15 Private Use")
#--> 1_897_586
# Executed in 0.02 second(s)

? oLargeStr.FindLast("Plane 15 Private Use")
#--> 1897640
# Executed in 0.04 second(s)

StopProfiler()
#--> Executed in 0.06 second(s)

/*-----------

StartProfiler()

#                    2    7
o1 = new stzString("•♥••••♥••")
//? o1.FindNthW(2, '@char = "♥"')
#--> 7
# Executed in 0.13 second(s)

? o1.FindNthW(2, '@substring = "•♥•"')
#--> 6

StopProfiler()
#--> Executed in 0.30 second(s)

/*===========

StartProfiler()

? Q("RING").StringCase()
#--> :Uppercase

? Q("ring").StringCase()
#--> :Lowercase

? Q("Ring").StringCase()
#--> :Capitalcase

? Q("Ring is AWOSOME!").StringCase()
#--> :Hybridcase

StopProfiler()
# Executed in 0.18 second(s)

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Uppercased()
#--> I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").IsUppercase()
#--> TRUE

StopProfiler()
# Executed in 0.01 second(s)

/*----------

StartProfiler()

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").Lowercased()
#--> i believe in ring future and engage for it!

? Q("i believe in ring future and engage for it!").IsLowcase()
#--> TRUE

# As a side note, the last fuction used above (IsLowcase()) is
# misspelled (should be IsLowerCase() with an "r" after low),*
# but Softanza accepts it.

StopProfiler()
# Executed in 0.02 second(s)

/*----------

StartProfiler()

? Q("i believe in ring future and engage for it!").Capitalcased()
#--> I Believe In Ring Future And Engage For It!

? Q("I Believe In Ring Future And Engage For It!").IsCapitalcase()
#--> TRUE

StopProfiler()
# Executed in 0.05 second(s)

/*==================

pron()

o1 = new stzString("ABC*EF")
o1.QStringObject().replace(3, 1, "D")
? o1.Content()
#--> "ABCDEF"

proff()
# Executed in 0.02 second(s)

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")

o1.ReplaceCharAt( :Position = 4, :By = "D")
? o1.Content()
#--> "ABCDEF"

StopProfiler()
# Executed in 0.02 second(s)

/*-----------------

StartProfiler()

o1 = new stzString("ABC*EF")
o1.ReplaceSection( 4, 4, "D")
? o1.Content()
#--> ABCDEF

StopProfiler()
#--> Executed in 0.01 second(s)

/*===========

pron()

? Q("121212").IsMadeOf("12")
#--> TRUE

? Q("984332").IsMadeOfNumbers()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

o1 = new stzString("ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332")

? o1.Lines()[3]
#--> "123346"

? Q( o1.Lines()[3] ).IsMadeOfNumbers()
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*-----------

StartProfiler()

o1 = new stzString("

ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332

")

o1.TrimQ().RemoveLinesW(' Q(@line).IsMadeOfNumbers() ')
? @@(o1.Content())
#-->
# "ABCDEF
#  GHIJKL
#  MNOPQU
#  RSTUVW"

StopProfiler()
# Executed in 0.14 second(s)

/*=============

StartProfiler()

o1 = new stzString("I love <<Ring>> and <<Softanza>>!")

# Finding the positions of substrings enclosed between << and >>
? @@S( o1.FindBetween("<<",">>") )
#--> [10, 23]

	# Returning the same result as sections
	? @@S( o1.FindBetweenAsSections("<<",">>") )
	#--> [ [10, 13], [23, 30] ]

	# Getting the substrings themselves
	? @@S( o1.Between("<<",">>") ) # Or SubStringsBetween("<<", :And = ">>")
	#--> [ "Ring", "Softanza" ]

# Now, we need to do the same thing but we want to return the
# bounding chars << and >> in the result as well. To do so,
# we can use the eXTended version of the same functions like this:

? @@S( o1.FindBetweenXT("<<",">>") )
#--> [8, 21]

	? @@S( o1.FindBetweenAsSectionsXT("<<",">>") )
	#--> [ [ 8, 15 ], [ 21, 32 ] ]

	? @@S( o1.BetweenXT("<<",">>") )
	#--> [ <<Ring>>, <<Softanza>> ]

StopProfiler()
#--> Executed in 0.12 second(s)

/*----------- /////////////  TODO   /////////////////////

pron()

o1 = new stzString('[
	"1", "1",
		["2", "♥", "2"],
	"1",
		["2",
			["3", "♥",
				["4",
					["5", "♥"],
				"4",
					["5","♥"],
				"♥"],
			"3"]
		]

]')

//? @@S( o1.DeepFindBetweenAsSections("[", "]") )

aList = o1.DeepSubStringsBetweenXT("[", "]")
nLen = len(aList)
for i = 1 to nLen
	? aList[i] + NL + NL + "--" + NL
next

proff()

#--> Executed in 0.61 second(s)

/*=============

StartProfiler()

o1 = new stzString("99999999999")
o1.SpacifyChars()

? o1.Content()
#--> 9 9 9 9 9 9 9 9 9 9 9

StopProfiler()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
? o1.Spacified()
#--> 9 9 9 9 9 9 9 9 9 9 9 

//? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
? o1.SpacifiedUsing("_")
#--> 9_9_9_9_9_9_9_9_9_9_9

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("99999999999")
o1.SpacifyXT( "_", 3, :Backward )
# Or you can be explicit and name the params like this:
# //o1.SpacifyXT( :Using = "_", :Step = 3, :Direction = :Backward )

? o1.Content()
#--> 99_999_999_999

proff()
# Executed in 0.03 second(s)

/*----------

StartProfiler()

o1 = new stzString("9999999999")
o1.SpacifyXT(
	:Using     = [ ".", :AndThen = " " ],
	:Step      = [ 2, :AndThen = 3],
	:Direction = :Backward
)

? o1.Content()
#--> 99 999 999.99

StopProfiler()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzString(" so ftan  za ")
o1.Unspacify()
? o1.Content()
#--> so ftan  za

proff()
# Executed in 0.01 second(s)

/*--------------

pron()

o1 = new stzListOfStrings([" r   in g", "r ing", "  r     i ng  "])
? o1.SpacesRemoved()
#--> [ "ring", "ring", "ring" ]

# Content of the string remained the same, because ...ed() functions
# work on a copy of it.

o1.RemoveSpaces()
? o1.Content()
#--> [ "ring", "ring", "ring" ]

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

? @@( Q(" ").Unspacified() )
#--> ""

? @@( Q("  ").Unspacified() )
#--> " "

? @@( Q("   ").Unspacified() )
#--> " "

? @@( Q(" ♥").Unspacified() )
#--> "♥"

? @@( Q("♥ ").Unspacified() )
#--> "♥"

? @@( Q(" ♥ ").Unspacified() )
#--> "♥"

? Q("r  in  g ").Unspacified() # Does not remove spaces inside!
#--> "r  in  g"

? Q("    r  in  g ").Unspacified()
#--> "r  in  g"

proff()

/*--------------

pron()

o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")

acSubStringsXT =  o1.SubStringsBetweenAndTheirSectionsXT("r","g")
//? @@S(acSubStringsXT)
#--> [
#	[ "r in g", [  1, 8  ] ],
#	[ "r ing",  [ 29, 34 ] ],
#	[ "r fing", [ 42, 47 ] ]
# ]


oHashList = QR(acSubStringsXT, :stzHashList)
acWithoutSpaces = oHashList.KeysQR(:stzListOfStrings).WithoutSapces()
#-->  [ "ring", "ring", "rfing" ]

aSectionsPos = Q(acWithoutSpaces).FindW('This[@i] = "ring"')
#--> [1, 2]

aSectionsToBeUnSpacified = oHashList.ValuesQ().ItemsAtPositions(aSectionsPos)
//? @@S(aSectionsToBeUnSpacified)
#--> [ [ 1, 8 ], [ 29, 34 ] ]

o1.UnspacifySections(aSectionsToBeUnSpacified)
? o1.Content()

proff()
# Executed in 0.12 second(s)

/*-------------

pron()

o1 = new stzString("   r  in  g  is a rin  g  ")
? @@S( o1.FindBetweenAsSectionsXT("r","g") )
#--> [ [ 4, 11 ], [ 19, 24 ] ]

? o1.SubStringsBetweenXTQR("r","g", :stzListOfStrings).WithoutSapces()
# NOTE: WithoutSapces() is misspelled and the correct form is WithoutSpaces!
# Despite that, softanza accepts it ;)
#--> [ "ring", "ring" ]

proff()
#--> Executed in 0.07 second(s)

/*--------------

pron()

o1 = new stzListOfStrings([
	"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
])

? o1.SubStrongs() # the strings containing other strings from the list
#--> [ "Ring" ]

? o1.SubStreaks() # the strings that are contained in other strings from the list
#--> [ "in" ]

proff()

/*--------------

pron()

o1 = new stzString("IbelieveinRingfutureandengageforit!")
o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()

proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzString(
"MahmoudBertAhmedMansourIlirGalMajdi"
)

o1.SpacifyTheseSubStrings([
	"Mahmoud", "Bert", "Ahmed", "Mansour", "Ilir", "Gal", "Majdi" ])

? o1.Content()
#--> Mahmoud Bert Ahmed Mansour Ilir Gal Majdi

proff()
# Executed in 0.08 second(s)

/*--------------

pron()

o1 = new stzString("99999999999")

o1.InsertXT("_", :EachNChars = 3)
//o1.InsertXT("_", [ :EachNChars = 3, :Forward ]) # TODO

? o1.Content()
#--> 999_999_999_99

proff()
# Executed in 0.05 second(s)

/*-------------

pron()

o1 = new stzString("123456789")

o1.InsertBefore([4, 7], "_") # or o1.InsertBeforePositions([4, 7], "_")
#--> 123_456_789

? o1.Content()
#--> 123_456_789

proff()

/*-------------

pron()

o1 = new stzString("123456789")

o1.InsertAfterPositions([3, 6], "_") # or o1.InsertAfterPositions([4, 7], "_")
#--> 123_456_789

//o1.InsertAfterEachNCharsXT(3, :StartingFrom = :End)
? o1.Content()
#--> 123_456_789

proff()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirst("♥♥♥")
#--> 6

? o1.FindFirstAsSection("♥♥♥")
#--> [6, 8]

? o1.FindFirstZ("♥♥♥")
#--> [ "♥♥♥", 6 ]

? o1.FindFirstZZ("♥♥♥")
#--> [ "♥♥♥", [6, 8] ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindLast("♥♥♥")
#--> 22

? o1.FindLastAsSection("♥♥♥")
#--> [22, 24]

? o1.FindLastZ("♥♥♥")
#--> [ "♥♥♥", 22 ]

? o1.FindLastZZ("♥♥♥")
#--> [ "♥♥♥", [22, 24] ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindNth(2, "♥♥♥")
#--> 22

? o1.FindNthAsSection(2, "♥♥♥")
#--> [22, 24]

? o1.FindNthZ(2, "♥♥♥")
#--> [ "♥♥♥", 22 ]

? o1.FindNthZZ(2, "♥♥♥")
#--> [ "♥♥♥", [22, 24] ]

proff()
# Executed in 0.03 second(s)

/*=================

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

# Spacifying the starting prosition with the S extension
? o1.FindNthS(2, "♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindFirstS("♥♥♥", :StartingAt = 5)
#--> 8

? o1.FindLastS("♥♥♥", :StartingAt = 6)
#--> 13

#--- Spacifying the direection with SD extension

? o1.FindNthSD(2, "♥♥♥", :StartingAt = 11, :Going = :Backward)
#--> 3

? o1.FindFirstSD("♥♥♥", :StartingAt = 14, :Backward)
#--> 8

? o1.FindLastSD("♥♥♥", :StartingAt = 6, :Direction = :Backward)
#--> 3

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", 8 ]

? o1.FindFirstSZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", 8 ]

? o1.FindLastSZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 13 ]

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSDZ(2, "♥♥♥", :StartingAt = 3, :Direction = :Forward)
#--> [ "♥♥♥", 8 ]

? o1.FindFirstSZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", 8 ]

? o1.FindLastSZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 13 ]

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥90♥♥♥")

? o1.FindNthSZZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindFirstSZZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindLastSZZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", [13, 15] ]

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥90♥♥♥")

? o1.FindNthSDZZ(2, "♥♥♥", :StartingAt = 3, :Direction = :Forward)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindFirstSDZZ("♥♥♥", :StartingAt = 5, :Direction = :Forward)
#--> [ "♥♥♥", [8, 10] ]

? @@S(o1.FindLastSDZZ("♥♥♥", :StartingAt = 6, :Direction = :Forward))
#--> [ "♥♥♥", [13, 15] ]

proff()
# Executed in 0.05 second(s)

/*=================
*/
pron()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥90♥♥♥")
/*
? @@S( o1.FindOccurrences( :Of = "♥♥♥" ) )
#--> [3, 8, 13 ]

? @@S( o1.FindOccurrencesZ( :Of = "♥♥♥") )
#--> [ "♥♥♥", [3, 8, 13 ] ]

? @@S( o1.FindOccurrencesZZ( :Of = "♥♥♥") )
#--> [ "♥♥♥", [ [3, 5], [8, 10], [13, 15] ] ]
*/
#--

? @@S( o1.FindOccurrencesD( :Of = "♥♥♥", :Backward ) )
#--> [3, 8, 13 ]

? @@S( o1.FindOccurrencesDZ( :Of = "♥♥♥", :Backward) )
#--> [ "♥♥♥", [3, 8, 13 ] ]

? @@S( o1.FindOccurrencesDZZ( :Of = "♥♥♥", :Backward) )
#--> [ "♥♥♥", [ [3, 5], [8, 10], [13, 15] ] ]

#--
/*
? o1.FindOccurrencesS( :Of = "♥♥♥", :StartingAt = 6 )
#--> [8, 13 ]

? o1.FindOccurrencesSZ( :Of = "♥♥♥", :StartingAt = 6 )
#--> [ "♥♥♥", [8, 13 ] ]

? o1.FindOccurrencesSZZ( :Of = "♥♥♥", :StartingAt = 6 )
#--> [ "♥♥♥", [ [8, 10], [13, 15] ] ]
*/

proff()

/*-----------------

FindTheseOccurrencesS([ 2, 3], :StartingAt)

/*=================

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥90♥♥♥")

FindNextS() # FindNextOccurrences()
FindNextNthS()
FindNextNthSZ()
FindNextNthSZZ()

# Same for Previous
/*-----------------

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")

? o1.FindFirstStartingAt("♥♥♥", 8)
? o1.FindFirstS("♥♥♥", :StartingAt = 8)
#--> Eliminate FindFirstXT("♥♥♥", :StartingAt = ...)

FindLastXT(..., :startingat)
FindNthXT(..., :startingat)

proff()

/*---------------

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@S( o1.FindBetween("{", "}") ) + NL
#--> [ 23, 33 ]

? @@S( o1.FindBetweenAsSections("{", "}") ) + NL
#--> [ [ 23, 25 ], [ 33, 35 ] ]

? @@S( o1.FindBetweenZ("{", "}") ) + NL
#--> [ [ "min", 23 ], [ "max", 33 ] ]

? @@S( o1.FindBetweenZZ("{", "}") ) # Or 
#--> [ [ "min", [ 23, 25 ] ], [ "max", [ 33, 35 ] ] ]

StopProfiler()
# Executed in 0.10 second(s)

/*------------/////

StartProfiler()

o1 = new stzString("The range is between {min} and {max}")

? @@S( o1.FindBetweenXT("{", "}") ) + NL
#--> [ 22, 32 ]

//? @@S( o1.FindBetweenXTZ("{", "}") ) + NL
#--> [ [ "min", 23 ], [ "max", 33 ] ]

? @@S( o1.FindBetweenXTZZ("{", "}") )
#--> [ [ "min", [ 23, 25 ] ], [ "max", [ 33, 35 ] ] ]

StopProfiler()
# Executed in 0.10 second(s)

/*============

pron()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}")
? @@S( o1.Find([ "♥♥♥", "✤✤✤" ]) ) # or FindMany()
#-->[ 6, 22, 35 ]

? @@S( o1.FindZ([ "♥♥♥", "✤✤✤" ]) ) + NL # or FindManyZ()
#--> [ [ "♥♥♥", [ 6, 22 ] ], [ "✤✤✤", [ 35 ] ] ]

? @@S( o1.FindZZ([ "♥♥♥", "✤✤✤" ]) ) # or FindManyZZ()
#--> [
#	[ "♥♥♥",   [ [6, 8], [22, 24] ] ],
# 	[ "✤✤✤", [ [ 35, 37 ] ] ]
# ]

proff()
# Executed in 0.07 second(s)

/*========================
/* NOTE :
	- RemoveNthItem(n) : Remove item at position n

	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
  	  (you can also use RemoveNthOccurrence(n, pItem)

	- RemoveThisNthItem(n, pItem) : remove nth item only if it
	  is equal to pItem
*/

/*
o1 = new stzString("_ABC_DE_")

o1.RemoveFirstChar()
? o1.Content()
#--> ABC_DE_

o1.RemoveThisFirstCharCS("a", :CS = FALSE)
? o1.Content()
#--> BC_DE_

o1.RemoveNthChar(:Last)
? o1.Content()
#--> BC_DE

o1.RemoveThisNthChar(3, "_")
? o1.Content()
#--> BCDE

/*========================

o1 = new stzString("ABC456DE")
o1.RemoveSection(4, 6)
? o1.Content()
#--> "ABCDE"

/*----------------------

o1 = new stzString("{HELLO}")
o1.RemoveFromStart("{")
? o1.Content()
#--> "HELLO}"

o1.RemoveFromEnd("}")
? o1.Content()
#--> "HELLO"

/*=================

StartProfiler()

o1 = new stzString("123456789")
o1.ReplaceSection(4, 6, :with = "♥♥♥")
? o1.Content()

StopProfiler()
#--> Executed in 0.02 second(s)

/*----------------

StartProfiler()

o1 = new stzString("ABcdeFG")

o1.ReplaceSection(4, 6, :By@ = '{ @EachCharQ.Uppercased() }')
? o1.Content()
#--> 123ABC789

StopProfiler()
#--> Executed in 0.013 second(s)

/*----------------

StartProfiler()

o1 = new stzList([ "A", "B", "c", "d", "e", "F" , "G" ])

o1.ReplaceSection(3, 5, :By@ = '{ @EachItemQ.Uppercased() }')
? o1.Content()
#--> [ "A", "B", "C", "D", "E", "F", "G" ]

StopProfiler()
#--> Executed in 0.011 second(s)

/*===================

StartProfiler()

Q("Ring programmin language.") {

	AddXT("g", :After = "programmin") # You can use :To instead of :After
	? Content()
	#--> Ring programming language.

}

StopProfiler()
#--> Executed in 0.02 second(s)

/*-----------

StartProfiler()

Q("__(♥__(♥__(♥__") {

	AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

Q("__♥__(♥__♥__") {

	AddXT( ")", :AfterNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.03 second(s)

/*-----------------

StartProfiler()

Q("__(♥__♥__♥__") {

	AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__(♥__") {

	AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()
# Executed in 0.04 second(s)

/*===------------

StartProfiler()

Q("Ring programming guage.") {	
	AddXT("lan", :Before = "guage")
	? Content()
	#--> Ring programming language.
}

StopProfiler()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

Q("__♥)__♥)__♥)__") {

	AddXT( "(", :BeforeEach = "♥" ) # ... you can also say :Before = "♥"
	? Content()
	#--> __(♥)__(♥)__(♥)__
}

StopProfiler()
# Executed in 0.02 second(s)

/*---------

StartProfiler()

Q("__♥__♥)__♥__") {

	AddXT( "(", :BeforeNth = [2, "♥"] )
	? Content()
	#--> __♥__(♥)__♥__
}

StopProfiler()
# Executed in 0.05 second(s)

/*---------

StartProfiler()

Q("__♥)__♥__♥__") {

	AddXT( "(", :BeforeFirst = "♥" )
	? Content()
	#--> __(♥)__♥__♥__
}

StopProfiler()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

Q("__♥__♥__♥)__") {

	AddXT( "(", :BeforeLast = "♥" )
	? Content()
	#--> __♥__♥__(♥)__
}

StopProfiler()
# Executed in 0.05 second(s)

/*===------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT(" ", :AroundEach = "♥")
	? Content()
	#--> __ ♥ __ ♥ __ ♥ __
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
	? Content()
	#--> __/♥\__/♥\__/♥\__
}
# Executed in 0.06 second(s)

StopProfiler()

/*-----------------

StartProfiler()

Q("__♥__♥__♥__") {

	AddXT([ "/","\" ], :AroundNth = [2, "♥"])
	? Content()
	#--> __♥__/♥\__♥__
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__♥__/♥\__/♥\__") {

	AddXT( [ "/","\" ], :AroundFirst = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.06 second(s)

/*-----------------

StartProfiler()

Q("__/♥\__/♥\__♥__") {

	AddXT( [ "/","\" ], :AroundLast = "♥" )
	? Content()
	#--> __/♥\__/♥\__/♥\__
}

StopProfiler()
# Executed in 0.07 second(s)

/*=====================

StartProfiler()

acOtherLangs = [ "JS", "C#", "PHP", "Python" ]

o1 = new stzString("JS style can be used in Ring!")

o1.Replace("JS", :By@ = '
	QR(acOtherLangs, :stzListOfStrings).
	ConcatenateXTQ([ :Using = ", ", :LastSep = ", and " ]).
	AddQ("s", :To = "style").
	Content()
')


? o1.Content()

StopProfiler()

/*------------------

StartProfiler()

o1 = new stzListOfStrings([ "Ring", "Python", "PHP", "JS" ])
? o1.ConcatenateXT(", ")
#--> Ring, Python, PHP, JS

? o1.ConcatenateXT(:Using = ", ")
#--> Ring, Python, PHP, JS

? o1.ConcatenateXT([ :Using = ", ", :LastSep = ", and " ])
#--> Ring, Python, PHP, and JS

? o1.Concatenate()
#--> RingPythonPHPJS

? o1.ConcatenateUsing(", ")
#--> Ring, Python, PHP, JS

? o1.ConcatenateUsingXT(", ", :LastSep = ", and ")
#--> Ring, Python, PHP, and JS

StopProfiler()
# Executed in 0.05 second(s)
/*==================

StartProfiler()

o1 = new stzString("ABC♥DEF★GHI♥JKL")
o1.ReplaceW(' Q(@char).IsNotLetter() ', :With = " ")
? o1.Content()
#--> ABC DEF GHI JKL

StopProfiler()
#--> Executed in 0.14 second(s)

#--------------------

StartProfiler()

o1 = new stzString("♥♥♥a★★★b♥♥♥")

o1.ReplaceW(' Q(@char).IsLetter() ', :With@ = " Q(@CurrentChar).Uppercased() ")
? o1.Content()
#--> ♥♥♥A★★★B♥♥♥

StopProfil er()
#--> Executed in 0.26 second(s)

/*==================

o1 = new stzString("_♥_★_♥_")

? @@S( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@S( o1.FindMany([ "♥", "★" ]) )
#--> [ 2, 4, 6 ]

o1 = new stzString("_♥_★_♥_")
? @@S( o1.FindManyXT([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
? @@S( o1.FindManyXT([ "♥", "★" ]) )
#--> [ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ]

/*-----------------

o1 = new stzString("12345")

? o1.Section(2, 4)
#--> "234"

? o1.Section(2, -2)
#--> "234"

? o1.Section(:First, :Last)
#--> "12345"

? o1.Section(3, :@)
#--> "3"

? o1.Section(:@, 3)
#--> "3"

/*----------

o1 = new stzString("123456")
? o1.NumberOfSubStrings()
#--> 21

//? o1.SubStrings()
#--> [
#	"123456", "6", "56", "456", "3456", "23456",
#	"12345", "5", "45", "345", "2345",
#	"1234", "4", "34", "234",
#	"123", "3", "23",
#	"12", "2",
#	"1"
# ]

stop()
/*----------

o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.NumbersComingAfter("@i")
#--> [ "-3", "3" ]

? o1.NumbersComingAfterQ("@i").Smallest()
#--> "-3"

? o1.NumbersComingAfterQ("@i").Greatest()
#--> "3"

/*----------

o1 = new stzString("@item = This[ @i+1 ]")
? o1.Numbers()
//? @@S( o1.NumbersAfter("@i") )

/*=================

o1 = new stzString("123456789")
? o1.Section(3, -3)
#--> "34567"

/*=================
*
o1 = new stzString("... ____ ... ____")
? o1.Find("...")
#--> [ 1, 10 ]

? @@S( o1.FindOccurrencesXT( :Of = "...", :AndReturnThemAs = :Positions ) )
#--> [ 1, 10 ]

? @@S( o1.FindOccurrencesXT( :Of = "...", :AndReturnThemAs = :Sections ) )
#--> [ [ 1, 3 ], [ 10, 12 ] ]

/*----------------

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")
? @@S( o1.Find("12.34") )
#--> [ 7, 39 ]
? @@S( o1.FindAsSections("12.34") )
#--> [ [ 7, 11 ], [ 39, 43 ] ]

? @@S( o1.FindManyAsSections([ "12.34", "-56.30", "77.12" ]) )
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

/*=================

o1 = new stzString("-23.67 pounds")
? o1.StartsWithANumber()
#--> TRUE

? o1.StartingNumber()
#--> -23.67

? o1.StartsWithNumber("-23.67")
#--? TRUE

/*-----------------

o1 = new stzString("Amount: -132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithNumber("-132.45")
#--> TRUE

? o1.TrailingNumber()
#--> -132.45

/*-----------------

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithNumber("+132.45")
#--> TRUE

? o1.TrailingNumber()
#--> +132.45

/*-----------------

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithNumber("132.45")
#--> TRUE

? o1.TrailingNumber()
#--> +132.45

/*-----------------

? Q([ "A", "B", "C", "D", "E" ]).NormaliseSection([1, :Last])

/*==================

o1 = new stzList([ ".", ".", "M", ".", "I", "X" ])
? o1.FindW(' @char = "." ')
#--> [1, 2, 4]

/*----------------- 

o1 = new stzString("..ONE...TWO..")
? @@S( o1.FindW(:Where = 'QR(@char, :stzChar).IsALetter()') )
#--> [ 3, 4, 5, 9, 10, 11 ]

? @@S( o1.YieldW( '@char', :Where = 'Q(@char).IsALetter()' ) )
#--> [ "O", "N", "E", "T", "W", "O" ]

/*------------------

o1 = new stzString("AB12CD345")
? @@S( o1.SplitToPartsOfNChars(2) )
#--> [ "AB", "12", "CD", "34", "5" ]

? @@S( o1.SplitToPartsOfNCharsXT(2) )
# Or you can be more explicit and say: SplitToPartsOfExactlyNChars(2)
#--> [ "AB", "12", "CD", "34" ]

/*===================

o1 = new stzString("ABC")
? @@S( o1.SubStrings() )
#--> [ "A", "AB", "B", "ABC", "C", "BC" ]

/*------------------

o1 = new stzString("*#!ABC$^..")
? o1.NumberOfSubStrings()
#--> 55

? o1.SubStringsW(' Q(@SubString).IsMadeOfLetters() ')
#--> #--> [ "A", "AB", "B", "ABC", "C", "BC" ]

/*==================

o1 = new stzString("..34..789..")
? o1.YieldXT( '@char', :StartingAt = 9, :UpTo = :LastItem ) # or :Until = :LastChar
#--> [ "9", ".", "." ]

? o1.YieldXT( '@char', :StartingAt = 7, :Until = ' @char = "." ' ) # The "." is not yielded
#--> "789"

? o1.YieldXT( '@char', :StartingAt = 7, :UntilXT = ' @char = "." ' ) # The "."  is yielded
#--> "789."

/*==================

o1 = new stzList([ ".",".",".","4","5","6",".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 4)
#--> [ "4", "5", "6" ]

? o1.PreviousNItems(3, :StartingAtPosition = 6)
#--> [ "4", "5", "6" ]

/*------------------

o1 = new stzString("...456...")
? o1.NextNChars(3, :StartingAtPosition = 4)
#--> [ "4", "5", "6" ]

? o1.PreviousNChars(3, :StartingAtPosition = 6)
#--> [ "4", "5", "6" ]


/*================== 

StartProfiler()
#                      4   8 01  4 6 89  23
o1 = new stzString("...12..1212..121212..12.")
? @@S( o1.FindMadeOf("12") )
#--> [ 4, 8, 10, 14, 16, 18 ]

? @@S( o1.FindMadeOfAsSections("12") )
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

? @@S( o1.SubStringsMadeOf("12") )
#--> [ "12", "1212", "121212", "12" ]

? @@S( o1.SubStringsMadeOfXT("12") )
#--> [
#	[ "12", [ 4, 5 ] ],
#	[ "1212", [ 8, 11 ] ],
#	[ "121212", [ 14, 19 ] ],
#	[ "12", [ 22, 23 ] ]
# ]

StopProfiler()

/*=============

pron()

o1 = new stzSplitter(1:8)
? @@S( o1.SplitAt([3, 5]) )
#--> [ [ 1, 2 ], [ 4, 4 ], [ 6, 8 ] ]

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? o1.FindW('This[@i] = "*"')
#--> [4, 7]
# Executed in 0.05 second(s)

? @@S( o1.SplitAtPositions([ 4, 7]) )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]
# Executed in 0.03 second(s)

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
? @@S( o1.SplitW('This[@i] = "*"') )
# [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

proff()
# Executed in 0.07 second(s)

/*--------

pron()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

? o1.FindWXT('@CurrentItem = "*"')
# Executed in 0.22 second(s)

? @@S(o1.SplitWXT('@CurrentItem = "*"'))
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]
# Executed in 0.22 second(s)

proff()
# Executed in 0.44 second(s)

/*==============

o1 = new stzString("..._...__...___...")
? @@S( o1.FindALL("_") )
#--> [ 4, 8, 9, 13, 14, 15 ]

? @@S( o1.FindSubstringsMadeOf("_") )
#--> [ 4, 8, 13 ]

? o1.SubStringsMadeOf("_")
#--> [ "_", "__", "___" ]

STOP()

/*-----------------

o1 = new stzString("_-132__114.45_ euros")
? o1.Numbers()

/*
? o1.StartsWithANumber()
#--> TRUE

? o1.StartsWithNumber("-132114.45")
#--> TRUE
/*
? o1.LeadingNumber()
#--> +132.45

/*=================

o1 = new stzString("book: 12.34, watch: -56.30, microbit: 12.34, glasses: 77.12")

? @@S( o1.Numbers() ) + NL
#--> [ "12.34", "-56.30", "12.34", "77.12" ]


? @@S( o1.UniqueNumbers() )
#--> [ "12.34", "-56.30", "77.12" ]


? @@S( o1.FindNumbers()) + NL
#--> [ 7, 21, 39, 55 ]

? @@S( o1.NumbersAndTheirPositions() ) + NL
#-->
# [
# 	[ "12.34",  [ 7, 39 ] ],
#	[ "-56.30", [ 21 ]    ],
#	[ "77.12",  [ 55 ]    ]
# ]

? @@S( o1.NumbersAndTheirSections() ) # TODO: Enhance performance!
#-->
# [
# 	[ "12.34", 	[ [ 7, 11 ], [ 39, 43 ]	] ],
#	[ "-56.30",	[ [ 21, 26 ] 		   	] ],
#	[ "77.12", 	[ [ 55, 59 ] 			] ]
# ]

? @@S( o1.FindNumbersAsSections() ) + NL
#--> [ [ 7, 11 ], [ 21, 26 ], [ 39, 43 ], [ 55, 59 ] ]

/*================

StartProfiler()

o1 = new stzString( " This 10 : @i - 1.23 and this: @i + 378.12! " )
? o1.NumbersComingAfter("@i")
#--> [ "-1.23", "+378.12" ]

? o1.NthNumberComingAfter(2, "@i")
#--> "+378.12"

? o1.Numbers()
#--> [ "10", "-1.23", "+378.12" ]

StopProfiler()
# Executed in 0.51 second(s)

/*-----------------

pron()

o1 = new stzString( " This[ @i - 1 ] = This[ @i + 3 ] " )
? o1.NumbersComingAfter("@i")
#--> [ "-1", "+3" ]

proff()
#--> Executed in 0.14 second(s)

/*-----------------

? SoftanzaLogo()
/* --> 

╭━━━┳━━━┳━━━┳━━━━┳━━━┳━╮╱╭┳━━━━┳━━━╮
┃╭━╮┃╭━╮┃╭━━┫╭╮╭╮┃╭━╮┃┃╰╮┃┣━━╮━┃╭━╮┃
┃╰━━┫┃╱┃┃╰━━╋╯┃┃╰┫┃╱┃┃╭╮╰╯┃╱╭╯╭┫┃╱┃┃
╰━━╮┃┃╱┃┃╭━━╯╱┃┃╱┃╰━╯┃┃╰╮┃┃╭╯╭╯┃╰━╯┃
┃╰━╯┃╰━╯┃┃╱╱╱╱┃┃╱┃╭━╮┃┃╱┃┃┣╯━╰━┫╭━╮┃
╰━━━┻━━━┻╯╱╱╱╱╰╯╱╰╯╱╰┻╯╱╰━┻━━━━┻╯╱╰━

Programming, by Heart! By: M.Ayouni╭
━━╮╭━━━━━━━━━━━━━━━━━━━━╮╱╭━━━━━━━━╯
  ╰╯

/*-----------------

? Basmalah()	#--> ﷽
? Heart()	#--> ♥
? 3Hearts()	#--> ♥♥♥
? 5Stars()	#--> ★★★★★

/*-----------------

? Heart() # --> ♥
? Q(Heart()).RepeatedNTimes(3) #--> ♥♥♥
# or you can use the short form .NTimes(3)

? Q("Go").RepeatedNTimes(3) #--> GoGoGo

? @@S( Q([ "A", "B" ]).RepeatedNTimes(3) )
#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

? Five(Star()) #--> ★★★★★
? Three(Heart()) #--> ♥♥♥
/*---

/*------------------

o1 = new stzString("{abc}")
o1.RemoveThisFirstChar("{")
o1.RemoveThisLastChar("}")
? o1.Content()

/*------------------

# When applied to the string "Hi!", RepeatedNTimes() will update
# it to become "Hi!Hi!Hi!".

? Q("Hi!").RepeatedNTimes(3)
#--> "Hi!Hi!Hi!"

# When used with all other types (stzList, stzNumber, and stzObject),
# it will repeat the object value inside a list:

? Q(5).RepeatedNTimes(3)
#--> [5, 5, 5]

? Q(1:3).RepeatedNTimes(3)
#--> [ 1:3, 1:3, 1:3 ]

# You my ask we we opted for a different behavior for
# strings compared to other types, and why we don't produce
# a list even when we use the function on a string, like this
# ? Q("Hi!").RepeatNTimes(3) #!--> [ "Hi!", "Hi!", "Hi" ] ?

# Well, because I think it's more natural to update the
# string when we ask to repeat it, and have a string as a
# result not a list!

# If you want to avoid any confusuion coming from this double-usage,
# rely on RepeatedXT() instead, and specify explicitly what
# you hant to have as an output, like this:

? Q("Hi!").RepeatedNTimesXT( 3, :InString)
#--> "Hi!Hi:Hi!

? Q("Hi!").RepeatedNTimesXT( 3, :InList)
#--> [ "Hi!", "Hi!", "Hi!" ]

/*----------------------

? Q("*").IsNotLetter()
#--> TRUE

/*----------------------

? Q("ONE-TWO-THREE").Split("-")
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE").SplitW('{ Q(@char).IsNotLetter() }')
#--> [ "ONE", "TWO", "THREE" ]

? Q("ONE-TWO-THREE") / W('Q(@char).IsNotLetter()')
#--> [ "ONE", "TWO", "THREE" ]

/*----------------------

# Five nice usecases of the / operator on a Softanza string:

# Usecase 1: Dividing the string into 3 equal parts
? Q("RingRingRing") / 3
# --> [ "Ring", "Ring", "Ring" ]

# Usecase 2: Splitting the string using a given char
? Q("Ring;Python;Ruby") / ";"
# --> [ "Ring", "Python", "Ruby" ]

# Usecase 3: Splitting the string on each char verifying a condition
? Q("Ring:Python;Ruby") / W('Q(@Char).IsNotLetter()')
#--> [ "Ring", "Python", "Ruby" ]

# Usecase 4: Sharing the string equally between three stakeholders
? Q("RingRubyJava") / [ "Qute", "Nice", "Good" ]
# --> [ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ]

# Usecase 5: Specifying how mutch char we should give to every stakeholder
? Q("IAmRingDeveloper") / [
	:Subject = 1,
	:Verb    = 2,
	:Noun1   = 4,
	:Noun2   = :RemainingChars
]
#--> [ :Subject = "I", :Verb = "Am", :Noun1 = "Ring", :Noun2 = "Developer" ]

/*---------------

? PLuralOfThisStzType("stzChar")
#--> "stzchars"

/*---------------

? Q("stzchars").IsPluralOfAStzType()
#--> TRUE

? Q("stzchars").IsPluralOfThisStzType("stzchar")

/*---------------

? Q("punctuation").InfereMethod(:From = :stzChar)
#--> "ispunctuation"

? Q("punctuations").InfereMethod(:From = :stzChar)
#--> "ispunctauion"

/*================= "What You Think Is What You Write"

# In plain english, when you see "12309" you would say
# "all chars are numbers". In Softanza, it's the same:
? Q("12309").AllCharsAre(:Numbers)
#--> TRUE

# For "248", yoou say "All chars are even positive numbers"
# In Softanza, it's exactly the same:
? Q("248").AllCharsAre([ :Even, :Positive, :Numbers ])
#--> TRUE

# In this example, "all chars are punctuations", right?
? Q(",:;").AllCharsAre(:Punctuations)
#--> TRUE

# And in this one, "all chars are arabic":
? Q("سلام").AllCharsAre(:Arabic)
#--> TRUE

# Yes, "all chars are arabic chars"!
? Q("سلام").AllCharsAre([ :Arabic, :Chars ])
#--> TRUE

# And yes, "all chars are right-to-left arabic chars"! 
? Q("سلام").AllCharsAre([ :RightToLeft, :Arabic, :Chars ])
#--> TRUE

# In fact, you can be as expressive as you want, and say:
# "all chars are right-to-left chars, where each char is an arabic char"!
# In Softanza, it's the same, exactly the same:
? Q("سلام").AllCharsAre([ :RightToLeft, :Chars, Where('Q(@EachChar).IsAnArabic()'), :Char ])
#--> TRUE

# In Softanza, "What You Think Is What You Write".

/*---

? Q("Riiiiinngg").UniqueChars() #--> [ "R", "i", "n", "g" ]

/*---

? StzListOfStringsQ([ "A", "A", "A", "B", "B", "C" ]).
	ContainsCS("a", :CS = FALSE) #--> TRUE

/*---

? StzListOfStringsQ([ "A", "A", "A", "B", "B", "C" ]).DuplicatesRemoved()
#--> [ "A", "B", "C" ]

/*---

? Q("Riiiiinngg").
	CharsQR(:stzListOfStrings).
	RemoveDuplicatesQ().
	Concatenated()
#--> "Ring"

/*---

? Q("Riiiiinngg").DuplicatedCharsRemoved() #--> "Ring"
#--> "Ring"

/*---

? Q("(9, 7, 8)").
	RemoveWQ('Q(@Char).IsNumberInString()'). # becomes (, , )
	RemoveSpacesQ().			 # becomes (,,)
	RemoveDuplicatedCharsQ().		 # becomes (,)
	AllCharsAre(:Punctuations)
#--> TRUE

/*--- TODO - FUTURE: Add a QZ() function that traces the intermediate results:

? QZ("(9, 7, 8)").
	RemoveWQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	AllCharsAre(:Punctuations)
#--> [ "(, , )", "(,,)", "(,)", TRUE ]

/*---

? Q("(9, 7, 8)").
	RemoveWQ('Q(@Char).IsNumberInString()').
	RemoveSpacesQ().
	RemoveDuplicatedCharsQ().
	AllCharsAre(:Punctuations)	#--> TRUE

/*-----------------

str = "sun"
? Q(str).IsEither("moon", :Or = "sun")
#--> return
? Q(str).IsEither(:This = "moon", :OrThat = "sun")

/*-----------------

? Q("stzLen").IsAFunction() 	#--> TRUE
# or isFunc()

? Q("stzChar").IsAClass()	#--> TRUE

/*-----------------

? QQ("ر").StzType() #--> stzChar
? QQ("ر").UnicodeDirectionNumber() #--> "13"
? QQ("ر").IsRightToLeft() #--> TRUE

/*-----------------

? Q("LOVE").Inverted() 	#--> ƎɅO⅂
? QQ("L").IsInvertible()	#--> TRUE
# Note that QQ() elevates "L" to a stzChar

/*-----------------

? Q("str").AllCharsAre(:Chars)		#--> TRUE
? Q("str").AllCharsAre(:Strings)	#--> TRUE
? Q("123").AllCharsAre(:Numbers) 	#--> TRUE
? Q("(,)").AllCharsAre(:Punctuations)	#--> TRUE

? Q("نور").AllCharsAre(:Arabic)		#--> TRUE
? Q("نور").AllCharsAre(:RighttoLeft)	#--> TRUE

? Q("LOVE").AllCharsAre(:Invertible)
? Q("LOVE").Inverted()			#--> ƎɅO⅂
/*-----------------

? Q(2).IsANumber()	#--> TRUE
? Q(2).IsEven()		#--> TRUE
? Q(2).IsPositive()	#--> TRUE

/*-----------------

? QQ("①").IsCircledNumber() #--> TRUE
# or QQ("①").IsCircledDigit() if you wana embrace the semantics of Unicode

/*-----------------

? Q("①②③").AllCharsAre(:CircledNumbers)			#--> TRUE
? Q("①②③").AllCharsAre([:CircledNumber, :Chars])	#--> TRUE

/*-----------------

? Q("248").AllCharsAreXT([ :Even, :Positive, :Numbers ], :EvaluateFrom = :RTL)

/*-----------------

? Q("123").Check( 'isnumber( 0+(@char) )' ) #--> TRUE

/*=================

# Inverting (or turning) chars and strings
# NOTE: In the mean time, Softanza uses Invert()
# and Turn() as alternatives, but this should
# change in the future to cope with their exact
# meaning in Unicode!

? StzCharQ("L").Inverted()
? StzCharQ("L").IsInvertible()

? Q("LIFE").Inverted()

? StzCharQ("L").Turned()
? StzCharQ("L").IsTurnable()

? Q("LIFE").Turned()

/*============

? Q(".;1;.;.;." ) / ";"
# Same as: ? Q(".;1;.;.;." ).Splitted(:Using = ";")

#--> [ ".", "1", ".", ".", "." ]

/*----------

? Q(".;1;.;.;." ) / ";"
# Same as: ? Q(".;1;.;.;." ).Splitted(:Using = ";")

#--> [ ".", "1", ".", ".", "." ]

/*===============

? Q("Ring").Repeated(3)
#--> "RingRingRing"

? Q([1,2]).Repeated(3)
#--> [ [1,2], [1,2], [1,2] ]

/*----------------

? Q("A").RepeatXTQ(:String, 3).StzType()
#--> "stzstring"

? Q("A").RepeatXTQ(:List, 3).StzType()
#--> "stzlist"

/*----------------

? @@S( Q("5").RepeatedXT(:InA = :List, :OfSize = 2) )
#--> [ "5", "5" ]

? Q("A").RepeatedInAPair()
#--> [ "A", "A" ]

? @@S( Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3) )
#--> [ 5, 5, 5 ]

? Q("5").RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

? Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

? Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3)
#--> [ 5, 5, 5 ]

? @@S( Q(5).RepeatedXT(:InA = :ListOfStrings, :OfSize = 3) )
#--> [ "5", "5", "5" ]

? @@S( Q("A").RepeatedXT(:InA = :ListOfPairs, :OfSize = 3) ) + NL
#--> [ [ "A", "A" ], [ "A", "A" ], [ "A", "A" ] ]

? @@S( Q("A").RepeatedXT(:InA = :ListOfLists, :OfSize = 3) ) + NL
#--> [ [ "A" ], [ "A" ], [ "A" ] ]

? @@S( Q("A").
	RepeatXTQ(:InA = :List, :OfSize = 3).
	RepeatedXT(:InA = :List, :OfSize = 3)
) + NL
#--> [ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ]

? @@S( Q("A").RepeatedXT(:InA = :Grid, :OfSize = [3, 3]) ) + NL
#-->
# [
# 	[ "A", "A", "A" ],
# 	[ "A", "A", "A" ],
# 	[ "A", "A", "A" ]
# ]

? @@S( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]) ) + NL
#--> [
#	[ "COL1", [ "A", "A", "A" ] ],
#	[ "COL2", [ "A", "A", "A" ] ],
#	[ "COL3", [ "A", "A", "A" ] ]
# ]

/*-------------------

? Q(5).RepeatedInAPair()
#--> [5, 5]

/*-==================

o1 = new stzString("ab_cd_ef_gh")
? o1.ContainsMoreThenOne("_") 	#--> TRUE
? o1.ContainsMoreThenOne("a") 	#--> FALSE
? o1.ContainsOne("a")		#--> TRUE

/*------------------

o1 = new stzString("ab_cd_ef_gh")
? o1.FindFirst("_")			#--> 3
? o1.FindFirstXT("*", :StartingAt = 4)	#--> 0
? o1.FindFirstXT("_", :StartingAt = 3)	#--> 3

? o1.FindLast("_")	#--> 9
? o1.FindLast("*")	#--> 0

? o1.FindNth(2,"_")	#--> 6

/*------------------

o1 = new stzString("ab_cd_ef_gh")
? o1.FindFirstNOccurrences(2, "_")	#--> [3, 6]
? o1.FindLastNOccurrences(2, "_")	#--> [6, 9]

/*------------------

o1 = new stzString("ab_cd_ef_gh")
? o1.FindAll("_")
#--> [3, 6, 9]

/*=================

? @@S ( Q("

	.;1;.;.;.
	1;2;3;4;5
	.;3;.;.;.
	.;4;.;.;.
	.;5;.;.;.  " ).

	RemoveEmptyLinesQ().
	LinesQR(:stzListOfStrings).
	TrimQ().
	StringsSplitted(:Using = ";")
)

#--> [
#	[ ".", "1", ".", ".", "." ],
#	[ "1", "2", "3", "4", "5" ],
#	[ ".", "3", ".", ".", "." ],
#	[ ".", "4", ".", ".", "." ],
#	[ ".", "5", ".", ".", "." ]
# ]

/*=================

o1 = new stzString("How many <<many>> are there in (many <<<many>>>): so <many>>!")

? @@S(o1.Bounds(:Of = "many", :UpToNChars = [ 0, 2, 0, 3, [1,2] ])) + NL
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

//Same as:
? @@S(o1.Bounds(:Of = "many", :UpToNChars = [ [0,0], [2, 2], [0,0], [3,3], [1,2] ]))
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

/*=================

o1 = new stzString("ACB")
o1.Move( :CharFromPosition = 3, :To = 2 )
? o1.Content() #--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> "ACB"

/*------------------

o1 = new stzListOfStrings([ "A", "C", "B" ])
o1.Move( :StringFromPosition = 3, :To = 2 )
? o1.Content() #--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> "ACB"

/*------------------

o1 = new stzList([ "A", "C", "B" ])
o1.Move( :ItemFromPosition = 3, :ToPosition = 2 )
? o1.Content() #--> [ "A", "B", "C" ]

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content() #--> [ "A", "C", "B" ]

/*=================

o1 = new stzString("*AB*")

? @@S( o1.Find("*") )	#--> [1, 4]

# Or you can say:
? @@S( o1.Find( :SubString = "*" ) )	#--> [1, 4]

# Or also:
? @@S( o1.FindSubString( "*" ) )	#--> [1, 4]

# And many other alternatives that you can discover in the fucntion code

/*==================

? Q("NEXTAV TUNISIA").Section(:From = 1, :To = 6)
#--> "NEXTAV"

? Q("NEXTAV TUNISIA").Section(:From = (:NthToLastChar = 6), :To = :LastChar)
#--> "TUNISIA"

/*-----------------

? Q("SOFTANZA").NthToLast(3)
#--> "A"

/*-----------------

? Q("SOFTANZA").Section(1, 4)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = 1, :To = 4)
#--> "SOFT"

? Q("SOFTANZA").Section(4, 1)
#--> "TFOS"

? Q("SOFTANZA").Section(:From = :LastChar, :To = :FirstChar)
#--> "AZNATFOS"

? Q("SOFTANZA").Section(:From = (:NthToLastChar = 3), :To = :LastChar)
#--> "ANZA"

? Q("SOFTANZA").Section(:From = "F", :To = "A")
#--> "FTA"

? Q("SOFTANZA").Section( :From = "A", :To = :EndOfString )
#--> "ANZA"

? Q("Programming By Heart!
     This is Softanza motto.").
	Section( :From = "By", :To = :EndOfLine)
#--> "By Heart!"

? Q("SOFTANZA").Section(-99, 99)
#--> ""

? Q("SOFTANZA").Section(4, :@)
#--> "T"

? Q("SOFTANZA").Section(:NthToLast = 3, :@)
#--> "A"

? Q("SOFTANZA").Section(:@, :@)
#--> "SOFTANZA"

/*-----------------

o1 = new stzString("and **<Ring>** and _<<PHP>>_ AND <Python/> and _<<<Ruby>>>_ ANDand !!C++!! and")
? @@( o1.Split( :Using = "and" ) )
# --> [ "<Ring> ", " <<PHP>> ", " <Python/> ", " <<<Ruby>>> ", "", " !!C++!!" ]

/*----------------- TODO: FUTURE

? o1.SplitXT(
	:Using = "and",

	[ 
	:CaseSensitive = TRUE,
	:SkipEmptyParts = TRUE,

	:IncludeLeadingSep = TRUE,
	:IncludeTrailingSep = TRUE,

	:ExcludeLeadingSubstrings_FromSplittedParts = [ "_", "**" ],
	
	:ExcludeTrailingSubstrings_FromSplittedParts = [ "_", "**", "/>" ],

	:ExcludeLeadingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, "<" ],
	:ExcludeTrailingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, ">" ]
	]
)

/*=================

# IDENTIFYING LISTS INSIDE A STRING

# In many situations (especially in advanced metaprogramming scenarios),
# you may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in real time, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used ( noramal [_,_,_] or short _:_ ), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,2,3]').IsListInString()		#--> TRUE

? StzStringQ('1:3').IsListInString()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInString()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInString()		#--> TRUE

# Softanza can tell you if the syntax used is normal or short:

? StzStringQ('[1,2,3]').IsListInNormalForm()		#--> TRUE
? StzStringQ('1:3').IsListInShortForm()			#--> TRUE

? StzStringQ(' "A":"C" ').IsListInShortForm()		#--> TRUE
? StzStringQ(' "ا":"ج" ').IsListInShortForm()		#--> TRUE

# And knows about the list beeing contiguous or not:

? StzStringQ('[1,3]').IsContiguousListInString()	#--> FALSE
? StzStringQ('1:3').IsContiguousListInString()		#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInString()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInString()	#--> TRUE

	# REMINDER: A contiguous list can be made of  numbers,
	# or contiguous chars (based on their unicode numbers).
	# And you can identify them using the stzList.IsContiguous():

	? StzListQ(1:3).IsContiguous()		#--> TRUE
	? StzListQ("A":"E").IsContiguous()	#--> TRUE


# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is contiguous
# or not, it can also see in what form they are:

? StzStringQ('[1,2,3]').IsContiguousListInNormalForm()	#--> TRUE
? StzStringQ('1:3').IsContiguousListInShortForm()	#--> TRUE

? StzStringQ(' "A":"C" ').IsContiguousListInShortForm()	#--> TRUE
? StzStringQ(' "ا":"ج" ').IsContiguousListInShortForm()	#--> TRUE

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,2,3]').ToListInShortForm() )	#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

? StzStringQ(' ["A","B","C","D"] ').ToListInShortForm()	#--> "A" : "D"
? StzStringQ(' "ا":"ج" ').ToListInShortForm()		#--> "ا" : "ج"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,2,3]').ToListInString() )	#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )	#--> "[1, 2, 3]"

? StzStringQ(' "A":"C" ').ToListInString()	#--> [ "A", "B", "C" ]
? StzStringQ(' "ا":"ج" ').ToListInString()	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# If you prefer (or need) the short form, there is an interesting
# abbreviation to the ToListInShortForm() alternative that uses
# the simple SF prefix (S for Short and F for Form), like this:

? @@( StzStringQ('[1,2, 3]').ToListInStringSF() ) 		#--> "1 : 3"

? @@( StzStringQ('1:3').ToListInStringSF() )			#--> "1 : 3"

? StzStringQ(' ["A","B","C","D"] ').ToListInStringSF()		#--> "A" : "D"
? StzStringQ(' [ "ا", "ب", "ة", "ت" ] ').ToListInStringSF() 	#--> "ا" : "ت"

# Finally, as a cherry on the cake, you can evaluate
# the string in list in real time like this:

? StzStringQ('1:3').ToList()	   	#--> [1, 2, 3]
? StzStringQ(' "A":"C" ').ToList() 	#--> ["A", "B", "C"]
? StzStringQ(' "ا":"ج" ').ToList() 	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

/*=================

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.SubstringsBetween("<<", :and = ">>")
#--> [ "word", "noword", "word" ]

? o1.UniqueSubStringsBetween("<<", :and = ">>")
#--> [ "word", "noword" ]

/*-----------------

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? o1.NumberOfOccurrence(:OfSubString = "many")
#--> 5
? @@S( o1.Positions(:of = "many") ) + NL	# or o1.FindSubString("many")
#--> [5, 12, 33, 40, 54]

? @@S(o1.Sections(:Of = "many")) + NL		# or o1.FindAsSections(:OfSubString = "many")
#--> [ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ], [ 40, 43 ], [ 54, 57 ] ]

	# Note that Sections() has an other syntax that returns, not the sections
	# as pairs of numbers as in the example above, the substrings corresponding
	# to the sections themselves:

	? o1.Sections([ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ] ])
	#--> [ "many", "many", "many" ]

? o1.NumberOfOccurrenceXT(
	:OfSubString = "many",
	:BoundedBy = ["<<", :and = ">>"]
	# or :Between = ["<<", :and = ">>"]
	# or :BetweenSubStrings = ["<<", :and = ">>"]
	# or :BoundedBySubStrings = ["<<", :and = ">>"]
)
#--> 3

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Section(8, 9)
#--> "<<"
? o1.Section(14, 16)
#--> ">>>"
? o1.Sections([ [8, 9], [14, 16] ])
#--> [ "<<", ">>>" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Section(50, 0)	#--> NULL
? o1.Section(0, 0)	#--> NULL
? o1.Section(-20, 10)	#--> NULL
? o1.Section(3, 3)	#--> "a"
? o1.Section(10, 13)	#--> "nice"
? o1.Section(13, 10)	#--> "ecin"

/*==================

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? @@S( o1.Bounds( :Of = "many", :UpToNChars = 1 ) ) + NL
#--> [ [ " ", " " ], [ "<", ">" ], [ "(", " " ], [ "<", ">" ], [ "<", ">" ] ]

# Same as:
? @@S( o1.Bounds( :Of = "many", :UpToNChars = [1, 1] ) ) + NL
#--> [ [ " ", " " ], [ "<", ">" ], [ "(", " " ], [ "<", ">" ], [ "<", ">" ] ]

? @@S( o1.Bounds( :Of = "many", :UpToNChars = [ 0, 2, 0 ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ] ]

? @@S( o1.Bounds(:Of = "many", :UpToNChars = [ 0, 2, 0, 2, 2 ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ], [ "<<", ">>" ], [ "<<", ">>" ] ]

? @@S( o1.Bounds(:Of = "many", :UpToNChars = [ [0,0], [2,2] ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ] ]

? @@S( o1.Bounds(:Of = "many", :UpToNChars = [ 0, [2,2], 0, 2, [2, 2] ] ) ) + NL
#--> [ [ "", "" ], [ "<<", ">>" ], [ "", "" ], [ "<<", ">>" ], [ "<<", ">>" ] ]

/*----------

o1 = new stzString("what a <<<nice>>> day!")
? @@S( o1.Bounds(:Of = "nice", :UpToNChars = 3) )
#--> [ [ "<<<", ">>>" ] ]

o1 = new stzString("what a <nice>>> day!")
? @@S( o1.Bounds(:Of = "nice", :UpToNChars = [1, 3]) )
#--> [ [ "<", ">>>" ] ]

o1 = new stzString("what a <<nice>>> day! Really <nice>>.")
? @@S( o1.Bounds(:Of = "nice", :UpToNChars = [ [2, 3], [1, 2] ]) )
#--> [ [ "<<", ">>>" ], [ "<", ">>" ] ]

/*==================

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ "<<", ">>>" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")
? o1.Sit(
	:OnPosition = 11, # the letter "i"
	:AndHarvest = [ :NCharsBefore = 1, :NCharsAfter = 2 ]
)
#--> { "n", "ce" ]

/*-----------------

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvestSections = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ [8, 9], [14, 16] ]

/*----------------- TODO

o1 = new stzString("what a 123nice>>> day!")

? o1.Sit(
	:OnSection  = o1.FindFirstSection("nice"),
	:AndHarvest = [ :CharsBeforeW = 'Q(@char).IsANumber()', :NCharsAfter = 3 ]
)
#--> [ "123", ">>>" ]

/*=================

o1 = new stzString("How many words in <<many many words>>? So many!")
? @@S( o1.FindPositions(:Of = "many") )
#--> [ 5, 21, 26, 43 ]
? @@S( o1.FindAsSections(:Of = "many") ) + NL
#--> [ [ 5, 8 ], [ 21, 24 ], [ 26, 29 ], [ 43, 46 ] ]

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? @@S( o1.AnySubstringsBetween("<<", :and = ">>") )
# --> [ "word", "noword", "word" ]

? @@S( o1.FindSubStringsBetween("<<", :and = ">>") ) + NL
# --> [ 11, 28, 43 ]

? @@S( o1.FindBetweenAsSections("<<",">>") )
# --> [ [ 11, 14 ], [ 28, 33 ], [ 43, 46 ] ]



/*----------------

o1 = new stzString("bla bla <<word1>> bla bla <<word2>> bla <<word3>>")
? o1.NthSubStringBetween(2, "<<", ">>") #--> "word2"
# or you can say:
? o1.NthSubStringXT(2, :Between = ["<<", ">>"]) #--> "word2"

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.Nth(2, "word")		#--> 30
? o1.NthAsSection(2, "word")	#--> [ 30, 33 ]

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.NthXT(2, "word", :ReturnSection)
#--> [30, 33]

? o1.NthXT(2, "word", :Between = ["<<", ">>"])
#--> 43

? o1.NthXTCS(2, "WORD", :Between = ["<<", ">>"], :CS = FALSE)
#--> 43

? o1.NthSectionXT(2, "word", :Between = ["<<", ">>"])
#--> [43, 46]

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
? o1.FindNthBetween(2, "word", "<<", ">>")
#--> 28
? o1.FindNthSectionBetween(2, "word", "<<", ">>")
#--> [28, 31]

? o1.FindNthXT(2, "word", :Between = ["<<", ">>"])
#--> 28
? o1.FindNthSectionXT(2, "word", :Between = ["<<", ">>"])

/*================

o1 = new stzString("**word1***word2**word3***")
? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveSections([
	[1,2], [8, 10], [16, 17], [23, 25]
])

? o1.Content() # --> "word1word2word3"

/*----------------------

o1 = new stzString("**word1***word2**word3***")
? o1.Ranges([ [1,2], [8, 3], [16, 2], [23, 3] ])
#--> [ "**", "***", "**", "***" ]

o1.RemoveRanges([ [1,2], [8, 3], [16, 2], [23, 3] ])
? o1.Content()
#--> "word1word2word3"

/*-----------------

o1 = new stzString("..AA..aa..BB..bb")

o1.RemoveSectionsW(
	[ [3, 4], [7,8], [11,12], [15,16] ],
	:Where = '{ Q( @section ).IsLowercase() }'
)

? o1.Content()
#--> "..AA....BB.."

/*-----------------

o1 = new stzString("..AA..aa..BB..bb")

o1.RemoveRangesW(
	[ [3, 2], [7,2], [11,2], [15,2] ],
	:Where = '{ Q( @range ).IsLowercase() }'
)

? o1.Content()
#--> "..AA....BB.."

/*=================

o1 = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International 
")

o1.Simplify()

o1.RemoveCharsW('{ lower(@char) = "x" }')
? o1.Content()

#--> 	The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit
#	home computer introduced in January 1982 by Commodore International

/*=================

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
#--> [ 11, 43 ]

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindNthXT(2, "word", :Between = ["<<", ">>"])
#--> 43

? o1.FindNthSectionXT(2, "word", :Between = ["<<", ">>"])
#--> [43, 46]

? o1.FindNthXT(2, "word", :ReturnSection)

/*-----------------

o1 = new stzString("12*45*78*c")
? o1.FindAll("*")
#--> [3, 6, 9]

? o1.NFirstOccurrences(2, :Of = "*") 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = "*", :StartingAt = 5)
#--> [3, 6]

? o1.LastNOccurrencesXT(2, :Of = "*", :StartingAt = 2)
#--> [6, 9]

/*-----------------

o1 = new stzString("12abc67abc12abc")
? o1.FindAll("abc")
#--> [3, 8, 13]

# Note: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 8]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 1)
#--> [3, 8]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [8, 13]

? o1.NLastOccurrencesXT(2, "abc", :StartingAt = 1)
#--> [8, 13]


? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 6)
#--> [8, 13]

? o1.LastNOccurrencesXT(2, :Of = "abc", :StartingAt = 10)
#--> [8, 13]

/*=================

o1 = new stzString("**3**67**012**56**92**")
? @@S( o1.FindBetweenXT("**") )	# or if you want FindSeparatedBy("**")
#--> [ 3, 6, 10, 15, 19 ]

? @@S( o1.FindBetweenAsSectionsXT("**") )
#--> [ [3,3], [6, 7], [10, 12], [15,16], [19,20] ]

/*-----------------
*/
o1 = new stzString("***ONE***TWO***THREE***")
? @@S( o1.FindManyCS([ "ONE", "TWO", "THREE"], 0) )
#--> [ [ 4 ], [ 10 ], [ 16 ] ]

o1 = new stzString("***ONE***TWO***THREE***")
? @@S( o1.FindManyCS([ "ONE", "TWO", "THREE"], 0) )

/*
? o1.SplitQ(:Using = "***").FindIn(o1.Content())

/*
? @@S( o1.FindBetweenXT("**") )
#--> [ 2, 4, 7, 10 ]

? @@S( o1.FindBetweenAsSectionsXT("**") )


/*-----------------
*/
# You can find the positions of any substring occurring between
# two bounds by saying:

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@S( o1.FindBetween("<<",">>") )
#--> [7, 20]

# In fact, "ring" occures in position 7 and "php" in position 20.

# Now, if you have the following case where the two bounds are
# the same (equal to "*" here):

o1 = new stzString("*2*45*78*0*")
? @@S( o1.FindBetween("*","*") )
#--> [2, 7]

# then you get "2" that starts at position 2 and "78" at position 7.
# Let's understand what happened to get this result:

	# the positions	:  12345678901
	# the string	: "*2*45*78*0*"
	# the occurences:   ^    ^

# Softanza starts scanning the string. First, it finds that "*2*"
# corresonds to a substring ("2") between "*" and "*". Then it
# takes its position 2.

# Second, Softanza starts from position 3 and scans the remaining
# substring "45*78*0*" for any other substring between "*" and "*".
# It finds it at position 7 (substring "78").

# Until now, we have positions 2 and 7.

# Again, Softanza retrives "*78*" from "45*78*0*". Now the substring
# to be scanned is "45*". There is no substrings between "*" and "*".
# So the result [2, 7] is returned.

# Now, you would ask me: What if I want to get all the positions of
# substrings separated by the char "*", like this:

	# the positions	:  12345678901
	# the string	: "*2*45*78*0*"
	# the occurences:   ^ ^  ^  ^
	# --> [2, 4, 7, 10]

# Then you can use the extended version of the function ..XT() and
# pass the "*" char as a parameter like this:

? @@S( o1.FindBetweenXT("*") )
#--> [ 2, 4, 7, 10 ]

/*--------------

# For each one of the 3 function calls we made so far (see
# example above), you can get the result as sections and not
# as positions. To do so, just use the same functions while
# adding the keyword Sections like this:

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@S( o1.FindBetweenAsSections("<<",">>") )
#--> [ [ 7, 9 ], [ 20, 21 ] ]

o1 = new stzString("*2*45*78*0*")
? @@S( o1.FindBetweenAsSections("*","*") )
#--> [ [ 2, 2 ], [ 7, 8 ] ]

? @@S( o1.FindBetweenAsSectionsXT("*") )
#--> [ 2, 4, 7, 10 ]

/*-----------------

? Q("txt <<ring>> txt <<ring>>").FindBetweenAsSections("<<",">>")
#--> [ [7,10], [20,23] ]

str = 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!'
? Q(str).FindBetweenAsSections('"', '"')

/*

? @@S( 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!' )
#--> 'for txt = "   val1  " to "   val2" do this or that!'

/*-----------------

o1 = new stzString("12*♥*78*♥*")
? @@S( o1.FindBetween("♥", "*","*") )
#--> [ 4, 9 ]

/*-----------------

o1 = new stzString("12*34*56*78")
? o1.FindNthXT(2, "*", :StartingAt = 4)
#--> 6

? o1.FirstXTT("*", :StartingAT = 4)
#--> 3

/*-----------------

o1 = new stzString("12*A*33*A*")
? o1.FindAll("*")
#--> [3, 5, 8, 10]

? o1.FindNth(3, "*")
#--> 8

? o1.FindFirst("*")
#--> 3

? o1.FindLast("*")
#--> 10

? @@S( o1.FindAsSections("*") )
#--> [ [ 3, 3 ], [ 5, 5 ], [ 8, 8 ], [ 10, 10 ] ]

/*-----------------

o1 = new stzString("12*A*33*A*")
? o1.Sections([ 1:2, 6:7 ])
#--> [ "12", "33" ]

/*-----------------

o1 = new stzString("12*A*33*A*")
? o1.FindBetween("A", "*", "*")
#--> [4, 9]

? o1.FindBetweenAsSections("A", "*", "*")
#--> [ [4, 4], [9, 9] ]

/*-----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
? o1.FindBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
#--> [ 11, 43 ]

? o1.FindBetweenAsSections("word", "<<", ">>")
#--> [ [11, 14], [43, 46] ]

//? o1.FindXT("word", :Between = [ "<<", ">>" ])


/*-----------------
/
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :Between = [ "<<", ">>" ])
#--> [6, 24]

? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [6, 24]

/*-----------------

o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindBetween("word", "<<", ">>")
#--> [6, 24]

/*-----------------

o1 = new stzString("my **word** and your **word**")

? o1.FindBetween("word", "**", "**")
#--> [6, 24]

? o1.FindXT("word", :BoundedBy = "**")
#--> [6, 24]

/*-----------------

o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :StartingAt = 12)
#--> [ 13 ]

? o1.FindXT("word", :InSection = [3, 10])
#--> [ 4 ]

/*-----------------

o1 = new stzString("12*♥*56*♥*")
? o1.FirstXT("♥", :BoundedBy = [ "*", "*"])
#--> 4

? o1.FirstXT("♥", :BoundedBy = "*")
#--> 4

/*-----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")
? @@S( o1.FindBetween("word", "<<", ">>") )
#--> [ 11 ]

? @@S( o1.FindBetweenAsSections("word", "<<", ">>") )
#--> [ [ 11, 14 ] ]

? @@S( o1.FindBetween("<<",">>") )
#--> [ 11, 28, 43 ]

? @@S( o1.FindBetweenAsSections("<<",">>") )
#--> [ [ 11, 14 ], [ 28, 33 ], [ 43, 49 ] ]

/*-----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")
o1.ReplaceAnyBetween("<<", ">>", :With = "word")
? o1.Content()  #--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

/*-----------------

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
o1.RemoveBoundsOfSubString(["<<", ">>"], "word")
? o1.Content()
#--> "bla bla word bla bla word bla word"

# or, mor naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
o1.RemoveBoundsXT(["<<", ">>"], :Of = "word")
? o1.Content() #--> "bla bla word bla bla word bla word"
#--> "bla bla word bla bla word bla word"

/*------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceBetween("noword", "<<", ">>", :With = "word")
? o1.Content()
#--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

# or, mor naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.ReplaceXT("noword", :Between = ["<<", ">>"], :With = "word")
#--> "bla bla <<word>> bla bla <<word>> bla <<word>>"

/*------ 

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveAnyBetween("<<", ">>")
? o1.Content()	# --> "bla bla <<>> bla bla <<>> bla <<>>"

/*----------------

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveSubStringBetween("noword", "<<", ">>") # Short form of RemoveBetween()
? o1.Content()
#--> "bla bla <<word>> bla bla <<>> bla <<word>>"

# Or, more naturally, you can say:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("noword", :Between = ["<<", ">>"])
? o1.Content()
#--> "bla bla <<word>> bla bla <<>> bla <<word>>"

/*-----------------

# EXAMPLE 1:

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("word", :Between = ["<<", ">>"])
? o1.Content() + NL
#--> bla bla <<>> bla bla <<noword>> bla <<>>
		
# EXAMPLE 2

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("word", :AtPosition = 11)
? o1.Content() + NL
#--> bla bla <<>> bla bla <<noword>> bla <<>>

# EXAMPLE 3

o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
o1.RemoveXT("word", :AtPositions = [ 11, 43 ])
? o1.Content()
#--> bla bla <<>> bla bla <<noword>> bla <<>>

/*-----------------

o1 = new stzString("<<Go!>>")
? o1.BoundsRemoved(["<<", ">>"]) # --> "Go!"

/*=================

# In Softanza, to remove a substring from left or right
# you can use RemoveFromLeft() and RemoveFromRight() functions.

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromLeft("let's say ")
? o1.Content() # --> welcome to everyone!

# But when right-to-left strings are used, this can be confusing,
# since left is no longer at the start of the string, nor the
# right is at the end!

# Hence, if you want to retrieve a substring from the beginning
# of a right-to-left arabic text ("هذه" in the following example),
# you should inverse the orientation and use RemoveFromRight()
# instead...

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
? o1.NRightChars(4) #--> "هذه "
o1.RemoveFromRight("هذه ")
? o1.Content() # --> "الكلمات الّتي سوف تبقى"

# To avoid this complication, Softanza provides a more general (semantic)
# solution working both for left-to-right and right-to-left strings:
# the RemoveFromStart() and RemoveFromEnd() functions...

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromStart("let's say ")
? o1.Content() # --> welcome to everyone!

# and the same code for arabic:

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
o1.RemoveFromStart("هذه ")
? o1.Content() # --> "الكلمات الّتي سوف تبقى"

/*========================

o1 = new stzString("من كان في زمنه من أصحابه فهو من أكبر المحظوظين")
o1.RemoveNthOccurrence(:Last, " من")
? o1.Content()
# --> Gives من كان في زمنه من أصحابه فهو أكبر المحظوظين

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrence(:Last, "A")
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveNthOccurrenceCS(:Last, "a", :CaseSensitive = FALSE)
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveLast("A")
? o1.Content() # --> **A1****A2***3

/*-----------------

o1 = new stzString("**A1****A2***A3")
o1.RemoveFirst("A")
? o1.Content() # --> **1****A2***A3

/*==================

o1 = new stzString("<<word>>")

? o1.IsBoundedBy(["<<", ">>"]) # --> TRUE

o1.RemoveBounds(["<<",">>"])
? o1.Content() # --> word

/*---------------

o1 = new stzString("word")
o1.AddBounds(["<<",">>"])	# --> or BoundWith(["<<",">>"])
? o1.Content()
#--> <<word>>

/*--------------- TODO (future)

o1 = new stzString("<<word>>")

? o1.Bounds() # !--> [ "<<", ">>" ]

? o1.LeftBound() # !--> "<<"
? o1.RightBound() # !--> ">>"

# And also FirstBound() and LastBound() for general
# use with left-to-right and right-toleft strings

/*=================

? StzRaise("Simple error message!")
# --> Simple error message! 

/*-----------------

? StzRaise([
	:Where	= "stzString.ring",
	:What 	= "Describes what happend",
	:Why  	= "Describes why it happened",
	:Todo 	= "Posposes an action to solve the error"
])

# --> Line ... in file stzString.ring:
#	  What : Describes what happend
#	  Why  : Describes why it happened
#	  Todo : Posposes an action to do
#

/*-----------------

? Q(:CaseSensitive = TRUE).IsTrue()	#--> TRUE
? Q(:CaseSensitive = FALSE).IsFalse()	#--> TRUE

/*-----------------

o1 = new stzString("@str = Q(@str).Uppercased()")
? o1.BeginsWithOneOfTheseCS([ "@str =", "@str=" ], :CS = TRUE) # --> TRUE

/*-----------------

o1 = new stzString("Baba, Mama, and Dada")
? o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = FALSE) # --> TRUE

/*-----------------

StzStringQ('') {
	UpdateFromURL("https://ring-lang.github.io/doc1.16/qt.html")
	? Content()
}
#--> Returns the page content as HTML

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {
	? @@S( FindAllOccurrencesCS(:Of = "ring", :CS = FALSE) )
	# --> [ 1, 17, 39 ]

	? @@S( FindAsSectionsCS(:Of = "ring", :CS = FALSE) )
	#--> [ [ 1, 4 ], [ 17, 20 ], [ 39, 42 ] ]

	? @@S( FindOccurrences([1, 3], :Of = "ring") )
	#--> [1, 39]

	? @@S( FindOccurrences([1, 3], :Of = "foo") )
	#--> [ ]
}

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? NextNthOccurrence(1, :of = "ring", :startingat = 1)	#--> 1
	? NextNthOccurrence(2, :of = "ring", :startingat = 17)	#--> 39

}

/*-----------------

StzStringQ("ring is not the ring you ware but the ring you program with") {

	? FindNextOccurrences(:Of = "ring", :StartingAt = 12)
	#--> [ 18, 40 ]

	? FindPreviousOccurrences(:Of = "ring", :StartingAt = 30)
	#--> [ 1, 17 ]

}

/*======================

o1 = new stzString("Softanza embraces ♥♥♥ simplicty and flexibility")
o1.ReplaceSubStringAtPosition(19, "♥♥♥", :With = "Ring")
? o1.Content() #--> Softanza embraces Ring simplicty and flexibility

/*======================

? Q("RINGO").HasCentralChar()		 #--> TRUE
? Q("RINGO").CentralChar()		 #--> N
? Q("RINGO").PositionOfCentralChar()	 #--> 3
? Q("RINGO").HasThisCharInTheCenter("N") #--> TRUE

/*----------------------

? Q("ArabicArabicArabic").IsMultipleOf("Arabic")	  # --> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic") # --> TRUE
? Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic") # --> FALSE

? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = TRUE)	  # --> FALSE
? Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = FALSE)	  # --> TRUE

/*====================== WORKING WITH MARQUERS

? StzStringQ("My name is #.").ContainsMarquers()   #--> FALSE
? StzStringQ("My name is #0.").ContainsMarquers()  #!--> FALSE --> TODO: Correct this!
? StzStringQ("My name is #1.").ContainsMarquers()  #--> TRUE
? StzStringQ("My name is #01.").ContainsMarquers() #--> FALSE

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {
	? Marquers() # --> #1, #2, #3
}

StzStringQ("My name is #2, my age is #3, and my job is #1.") {
	? Marquers() # --> #2, #3, #1
}

/*----------------------

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@S( Marquers() )
	# --> [ "#1", "#2", "#3", "#1" ]

	? @@S( MarquersPositions() ) # or FindMarquers()
	# --> [   12,   25,   44,   66 ]

	? @@S( MarquersAndPositions() )
	# --> [ "#1" = 12, "#2" = 25 , "#3" = 44, "#1" = 66 ]

	? @@S( MarquersAndPositionsXT() )
	# --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NumberOfMarquers()		#--> 4

	? FirstMarquer()		# --> #1

	? FindFirstMarquer()		# --> 12
	# You can also say:
	# ? FirstMarquerOccurrence()
	# ? FirstMarquerPosition()

	? LastMarquer()			# --> #1
	
	? FindLastMarquer()		# --> 66
	# You can also say:
	# ? LastMarquerOccurrence()
	# ? LastMarquerPosition()

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NthMarquer(2)			# --> #2

	? FindNthMarquer(2)		# --> 26
	# You can also say:
	# ? NthMarquerOccurrence(2)
	# ? NthMarquerPosition(2)
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NextNthMarquer(2, :StartingAt = 14)		# --> #3
	# Or you can say:
	# ? NthNextMarquer(2, :StartingAt = 14)

	? FindNextNthMarquer(2, :StartingAt = 14)	# --> 44
	# Or you can say:
	# ? NextNthMarquerOccurrence(2, :StartingAt = 14)
	# ? NthNextMarquerOccurrence(2, :StartingAt = 14)
	# ? NextNthMarquerPosition(2, :StartingAt = 14)
	# ? NthNextMarquerPosition(2, :StartingAt = 14)

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? @@S( MarquersAndPositionsXT() )
	# --> # --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]

	? @@S( FindMarquer("#1") ) #--> [ 12, 66]
	# Or ? OccurrencesOfMarquer("#1")
	

	? @@S( FindMarquer("#7") ) # --> []

	? MarquerByPosition(66)	  # --> #1
	? MarquerByPosition(44)   # --> #3

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	? PreviousMarquers(:StartingAt = 50 ) # --> [ "#1", "#2", "#3" ]
	? NextMarquers(:StartingAt = 15)      # --> [ "#2", "#3", "#1" ]
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	? PreviousNthMarquer(3, :StartingAt = 50) 		# --> #1
	? PreviousNthMarquerPosition(3, :StartingAt = 50) 	# --> 12
	? PreviousNthMarquerAndItsPosition(3, :StartingAt = 50) # --> [ "#1", 12 ]
}
/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {

	? NthPreviousMarquerPosition(1, :StartingAt = 50)		# --> 44
	? @@S( PreviousMarquerAndItsPosition(:StartingAt = 50) )	# --> [ "#3", 44 ]

}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
	? @@S( MarquersSections() ) + NL
	# --> [ [ 12, 13 ], [ 26, 27 ], [ 44, 45 ], [ 66, 67 ] ]

	? @@S( MarquersAndSections() ) + NL
	# --> [ [ "#1", [ 12, 13 ] ], [ "#2", [ 26, 27 ] ], [ "#3", [ 44, 45 ] ], [ "#1", [ 66, 67 ] ] ]

	? @@S( MarquersAndSectionsXT() )
	# --> [ [ "#1", [ [ 12, 13 ], [ 66, 67 ] ] ], [ "#2", [ [ 26, 27 ] ] ], [ "#3", [ [ 44, 45 ] ] ] ]
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSortedInAscending() # --> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInAscending() # --> FALSE
}

/*---------------------- 

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSortedIndescending() # --> TRUE
}

StzStringQ("My name is #2, my age is #1, and my job is #3.") {	
	? MarquersAreSortedInDescending() # --> FALSE
}

/*---------------------- 

StzStringQ("My name is #1, my age is #2, and my job is #3.") {	
	? MarquersAreSorted()		# --> TRUE
	? MarquersSortingOrder() 	# --> :Ascending
}

/*---------------------- 

StzStringQ("My name is #3, my age is #2, and my job is #1.") {	
	? MarquersAreSorted()		# --> TRUE
	? MarquersSortingOrder() 	# --> :Descending
}

/*---------------------- 

StzStringQ("My name is #1, my age is #3, and my job is #2.") {	

	? MarquersAreUnsorted()		# --> TRUE
	? MarquersSortingOrder()	# --> :Unsorted

}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {	
	? NumberOfMarquers()	# --> 3
	? MarquersPositions()	# --> [ 24, 42, 65 ]
	
	? FindNextNthMarquer(2, :startingat = 14) # --> 42
	
	? MarquersPositionsSortedInAscending() # --> [ 24, 42, 65 ]
}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	? Marquers() # --> [ "#3", "#1", "#2" ]

	? MarquersAndPositionsSortedInAscending()
	# --> [ [ "#1", 24 ], [ "#2", 42 ], [ "#3", 65 ] ]

	? MarquersAndSectionsSortedInAscending()
	# --> [ "#1" = [24, 25], "#2" = [42, 43], "#3" = [65, 66] ]
}

/*---------------------- 

o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
? @@S( o1.MarquersAndSectionsSortedInDescending() )
# --> [ [ "#3", [ 12, 13 ] ], [ "#2", [ 27, 28 ] ], [ "#1", [ 45, 46 ] ] ]

/*---------------------- 

StzStringQ("My name is #1, my age is #3, and my job is #2. Again: my name is #1!") {	

	? @@S( MarquersAndPositionsSortedInAscending() )
	#--> [ [ "#1", 12 ], [ "#1", 26 ], [ "#2", 44 ], [ "#3", 66 ] ]

	? @@S( MarquersAndSectionsSortedInAscending() )
	#--> [ [ "#1", [ 12, 13 ] ], [ "#1", [ 26, 27 ] ], [ "#2", [ 44, 45 ] ], [ "#3", [ 66, 67 ] ] ]
}

/* ----------------------

StzStringQ("The first candidate is #3, the second is #1, while the third is #2!") {

	SortMarquersInAscending()
	? Content() + NL
	# --> The first candidate is #1, the second is #2, while the third is #3!

	SortMarquersInDescending()
	? Content()
	# --> The first candidate is #3, the second is #2, while the third is #1!
}

/*----------------------

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.ReplaceSubstringsWithMarquersCS( [ "Ring", "Python", "Ruby", "PHP" ], :CS = TRUE )
? o1.Content()
# --> "#1 can be compared to #2, #3 and #4."

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.ReplaceSubstringsWithMarquersCS( [ "ring", "python", "ruby", "PHP" ], :CS = FALSE )
? o1.Content()
# --> "#1 can be compared to #2, #3 and #4."

/*----------------------

tartProfiler()

	aMyChildren = [ "Teeba", "Haneen", "Hussein" ]
	
	o1 = new stzString("My two children are #1, #2 and #3!")
	
	o1.ReplaceMarquers(:with = aMyChildren)
	? o1.Content() + NL
	#--> My two children are Teeba, Haneen and Hussein!
	
	o1.ReplaceSubStringsWithMarquers(aMyChildren)
	? o1.Content() + NL
	#--> My two children are #1, #2 and #3!
	
	o1.SortMarquersInDescending()
	? o1.Content() + NL
	#--> My two children are #3, #2 and #1!
	
	o1.ReplaceMarquers(:With = aMyChildren)
	? o1.Content()
	#--> My two children are Hussein, Haneen and Teeba!

StopProfiler()

/*=====================

o1 = new stzString("BCAADDEFAGTILNXV")

? o1.SortedInAscending()	# --> AAABCDDEFGILNTVX
? o1.IsSortedInAscending()	# --> FALSE

? o1.SortedInDescending()	# --> XVTNLIGFEDDCBAAA
? o1.IsSortedInDescending()	# --> FALSE

? o1.SortingOrder()		# --> :Unsorted

/*----------------------

o1 = new stzString("BCAADDEFAGTILNXV")
? o1.SortingOrder()	# --> :Unsorted

? o1.SortedInAscending() 	# --> AAABCDDEFGILNTVX
? o1.SortedInDescending()	# --> XVTNLIGFEDDCBAAA

? Q("AAABCDDEFGILNTVX").IsSorted()	# --> TRUE
? Q("AAABCDDEFGILNTVX").SortingOrder()	# --> :Ascending

? Q("XVTNLIGFEDDCBAAA").IsSorted()	# --> TRUE
? Q("XVTNLIGFEDDCBAAA").SortingOrder()	# --> :Descending

/*=======================

o1 = new stzString("My name is Mansour. What's your name please?")
? @@S( o1.FindManyCS( [ "name", "your", "please" ], :CS = TRUE ) )
# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

? @@S( o1.FindMany( [ "name", "your", "please" ] ) )
# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

? @@S( o1.FindManyXTCS( [ "name", "your", "please" ], :CS = TRUE ) )
# --> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

o1 = new stzString("My name is Mansour. What's your name please?")
? @@S(o1.FindManyXT( [ "name", "nothing", "please" ] ))
#--> [ [ "name", [ 4, 33 ] ], [ "nothing", [ ] ], [ "please", [ 38 ] ] ]

/*====================

# The "A":"E" syntax is a beautiful feature of Ring:

? "A" : "E"	# --> [ "A", "B", "C", "D", "E" ]

# And it works backward also like this:

? "E" : "A"	# --> [ "E", "D", "C", "B", "A" ]

# Softanza reproduces it using UpTo() and DownTo() functions:

? Q("A").UpTo("E")	# --> [ "A", "B", "C", "D", "E" ]
? Q("E").DownTo("A")	# --> [ "E", "D", "C", "B", "A" ]

# And extends it to cover any Unicode char not only ASCII chars
# as it is the case for the Ring syntax:

? Q("ب").UpTo("ج") 	# --> [ "ب", "ة", "ت", "ث", "ج" ]
? Q("ج").DownTo("ب")	# --> [ "ج", "ث", "ت", "ة", "ب" ]

/*----------------------

o1 = new stzString("I Work For Afterward")
? o1.RemoveCharQ(" ").Content() # --> IWorkForAfterward

# Or you can say it more naturally:
? Q("I Work For Afterward").CharRemoved(" ")
# Or even more expressively:
? Q("I Work For Afterward").WithoutSpaces()
# Or if you prefer:
? Q("I Work For Afterward").SpacesRemoved()

/*======================

? StzStringQ("9876543210").Reversed()	# --> 0123456789

/*----------------------

StzStringQ("73964532041") {
	? SortedInAscending()	# --> 01233445679
	? SortedInDescending()	# --> 97654433210
}

/*----------------------

? StzStringQ("01233445679").IsSortedInAscending()	# --> TRUE
? StzStringQ("01233445679").IsSortedInDescending()	# --> FALSE

/*======================

? StzStringQ("Arc").IsAnagramOfCS("car", :CS = FALSE)	#--> TRUE

/*=====================

o1 = new stzString("KALIDIA")
o1.InsertBeforeW( '{ @char = "I" }', "*" )
? o1.Content() # --> KAL*ID*IA

/*----------------------

o1 = new stzString("KALIDIA")
o1.InsertAfterW( '{ @char = "I" }', "*" )
? o1.Content() # --> KALI*DI*A

/*----------------------

StzStringQ("12500;NAME;10;0") {
	? NextOccurrence( :Of = ";", :StartingAt = 1 ) 		# --> 6
	? NextNthOccurrence( 2, :Of = ";", :StartingAt = 5) 	# --> 11
}

/*=======================

# One of the design goals of Softanza is to be as consitent as possible
# in managing Strings and Lists. In other terms, What works for one,
# should work for the other, preserving the same semantics.

# To show this, the following code that plays with leading and trailing
# chars in a string...

StzStringQ( "***Ring++" ) {

	? HasLeadingChars() # --> TRUE
	? NumberOfLeadingChars() # 3
	? @@( LeadingChars() ) # --> "***"
	
	? HasTrailingChars() # --> TRUE
	? NumberOfTrailingChars() # 2
	? @@( TrailingChars() ) # --> "++"

	ReplaceLeadingChars(:With = "+")
	? Content() # --> "+++Ring++"
	
	ReplaceLeadingAndTrailingChars(:With = "*")
	? Content() # --> "***Ring**"
}

# works quiet the same with leading and trailing items items of this list:

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems() # --> TRUE
	? NumberOfLeadingItems() # 3
	? @@S( LeadingItems() ) # --> [ "*", "*", "*" ]
	
	? HasTrailingItems() # --> TRUE
	? NumberOfTrailingItems() # 2
	? @@S( TrailingItems() ) # --> [ "+", "+" ]

	ReplaceLeadingItems(:With = "+")
	? @@S( Content() ) # --> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItems(:With = "*")
	? @@S( Content() ) # --> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

# Note that, as far as strings are concerned, this feature is sensitive to case,
# so we can say:

StzStringQ("eeEEeeTUNISeeEE") {

	? NumberOfLeadingCharsCS(:CaseSensitive = FALSE)	#--> 6
	? LeadingCharsCS(:CaseSensitive = FALSE)		#--> eeEEee

	? NumberOfLeadingCharsCS(:CaseSensitive = TRUE)		#--> 2
	? LeadingCharsCS(:CaseSensitive = TRUE)			#--> ee

	? LeadingCharIsCS("E", :CaseSensitive = FALSE)	+ NL	#--> TRUE

	#--

	? NumberOfTrailingCharsCS(:CaseSensitive = FALSE)	#--> 4
	? TrailingCharsCS(:CaseSensitive = FALSE)		#--> EEee

	? NumberOfTrailingCharsCS(:CaseSensitive = TRUE)	#--> 2
	? TrailingCharsCS(:CaseSensitive = TRUE)		#--> EE

	? LeadingCharIsCS("e", :CaseSensitive = FALSE)		#--> TRUE

}

# NOTE: Case sensitivity is supported in Lists with some functions. In the future
# all functions wil be covered.

/*=====================

o1 = new stzString( "----@@--@@-------@@----@@---")
o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
? o1.Content() # --> ----@@--@@-------@@----##---

/*----------------------

o1 = new stzString( "----@@--@@-------@@----@@---")
o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
? o1.Content() # --> ----@@--##-------@@----@@---

/*======================

? Q("DIGIT ZERO").IsCharName()			#--> TRUE
? Q("LATIN CAPITAL LETTER O").IsCharName()	#--> TRUE
? Q("JAVANESE PADA PISELEH").IsCharName()	#--> TRUE

/*----------------------

o1 = new stzString("ar_Arab_TN")
? o1.IsLocaleAbbreviation() #--> TRUE

/*--------------------- TODO: Retest after completing Split and revising stzLocale

# The standard (ISO) form of a locale is <langauge>_<script>_<country> where:
# 	-> <language> is an abbreviation of 2 or 3 lowercase letters
#	-> <script> is an abbreviation of 4 letters, the 1st beeing capitalised
#	-> <country> is an abbreviation of 2 or 3 uppercase letters
#
#	Example: "ar_Arab_TN" is the locale form where:
#	-> "ar" is the abbreviation of arabic language
#	-> "Arab" is the abbreviation of arabic script
#	-> "TN" is the abbreviation the country Tunisia
#
# Usually, locale is provided in <language>_<country> form like this:
#	-> "ar_TN" or "fr_FR" or "en_US" for example
#
# All these forms are supported by Softanza, but not only them!
#
# In fact, both of these stadard forms return TRUE

? StzStringQ("ar_arab_tn").IsLocaleAbbreviation()	# --> TRUE

? StzStringQ("ar_TN").IsLocaleAbbreviation()		# --> TRUE
# (as a side note, Softanza doesn't care of the case, so do not feel any pressure)

# But this one also return TRUE
? StzStringQ("Arab_TN").IsLocaleAbbreviation()		# --> TRUE
# Which corresponds to the non-standard form <script>_<country>.

# And this is accepted by Softanza, because when you use it to create
# a locale object, Softanza inferes the language from the script, and
# constructs the hole standard-formed abbreviation for you:

? StzLocaleQ("Arab_TN").Abbreviation()	# --> "ar_Arab_TN"	TODO: Check it!
# (as a side note, even if you don't respect standard lettercasing,
# Softanza accepts your inputs, and returns an abbreviation that
# is wellformed regarding to the standard!)

# You may think that you would abuse this spirit of flexibility by
# trying to induce Softanza in error by providing sutch an abbreviation
# form <scrip>_<language>:

? StzStringQ("arab_ar").IsLocaleAbbreviation()	#--> FALSE

# The point is that the first abbreviation is a script ("arab" -> arabic),
# and that, conforming to the standard, the second one must be an abbreviation
# of a country ("ar" -> :Argentina). Try this:

? StzCountryQ("ar").Name()	# --> argentina

# And because :Argentina do not have arabic, neigher as a spoken language nor
# a written script, then the returned result is FALSE!

# When you do the same with a country like :Turkey or :Iran, for example,
# where arabic script is (historically) used in writtan turkish and persian
# languages, than the abbreviation is accepted to be well formed

? StzStringQ("arab_tk").IsLocaleAbbreviation()	# !--> TRUE	TODO: Check it!

# And, therefore, you can use it to create locale object:

? StzLocaleQ("arab_tk").Abbreviation()		# --> ar_Arab_TK	TODO: Check it!
? StzLocaleQ("ar_Arab_TK").CountryName()	# !--> :turkey NOT :Egypt

/*=====================

o1 = new stzString("ritekode")

? o1.IsEqualTo("ritekode")			# --> TRUE
? o1.IsEqualToCS("RiteKode", :CS = FALSE)	# --> TRUE
? o1.IsEqualToCS("RiteKode", :CS = TRUE)	# --> FALSE

/*--------------------

? Q("date").IsLowercase() # --> TRUE
? Q("date").IsLowercaseOf("DATE") # --> TRUE

/*--------------------

# Here we take an example of a greek word

? TQ("Σίσυφος").Script()	# --> greek
? Q("Σίσυφος").StringCase()	# --> capitalcase
? Q("ΣΊΣΥΦΟΣ").StringCase()	# --> uppercase
? Q("ΣΊΣΥΦΟΣ").Lowercased()	# --> σίσυφοσ
? Q("σίσυφοσ").Uppercased()	# --> ΣΊΣΥΦΟΣ
? Q("σίσυφοσ").Capitalcased()	# --> Σίσυφοσ

? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = FALSE)	# --> TRUE
? Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = TRUE)	# --> FALSE

/*--------------------

# Let's take this example of a turkish letter ı that should be
# uppercased to İ and not I

? TQ("ı").Script()	# latin (in fact this is a turk letter) (TQ --> stzText object)
? Q("ı").StringCase()	# lowercase
? Q("İ").StringCase()	# uppercase

/*--------------------

# This sample shows a logical error in Qt unicode:

? Q("ı").UppercasedInLocale("tr-TR")	# ERROR: --> I but !--> İ
? Q("İ").Lowercased()	# i
? Q("İ").LowercasedInLocale("tr-TR")	# ERROR: --> i but !--> ı

# In fact, this is a logical bug in Qt as demonstrated here:

oQLocale = new QLocale("tr-TR")
? oQLocale.toupper("ı") # ERROR: --> I but !--> İ

# TODO: solve this by implementing the specialCasing of unicode as
# described in this file:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

/*--------------------

# Do you think "ê" and "ê" are the same?
# If one should trust the visual shape of these two strings, then yes...
# but, the truth, is that they are different.

# In fact, both Ring and Softanza know it:
? "ê" = "ê" 			# --> FALSE
? Q("ê").IsEqualTo("ê")		# --> FALSE

# and that's because ê is just one char:
Q("ê") { ? NumberOfChars() ? Unicode() } # --> 1 char	Unicode: 234

# while ê are two chars:
Q("ê") { ? NumberOfChars() ? Unicode() } # --> 2 chars	Unicodes: 101, 770

# And we can do even better by getting the names of the chars in every string
? Q("ê").CharName() # --> So "ê" contains one char called:
		     #     'LATIN SMALL LETTER E WITH CIRCUMFLEX'

? Q("ê").CharsNames() 	# --> while "ê" contains two chars called:
			#   [ 'LATIN SMALL LETTER E', 'COMBINING CIRCUMFLEX ACCENT' ]

# Combining characters is an advanced aspect of Unicode we are not going to delve
# in now. For more details you can read these FAQs at the following link:
# http://unicode.org/faq/char_combmark.html

/*-------------------- TODO: LOGICAL ERROR IN QT??

# Let's take the example of the german letter ß that
# should be uppercased to SS

? Q("ß").CharCase() # lowercase
? Q("ß").Uppercased() # --> SS

# Which is nice, and we can check it for a hole word
? StzStringQ("der fluß").Uppercased()	# --> DER FLUSS

# Now, if we check the other way around :
? Q("SS").Lowercased() # --> ss


# we don't get "ß", which is expected, because Softanza is running
# at the default locale ("C" locale) and not the german locale.

# Therefore, we need to tune the previous expression by sepecifying
# the german locale ("ge-GE")

? Q("SS").LowercasedInLocale("ge-GE") # !--> ß		LOGICAL ERROR IN QT --> ss

/*--------------------

? StzStringQ("der fluß").Uppercased()	# --> DER FLUSS
? StzStringQ("der fluß").IsLowercase()	# --> TRUE

/*-------------------- LOGICAL ERROR IN QT: Revist after fixing stzLocale

? Q("DER FLUSS").LowercasedInLocale("de-DE")
? Q("der fluß").IsLowercaseOfXT("DER FLUSS", :InLocale = "de-DE") # !--> TRUE

/*--------------------

StzStringQ("in search of lost time") {
	? TitlecasedInLocale("en-US")
	# --> In Search Of Lost Time
	? CapitalisedInLocale("en-US")
	# !--> In Search Of Lost Time
}

StzStringQ("à la recherche du temps perdu") {
	? TitlecasedInLocale("fr-FR")
	# --> À la recherche du temps perdu
	? CapitalisedInLocale("fr-FR")
	# !--> À la Recherche du Temps Perdu
}

/*--------------------

? StzStringQ(:Arabic).IsScript()		#--> TRUE
? StzStringQ(:Arabic).IsScriptName()		#--> TRUE
? StzStringQ(:Arab).IsScriptAbbreviation()	#--> TRUE
? StzStringQ("1").IsScriptCode()		#--> TRUE

/*====================

o1 = new stzString("125.450")
o1.RemoveNthChar(7)
? o1.Content() #--> "125.45"

/*--------------------

o1 = new stzString("125.450")

o1.RemoveW('{ @char = "2" }')
? o1.Content()	# --> "15.450"

/*=====================

? Q("12.45600").ThisTrailingCharRemoved("0")	# --> "12.456"

/*--------------------

o1 = new stzString("000122.12")

? o1.HasLeadingChars()		# --> TRUE
? o1.LeadingChars()		# --> "000"
? o1.LeadingCharsRemoved()	# --> "122.12"

/*--------------------

o1 = new stzString("000122.12")
? o1.LeadingChar() # --> "0"

o1.RemoveThisLeadingChar("0")
? o1.Content()	# --> "122.12"

/*--------------------

o1 = new stzString("22.3450000")

? o1.HasTrailingChars()		# --> TRUE
? o1.TrailingChars()		# --> "0000"
? o1.TrailingCharsRemoved()	# --> "22.345"

/*--------------------

o1 = new stzString("22.3450000")

? o1.TrailingChar()		# --> "0"
? o1.TrailingCharsRemoved()	# --> "22.345"

/*=====================

o1 = new stzString("ABC")
? o1.FirstChar() # --> A
? o1.LastChar()  # --> C

/*--------------------

o1 = new stzString("BATISTA123")
o1.RemoveNLastChars(3)
? o1.Content()	# --> BATISTA

? StzStringQ("BATISTA123").LastNCharsRemoved(3) # --> BATISTA

/*--------------------

o1 = new stzString("BATISTA1")
o1.RemoveLastChar()
? o1.Content()	# --> BATISTA

? StzStringQ("BATISTA1").LastCharRemoved() # --> BATISTA

/*--------------------

o1 = new stzString("123BATISTA")
o1.RemoveNFirstChars(3)
? o1.Content()	# --> BATISTA

? StzStringQ("123BATISTA").FirstNCharsRemoved(3) # --> BATISTA

/*--------------------

o1 = new stzString("1BATISTA")
o1.RemoveFirstChar()
? o1.Content()	# --> BATISTA

? StzStringQ("1BATISTA").FirstCharRemoved() # --> BATISTA

/*--------------------

o1 = new stzString("SOFTANZA IS AWSOME!")
? o1.IsEqualTo("softanza is awsome!")			#--> FALSE
? o1.IsEqualToCS("softanza is awsome!", :CS = FALSE)	#--> TRUE
? o1.IsUppercaseOf("softanza is awsome!")		#--> TRUE

/*================= Quiet-Equality of two strings

o1 = new stzString("SOFTANZA IS AWSOME!")
# TODO: Check performance of IsQuietEqualTo() --> Root cause RemoveDiacritics()
? o1.IsQuietEqualTo("softanza is awsome!")	# --> TRUE
? o1.IsQuietEqualTo("Softansa is aowsome!")	# --> TRUE (we added an "o" to "awsome")
? o1.IsQuietEqualTo("Softansa iis aowsome!")	# --> FALSE (we add "i" to "is" and "o" to "awsome")

/*--------------------

# Quiet-eqality is particularily useful in french where "énoncé" and "ÉNONCÉ" are the same:
o1 = new stzString("énoncé")
? o1.IsEqualTo("enonce")	# --> FALSE
? o1.IsQuietEqualTo("enonce")	# --> TRUE
? o1.IsQuietEqualTo("ÉNONCÉ")	# --> TRUE

/*--------------------

# We can adjust the ratio of QuitEquality by our selves (value between 0 and 1):

o1 = new stzString("mahmoud fayed")
? o1.IsQuietEqualTo("Mahmood al-feiyed")	# --> FALSE
? QuietEqualityRatio()	# --> 0.09 (default value)

# If we need a more permissive quiet-eqality check, then we set it at a weaker value:
SetQuietEqualityRatio(0.35)
? o1.IsQuietEqualTo("Mahmood al-feiyed")	# --> TRUE

/*====================

# Operators on stzString

o1 = new stzString("SOFTANZA")

# Getting a char by position
? o1[5]		# --> "A"

# Finding the occurrences of a substring in the string
? o1["A"]	# --> [ 5, 8 ]
? o1["NZA"]	# --> [ 6 ]

# Getting occurrences of chars verifying a given condition
? o1[ W('{ Q(@char).IsOneOfThese(["A", "T", "Z"]) }') ]	# --> [ 4, 5, 7, 8 ]

# Comparing the string with other strings
? o1 = StringUppercase("softanza")	# --> TRUE

# TODO: Complete the other operators when COMPARAISON methods are made in stzString

/*=================

o1 = new stzString("{{{ Scope of Life }}}")
? o1.BeginsWith("{")
? o1.EndsWith("}")

? o1.IsBoundedBy([ "{", "}" ])		# --> TRUE
? o1.BoundsRemoved([ "{", "}" ]) 	# --> {{ Scope of Life }}

/*--------------------

o1 = new stzString('"name"')
? o1.IsBoundedBy([ '"','"' ])	#--> TRUE

o1 = new stzString(':name')
? o1.IsBoundedBy([ ':', NULL ])	#--> TRUE

/*--------------------

o1 = new stzString("one two three four")
o1.ReplaceAll( "two", "---")
? o1.Content()
#--> "one --- three four"

/*--------------------

o1 = new stzString("one two three four")
o1.ReplaceMany([ "two", "four" ], :By = "---")
? o1.Content()
#--> "one --- three ---"

/*=====================

o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNthOccurrenceCS(3, "Mio", :CS = TRUE)	#--> 16

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 1)  # --> 4
? o1.FindNextNthOccurrence(2, "Mio", :StartingAt = 7)  # --> 16
? o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 20) # --> 22

/*--------------------

#		    1...5...9...3...7...1...5..
o1 = new stzString("---Mio---Mio---Mio---Mio---")
? o1.NextOccurrence("Mio", :StartingAt = 1) 		# --> 4
? o1.NthPreviousOccurrence(2, "Mio", :StartingAt = 15)  # --> 4
? o1.NthPreviousOccurrence(4, "Mio", :StartingAt = 25)  # --> 4

/*=====================

o1 = new stzString("216;TUNISIA;227;NIGER")
? o1.Section(5, o1.NextOccurrence( :Of = ";", :StartingAt = 5 ) - 1 ) #--> TUNISIA

/*====================

o1 = new stzString("amd[bmi]kmc[ddi]kc")
? o1.SubStringsBetween("[","]")
#--> [ "bmi", "ddi" ]

/*-------------------- ERROR: TODO in the future

# SubStringsBetween can't manage DEEP combinations like this

o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
? o1.SubStringsBetween("[","]")

 #!--> "A", "T", [ :hi, [ "deep1", [

/*====================

# In Softanza both n and N chars correspond to the letter "N"
o1 = new stzString("Adoption of the plan B")
? o1.ContainsTheLetters([ "N", "b" ]) # --> TRUE

/*--------------------

o1 = new stzString("opsus amcKLMbmi findus")
? o1.FindBetween("KLM", "amc", "bmi") # --> 10

/*====================

StzStringQ("__b和平س__a__و") {
	? ContainsLettersInScript(:Latin) 		# TRUE
	? CharsW( ' Q(@char).IsLatin() ')		# [ "b", "a" ]

	? ContainsLettersInScript(:Arabic)		# TRUE
	? CharsW( ' Q(@char).IsArabic() ')		# [ "س", "و" ]

	? ContainsLettersInScript(:Han)			# TRUE
	? CharsW( ' StzCharQ(@char).IsHanScript() ')	# [ "和", "平" ]

	? ContainsCharsInScript(:Common)		# TRUE
	? CharsW( ' StzCharQ(@char).IsCommonScript() ')	# [ "_", "_", "_", "_", "_", "_" ]

	# Note that if you say
	? ContainsLettersInScript(:Common)	# or
	? ContainsLettersInScript(:Unkowan)
	# you get FALSE because there is no sutch letter that has a script
	# 'common'. In other terms, any letter in the world has to belong
	# to a knowan script.
}

/*====================

# Case sensisitivity is considered only for latin letters

? StzCharQ("9").IsLowercase() 		# FALSE
? StzCharQ("9").IsUppercase() 		# FALSE

? StzCharQ("ك").IsLowercase() 		# FALSE
? StzCharQ("ك").IsUppercase() 		# FALSE

? StzStringQ("120").IsLowercase() 	# FALSE
? StzStringQ("120m").IsLowercase() 	# TRUE
? StzStringQ("120M").IsUppercase() 	# TRUE

? StzStringQ("كلام").IsLowercase() 	# FALSE

/*====================

? StzStringQ("abcdef").ContainsNoOneOfThese([ "xy", "xyz", "mwb" ]) #--> TRUE

/*====================

? Q("tunis").Lowercased()	# tunis
? Q("tunis").Uppercased()	# TUNIS
? Q("tunis").Titlecased()	# Tunis

//? Q("tunis").Foldcased()	# TODO

/*--------------------

? StzStringQ("tunis").IsLowercased()	# TRUE
? StzStringQ("TUNIS").IsUppercased()	# TRUE
? StzStringQ("Tunis").IsTitlecased()	# TRUE

//? StzStringQ("tunis").IsFoldcased()	# TODO

/*====================

? StringsAreEqualCS([ "abc","abc" ], :CaseSensitive = TRUE )	#--> TRUE
? StringsAreEqual([ "cbad", "cbad", "cbad" ])			#--> TRUE

? BothStringsAreEqualCS("abc", "abc", :CaseSensitive = TRUE)	#--> TRUE
? BothStringsAreEqual("abc", "abc")				#--> TRUE

/*====================

? Q("HUSSEIN").ItemsW('{ Q(@item).isLetter() }')
#--> [ "H","U","S","S","E","I","N" ]

? Q("HUSSEIN").NumberOfItemsW('{ Q(@item).isLetter() }') #--> 7

/*--------------------

? Q("--A--B--").ContainsLetters()	#--> TRUE
? Q("--A--B--").ContainsLetter("A")	#--> TRUE
? Q("--A--B--").ContainsLetter("a")	#--> TRUE
? Q("--A--B--").ContainsLetter("M")	#--> FALSE

? Q("H").IsALetterOf("HUSSEIN") 	#--> TRUE
? Q("h").IsALetterOf("HUSSEIN")		#--> TRUE

/*=====================

? StzStringQ("SOFTANZA").CharsReversed() #--> AZNATFOS

? StzStringQ(" Softanza    Near-natural Programming   ").Simplified()
#--> Softanza Near-natural Programming

/*--------------------

# TQ is an abbreviation of StzTextQ()

? TQ("عربي").Script() # --> arabic
? TQ("ring").Script() # --> latin

/*-------------------

# Used internally bu the library in evaluating conditional code:

? StzStringQ('myfunc()').IsAlmostAFunctionCall()	#--> TRUE
? StzStringQ('my_func("name")').IsAlmostAFunctionCall()	#--> TRUE

/*-------------------

? StzStringQ("G").IsLetter() 	# --> TRUE
? UppercaseOf("b")		# --> B
? LowercaseOf("B")		# --> b
//? FoldcaseOf("sinus")		# !!! Undefined function

/*===================

# Are you confused between chars, bytes, unicodes (or unicode code points), and bytecodes?!
# Here how Softanza can help you see them all in clarity:

StzStringQ("s㊱m") {
	? Chars()
	# --> [ "s", "㊱", "m" ]

	? Unicodes()
	# --> [ 115, 12977, 109 ]

	? UnicodesPerChar()
	# --> [ [ "s", 115 ], [ "㊱", 12977 ], [ "m", 109 ] ]

	? SizeInBytes() # --> 5

	? Bytes()
	# --> [ "s", "�", "�", "�", "m" ]
	? BytesPerChar()
	# --> [ [ "s", [ "s" ] ], [ "㊱", [ "�", "�", "�" ] ], [ "m", [ "m" ] ] ]
	? NumberOfBytesPerChar()
	# -->  [ [ "s", 1 ], [ "㊱", 3 ], [ "m", 1 ] ]

	? Bytecodes()
	# --> [ 115, -29, -118, -79, 109 ]
	? BytecodesPerChar()
	# --> [ [ "s", [ 115 ] ], [ "㊱", [ -29, -118, -79 ] ], [ "m", [ 109 ] ] ]
}

/*===================

? StzStringQ("sAlut").IsLowercase() #--> FALSE

/*===================

? StzStringQ("@char___@char___@char").ReplaceAllQ("@char","@item").Content()
# --> @item___@item___@item

/*------------------

StzStringQ( "Text processing with Ring" ) {
	ReplaceAllCharsW(
		:Where = '{ @char = "i" }',
		:With = "*"	
	)

	? Content()
} # --> "Text process*ng w*th R*ng"

/*-------------------

StzStringQ("1a2b3c") {
	ReplaceAllCharsW(
		:Where = '{ Q(@char).isLowercase() }',
		:With  = "*"
	)

	? Content() #--> 1*2*3*
}

/*------------------- TODO: Fix erro when using :With@
*
StzStringQ("1a2b3c") {
	ReplaceCharsW(
		:Where = '{ StzCharQ(@char).IsLetter() and StzCharQ(@char).isLowercase() }',
		:With@  = '{ StzCharQ(@char).Uppercased() }'
	)

	? Content() #--> 112A32
}

/*====================

? StringInvert("LIFE") 	# --> ƎℲI⅂
? StringInvert("GAYA")	# --> Ɐ⅄Ɐ⅁
? StringInvert("TIBA")	# --> ⱯBIꞱ
? StringInvert("HANEEN") # --> NƎƎNⱯH
? StringInvert("MILLAVOY (Y908$)") # --> ($806⅄) ⅄OɅⱯ⅂⅂IƜ

/*-------------------

? "TIBA -->"
? StzStringQ("TIBA").Inverted()
? ""
? "HANEEN -->"
? StzStringQ("HANEEN").Inverted()
? "LIFE -->"
? StzStringQ("LIFE").Inverted()
? ""
? "GAYA -->"
? StzStringQ("GAYA").Inverted()
? ""
? "TELLAVIX (Y908$) -->"
? StzStringQ("TELLAVIX (Y908$)").Inverted()

/*==================

o1 = new stzString("Ring Programming Language")
? o1.WalkBackwardW( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ) # --> 5
? o1.WalkForewardW( :StartingAt =  6, :UntilBefore = '{ @char = "r" }' ) # --> 9

/*==================

? StzTextQ("abc سلام abc").ContainsScript(:Arabic)	#--> TRUE
? StzTextQ("abc سلام abc").ContainsArabicScript()	#--> TRUE
# NOTE: Scripts are now moved from stzString to stzText

# You can use this short form instead of StzTextQ()
? TQ("سلام").Script() #--> :Arabic

/*==================

? StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content()		#--> év*nement
? StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content()	#--> év*nement

/*==================

StzStringQ("original text before hashing") {
	Hash(:MD5)
	? Content() #--> 8ffad81de2e13a7b68c7858e4d60e263
}

/*==================

? StzStringQ("ring").StringCase() # --> :Lowercase
? StzStringQ("RING").StringCase() # --> :Uppercase
? StzStringQ("RING and python").StringCase() # --> :hybridcase

/*========== STRING PARTS ===========

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@S(o1.PartsAsSubstrings( :Using = 'StzCharQ(@char).CharCase()' )) # or simply o1.Parts('StzCharQ(@char)')
# [
# 	[ "H", "uppercase" ],
# 	[ "anine", "lowercase" ],
# 	[ "o حنين o", NULL ],
# 	[ "is", "lowercase" ],
# 	[ " ", NULL ],
# 	[ "a", "lowercase" ],
# 	[ " ", NULL ],
# 	[ "nice", "lowercase" ],
# 	[ "o جميلة وعمرها 7 o", NULL ],
# 	[ "years", "lowercase" ],
# 	[ "-", NULL ],
# 	[ "old", "lowercase" ],
# 	[ "o سنوات o", NULL ],
# 	[ "girl", "lowercase" ],
# 	[ "!", NULL ]
# ]

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? @@S(o1.PartsAsSections( :Using = 'StzCharQ(@char).CharCase()' ))

#--> [
# 	[ [ 1, 1 ], 	"uppercase" 	],
# 	[ [ 2, 6 ], 	"lowercase" 	],
# 	[ [ 7, 12 ], 	NULL 		],
# 	[ [ 13, 14 ], 	"lowercase"	],
# 	[ [ 15, 15 ], 	NULL 		],
# 	[ [ 16, 16 ], 	"lowercase" 	],
# 	[ [ 17, 17 ], 	NULL		],
# 	[ [ 18, 21 ], 	"lowercase" 	],
# 	[ [ 22, 37 ], 	NULL		],
# 	[ [ 38, 42 ], 	"lowercase" 	],
# 	[ [ 43, 43 ], 	NULL		],
# 	[ [ 44, 46 ], 	"lowercase" 	],
# 	[ [ 47, 53 ], 	NULL 		],
# 	[ [ 54, 57 ], 	"lowercase"  	],
# 	[ [ 58, 58 ], 	NULL 		]
#    ]

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? @@S( o1.PartsAsSubstringsAndSections( :Using = 'StzCharQ(@char).CharCase()' ) )

#-->
# [ 	
# 	[ "H", 				[ 1, 1 ], 	"uppercase" 	],
# 	[ "anine", 			[ 2, 6 ], 	"lowercase" 	],
# 	[ "o حنين o", 			[ 7, 12 ], 	NULL		],
# 	[ "is", 			[ 13, 14 ], 	"lowercase" 	],
# 	[ " ", 				[ 15, 15 ], 	NULL		],
# 	[ "a", 				[ 16, 16 ], 	"lowercase" 	],
# 	[ " ", 				[ 17, 17 ], 	NULL		],
# 	[ "nice", 			[ 18, 21 ], 	"lowercase" 	],
# 	[ "o جميلة وعمرها 7 o", 	[ 22, 37 ], 	NULL		],
# 	[ "years", 			[ 38, 42 ], 	"lowercase" 	],
# 	[ "-", 				[ 43, 43 ], 	NULL		],
# 	[ "old", 			[ 44, 46 ], 	"lowercase" 	],
# 	[ "o سنوات o", 			[ 47, 53 ], 	NULL		],
# 	[ "girl", 			[ 54, 57 ], 	"lowercase" 	],
# 	[ "!", 				[ 58, 58 ], 	NULL		]
# ]

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? @@S( o1.PartsAsSectionsAndSubstrings( :Using = 'StzCharQ(@char).CharCase()' ) )

#-->
# [ 	
# 	[ [ 1, 1 ],	"H", 			"uppercase" 	],
# 	[ [ 2, 6 ],	"anine", 		"lowercase" 	],
# 	[ [ 7, 12 ],	"o حنين o", 		NULL		],
# 	[ [ 13, 14 ],	"is", 			"lowercase" 	],
# 	[ [ 15, 15 ],	" ", 			NULL		],
# 	[ [ 16, 16 ],	"a", 			"lowercase" 	],
# 	[ [ 17, 17 ],	" ", 			NULL		],
# 	[ [ 18, 21 ],	"nice", 		"lowercase" 	],
# 	[ [ 22, 37 ],	"o جميلة وعمرها 7 o", 	 NULL		],
# 	[ [ 38, 42 ],	"years", 		"lowercase" 	],
# 	[ [ 43, 43 ],	"-", 			NULL		],
# 	[ [ 44, 46 ],	"old", 			"lowercase" 	],
# 	[ [ 47, 53 ],	"o سنوات o", 		NULL		],
# 	[ [ 54, 57 ],	"girl", 		"lowercase" 	],
# 	[ [ 58, 58 ],	"!", 			NULL		]
# ]

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? @@S( o1.PartsClassified( :Using = 'StzCharQ(@char).Script()' ) )

# --> [
#	:latin	 	= [ "Hanine", "is", "a", "nice", "years", "old", "girl" ],
#	:common		= [ " ", " 7 ", "-", "!" ],
#	:arabic		= [ "حنين", "جميلة", "وعمرها", "سنوات" ],
#     ]

# Alternatives ti PartsClassified(): Classify() and Classified()

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@S( o1.Parts('{ StzCharQ(@char).Script() }') )

#--> [
#	[ "Hanine", "latin" 	],
#	[ " ", "common" 	],
#o 	[ "حنين", "arabic" 	],
#	[ " ", "common" 	],
#	[ "is", "latin" 	],
#	[ " ", "common" 	],
#	[ "a", "latin"	 	],
#	[ " ", "common" 	],
#	[ "nice", "latin" 	],
#	[ " ", "common" 	],
#o	[ "جميلة", "arabic" 	],
#	[ " ", "common" 	],
#o	[ "وعمرها", "arabic" 	],
#	[ " 7 ", "common" 	],
#	[ "years", "latin" 	],
#	[ "-", "common" 	],
#	[ "old", "latin" 	],
#	[ " ", "common" 	],
#o	[ "جميلة", "arabic" 	],
#	[ " ", "common" 	],
#	[ "girl", "latin" 	],
#	[ "!", "common" 	]
#    ]

/*-----------------

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")
? o1.UniquePartsQ('StzCharQ(@char).Script()').ToStzHashList().Classify()
# --> [
#	:latin	 	= [ "Hanine", "is", "a", "nice", "years", "old", "girl" ],
#	:common		= [ " ", " 7 ", "-", "!" ],
#	:arabic		= [ "حنين", "جميلة", "وعمرها", "سنوات" ],
#     ]

? o1.UniquePartsQ('StzCharQ(@char).Script()').ToStzHashList().Klass(:arabic)
#--> Gives [ "حنين", "جميلة", "وعمرها", "سنوات" ]

/*-----------------

o1 = new stzString("AM23-X ")
? o1.Parts('StzCharQ(@char).CharType()')
# --> [
#	"AM" = :Letter_Uppercase,
#	"23" = :Number_Decimaldigit,
#	"-"  = :Punctuation_Dash",
#	"X"  = :Letter_Uppercase,
#	" "  = :Separator_Space
#    ]

/*-----------------

o1 = new stzString("Abc285XY&من")
? o1.Parts('{
	StzCharQ(@char).CharType()
}')

#--> [
#	"A"	= :Letter_Uppercase,
#	"bc"	= :Lerrer_Lowercase,
#	"285"	= :Number_DecimalDigit,
#	"XY"	= :Letter_Uppercase,
#	"&"	= :Punctauation_Other,
#o	"من"	= :Letter_Other
#    ]

/*-----------------

o1 = new stzString("maliNIGERtogoSENEGAL")
? o1.Parts(:Using = '{ StzCharQ(@char).CharCase() }')
#--> [ 	
#	"mali" 		= :Lowercase,
# 	"NIGER" 	= :Uppercase,
#	"togo" 		= :Lowercase,
#	"SENEGAL" 	= :Uppercase
#    ]

? o1.PartsAsSections(:Using = '{ StzCharQ(@char).CharCase() }')
#--> [ 	
#	[1, 4  ] = :Lowercase,
# 	[5, 9  ] = :Uppercase,
#	[10, 13] = :Lowercase,
#	[14, 20] = :Uppercase
#    ]

/*-----------------

o1 = new stzString("Abc285XY&من")
? o1.Parts( :Using = 'StzCharQ(@char).IsLetter()' )
# --> Gives:
# [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

? o1.Parts(:Using = "StzCharQ(@char).Orientation()")
# --> Gives:
# [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? o1.Parts(:Using = "StzCharQ(@char).IsUppercase()")
# --> Gives:
# [ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

? o1.Parts(:Using = "StzCharQ(@char).CharCase()")
# --> Gives:
# [ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

/*========================

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceAllChars( :With = "*" )
? o1.Content()
#--> *******************************

/*================

o1 = new stzString("Use these two letters: س and ص.")
? o1.FindCharsW(
	:Where = '{
		StzCharQ(@char).IsLetter() AND
		NOT StzCharQ(@Char).IsLatinLetter()
	}'
)
#--> [ 24, 30 ]

? o1.CharsW(
	:Where = '{
		StzCharQ(@char).IsLetter() AND
		NOT StzCharQ(@Char).IsLatinLetter()
	}'
)
#--> Gives [ "س", "ص" ]

/*================

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceCharsW(

	:Where = '{
		StzCharQ(@char).IsLetter() AND
		(NOT StzCharQ(@Char).IsLatinLetter())
	}',

	:With = '***'
)

? o1.Content()
#--> "Use these two letters: *** and ***."

/*================

? StzCharQ(":").IsPunctuation()	#--> TRUE
? StzCharQ(":").CharType() 	#--> punctuation_other

/*================

o1 = new stzString("Use these two letters: س , ص.")

o1.RemoveCharsWhereQ('{

	StzCharQ(@Char).IsArabicLetter() or
	StzCharQ(@char).IsPunctuation()

}')

? o1.Content() #--> "Use these two letters"

/*---------------

o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceCharsWhere(
	:Where = '{ @char != " " and StzCharQ(@Char).IsArabicLetter() }',
	:With = "*"
)

? o1.Content() #--> "Use these two letters: * and *."

/*===============

? StzCharQ("س").Name() #--> ARABIC LETTER SEEN
? StzCharQ("ص").Name() #--> ARABIC LETTER SAD

/*--------------- TODO: Fix Error when using :With@

o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceCharsW(
	:Where = '{ @char != " " and StzCharQ(@Char).IsArabicLetter() }',
	:With@ = 'StzCharQ(@char).Name()'
)

? o1.Content()
#--> "Use these two letters: LATIN CAPITAL LETTER U and LATIN SMALL LETTER S."

/*==============

o1 = new stzString("SoftAnza Libraray")
? o1.CountCharsWhere('{ @Char = "a" }') #--> 3
? o1.CountCharsWhere('{	Q(@Char).IsEqualToCS("a", :CS = FALSE) }') #--> 4

/*--------------

o1 = new stzString("SoftAnza Libraray")
? o1.FindCharsWhere('{ StzCharQ(@Char).Lowercased() = "a" }')
# --> Gives [ 5, 8, 14, 16 ]

/*---------------

o1 = new stzString("abc;123;gafsa;ykj")
? o1.SplitQ(";").NthItem(3)
#--> gafsa

# Same as:
? o1.NthSubstringAfterSplittingStringUsing(3, ";") #--> gafsa
#--> To be used in natural coding.

/*===================

? StzStringQ("SOFTANZA IS AWSOME!").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
	:TextAdjustedTo = :Center # or :Left or :Right or :Justified
])

#--> ╭─────────────────────┐
#    │ SOFTANZA IS AWSOME! │
#    └─────────────────────╯

/*------------------

StzStringQ("RING") {
	? Content()
	? Boxed()
	? BoxedRound()
	? BoxedRoundDashed()

	? EachCharBoxed()
	# ? VizFindBoxed("I")	#--> TODO: Add VizFindBoxed()
}

#--> RING
#   ┌──────┐
#   │ RING │
#   └──────┘
#   ╭──────╮
#   │ RING │
#   ╰──────╯
#   ╭╌╌╌╌╌╌╮
#   ┊ RING ┊
#   ╰╌╌╌╌╌╌╯
#   ┌───┬───┬───┬───┐
#   │ R │ I │ N │ G │
#   └───┴───┴───┴───┘
#   ┌───┬───┬───┬───┐
#   │ R │ I │ N │ G │
#   └───┴─•─┴───┴───┘

/*------------------

StzStringQ("MY BEAUTIFUL RING") {
	? Content()
	? Boxed()
	? BoxedRound()

	//? BoxedEachChar()		# TODO: Add it
	// ? BoxedEachCharRound()	# TODO: Add it

	// ? VizFindBoxed("I")	# TODO: Add it

	? BoxedDashed()
	? BoxedDashedRound()

	? BoxedXT([
		:Line = :Thin,
		:Corners = [
			:Round, :Rectangular,
			:Round, :Rectangular
		]
	])
}

#--> MY BEAUTIFUL RING
#   ┌───────────────────┐
#   │ MY BEAUTIFUL RING │
#   └───────────────────┘
#   ╭───────────────────╮
#   │ MY BEAUTIFUL RING │
#   ╰───────────────────╯
#   ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
#   │ M │ Y │   │ B │ E │ A │ U │ T │ I │ F │ U │ L │   │ R │ I │ N │ G │
#   └───┴───┴───┴───┴───┴───┴───┴───┴─•─┴───┴───┴───┴───┴───┴─•─┴───┴───┘
#   ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
#   ┊ MY BEAUTIFUL RING ┊
#   └╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
#   ╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
#   ┊ MY BEAUTIFUL RING ┊
#   ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯
#   ╭───────────────────┐
#   │ MY BEAUTIFUL RING │
#   └───────────────────╯

/*-----------------

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Center
])
#-->
# ╭────────────────────╮
# │ PARIS              │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Left
])
#-->
# ╭────────────────────╮
# │       PARIS        │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Right
])
#-->
# ╭────────────────────╮
# │ P    A   R   I   S │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Justified
])
#-->
# ╭────────────────────╮
# │              PARIS │
# ╰────────────────────╯

/*---------------------

# You can box the entire string like this:
? StzStringQ("SOFTANZA").BoxedXT([])
#-->
# ┌──────────┐
# │ SOFTANZA │
# └──────────┘

# Or box it char by char like this:

? StzStringQ("SOFTANZA").BoxedXT([ :EachChar = TRUE ])

# -->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

/*--------------------- TODO

# Boxing work great for latin chars, but for non latin chars,
# it would break:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:TextAdjustedTo = :Center
])
#-->
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌┘

# That is because chars in non-latin script won't have necessarily
# same width. In fact, this is related to the font used to render
# the chars on the screen. Hence, if you use a fixed-width font,
# the boxing will work correclty (TODO: check this!).

# As a configuration option that helps in solving this issue (without
# switching ta a fixed-width font, Softanza provide the width option
# that you can adjust manually and get a nice result like this:

? StzStringQ("乇乂丅尺卂 丅卄工匚匚").BoxedXT([
	:Line = :Dashed,
	:AllCorners = :Rectangular,

	:Width = 15,
	:TextAdjustedTo = :Center
])
#--> TODO: Fix the output to return this
# ┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
# ┊ 乇乂丅尺卂 丅卄工匚匚 ┊
# └╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘


/*==================

? StzStringQ("ar_TN-tun").ContainsEachCS(["_", "-"],:CS = TRUE)	#--> TRUE
? StzStringQ("ar_TN-tun").ContainsBoth("_", "-") #--> TRUE

/*==================

o1 = new stzString("a")
o1.MultiplyBy([ "b", "c", "d" ])
? o1.Content() #--> "abacad"

/*--------------

o1 = new stzString("a")
o1 * [ "b", "c", "d" ]
? o1.Content() #--> abacad

/*---------------

o1 = new stzString("abcdefj")
? o1 / 2	#--> [ "abcd", "efj" ]
? o1 % 2	#--> "efj"

/*--------------

o1 = new stzString("ab-ac-ad")
? o1 / "-" # Same as ? o1.Split("-")
#--> [ "ab", "ac", "ad" ]

/*==================

o1 = new stzString("happy-holidays")
? o1.IsLowercase() #--> TRUE

o1 = new stzString("HOLIDAYS!")
? o1.IsUppercase() #--> TRUE

/*==================

StzStringQ("What a tutorial! Very instructive tutorial.") {

	? FindAll("tutorial") #--> [ 8, 35 ]
	? NumberOfOccurrence("tutorial") + NL	#--> 2

	? FindNextOccurrence("tutorial", :StartingAt = 20) + NL     #--> 35
	? FindPreviousOccurrence("tutorial", :StartingAt = 20) + NL #--> 8

	? NumberOfChars() + NL #--> 43
	 
	? @@S( SplitToPartsOfNChars(12) ) + NL
	#--> [
	# 	"What a tutor",
	# 	"ial! Very in",
	# 	"structive tu",
	# 	"torial."
	#    ]

	? @@S( SplitBeforePositions([ 17, 34 ]) ) + NL
	#--> [
	# 	"What a tutorial!",
	# 	" Very instructive",
	# 	" tutorial."
	#    ]

	? @@S( SplitBeforeW(' @char = "a" ') ) + NL
	# --> [
	# 	"Wh", "at ", "a tutori",
	# 	"al! Very instructive tutori", "al."
	#     ]

}

/*===================

str = "قَالُوا ادْعُ لَنَا رَبَّكَ يُبَيِّن لَّنَا مَا هِيَ إِنَّ الْبَقَرَ 
تَشَابَهَ عَلَيْنَا وَإِنَّا إِن شَاءَ اللَّهُ لَمُهْتَدُونَ (70)
 قَالَ إِنَّهُ يَقُولُ إِنَّهَا بَقَرَةٌ لَّا ذَلُولٌ تُثِيرُ الْأَرْضَ وَلَا
 تَسْقِي الْحَرْثَ مُسَلَّمَةٌ لَّا شِيَةَ فِيهَا ۚ قَالُوا الْآنَ 
جِئْتَ بِالْحَقِّ ۚ فَذَبَحُوهَا وَمَا كَادُوا يَفْعَلُونَ (71)
 وَإِذْ قَتَلْتُمْ نَفْسًا فَادَّارَأْتُمْ فِيهَا ۖ وَاللَّهُ مُخْرِجٌ مَّا كُنتُمْ تَكْتُمُونَ (72)
 فَقُلْنَا اضْرِبُوهُ بِبَعْضِهَا ۚ كَذَٰلِكَ يُحْيِي اللَّهُ 
الْمَوْتَىٰ وَيُرِيكُمْ آيَاتِهِ لَعَلَّكُمْ تَعْقِلُونَ (73)
 ثُمَّ قَسَتْ قُلُوبُكُم مِّن بَعْدِ ذَٰلِكَ فَهِيَ كَالْحِجَارَةِ أَوْ أَشَدُّ قَسْوَةً 
ۚ وَإِنَّ مِنَ الْحِجَارَةِ لَمَا يَتَفَجَّرُ مِنْهُ الْأَنْهَارُ ۚ 
وَإِنَّ مِنْهَا لَمَا يَشَّقَّقُ فَيَخْرُجُ مِنْهُ الْمَاءُ 
ۚ وَإِنَّ مِنْهَا لَمَا يَهْبِطُ مِنْ خَشْيَةِ اللَّهِ ۗ وَمَا اللَّهُ بِغَافِلٍ
 عَمَّا تَعْمَلُونَ (74) ۞ أَفَتَطْمَعُونَ أَن يُؤْمِنُوا لَكُمْ
 وَقَدْ كَانَ فَرِيقٌ مِّنْهُمْ يَسْمَعُونَ كَلَامَ اللَّهِ ثُمَّ يُحَرِّفُونَهُ
 مِن بَعْدِ مَا عَقَلُوهُ وَهُمْ يَعْلَمُونَ (75)
 وَإِذَا لَقُوا الَّذِينَ آمَنُوا قَالُوا آمَنَّا
 وَإِذَا خَلَا بَعْضُهُمْ إِلَىٰ بَعْضٍ قَالُوا أَتُحَدِّثُونَهُم
 بِمَا فَتَحَ اللَّهُ عَلَيْكُمْ لِيُحَاجُّوكُم بِهِ عِندَ رَبِّكُمْ ۚ أَفَلَا تَعْقِلُونَ  (76)  
"

o1 = new stzString(str)
? o1.UniqueChars()
? o1.Split(:Using = "۞")

/*-------------------

o1 = new stzString(" same   ")
o1 {
	TrimLeft()
	? @@( Content() ) #--> "same   "
}

# Try also: TrimRight(), TrimStart(), TrimEnd()
# RemoveLeadingSpaces(), and RemoveTrailingSpaces

/*==================

str = "   سلام"
o1 = new stzString(str)

? o1.HasRepeatedLeadingChars()		#--> TRUE
? @@( o1.RepeatedLeadingChar() )	#--> " "
o1.TrimRight() ? o1.Content()		#--> سلام

/*------------------

o1 = new stzString("eeeTUNIS")	
? o1.RepeatedLeadingChar() #--> 'e'
? o1.RepeatedLeadingChars() #--> 'eee'

/*------------------

o1 = new stzString("exeeeeeTUNIS") # 	
? @@( o1.RepeatedLeadingChar() )	#--> ""
? @@( o1.RepeatedLeadingChars() )	#--> ""

/*----------------

o1 = new stzString("eeeeTUNISIAiiiii")

o1 {
	? HasRepeatedLeadingChars()			#--> TRUE
	? NumberOfRepeatedLeadingChars()		#--> 4
	? RepeatedLeadingchars()			#--> eeee
	? RepeatedLeadingCharsQ().Content() + NL	#--> eeee
	
	? HasRepeatedTrailingChars()			#--> TRUE
	? NumberOfRepeatedTrailingChars()		#--> 5
	? RepeatedTrailingChars()			#--> iiiii
	? RepeatedTrailingCharsQ().Content()		#--> iiiii	
}

/*-----------------

o1 = new stzString("eeebxeTuniseee")
o1 {

	RemoveNLeftChars(3)
	RemoveNRightChars(3)

	# or alternatively:
	# RemoveFirstNChars(3)
	# RemoveLastNChars(3)

	? Content()	#--> bxeTunis
	
}

/*----------------

o1 = new stzString("eeeTuniseee")
o1 {
	RemoveRepeatedLeadingChars()
	RemoveRepeatedTrailingChars()
	
	? Content() #--> Tunis
}


o1 = new stzString("eeeTuniseee")
o1 {
	RemoveLeadingAndTrailingChars()
	? Content() # --> Tunis
}

/*-----------------

o1 = new stzString("eeebxeTuniseee")

? o1.Section(:FirstChar, :LastChar) #--> eeebxeTuniseee
? o1.Section( 7, 4 ) #--> Texb

/*-----------------

o1 = new stzString("___VAR---")
o1.ReplaceLeadingChars(:With = "*")
? o1.Content() #--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChars(:With = "*")
? o1.Content() #--> ___VAR*

o1 = new stzString("___VAR---")
o1.ReplaceLeadingAndTrailingChars(:With = "*")
? o1.Content() #--> *VAR*

/*-----------------

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingChar(:With = "*")
? o1.Content() #--> ***VAR---

o1 = new stzString("___VAR---")
o1.ReplaceEachTrailingChar(:With = "*")
? o1.Content() #--> ___VAR***

o1 = new stzString("___VAR---")
o1.ReplaceEachLeadingAndTrailingChar(:With = "*")
? o1.Content() #--> ***VAR***

/*-----------------

o1 = new stzString("___VAR---")
o1.ReplaceLeadingChar("_", :With = "*")
? o1.Content()
#--> *VAR---

o1 = new stzString("___VAR---")
o1.ReplaceTrailingChar("-", :With = "*")
? o1.Content()
#--> ___VAR*

/*----------------- TODO (future)

StzStringQ("eeebxeTuniseee") {
	RemoveRepeatedLeadingCharsW('{
		cChar = "e"
	}')

	RemoveRepeatedLeadingCharsW('{ oChar.IsSpecialChar() }')
	RemoveRepeatedLeadingCharsW('{ oChar.IsPunctuation() }')

	RemoveRepeatedLeadingCharsW('{ nNumberOfLeadingChars = 5 }')
	RemoveRepeatedLeadingCharsW('{ cLeadingSubstring = "<<<" }')
	RemoveRepeatedLeadingCharsW('{ oLeadingSubstring.IsANumber() }')
	
	? Content()
}

/*----------------

o1 = new stzString("bbxeTuniseee")
? o1.RepeatedLeadingChars() #--> bb
? o1.HasRepeatedLeadingChars() #--> TRUE

/*-----------------

o1 = new stzString("aaaaah Tunisia!---")
o1 {
	ReplaceEachLeadingChar(:With = "O")
	? Content()
	#--> OOOOOh Tunisia!---

	ReplaceEachTrailingChar(:With = "")
	? Content()
	#--> OOOOOh Tunisia!
}

/*-----------------

o1 = new stzString("---Ring!")
o1.ReplaceFirstNChars(3, :With = "Hi ")
? o1.Content()
#--> Hi Ring!

o1 = new stzString("Hi Ring---")
o1.ReplaceLastNChars(3, :With= "!")
? o1.Content()
#--> Hi Ring!

/*-----------------

o1 = new stzString("oooo Tunisia---")
o1 {
	ReplaceLeadingChar("o", :With = "Hi")
	? Content()
	#--> Hi Tunisia---

	ReplaceTrailingChar("-", :With = "!")
	? Content()
	#--> Hi Tunisia!
}

/*-----------------

o1 = new stzString("aaaaah Tunisia---")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oh Tunisia---

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Oh Tunisia!

/*-----------------

o1 = new stzString("Oooooh TunisiammMmmM")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oooooh TunisiammmmM

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Aaaaah TunisiammmmM

o1 = new stzString("Oooooh TunisiammMmmM")
o1.ReplaceLeadingCharsCS(:With = "O", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh TunisiammmmM

o1.ReplaceTrailingCharsCS(:With = "!", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh Tunisia!

/*-----------------

o1 = new stzString("Oooo Tunisia---")
? o1.LeadingChar() 		#--> ""
? o1.LeadingCharCS(:CS = FALSE)	#--> "O"

? o1.LeadingChars()		#--> ""
? o1.LeadingCharsCS(:CS=FALSE) #--> "Oooo"

/*-----------------

o1 = new stzString("oooTunisia")
o1.RemoveLeadingChar("O")
? o1.Content()
#--> oooTunisia

o1.RemoveLeadingCharCS("O", :CS=FALSE)
? o1.Content()
#--> Tunisia

/*-----------------

o1 = new stzString("oooTunisia")
o1.ReplaceLeadingChar("O", :With = "")
? o1.Content()
#--> oooTunisia

o1.ReplaceLeadingCharCS("O", :With = "", :CS=FALSE)
? o1.Content()
#--> Tunisia

/*==================

? (StzStringQ("ORingoriaLand") - [ "O", "oria", "Land" ]).Content()
# --> Ring

/*==================

? StzStringQ("[ 2, 3, 5:7 ]").IsListInString()
? StzStringQ("'A':'F'").IsListInString()

/*==================

o1 = new stzstring("123456789")
? o1.Section(4,6)
#--> "456"

/*-------------

o1 = new stzstring("123456789")
o1.ReplaceSection(4, 6, :with = "***")
? o1.Content()
#--> "123***789"

/*-------------

o1 = new stzstring("abcDEFgehij")
o1.ReplaceSection(4, 6, :With@ = "Q(@section).Lowercased()")
? o1.Content()
#--> abcdefgehij

/*-------------------

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAll("Tunis", "Niamey" )
	? Content()
}
#--> Niamey is the town of my memories.

/*-------------------

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAllCS("TUNIS", "Niamey", :CS = FALSE )
	? Content()
}
#--> Niamey is the town of my memories

/*-------------------

StzStringQ( "a + b - c / d = 0" ) {
	ReplaceMany( [ "+", "-", "/" ], "*" )
	? Content()
}

/*-------------------

StzStringQ("Tunisia is back! People united.") {

	ReplaceAll("People", "Tunisians")
	? Content() + NL	# --> Tunisia is back! Tunisians united.

	? Section(3, 7)		# --> nisia

	? Section(7, 3) + NL	# --> nisia

	? Section(:From = 3, :To = :EndOfWord)	# --> nisia
	? Section(:From = 12, :To = :EndOfWord) + NL	# --> back

	? Section(:From = 9, :To = :EndOfSentence) + NL	# --> is back!

	? Section(:From = :FirstChar, :To = :EndOfString) + NL	# --> Tunisia is back! Tunisians united.

	ReplaceFirst("Tunisia", :With = "Egypt") 
	Replace( "Tunisians", :With = "Egyptians")
	? Content()	# --> Egypt is back! Egyptians united.

}

/*----------------

o1 = new stzString("this text is my text not your text, right?!")
? o1.FindAllCS("text", :casesensitive = false)
#--> [6, 17, 31]

? o1.FindNthOccurrence(2, "Text") #--> 0
? o1.FindNthOccurrenceCS(2, "Text", :casesensitive = false) #--> 17

/*----------------

o1 = new stzString("This text is my text not your text, right?!")
? o1.ReplaceNthOccurrenceCSQ(2, "TEXT", :With = "destiny", :Casesensitive = FALSE).Content()
#--> This text is my destiny not your text, right?!

o1 = new stzString("هذا نصّ لا يشبه أيّ نصّ ويا له من نصّ يا صديقي")
? o1.FindAll("نصّ")
#--> [5, 21, 35]

? o1.FindFirst("نصّ") 	#--> 5
? o1.FindLast("نصّ")	#--> 35

/*---------------

o1 = new stzString("LandRingoriaLand")
o1.RemoveFirstOccurrence( :Of = "Land")
? o1.Content()
#--> RingoriaLand

/*---------------

o1 = new stzString("LandRingoriaLand")
o1 - "Land"
? o1.Content()
#--> Ringoria

/*--------------- TODO: Maybe this should move to stzText

o1 = new stzString("ring language isسلام  a nice language")
? o1.Orientation() #--> :LeftToRight
? o1.ContainsHybridOrientation() #--> TRUE

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")
? o1.Orientation() #--> :RightToLeft
? o1.ContainsHybridOrientation() #--> TRUE

/*----------------

o1 = new stzString("ring language isسلام  a nice language")
? @@S( o1.Parts(:Using = 'StzCharQ(@char).Orientation()') ) + NL
#--> [
# 	[ "ring language is", "lefttoright" ],
o# 	[ "سلام", "righttoleft" ],
o# 	[ " a nice language", "lefttoright" ]
# ]

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")
? @@S( o1.Parts(:By = 'StzCharQ(@char).Orientation()') )
#--> [
o# 	[ "سلام", "righttoleft",
o# 	[ " ", "lefttoright" ],
o# 	[ "عليكم", "righttoleft" ],
o# 	[  " ", "lefttoright" ],
o# 	[ "ياأهل", "righttoleft" ],
o# 	[ " ", "lefttoright" ],
o# 	[  "مصر", "righttoleft" ],
o# 	[ " hello ", "lefttoright" ],
o# 	[ "الكرام", "righttoleft" ]
# ]

/*----------------

o1 = new stzString("سلام لأهل مصر الكرام")
o1.RemoveNLeftChars(7)
? o1.Content()
o#--> سلام لأهل مصر

/*----------------

o1 = new stzString("ring language is nice language")
? o1.NLastCharsRemoved(9)
#--> ring language is nice

? o1.SectionQ(1,4).CharsReversed()
#--> gnir

/*----------------

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveAllQ("<<script>>").Content()
#--> "func return :done"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveLeftOccurrenceQ("<<script>>").Content()
#--> "func return :done<<script>>"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveRightOccurrenceQ("<<script>>").Content()
#--> "<<script>>func return :done"
o1.RemoveNFirstChars(10)
? o1.Content()
#--> "func return :done"

/*----------------

o1 = new stzString("Softanza loves simplicity")
? o1.ReplaceFirstQ( o1.Section(10, :LastChar), "arrives!").Content()
#--> "Softanza arrives!"

/*----------------

o1 = new stzString("<script>func return :done<script/>")
? o1.IsBoundedBy(["<script>", :And = "<script/>"])
#--> TRUE

o1.RemoveBounds(["<script>", "<script/>"])
? o1.Content()
#--> "func return :done"

/*----------------

? StzStringQ("{nnnnn}").IsBoundedBy(["{","}"]) #--> TRUE

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.IsBoundedBy(["بسم", "الرّحيم"])

/*---------------- TODO

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.FindBounds(["بسم", "الرّحيم"])
? o1.FindBoundedBy(["بسم", "الرّحيم"])

/*=================

o1 = new stzString("Rixo Rixo Rixo")
? o1.ReplaceQ("xo", "ng").Content()
#--> Ring Ring Ring

/*----------------

o1 = new stzString("Ringos Ringos Ringos")
o1.RemoveAll("os")
? o1.Content()
#--> Ring Ring Ring

/*----------------

o1 = new stzString("extrasection")
o1.RemoveSectionQ(6, :LastChar)
? o1.Content()
#--> extra

/*----------------

o1 = new stzString("extrasection")
o1.RemoveRange(1, 5)
? o1.Content()
#--> section

/*=======================

? Q("SFOTANZA").AlignedXT( :Width=30, :Char=".", :Direction=:Center )
#--> ...........SFOTANZA...........

/*-----------------------

? StringAlign("SOFTANZA", 30, ".", :Left)
? StringAlign("SOFTANZA", 30, ".", :Right)
? StringAlign("SOFTANZA", 30, ".", :Center)
? StringAlign("SOFTANZA", 30, ".", :Justified) + NL

# -->
/*
SOFTANZA......................
......................SOFTANZA
...........SOFTANZA...........
S....O...F...T...A...N...Z...A
*/

/*----------------

str = "منصوريّات"
? StringAlign(str, 30, ".", :Left)
? StringAlign(str, 30, ".", :Right)
? StringAlign(str, 30, ".", :Center)
? StringAlign(str, 30, ".", :Justified)

# -->
/*
......................منصوريّات
منصوريّات......................
...........منصوريّات...........
م....ن...ص...و...ر...يّ...ا...ت
*/

/*==================

o1 = new stzString("مَنْصُورِيَّاتُُ")
? o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ]) #--> TRUE

/*==================

o1 = new stzString("ABCDEFGH")
o1.CompressUsingBinary("10011011")
? o1.Content()
 #--> ADEGH

/*==================

o1 = new stzString("aabbcaacccbb")
? o1.IsMadeOf([ "aa", "bb", "c" ])		# --> TRUE
? o1.IsMadeOfSome([ "a", "b", "c", "x" ])	# --> TRUE

/*------------------

o1 = new stzString("سلسبيل")
? o1.IsMadeOf([ "ب", "ل", "س", "ي" ])		# --> TRUE
? o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ])	# --> FALSE
? o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ])	# --> TRUE

/*==================

o1 = new stzString("NoWomanNoCry")
anPos = o1.FindCharsW( :Where = 'Q(@char).IsUppercase()')
? o1.SplitBeforePositions(anPos)
# --> [ "No", "Woman", "No", "Cry" ]

/*------------------

o1 = new stzString("NoWomanNoCry")
? o1.SplitBeforeW(:Where = 'Q(@char).IsUppercase()')
# --> [ "No", "Woman", "No", "Cry" ]

/*==================

StzStringQ("أهلا بأيّ كانَ، ومرحبا بأيّ كان، ومرحى لأيّ كان، أيّا كان من سمَّاهُ حُسَيْنْ") {

	cSubStr = "أيّ كان"
	cNewSubStr = " اسْمُهُ حُسَيْنْ"

	InsertBefore(cSubStr,cNewSubStr)
	? Content()
}
# -->
/*
أهلا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحبا بأيّ كان اسْمُهُ حُسَيْنْ، ومرحى لأيّ كان اسْمُهُ حُسَيْنْ، أيّا كان من سمَّاهُ حُسَيْنْ
*/

/*-------------------

o1 = new stzString("Hi Dan! Your are Dan, but your work is always not done ;)")
o1.ReplaceNthOccurrence(2, "Dan", "hardworker")
? o1.Content()
#--> Hi Dan! Your are harworker, but your work is always not done ;)

/*-------------------

o1 = new stzString("text this text is written with the text of my scrampy text")
? o1.FindAll("text")
#--> [ 1, 11, 36, 55 ]

? o1.FindNthOccurrence(4, :Of = "text")	#--> 55

? o1.ContainsNtimes(4, "text") #--> TRUE

/*==================

o1 = new stzString("reserve")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Equal

o1 = new stzString("réservé")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Greater

o1 = new stzString("reserv")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = False ) # --> :Less

/*--------------------

# Strings comparisons are made in a locale-sensitive manner
o1 = new stzString("RÉSERVÉ")
? o1.UnicodeCompareWithInSystemLocale("réservé")	# --> :Greater
# o1.UnicodeCompareWithInLocale("réservé"", "fr-FR")	# TODO

/*==================

o1 = new stzString("  lots   of    whitespace  ")
? o1.Trimmed()
? o1.SimplifyQ().UPPERcased()
#--> "LOTS OF WHITESPACE"

/*--------------------

o1 = new stzString("اسمي هو فلانة، قلت لك فلانة! أوَ لم يعجبك أن يكون اسمي فلانة؟")
o1.ReplaceAll("فلانة", "فلسطين")
? o1.Content()
o#--> اسمي هو فلسطين، قلت لك فلسطين! أوَ لم يعجبك أن يكون اسمي فلسطين؟

/*--------------------

o1 = new stzString("Mon prénom c'est Foulèna. J'ai bien dit Foulèna! " +
"Où bien tu n'aimes pas que ce soit Foulèna?")
o1.ReplaceAll("Foulèna", "Tiba")
? o1.Content()
#--> Mon prénom c'est Tiba. J'ai bien dit Tiba! Où bien tu n'aimes pas que ce soit Tiba?

/*======================

o1 = new stzString("0o20723.034")
o1 {
	? RepresentsNumber()			#--> TRUE
	? RepresentsSignedNumber()		#--> FALSE
	? RepresentsUnsignedNumber()		#--> TRUE
	? RepresentsCalculableNumber() 		#--> TRUE
	
	? RepresentsInteger()			#--> FALSE
	? RepresentsSignedInteger()		#--> FALSE
	? RepresentsUnsignedInteger()		#--> FALSE
	? RepresentsCalculableInteger()		#--> FALSE
	
	? RepresentsRealNumber()		#--> TRUE
	? RepresentsSignedRealNumber()		#--> FALSE
	? RepresentsUnsignedRealNumber()	#--> TRUE
	? RepresentsCalculableRealNumber()	#--> TRUE
	
	? RepresentsNumberInDecimalForm()	#--> FALSE
	? RepresentsNumberInBinaryForm()	#--> FALSE
	? RepresentsNumberInHexForm()		#--> FALSE
	? RepresentsNumberInOctalForm()		#--> TRUE
}

/*------------------

o1 = new stzString("12500543.12")
? o1.RepresentsRealNumber()
#--> TRUE

/*------------------

o1 = new stzString("0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("-0b110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> TRUE

o1 = new stzString("0b-110001.1001")
? o1.RepresentsNumberInBinaryForm()
#--> FALSE

/*------------------

o1 = new stzString("0x12_5AB34.123F")
? o1.RepresentsNumber() 		#--> TRUE
? o1.NumberForm()			#--> :Hex

? o1.RepresentsNumberInHexForm()	#--> TRUE

o1 = new stzString("0o2304.307")
? o1.RepresentsNumber()			#--> TRUE
? o1.NumberForm()			#--> :Octal
? o1.RepresentsNumberInOctalForm()	#--> TRUE

/*===================

o1 = new stzString("All our software versions must be updated!")

# Defining the position of insertion
nPosition = o1.PositionAfter("versions")

# Inserting the list of string using extended configuration
o1.InsertListOfSubstringsXT(
	nPosition,

	[ "V1", "V2", "V3", "V4", "V5" ], 

	[
	:InsertBeforeOrAfter = :Before,
	:OpeningChar = "{ ",
	:ClosingChar = " }", 

	:MainSeparator = ",",
	:AddSpaceAfterSeparator = TRUE,

	:LastSeparator = "and",
	:AddLastToMainSeparator = TRUE,	# adds an ", and" as a last separator

	:SpaceOption = :AddLeadingSpace //+ :AddTrailingSpace	# or :DoNothing
	])

? o1.Content()
# --> All our software versions { V1, V2, V3, V4, and V5 } must be updated!

/*===================

o1 = new stzString("latin")
? o1.IsScriptName()
#--> TRUE

/*------------------

o1 = new stzString("TN-fr") # Fix this; tn-fr gives true --> Incorrect!
? o1.IsLocaleAbbreviation()
#--> TRUE

/*------------------

o1 = new stzString("fr")
? o1.IsLocaleAbbreviation()
#--> TRUE

/*------------------

o1 = new stzString("105")
? o1.IsLanguageNumber()
#--> TRUE

? StzLanguageQ("105").Name()
#--> :Sindhi

? StzLanguageQ("105").DefaultCountry()
#--> :Pakistan

/*------------------

o1 = new stzString("ara")
? o1.IsLanguageAbbreviation()		#--> TRUE
? o1.IsShortLanguageAbbreviation()	#--> FALSE
? o1.IsLongLanguageAbbreviation()	#--> TRUE
? o1.LanguageAbbreviationForm()		#--> :Long

/*------------------

o1 = new stzString("Ⅱ")
? o1.IsLatin()
#--> TRUE

o1 = new stzChar("Ⅱ")
? o1.IsRomanNumber()
#-->

/*------------------ TODO

# TODO:
# 	Should go to stzString class
# 	Homogenize the semantics of ArabicNumber, ArabicNumerals, ArabaicDecimalDigit...

? StringIsNumberFraction("1/2") # arabic
#--> TRUE

? StringIsArabicNumberFraction("1/2") 
#--> TRUE

? StringIsNumberFraction("۱/٢") # indian
#--> TRUE

? StringIsNumberFraction("Ⅰ/Ⅱ") # roman
#!--> FALSE 	(TODO: fix it - should return TRUE)

? StringIsNumberFraction("一/二") # mandarin
#!--> FALSE 	(TODO: fix it - should return TRUE)

/*----------------

# How to add a string to a QString objet (Qt-side)
# Used internally by Softanza

oQStr = new QString()
oQStr.append("salem")
? QStringToString(oQStr)

/*--------------------

o1 = new stzString("100110001")
? o1.IsMadeOf([ "1","0" ])
#--> TRUE

/*--------------------

o1 = new stzString("01234567")
? o1.IsMadeOfSome( OctalChars() )
#--> TRUE

o1 = new stzString("001100101")
? o1.IsMadeOf( BinaryChars() )
#--> TRUE

/*-------------------

o1 = new stzString("o01234567")
? o1.RepresentsNumberInOctalForm()
#--> TRUE

/*-------------------

o1 = new stzString("4E992")
? o1.IsMadeOfSome( HexChars() )
#--> TRUE

/*-------------------

o1 = new stzString("x4E992")
? o1.RepresentsNumberInHexForm()
#--> TRUE

/*-------------------

o1 = new stzString("maan")
? o1.IsMadeOf([ "m", "a", "a", "n" ])
#--> TRUE

/*--------------

# In Softanza you get get the unicode number of a char by saying:
? Unicode("鶊")
# And you have the code, you can pass it as an imput to a stzChar
# char object to get the char:
? StzCharQ(40330).Content() #--> 鶊

# If you are curious to know how I made it internally inside the
# Unicode() function, then fellow the following discussion...

# First we create the QChar from whatever a decimal unicode could be

oChar = new QChar(40220) # the char "鴜" coded on 3 bytes

# Second, we create a QString from that QChar

oStr = new QString()
oStr.append_2(oChar)

# Third, we use toUtf8() on QString to get a QByteArray as a result,
# and then we call data() method on it to get the string with our "鴜"

? oStr.ToUtf8().data()
#--> 鶊

/*--------------

o1 = new stzString("abcbbaccbtttx")
? @@S( o1.UniqueChars() )
#--> [ "a", "b", "c", "t", "x" ]

? o1.ContainsNOccurrences(2, :Of = "a")
#--> TRUE

/*---------------

o1 = new stzString("saस्तेb")
? o1.NumberOfChars()
#--> 7

? @@S( o1.Unicodes() )
#--> [ 115, 97, 2360, 2381, 2340, 2375, 98 ]

? @@S( o1.UnicodesXT() )
#--> [ [ 115, "s" ], [ 97, "a" ], [ 2360, "स" ], [ 2381, "्" ], [ 2340, "त" ], [ 2375, "े" ], [ 98, "b" ] ]

? @@S( o1.CharsAndTheirUnicodes() )
#--> [ [ "s", 115 ], [ "a", 97 ], [ "स", 2360 ], [ "्", 2381 ], [ "त", 2340 ], [ "े", 2375 ], [ "b", 98 ] ]

/*---------------

o1 = new stzString("number 12500 number 18200")
? o1.OnlyNumbers()
#--> "1250018200"

/*================

o1 = new stzString("12500")
? o1.RepresentsNumberInDecimalForm() # --> TRUE

o1 = new stzString("b100011")
? o1.RepresentsNumberInBinaryForm() # --> TRUE

o1 = new stzString("100011") # Withount the b, it's rather a decimal not binary number!
? o1.RepresentsNumberInBinaryForm() # --> FALSE

o1 = new stzString("100011")
? o1.RepresentsNumberInDecimalForm() # --> TRUE

/*---------------

o1 = new stzString("Приве́т नमस्ते שָׁלוֹם")
? @@S( o1.Parts( :Using = "StzCharQ(@char).Script()" ) )
#--> [
# 	[ "Приве", "cyrillic" 	],
# 	[ "́", 	   "inherited" 	],
# 	[ "т",     "cyrillic" 	],
# 	[ " ",     "common" 	], 
#	[ "नमस्ते",         "devanagari" ],
# 	[ " ",     "common" 	],
o# 	[ "שָׁלוֹם", "hebrew" 	]
# ]

# TODO
? o1.PartsW('{
	Q(@part).Script() = :Cyrillic
}')
#--> [ "Приве", "т" ]

/*---------------

o1 = new stzString("🐨")
? o1.NumberOfChars() # returns 2! --> Number of CodePoints()
? o1.SizeInBytes() # returns 4

# TODO: Reflect on this: NumberOfChars() is actually NumberOfCodePoints()

/*---------------

? Q('[1, 2, 3]').ToList() #--> [1, 2, 3]

/*=============

? Heart()
#--> "♥"

? Smile()
#--> "😆"

? Handshake()
#--> "🤝"

? Sun()
#--> "🌞"

? Star()
#--> "★"

? CheckMark()
#--> "✓"

? Dot()
#--> "•"

? Flower()
#--> "✤"

/*================

StzStringQ("MustHave@32@Chars") {
	? NumberOfOccurrenceCS(:Of = "@", :CS = TRUE) #--> 2
	? FindAll("@") #--> [9, 12]

	? FindNext("@", :StartingAt = 5) #--> 9
	? FindNextNth(2, "@", :StartingAt = 5) #--> 12

	? FindPrevious("@", :StartingAt = 10) #--> 9
	? FindPreviousNth(2, "@", :StartingAt = 12) #--> 9
}

/*---------------- Used to enable constraint-oriented programming

o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
? o1.SubstringsBetween("@","@") #--> ["32", "8" ]

o1 = new stzString("MustHave32CharsAnd8Spaces")
? @@( o1.SubstringsBetween("@","@") ) #--> [ ]



///////////////////////////////////////////////////////////////////////////////////////////
////////////////////                                       ////////////////////////////////
////////////////////            TO BE FIXED LATER          ////////////////////////////////
////////////////////                                       ////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
/*---------------- TODO : AFTER CONSTRAINT IMPLEMENTED

aList = [
	:Where = "file.ring",
	:What  = "Describes what happened",
	:Why   = "Describes why it happened",
	:Todo  = "Posposes an action to do"
]

StzListQ(aList).IsRaiseNamedParam() # --> TRUE

# Internally, StzList checks for a number of conditions

StzListQ(aList) {
	? NumberOfItems() <= 4 # --> TRUE
	? IsHashList() # --> TRUE
	? ToStzHashList().KeysQ().IsMadeOfSomeOfThese([ :Where, :What, :Why, :Todo ]) # --> TRUE
	? ToStzHashList().ValuesQ().AllItemsVerifyW("isString(@item) and @item != NULL") # --> TRUE
}

# In a better world, those conditions could be expressed as
# constraints on the list object like this:

StzListQ(aList) {
	:MustHave@4@Items
	:MustBeAHashList
	:AKeyMustBeOneOfThese = [ :Where, :What, :Why, :Todo ]
	:ValuesMustBeNonNullStrings
}

# To make it happen, those constraints should be defined once at
# the global level, and then reused every where inside a stzList

/*-----------------// TODO - FUTURE //

# Constarints are defined at the global level and then reused every where
# inside your softanza objects

DefineConstraints([
	:OnStzString = [
		:MustBeUppercase 	= '{ Q(@str).IsUppercase() }',
		:MustNotExceed@n@Chars 	= '{ Q(@str).NumberOfChars() <= n }',
		:MustBeginWithLetter@c@	= '{ Q(@str).BeginsWithCS(c, :CS = FALSE) }'
	],

	:OnStzNumber = [
		:MustBeStrictlyPositive = '{ @number > 0 }'
	],

	:OnStzList = [
		:MustBeAHashList = '{ Q(@list).IsHashList() }'
	]

])

# Let's use the constraints defined in a StzString object

StzStringQ("SOFTANZA") {

	EnforeConstraints([
		:MustBeUppercase,
		:MustNotExceed10Chars
	])

	? "Passed"
}

/*----------------- TODO - FIX THIS : Revisit this after completing stzWalker

// WalkUntil has not same output in stzString and stzList!

# In stzString only the last position is returned

? StzStringQ("size()").WalkUntil('@char = "("') # --> 4
? StzStringQ("size()").WalkUntil('@char = "*"') # --> 0

# In stzList all the walked positions are returned

StzListQ([ "A", "B", 12, "C", "D", "E", 4, "F", 25, "G", "H" ]) {
	? WalkUntil("@item = 'D'") # --> 1:5
	? WalkUntil('@item = "x"') # --> 0
}

/*================== TODO: Fix error

? StzStringQ("ABTCADNBBABEFACCC").VizFind("A")

#--> 
#	"ABTCADNBBABEFACCC"
#	 ^---^----^---^---

/*-----------------

o1 = new stzString("ABTCADNBBABEFACCC")
? o1.VizFindXT("A", [ :Numbered = TRUE, :Spacified = TRUE, :PositionSign = Heart() ])

# --> Returns a string like this:

#    "A B T C A D N B B A B E F A C C C "
#     ♥-------♥---------♥-------♥-------
#     1       5         0       4

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindMany([ "A", "T", "V" ])

# --> Returns a string like this:

#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-.
#  "T" :  --^----.------.-^
#  "V" :  -------^------^--
#  "X" :  -----------------

/*----------------- (TODO)

? StzStringQ("ABTCADNBBABEFAVCC").VizFindManyXT("A")

# --> Returns a string like this:

#	  1..4..7..0..3..6.
#	 "ABTCADNVBABEFLVCT"
#  "A" :  ^-.-^--.-^----.-. (3)
#  "T" :  --^----.------.-^ (2)
#  "V" :  -------^------^-- (2)
#  "X" :  ----------------- (0)
