load "stzlib.ring"

? StzListOfStringsQ(' "A":"E" ').Content()

/*------------------- ERRORS: fix'em

o1 = new stzListOfStrings([ "WATCH", "see", "Watch", "Observe", "watch" ])
? o1.StringsW('{ @str = "watch" }') # --> "watch"

? o1.StringsW('{ @str = "watch" }')
# --> [ "WATCH", "Watch", "watch" ]
? "---"
? o1.StringsPositionsW('{ @str = "watch" }')
? "---"
//o1.StringsAndTheirPositionsW
//o1.StringAndTheirSectionsW

/*-------------------

o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])
? o1.StringsW('T(@str).Script() = :Arabic') # --> [ "قرية" ]
/*
? o1.StringsPositionsW('T(@str).Script() = :Arabic') # --> 2

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	? First()	# --> one
	? Last()	# --> four
	
	? FindAll("two") # --> [ 2, 4 ]
	? FindFirst("two") # --> 2
	? FindLast("two") # --> 4
	? FindNthOccurrence(2, "two") # --> 4
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveStringAtPosition(4)
	? Content()
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveAll("two")
	# --> Same as RemoveAll("two")
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
	RemoveFirst() # --> [ "two", "three", "two", "four" ]
	? Content()

	RemoveNth(n)
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveFirstString("two") 
	? Content() # --> [ "one", "three", "two", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	
	RemoveNthString(2, "two")
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
*/
o1 = new stzListOfStrings([ "village", "town", "country" ])
o1.ForEachStringPerform('{ @str = Q(@str).Uppercased() }')
? o1.Content() # --> [ "VILLAGE", "TOWN", "COUNTRY" ]

