load "stzlib.ring"

/*-------------------

? StzStringQ("salem").IsEqualToCS("SALEM", :CS = FALSE)

/*-------------------

o1 = new stzListOfStrings([ "str1", '', "str2", "str3", '', '' ])
o1.RemoveEmptyStrings()
? o1.Content() #--> [ "str1", "str2", "str3" ]

/*-------------------

? StzListOfStringsQ(' "A":"E" ').Content()

/*-------------------

o1 = new stzListOfStrings([ "WATCH", "see", "Watch", "Observe", "watch" ])
? o1.StringsW('{ @string = "watch" }') # --> "watch"

? o1.StringsW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [ "WATCH", "Watch", "watch" ]

? o1.Yield('{ Q(@string).IsEqualToCS("watch", :CaseSensitive = FALSE) }')
#--> [ 1, 0, 1, 0, 1 ]

? o1.YieldW('@string', :Where = '{ Q(@string).IsEqualToCS("watch", :CaseSensitive = FALSE) }')
#--> [ "WATCH", "Watch", "watch" ]


? o1.FindW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [1, 3, 5]

? o1.StringsPositionsW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [1, 3, 5]

/*-------------- TODO: ERROR

# The Yield() function in stzListOfStrings calls the Yield() function
# in stzList. And sp its condition is evaluated there, and CaseSensitivity
# is not supported (==> Remove inheritance alltogethor!)

? @@( o1.Yield("[ @string, This.Find(@string, :CS = FALSE) ]") )

/*-------------------

o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])
? o1.StringsW('T(@string).Script() = :Arabic') # --> [ "قرية" ]

? o1.StringsPositionsW('T(@string).Script() = :Arabic') # --> 2

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	? FirstString()	# --> one
	? LastString()	# --> four
	
	? FindAll("two") # --> [ 2, 4 ]
	? FindFirst("two") # --> 2
	? FindLast("two") # --> 4
	? FindNthOccurrence(2, "two") # --> 4
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveStringAtPosition(4)
	? @@( Content() ) #--> [ "one", "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveAll("two")

	? Content() # --> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveAllCS("TWO", :CaseSensitive = FALSE) 
	# --> Same as RemoveAllCS("TWO", :CS = FALSE)
	? Content() # --> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveFirstString() # --> [ "two", "three", "two", "four" ]
	? Content()

	RemoveNthString(3) # or RemoveStringAtPosition(3)
	? Content() #--> [ "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveFirst("two") 
	? Content() # --> [ "one", "three", "two", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	
	RemoveNthOccurrence(2, "two")
	# Same as: RemoveNthOccurrenceOfString(2, "two")

	? Content()  # --> [ "one", "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveStringsAtThesePositions([ 2, 4 ])
	? Content() # --> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveMany([ "two", "four" ])
	# Same as RemoveManyStrings(), RemoveTheseStrings() and RemoveThese()
	? Content() # --> [ "one","three" ]
}

/*-------------------

# Be careful: there is a difference between finding a string
# and finding a substring in a lists of string

# Let's explain this by example

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

# The following finds the hole string "name" (whatever case it has)
# and sees if it exists AS AN ITEM of the list of strings

? @@( o1.FindStringCS("name", :CS = TRUE) ) # --> [ ]

# While the following analyses the strings themselves and finds
# where they may include the SUBSTRING "name"

? o1.FindSubstringCS("name", :CS = FALSE)
# --> [ "1" = [ 13 ], "3" = [ 6, 21 ]

# This means that "name" exists in:
#	- in the 1st at the position 13, and
#	- in the 3rd string at the positions 6 and 21

# Now guess the following:
? o1.FindStringCS("mabrooka", :CaseSensitive = FALSE)
# #--> [ 2, 6 ]

# And this one:
? o1.FindSubstringCS("mabrooka", :CaseSensitive = FALSE)
# --> [ "2" = [ 1 ], "6" = [ 1 ] ]

/*-----------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

//? o1.FindSubstringCS("name", :CaseSensitive = TRUE)
#--> [ "1" = [ 13 ], "3" = [ 6, 21 ] ]

? o1.FindNthSubstringCS(2, "name", :CS = TRUE)
# --> [ "3", 6 ]
# --> The 2nd occurrenc of "name" in the list
# of strings is in position 6 of the 3rd string.

/*-----------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindManySubstringsCSXT([ "name", "nice" ], :CaseSensitive = TRUE)
# --> [
#	"name" = [ "1" = [ 13 ], "3" = [ 6,21 ] ],
#	"nice" = [ "3" = [ 16 ] ]
#     ]

// TODO: To make it simpler, add this syntax:
	# ? o1.FindManySubStringsXT([ "name", "nice" ], [ :CS = FALSE ])
	#--> In general we should avoid this prefix ..XTCS() and add
	#    add CaseSensitivity as an option


/*---------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindStringCS("i see", :CaseSensitive = FALSE) # --> [4]
? o1.FindStringCS("mabrooka", :CaseSensitive = FALSE) # --> [ 2, 6 ]

? o1.FindManyStringsCS( [ "i see", "mabrooka" ], :CS = FALSE ) # [ 2, 4, 6 ]


/*---------------

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortingOrder()			# --> :Ascending
? o1.IsSortedInAscending()		# --> TRUE
? o1.StringsAreSortedInAscending()	# --> TRUE

/*---------------

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
? o1.SortingOrder()			# --> :Descending
? o1.IsSortedInDescending()		# --> TRUE
? o1.StringsAreSortedInDescending()	# --> TRUE

/*---------------

o1 = new stzListOfStrings([ "aaa", "ccc", "bbb" ])
? o1.SortingOrder()		# --> :Unsorted
? o1.IsSortedInAscending()	# --> FALSE
? o1.IsSortedInDescending()	# --> FALSE

/*---------------

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
o1.SortInAscending()
? o1.Content()	# ---> [ "aaa", "bbb", "ccc" ]

/*---------------

? StzListOfStringsQ([ "ccc", "bbb", "aaa" ]).SortInAscendingQ().Content()
# ---> [ "aaa", "bbb", "ccc" ]

/*---------------

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
o1.SortInDescending()
? o1.Content()	# ---> [ "ccc", "bbb", "aaa" ]

/*---------------

? StzListOfStringsQ([ "aaa", "bbb", "ccc" ]).SortInDescendingQ().Content()
# ---> [ "ccc", "bbb", "aaa" ]

/*---------------

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
? o1.SortedInAscending() # --> [ "aaa", "bbb", "ccc" ]
#--> Content of the main lis tis not sorted:
? o1.Content() # --> [ "ccc", "bbb", "aaa" ]

/*---------------

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortedInDescending() # ---> [ "ccc", "bbb", "aaa" ]
? o1.Content()		  # ---> [ "aaa", "bbb", "ccc" ]

/*---------------

o1 = new stzListOfStrings([ "abcde", "bdace", "ebadc", "debac", "edcba" ])
? o1.StringsSortedInAscending()
# --> [ 	"abcde",
#       	"bdace",
#       	"debac",
#       	"ebadc",
#       	"edcba"
#     ]

? o1.CharsOfEachStringSortedInAscending()
# --> [ 	"abcde",
# 	"abcde",
# 	"abcde",
# 	"abcde",
# 	"abcde"
#    ]

? o1.CharsOfEachStringSortedInDescending()
# --> [ 	"edcba", 
#	"edcba",
#	"edcba",
#	"edcba",
#	"edcba"
#     ]

? o1.CharsSortingOrders()
# --> [ :Ascending,
# 	:Unsorted,
# 	:Unsorted,
# 	:Unsorted,
#	:Descending
#     ]

? o1.NumberOfStringsWhereCharsAreSortedInAscending() 	# --> 1
? o1.NumberOfStringsWhereCharsAreSortedInDescending()	# --> 1
? o1.NumberOfStringsWhereCharsAreUnsorted()		# --> 3

/*---------------

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "aaa vvv", "nn yyy", "aa bb c" ])
? o1.WordsOfEachStringAreSortedInAscending()	# --> TRUE

o1 = new stzListOfStrings([ "ccc bbb aaa", "oo nnn mm", "vvv aaa", "yyy nn", "c bb aa" ])
? o1.WordsOfEachStringAreSortedInDescending()	# --> TRUE

/*---------------

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "vvv aaa", "yyy nn", "bb aa c" ])
? o1.WordsOfEachStringAreSortedInAscending() # --> FALSE

? o1.WordsOfEachStringSortedInAscending()
# --> [ "aaa bbb ccc", 
#	"mm nnn oo",
#	"aaa vvv",
#	"nn yyy",
	"aa bb c"
#     ]

? o1.WordsOfEachStringAreSortedInAscending() # --> FALSE

? o1.WordsOfEachStringSortedInDescending()
# --> [ "ccc bbb aaa", 
#	"oo nnn mm",
#	"vvv aaa",
#	"yyy nn",
	"c bb aa"
#     ]

? o1.WordsSortingOrders()
# --> [ :Ascending,
# 	:Ascending,
# 	:Descending,
# 	:Unsorted,
#	:Unsorted
#     ]

? o1.NumberOfStringsWhereWordsAreSortedInAscending() 	# --> 2
? o1.NumberOfStringsWhereWordsAreSortedInDescending()	# --> 2
? o1.NumberOfStringsWhereWordsAreUnsorted()		# --> 1

/*---------------

o1 = new stzListOfStrings([ "abcde", "bdace", "ebadc", "debac", "edcba" ])
? o1.AreAnagrams()		# --> TRUE
? o1.IsListOfAnagrams() 	# --> TRUE

/*---------------

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? o1.ContainsCS("sam", :CS = TRUE)	# --> TRUE
? o1.ContainsCS("SAM", :CS = TRUE)	# --> FALSE
? o1.ContainsCS("SAM", :CS = FALSE)	# --> TRUE

/*---------------

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? o1.Uppercased()	# --> [ "TOM", "SAM", "DAN" ]

o1 = new stzListOfStrings([ "TOM", "SAM", "DAN" ])
? o1.Lowercased()	# --> [ "tom", "sam", "dan" ]

/*---------------

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? @@(o1.Unicodes())
#--> [ [ 116,111,109 ],[ 115,97,109 ],[ 100,97,110 ] ]

# Same as

? @@( ListOfStringsToUnicodes([ "tom", "sam", "dan" ]) )

/*--------------- /// ERROR: Retest it after fixing Split()

cUnicodeNames = "0020;SPACE
0021;EXCLAMATION MARK
0022;QUOTATION MARK
0023;NUMBER SIGN
0024;DOLLAR SIGN
0025;PERCENT SIGN
0026;AMPERSAND
0027;APOSTROPHE
0028;LEFT PARENTHESIS
0029;RIGHT PARENTHESIS
002A;ASTERISK
002B;PLUS SIGN
002C;COMMA
002D;HYPHEN-MINUS
002E;FULL STOP
002F;SOLIDUS
"

? StzStringQ(cUnicodeNames).
	SplitQR(NL, :stzListOfStrings).SplitQ(";").Content()

/*------------------- Idem

o1 = new stzListOfStrings([ "abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp" ])

? o1.Split(";")	   # --> [
		   # 		[ "abc", "123", "tunis", "rgs" ],
		   # 		[ "jhd", "343", "gafsa", "ghj" ],
		   # 		[ "lki", "112", "beja" , "okp" ]
		   #     ]

? o1.Split(";")[1] # --> [ "abc", "123", "tunis", "rgs" ]
? o1.Split(";")[2] # --> [ "jhd", "343", "gafsa", "ghj" ]
? o1.Split(";")[3] # --> [ "lki", "112", "beja" , "okp" ]

? o1.NthSubstringsAfterSplittingStringsUsing(3, ";") # --> [ "tunis", "gafsa", "beja" ]

# The same function can be expressed like this
? o1.NthSubstrings(3, :AfterSplittingStringsUsing = ";") # --> [ "tunis", "gafsa", "beja" ]

/*-------------------

o1 = new stzListOfStrings([ "a", "b", "c", "d" ])

? o1.NumberOfCombinations() + NL #--? 12

? @@( o1.Combinations() )

# [
# 	[ "a", "b" ], [ "a", "c" ], [ "a", "d" ],
# 	[ "b", "a" ], [ "b", "c" ], [ "b", "d" ],
# 	[ "c", "a" ], [ "c", "b" ], [ "c", "d" ],
# 	[ "d", "a" ], [ "d", "b" ], [ "d", "c" ]
# ]

/*-----------------

o1 = new stzListOfStrings([
	"TUNIS", "GAFSA", "SFAX", "BEJA", "GABES", "REGUEB"
])

? o1.IsUppercase() # --> TRUE
? o1.AllStringsAreUppercase() # --> TRUE

/*------------------

o1 = new stzListOfStrings([
	"tunis", "gafsa", "sfax", "beja", "gabes", "regueb"
])

? o1.IsLowercase()
? o1.AllStringsAreLowercase()

/* ---------------

o1 = new stzListOfStrings([
	"Medianet", "ST2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"ISIE", "HNEC", "HAICA", "kalidia", "triciti", "maxeam", "Ring" ])

? o1.ContainsEachCS([ "IFES", "HAICA" ], :CS = TRUE ) #--> FALSE (because 'ifes' is lowercase)
? o1.ContainsEach([ "Ring", "keyrus" ]) #--> TRUE

? o1.ContainsBothCS("WHITECAPE", "MEDIANET", :CS = FALSE) 	#--> TRUE
? o1.ContainsBothCS( "WHITECAPE", "Medianet", :CS = FALSE )	#--> TRUE
? o1.ContainsBoth("Medianet", "ST2i") #--> TRUE

/* ---------------

o1 = new stzListOfStrings([
	:tunis, :tunis, :tunis, :gatufsa, :tunis, :tunis, :gabes,
	:tunis, :tunis, :regueb, :tuta, :regueb, "Tunis"
])

? @@( o1.FindAllCS("Tunis", :CS = FALSE) )
#--> [ 1, 2, 3, 5, 6, 8, 9, 13 ]

/* -------------

o1 = new stzListOfStrings([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

? @@(o1.FindAll("tunis"))
#--> [ 6, 7, 14 ]

? @@(o1.FindAllCS("tunis", :CS = TRUE))
#--> [ 6, 7, 14 ]

? o1.FindAllCS("tunis", :cs = false)
# --> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

? @@( o1.FindAllExceptNthCS("tunis", :FirstOccurrence, :CS = FALSE) )
# --> [ 2, 3, 4, 6, 7, 9, 10, 14 ]

? o1.FindAllExceptNthCS("tunis", :LastOccurrence, :CS = FALSE)
# --> [ 1, 2, 4, 6, 7, 9, 10 ]

? o1.FindAllExceptNthCS("tunis", 3, :cs = false )
# --> [ 1, 2, 4, 6, 7, 9, 10, 14 ]

/* =================== MANAGING DUPLICATED STRINGS

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.ContainsDuplicatedStrings() #--> TRUE

? @@( o1.DuplicatedStrings() )
#--> [ "tunis", "regueb" ]

? @@( o1.FindDuplicatedStrings() )
#--> [ 1, 10 ]

? o1.ContainsThisDuplicatedString("tunis") #--> TRUE
? o1.FindDuplicatedString("tunis") 	#--> 1

? o1.ContainsThisDuplicatedString("regueb") #--> TRUE
? o1.FindDuplicatedString("regueb")	#--> 10

? o1.NumberOfDuplicates() 			#--> 7
? o1.NumberOfDuplicatesOfString("tunis") 	#--> 6
? o1.NumberOfDuplicatesOfString("regueb")	#--> 1

? o1.StringIsDuplicatedNTimes("tunis", 6)	#--> TRUE
? o1.StringIsDuplicatedNTimes("regueb", 1)	#--> TRUE

? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]

? @@( o1.FindDuplicatesOfString("regueb") )
#--> [ 12 ]

? @@( o1.FindDuplicatesXT() )
#--> [ "tunis" = [ 2, 3, 5, 6, 8, 9 ], [ "regueb" = [ 12 ] ]

/*--------------

o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
? @@( o1.DuplicatedStrings() ) #--> [ "111", "222" ]

o1.RemoveDuplicates()
? @@( o1.Content() ) #--> [ "111", "b", "222", "c", "s" ]

/*--------------

o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
o1.RemoveDuplicatesOfThisString("111")
? @@( o1.Content() )
#--> [ "111", "b", "222", "c", "222", "s", "222" ]

/*--------------

o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
o1.RemoveDuplicatesOfTheseStrings([ "111", "222" ])
? @@( o1.Content() )
#--> [ "111", "b", "222", "c", "s" ]

/*==================

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
o1.SortInDescending()
? @@(o1.Content())
#--> [ "tuta", "tunis", "tunis", "regueb", "regueb", "gatufsa", "gabes", "Tunis" ]

/*--------------

o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
? o1.ConcatenateUsing(" ")
#--> Tunis gafsa tunis gabes tunis regueb tuta regueb

/*--------------

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
? o1.FindNthOccurrenceCS(2, "tunis", :CS = TRUE) #--> 5

? @@(o1.StringsContainingCS("tu", :CS = TRUE)) # Same as o1.FilterCS("tu", :CS = TRUE)
#--> [ "gatufsa","tunis","tunis","tuta" ]

? @@( o1.UniqueStringsContainingCS("tu", :CS = TRUE) )
#--> [ "gatufsa", "tunis", "tuta" ]

/*--------------

? StzStringQ("CAIRO").BoxedXT([ :EachChar = TRUE, :AllCorners = :Round ])

#--> 	╭───┬───┬───┬───┬───╮
# 	│ C │ A │ I │ R │ O │
# 	╰───┴───┴───┴───┴───╯

/*--------------

o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])
? o1.BoxedRound()

#--> 	╭───────╮
#	│ CAIRO │
# 	╰───────╯
# 	╭───────╮
# 	│ TUNIS │
# 	╰───────╯
# 	╭───────╮
# 	│ PARIS │
# 	╰───────╯

/*-------------- ERROR: Fix it!
*/
o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])