/*-------------------

o1 = new stzListOfStrings([ "village", "town", "country" ])
o1.ForEachStringPerform('{ @str = Q(@str).Titlecased() }')
? o1.Content() # --> [ "Village", "Town", "Country" ]

/*-------------------

o1 = new stzListOfStrings([ "village.txt", "town.txt", "country.txt" ])

o1.ForEachStringPerform('{ @str = Q(@str).RemoveQ(".txt").Content() }')
? o1.Content() # ---> [ "village", "town", "country" ]

# TODO: Reflect on removing the string itself... Should we allow it?
/*-------------------

o1 = new stzListOfStrings([ "village", "town", "country" ])
o1.ForEachStringPerform('{ @str += ".txt" }')

? o1.Content() # ---> [ "village.txt", "town.txt", "country.txt" ]

/*-------------------

o1 = new stzListOfStrings([ "village", "town", "country" ])

? o1.ForEachStringYield('[ @str, Q(@str).NumberOfChars() ]')
# ---> [ [ "village", 7 ], [ "town", 4 ], [ "country", 7 ] ]

/*-------------------

o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])

? o1.Yield('[ @str, T(@str).Script() ]') # T --> StzTextQ() -- TODO: W() for stzWord()
# ---> [ [ "village", :Latin ], [ "town", :Arabic ], [ "country", :Gujarati ] ]

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
# #--> [ 2, 6]

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

? o1.FindSubstringCS("name", :CaseSensitive = TRUE)
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


/*---------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindManyStringsCSXT([ "i see", "mabrooka" ], :CaseSensitive = FALSE)
# --> [
#	[ "i see", 	 [ 4 ] ],
#	[ "mabrooka", [ 2, 6 ] ]
#     ]

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
? o1.Content()		 # --> [ "ccc", "bbb", "aaa" ]

/*---------------

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortedInDescending() # ---> [ "ccc", "bbb", "aaa" ]
? o1.Content()		  # ---> [ "aaa", "bbb", "ccc" ]

/*---------------

o1 = new stzListOfStrings([ "abcde", "bdace", "ebadc", "debac", "edcba" ])
? o1.StringsSortedInAscending()
# --> [ "abcde",
#	"bdace",
#	"debac",
#	"ebadc",
#	"edcba"
#     ]


? o1.CharsOfEachStringSortedInAscending()
# --> [ "abcde",
# 	"abcde",
# 	"abcde",
# 	"abcde",
# 	"abcde"
#    ]

? o1.CharsOfEachStringSortedInDescending()
# --> [ "edcba", 
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
? o1.AreAnagrams()	# --> TRUE
? o1.IsListOfAnagrams() # --> TRUE

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

? ListOfStringsToUnicodes([ "tom", "sam", "dan" ])

/*---------------

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

/*-------------------

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

? o1.NumberOfCombinations() + NL

for aPair in o1.Combinations()
	? aPair
next

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

/*-----------------

#? o1.ContainsEachCS([ "IFES", "HAICA" ], :CS = TRUE )
#? o1.ContainsEach([ "Ring", "keyrus" ])

#? o1.ContainsBothCS("WHITECAPE", "MEDIANET", :CS = FALSE)

? o1.ContainsBothCS( "WHITECAPE", "Medianet", :CS = FALSE )
? o1.ContainsBoth("Medianet", "ST2i")

/* ---------------

o1 = new stzListOfStrings([
	"Medianet", "ST2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"ISIE", "HNEC", "HAICA", "kalidia", "triciti", "maxeam", "Ring" ])

? o1.Copy().Uppercased()
? o1.Copy().Lowercased()

/* -----------------

o1 = new stzListOfStrings([
	:tunis, :tunis, :tunis, :gatufsa, :tunis, :tunis, :gabes,
	:tunis, :tunis, :regueb, :tuta, :regueb, "Tunis"
])

? o1.DuplicatesCS( :cs = true )


/* ---------------

o1 = new stzListOfStrings([
	:tunis, :tunis, :tunis, :gatufsa, :tunis, :tunis, :gabes,
	:tunis, :tunis, :regueb, :tuta, :regueb, "Tunis"
])

? o1.FindAllCS("Tunis", :CS = FALSE)

/* -------------

o1 = new stzListOfStrings([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

? @@(o1.FindAll("tunis"))
#--> [ 1,2,3,4,6,7,9,10,14 ]

? @@(o1.FindAllCS("tunis", :CS = TRUE))
#--> [ 6,7,14 ]

? o1.FindAllCS("tunis", :cs = false)
# --> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

? o1.FindAllExceptNthCS("tunis", :FirstString, :CS = FALSE)
# --> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

? o1.FindAllExceptNthCS("tunis", :LastString, :CS = FALSE)
# --> [ 1, 2, 4, 6, 7, 9, 10 ]

? o1.FindAllExceptNthCS("tunis", 3, :cs = false )
# --> [ 1, 2, 4, 6, 7, 9, 10, 14 ]

/* -------------

o1 = new stzListOfStrings([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

# Positions where strings were duplicated
? o1.Duplicates()
#--> [ 4, 7, 9, 10, 13, 14 ]

? o1.DuplicatedStrings()
#--> [ "Tunis", "TUNIS", "tunis", "regueb" ]

? o1.IsDuplicatedStringCS( "tunis", :CS = TRUE ) #--> TRUE
#? o1.DuplicatedStringsCS( :CS = true )

o1.RemoveDuplicatesCS( :CS = TRUE )
? @@(o1.Content())
#--> [ "TuNIS","Tunis","TUNIS","gatufsa","tunis","gabes","regueb","tuta" ]

/* --------------

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
o1.SortInDescending()
? @@(o1.Content())
#--> [ "tuta","tunis","tunis","regueb","regueb","gatufsa","gabes","Tunis" ]

/*--------------

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
? o1.ConcatenateUsing(" ")
#--> Tunis gatufsa tunis gabes tunis regueb tuta regueb

/*--------------

o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
? o1.FindNthOccurrenceCS(2, "tunis", :CS = TRUE) #--> 5

? @@(o1.StringsContainingCS("tu", :CS = TRUE)) # Same as o1.FilterCS("tu", :CS = TRUE)
#--> [ "gatufsa","tunis","tunis","tuta" ]

? o1.UniqueStringsContainingCS("tu", :CS = TRUE)
#--> [ "gatufsa","tunis","tunis","tuta" ]





/* ------------------

//? StzStringQ("CAIRO").BoxedXT([ :EachChar = TRUE, :AllCorners = :Round ])

o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])
? o1.BoxedRound()
? o1.BoxedXT([ :AllCorners = :Round, :EachChar = TRUE ])
//? o1.BoxedXT([ :AllCorners = :Round, :EachChar = FALSE, :Width = 10, :TextAdjustedTo = :Right ])
? o1.VizFindBoxed("I")

/* --------------------

? o1.boxedXT([ :line = :dashed,
		:corners = [ :round, :rectangular, :round, :round ]
	    ])
/*

//? o1.ListOfStrings()
? o1.ContainsCS("bingo", :CS = TRUE)
? o1.Contains("Bingo")
? o1.ContainsSubstring_InEachStringCS("bOx", :CaseSensitive = FALSE)

/* ---------------------

o1 = new stzListOfStrings([ "bingo", "tongo", "congo" ])
o1.ReplaceStringAtPosition(3,"fongo")
? o1.Content()

/* ----------------------

o1 = new stzListOfStrings(["a", "b", "c", "A", "a"])
? o1.ReplaceInStrings("a","x", :CaseSensitive = FALSE)

/* -----------------------

// Creating the list of strings
oListOfStrings = new stzListOfStrings(["1a3c52debeffd", "2b6178c97a938stf", "3ycxdb1fgxa2yz"])
// Getting the common characters between the strings and sorting them
aCommon = sort(oListOfStrings.CommonChars())
? aCommon
// Among them, finding characters appearing in each string once only
aRes = []
for c in aCommon
	if oListOfStrings.EachStringContains_N_OccurrenceOf(c,1)
		aRes + c
	ok
next

// Transforming the result to a string
oTempList = new stzListOfStrings(aRes)
? oTempList.ToStringWithSeparator(" ")

//? o1.EachStringContains_N_OccurrenceOf("a", 1)

/* ---------------------

//? o1.UniqueChars()
//? o1.NumberOfOccurrence("x")
//? o1.CommonChars_WithNumberOfOccurrenceEqualTo(1)


aCaract_Occurr = o1.NumberOfOccurrenceOfMany( sort(o1.CommonChars()) )
//? aCaract_Occurr["f"]

aResult1 = []
for item in aCaract_Occurr
	cCaract = item[1]
	if o1.EachStringContains_N_OccurrenceOf(


next
? aResult1

/* -------------------

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.NumberOfOccurrence("a")
? o1.NumberOfOccurrenceOfSubstring( "aa" ) // Returns 4 
#? o1.NumberOfOccurrenceOfSubstringXT( "aa" ) // TODO : should return [ :1 = 1, :2 = 1, :3 = 2 ]
# ? o1.NumberOfOccurrenceOfMany(["a","f","x"]) // TODO

//* -----------------------------
/*
o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.UniqueChars()

? o1.CommonChars()
? o1.NumberOfOccurrenceOfSubstring("aa")
? o1.NumberOfOccurrenceOfChar("c")

//* -----------------------------

o1 = new stzListOfStrings([ "aabc", "abxaxcccz", "aattcvv" ])
? o1.CommonCharsQR(:stzList).Content()
? o1.ContainsCharInEachString("a")