? o1.BoxXT([ :AllCorners = :Round, :EachChar = TRUE ])
/*
? o1.BoxedXT([ :AllCorners = :Round, :EachChar = FALSE, :Width = 10, :TextAdjustedTo = :Right ])
? o1.VizFindBoxed("I")

? o1.boxedXT([ :line = :dashed,
		:corners = [ :round, :rectangular, :round, :round ]
	    ])


/* ---------------------

o1 = new stzListOfStrings([ "bingo", "tongo", "congo" ])
o1.ReplaceStringAtPosition(3,"fongo")
? @@( o1.Content() )
#--> [ "bingo", "tongo", "fongo" ]

/* ----------------------

o1 = new stzListOfStrings(["12-120-0", "100-10-76", "87-458-20"])
o1.ReplaceSubString("-", :With = "_")
? o1.Content()
#--> [ "12_120_0", "100_10_76", "87_458_20" ]


/* -------------------

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? @@( o1.FindSubString("aa") )
#--> [ "1" = [ 1 ], "2" = [ 4 ], "3" = [ 1, 5 ] ]

/* -------------------

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.NumberOfOccurrence("a") 			#--> 0
? o1.NumberOfOccurrenceOfSubstring( "aa" )	#--> 4 

? @@( o1.FindSubstring( "aa" ) )
#--> [ [ "1", [ 1 ] ], [ "2", [ 4 ] ], [ "3", [ 1, 5 ] ] ]

? o1.NumberOfOccurrenceOfManySubstrings(["a","f","x"])
#--> [ 9, 0, 2 ]

? @@(o1.NumberOfOccurrenceOfManySubstringsXT(["a","f","x"]))
#--> [ [ "a", 9 ], [ "f", 0 ], [ "x", 2 ] ]

//*====================

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.ContainsSubStringInEachString("aa") #--> TRUE

? @@( o1.UniqueChars() )
#--> [ "a", "b", "c", "x", "z", "t", "v" ]


? @@( o1.CommonChars() )
#--> ["a", "c"]

