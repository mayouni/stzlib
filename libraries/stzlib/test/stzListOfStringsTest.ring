load "../max/stzmax.ring"

/*============
/*
pr()

o1 = new stzListOfStrings([ "ring", "programming", "languag" ])
? o1.ConcatenatedUsing(" ")
#--> ring programming languag

o1 = new stzListOfStrings([ ])
? @@( o1.ConcatenatedUsing(" ") )
#--> ""

proff()
# Executed in 0.03 second(s)

#--------
/*
pr()

o1 = new stzListOfStrings([ "aa", "  ", "b", "     ", "ccc" ])
o1.RemoveBlankSpacesStrings()
? @@( o1.Content() )
#--> [ "aa", "b", "ccc" ]

proff()
# Executed in 0.03 second(s)

/*============

pr()

o1 = new stzListOfStrings([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortBy('len(@string)')

? o1.Content()
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

proff()
#--> Executed in 0.28 second(s)

/*=========

pr()

o1 = new stzListOfStrings([ "--**-*", "*---*", "--*-***" ])
o1.RemoveSubString("*")
? @@( o1.Content() )
#--> [ "---", "---", "---" ]

proff()
# Executed in 0.05 second(s)

/*============

StartProfiler()

o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.Trim()
? @@(o1.Content())
#--> [ " one ", " two ", " three" ]

o1.TrimStrings()
? @@(o1.Content())
#--> [ "one", "two", "three" ]

StopProfiler()
# Executed in 0.08 second(s)

/*-------------

StartProfiler()

o1 = new stzListOfStrings([ "  ", " ", "  one ", " two ", "    three", "    ", " "])
o1.TrimStart()
? @@(o1.Content())
#--> [ " one ", " two ", " three", " ", " " ]

o1.TrimEnd()
#--> [ " one ", " two ", " three" ]

? @@(o1.Content())

StopProfiler()
# Executed in 0.04 second(s)

/*----------------- TODO

StartProfiler()

o1 = new stzListOfStrings([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])
? @@( o1.FindDuplicates() )


StopProfiler()

/*-----------------

o1.RemoveDuplicatesCS(_TRUE_)

? o1.Content()

StopProfiler()

/*----------------

StartProfiler()

o1 = new stzList([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.RemoveSection(1,3)
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.RemoveRange(:Last, -3)
//? @@( o1.Content() )
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

/*----------------

StartProfiler()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.RemoveSection(1,3)
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.RemoveRange(:Last, -3)
//? @@( o1.Content() )
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

/*----------------

StartProfiler()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])

o1.TrimStart()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE", "", "", "" ]

o1.TrimEnd()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

/*---------------

StartProfiler()

o1 = new stzListOfStrings([ "", "", "", "ONE", "TWO", "THREE", "", "", "" ])
o1.Trim()
? @@( o1.Content() )
#--> [ "ONE", "TWO", "THREE" ]

StopProfiler()

/*---------------

StartProfiler()

o1 = new stzListOfStrings([
	"", "",
	"ABCDEF", "GHIJKL",
	"123346", "MNOPQU", "RSTUVW", "984332",
	"", ""
])

o1.RemoveAtQ([5, 8]).TrimQ()
? @@( o1.Content() )
#--> [ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ]

StopProfiler()
/*---------------

o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
o1.RemoveAt(2)
? @@(o1.Content())
#--> [ "name", "姓名" ]

/*---------------

? StzTextQ("姓名").Script() #--> "han"

o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
? o1.Scripts()
#--> [ "latin", "arabic", "han" ]

/*---------------

/* NOTE :
	- RemoveNthItem(n) : Remove item at position n

	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
  	  (you can also use RemoveNthOccurrence(n, pItem)

	- RemoveThisNthItem(n, pItem) : remove nth item only if it
	  is equal to pItem
*/
/*
StartProfiler()

o1 = new stzListOfStrings([ "_", "A", "B", "C", "_", "D", "E", "_" ])

o1.RemoveFirstItem()
? @@( o1.Content() )
#--> [ "A", "B", "C", "_", "D", "E", "_" ]

o1.RemoveThisNthItem(1, "A")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E", "_" ]

o1.RemoveNth(2, "_")
? @@( o1.Content() )
#--> [ "B", "C", "_", "D", "E" ]

o1.RemoveFirstXT("_")
? @@( o1.Content() )
#--> [ "B", "C", "D", "E" ]

o1.RemoveThisFirstItemCS("b", :CS = _FALSE_)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last) # ChekParams() should be turned ON for :Last to be recognised
			# Otherwise, use o1.RemoveNthItem(o1.NumberOfItems())
? @@( o1.Content() )
#--> [ "C", "D" ]

StopProfiler()
#--> Executed in 0.07 second(s)

/*-----------------

o1 = new stzListOfStrings([ "1", "2", "abc", "4", "5", "abc", "7", "8", "abc" ])

? o1.FindAll("abc")
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString and
# stzList, because they are abstracted in stzObject


? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [6, 9]

? o1.NLastOccurrencesXT(2, "abc", :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = "abc", :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesXT(2, :Of = "abc", :StartingAt = 10)
#--> [6, 9]

/*-----------------

o1 = new stzGrid([
	[ ".", ".", "." ],
	[ "-", "-", "-" ],
	[ "*", "*", "*" ]
])
? o1.Show()
#--> . . .
#    - - -
#    * * *
/*-----------------

o1 = new stzListOfStrings([
	".;.;.",
	"-;-;-",
	"*;*;*"
])
? @@( o1.Splitted(:Using = ";") )
#--> [
#	[ ".", ".", "." ],
#	[ "-", "-", "-" ],
#	[ "*", "*", "*" ]
# ]

/*-----------------

o1 = new stzListOfStrings([
	"      ........  ",
	"   ........ ",
	"       ........       ",
	"........  "
])

? @@( o1.StringsTrimmed() )
#--> [
# 	"........",
# 	"........",
# 	"........",
# 	"........"
# ]

/*-----------------

pr()

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E", "F"])
o1.ReplaceManyOneByOneCS([ "B", "D", "F"], :With = [ "1", "2", "3" ], :CS=_TRUE_)
#--> [ "A", "1", "C", "2", "E", "3" ]
? o1.Content()

proff()
# Executed in 0.04 second(s)

/*-----------------

o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
? o1.FindAllCS("B", :CS = _FALSE_)
#--> [2, 4]

/*-----------------

o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
o1.ReplaceStringCS("B", "_", :CS = _FALSE_)
? o1.Content() #--> [ "A", "_", "C", "_" ]

/*-----------------

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E", "F"])
o1.ReplaceManyOneByOneCS([ "b", "d", "f"], :With = [ "1", "2", "3" ], :CS=FALSE)
? @@( o1.Content() ) #--> [ "A", "1", "C", "2", "E", "3" ]

/*------------

o1 = new stzListOfStrings([ "ONE", "TWO", "THREE" ])
? o1.Lowercased() #--> [ "one", "two", "three" ])

/*------------

o1 = new stzListOfStrings( functions() )
? o1.ContainsCS("StzRaise", :CS = _FALSE_)	#--> _TRUE_
? o1.FindFirstcs("StzRaise", :CS = _FALSE_)	#--> 318

/*-----------------

o1 = new stzListOfStrings([ "C", "B", "A" ])
o1.Move( :StringAtPosition = 3, :ToPosition = 1 )
? o1.Content() #--> [ "A", "C", "B" ]

o1.Move( :StringAtPosition = 2, :ToPosition = 3 )
? o1.Content() #--> [ "A", "B", "C" ]

/*-----------------

o1 = new stzListOfStrings([ "C", "B", "A" ])
o1.Move( :String = 1, :ToPositionOfString = 3)
? o1.Content() #--> [ "B", "A", "C" ]

o1.Swap(:BetweenString = 1, :AndString = 2)
? o1.Content() #--> [ "A", "B", "C" ]

/*-----------------

o1 = new stzListOfStrings([ "*", "A*B*C", "*" ])

? @@( o1.Find( :String = "*" ) ) + NL
#--> [1, 3]

? @@( o1.Find( :SubString = "*" ) )
#--> [ [1, [1]], [2, [2, 4]], [3, [1]] ]

/*----------------
o1 = new stzListOfStrings([
	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Justified )
	? o1.Aligned( :To = :Right )
	? o1.AlignedTo( :Right )
	? o1.AlignedToRightXT( :Width = :Max, :Char = "" )
	? o1.RightAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToRight()
	? o1.RightAligned()

/*----------------
o1 = new stzListOfStrings([
	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Left )
	? o1.Aligned( :To = :Left )
	? o1.AlignedTo( :Left )
	? o1.AlignedToLeftXT( :Width = :Max, :Char = "" )
	? o1.LeftAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToLeft()
	? o1.LeftAligned()

/*----------------
o1 = new stzListOfStrings([
	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Center )
	? o1.Aligned( :To = :Center )
	? o1.AlignedTo( :Center )
	? o1.AlignedToCenterXT( :Width = :Max, :Char = "" )
	? o1.CenterAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToCenter()
	? o1.CenterAligned()
	? o1.Centered()

/*----------------

o1 = new stzListOfStrings([
	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.JustifiedXT( :Width = 50, :Char = " " )
#-->
# H o w   m a n y   r o a d s   must a man walk down
# B e f o r e   y o u   c a l l   h i m   a   m a n?
# H o w   m a n y   s e a s   must a white dove sail
# B e f o r e   s h e   s l e e p s   i n  the sand?

? o1.Justified()
#-->
# H ow many roads must a man walk down
# B e f o r e   y o u  call him a man?
# How many seas must a white dove sail
# B e f o r e  she sleeps in the sand?

//? o1.AlignedXT( :Max, ".", :Justify )


/*================== FINDING SUBSTRINGS

o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

? @@( o1.FindSubString("ring") )
#--> [ [ 1, [ 5, 14 ] ], [ 2, [ 1, 10, 19 ] ], [ 3, [ 5 ] ] ]

? @@( o1.FindSubStringXT("ring") )
#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1 ], [ 2, 10 ], [ 2, 19 ], [ 3, 5 ] ]

? @@( o1.FindTheseOccurrencesOfSubString([1, 3, 5 ], "ring") )
#--> [ [ 1, 5 ], [ 2, 1 ], [ 2, 19 ] ]

/*-----------------------

o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

? @@( o1.FindNFirstOccurrencesOfSubString(4, "ring") )
#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1], [ 2, 10 ] ]

? @@( o1.FindNLastOccurrencesOfSubString(3, "ring") )
#--> [ [ 2, 10 ], [ 2, 19 ], [ 3, 5 ] ]

/*-----------------------

o1 = new stzListOfStrings([
	"what's your name please",
	"mabrooka",
	"your name and my name are not the same",
	"i see",
	"nice to meet you",
	"mabrooka"
])

? @@( o1.FindSubStrings([ "name", "mabrooka"]) ) + NL
#-->
#  [
#	# "name" is found here
#	[
#		[ 1, [ 13 ] ], [ 3, [ 6, 18 ] ]
#	],
#
#	# and "mabrooka" is found here
#	[
#		[ 2, [ 1 ] ], [ 6, [ 1 ] ]
#	]
#  ]

? @@( o1.FindSubStringsXT([ "name", "mabrooka"]) )
#-->
#  [
#	# "name" is found here
#	[
#		[ 1, 13 ], [ 3, 6 ], [ 3, 18 ]
#	],
#
#	# and "mabrooka" is found here
#	[
#		[ 2, 1 ], [ 6, 1 ]
#	]
#  ]

/*------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindNthOccurrenceOfSubString(2, "name")
#--> [ 3, 6 ]

/*------------------

o1 = new stzListOfStrings([
	"What's your name please?",
	"Mabrooka!",
	"Your name and my name are not the same...",
	"I see.",
	"Nice to meet you,",
	"Mabrooka!"
])
	
? @@( o1.FindSubstring("name") ) + NL
#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

# For your convinience, you can get the result in an exmpanded form:
? @@( o1.FindSubStringXT("name") )
#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

/*------------------

o1 = new stzListOfStrings([
	"___ ring ___",
	"___ ring ___ ring",
	"___ ruby ___ ring",
	"___ ring ___ ruby ___ ring"
])

? o1.NumberOfOccurrenceOfManySubStrings([ "ring", "ruby", "python" ])
#--> [ 6, 2, 0 ]

? @@( o1.NumberOfOccurrenceOfManySubStringsXT([ "ring", "ruby", "python" ]) )
#--> [
#	[ [ 1, 1], [2, 2], [3, 1], [4, 2] ], 	#<<< Occurrence of "ring"
#	[ [ 3, 1 ], , [ 4, 1 ] ], 		#<<< Occurrences of "ruby"
#	[  ] 					#<<< No occurrences at all for "pyhthon"
#   ]

/*--------------

o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])

# How many occurrence are there of the substring "ring" in the list?
? o1.NumberOfOccurrenceOfSubString("ring") #--> 3

# Show these 3 in detail, string by string:
? @@( o1.NumberOfOccurrenceOfSubStringXT("ring") )
#--> [ [ 1, 1 ], [ 3, 2 ] ]

/*================= REPLACING SUBSTRINGS

o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

o1.ReplaceSubStringAtPosition( [2, 10], "ring", "♥♥♥" )

? @@(o1.Content() )
#--> [ "___ ring ___ ring", "ring ___ ♥♥♥ ___ ring", "___ ring" ]

/*-----------------------

o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

o1.ReplaceNthOccurrenceOfSubString(4, "ring", "♥♥♥")

? @@(o1.Content() )
#--> [ "___ ring ___ ring", "ring ___ ♥♥♥ ___ ring", "___ ring" ]

/*============= REPLACING SUBSTRINGS INSIDE A GIVEN STRING OF THE LIST

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringN(2, "ring", :With = "♥")
? o1.Content()
#--> [ "php", "♥ php ♥ python ♥", "python" ]

/*-----------------

o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
o1.ReplaceSubStringAtPosition([2, 5], "ring", "♥" )
? o1.Content()
#--> [ "php", "php ♥ python", "python" ]

/*-----------------

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
o1.ReplaceInStringNTheNthOccurrence(2, 3, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]

/*-----------------

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
o1.ReplaceInStringNTheFirstOccurrence(2, "ring", "♥" )
? o1.Content()
#--> [ "php", "♥ php ring python ring", "python" ]

/*-----------------

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
o1.ReplaceInStringNTheLastOccurrence(2, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]

/*====================

? StzStringQ("salem").IsEqualToCS("SALEM", :CS = _FALSE_) #--> _TRUE_

/*===================

o1 = new stzListOfStrings([ "str1", '', "str2", "str3", '', '' ])
o1.RemoveEmptyStrings()
? o1.Content() #--> [ "str1", "str2", "str3" ]

/*===================

? StzListOfStringsQ(' "A":"E" ').Content()

/*===================

o1 = new stzListOfStrings([ "WATCH", "see", "Watch", "Observe", "watch" ])
? o1.StringsW('{ @string = "watch" }') #--> "watch"

? o1.StringsW('{ Q(@string).IsEqualToCS("watch", :CS = _FALSE_) }')
#--> [ "WATCH", "Watch", "watch" ]

? o1.Yield('{ Q(@string).IsEqualToCS("watch", :CaseSensitive = _FALSE_) }')
#--> [ 1, 0, 1, 0, 1 ]

? o1.YieldW('@string', :Where = '{ Q(@string).IsEqualToCS("watch", :CaseSensitive = _FALSE_) }')
#--> [ "WATCH", "Watch", "watch" ]


? o1.FindW('{ Q(@string).IsEqualToCS("watch", :CS = _FALSE_) }')
#--> [1, 3, 5]

? o1.StringsPositionsW('{ Q(@string).IsEqualToCS("watch", :CS = _FALSE_) }')
#--> [1, 3, 5]

/*-------------- TODO: ERROR

# The Yield() function in stzListOfStrings calls the Yield() function
# in stzList. And sp its condition is evaluated there, and CaseSensitivity
# is not supported (==> Remove inheritance alltogethor!)

? @@( o1.Yield("[ @string, This.Find(@string, :CS = _FALSE_) ]") )

/*-------------------

o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])
? o1.StringsW('T(@string).Script() = :Arabic') #--> [ "قرية" ]

? o1.StringsPositionsW('T(@string).Script() = :Arabic') #--> 2

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	? FirstString()	#--> one
	? LastString()	#--> four
	
	? FindAll("two") #--> [ 2, 4 ]
	? FindFirst("two") #--> 2
	? FindLast("two") #--> 4
	? FindNthOccurrence(2, "two") #--> 4
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveStringAtPosition(4)
	? @@( Content() ) #--> [ "one", "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveAll("two")

	? Content() #--> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveAllCS("TWO", :CaseSensitive = _FALSE_) 
	#--> Same as RemoveAllCS("TWO", :CS = _FALSE_)
	? Content() #--> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveFirstString() #--> [ "two", "three", "two", "four" ]
	? Content()

	RemoveNthString(3) # or RemoveStringAtPosition(3)
	? Content() #--> [ "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveFirst("two") 
	? Content() #--> [ "one", "three", "two", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	
	RemoveNthOccurrence(2, "two")
	# Same as: RemoveNthOccurrenceOfString(2, "two")

	? Content()  #--> [ "one", "two", "three", "four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
	RemoveStringsAtThesePositions([ 2, 4 ])
	? Content() #--> [ "one","three","four" ]
}

/*-------------------

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveMany([ "two", "four" ])
	# Same as RemoveManyStrings(), RemoveTheseStrings() and RemoveThese()
	? Content() #--> [ "one","three" ]
}

/*-------------------

# Be careful: there is a difference between finding a string
# and finding a substring inside the string items of the list of string

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

? @@( o1.FindStringCS("name", _TRUE_) ) #--> [ ]

# While the following analyses the strings themselves and finds
# where they may include the SUBSTRING "name"

? @@( o1.FindSubstringCS("name", :CS = _FALSE_) )
#--> [
#	[ 1, [ 13    ] ],
#	[ 3, [ 6, 21 ] ]
# ]

# This means that "name" exists :
#	- in the 1st string at  position 13, and
#	- in the 3rd string at positions 6 and 21

# Now guess the following:
? @@( o1.FindStringCS("mabrooka", :CaseSensitive = _FALSE_) )
#--> [ 2, 6 ]
#--> "mabourka" exists (whatever case is) as an entire string item in positions 2 and 6

# And this one:
? @@( o1.FindSubstringCS("mabrooka", :CaseSensitive = _FALSE_) )
#--> [
# 	[ 2, [ 1 ] ],
# 	[ 6, [ 1 ] ]
# ]
#--> "mabourka" exists (whatever case is) AS A SUBSTRING:
# 	- of the 2nd string, at position 1, and
# 	- of the 6th string at position 1

/*-----------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindSubstringCS("name", _TRUE_) ) + NL
#--> [
#	[ 1, [ 13    ] ],
#	[ 3, [ 6, 21 ] ]
#    ]

? @@( o1.FindNthSubstringCS(2, "name", _TRUE_) )
#--> [ 3, 6 ]
#--> The 2nd occurrenc of "name" in the list
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

? @@( o1.FindManySubstringsCSXT([ "name", "nice" ], _TRUE_) )
#--> [
#	[ "name" , [ [ 1, 13 ], [ 3, 6 ], [ 3, 21 ] ] ],
#	[ "nice" , [ [ 3, 16 ] ] ]
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

? o1.FindStringCS("i see", :CaseSensitive = _FALSE_) #--> [4]
? o1.FindStringCS("mabrooka", :CaseSensitive = _FALSE_) #--> [ 2, 6 ]

? o1.FindManyStringsCS( [ "i see", "mabrooka" ], :CS = _FALSE_ ) # [ 2, 4, 6 ]


/*================

pr()

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortingOrder()
#--> :Ascending

? o1.IsSortedInAscending()
#--> _TRUE_

? o1.StringsAreSortedInAscending()
#--> _TRUE_

proff()
# Executed in 0.08 second(s)

/*---------------

pr()

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
? o1.SortingOrder()
#--> :Descending

? o1.IsSortedInDescending()
#--> _TRUE_

? o1.StringsAreSortedInDescending()
#--> _TRUE_

proff()
# Executed in 0.09 second(s)

/*---------------

pr()

o1 = new stzListOfStrings([ "aaa", "ccc", "bbb" ])
? o1.SortingOrder()
#--> :Unsorted

? o1.IsSortedInAscending()
#--> _FALSE_

? o1.IsSortedInDescending()
#--> _FALSE_

proff()
# Executed in 0.09 second(s)

/*---------------

pr()

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
o1.SortInAscending()
? o1.Content()
#--> [ "aaa", "bbb", "ccc" ]

proff()
# Executed in 0.04 second(s)

/*---------------

pr()

? StzListOfStringsQ([ "ccc", "bbb", "aaa" ]).SortInAscendingQ().Content()
#--> [ "aaa", "bbb", "ccc" ]

proff()
# Executed in 0.04 second(s)

/*---------------

pr()

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
o1.SortInDescending()
? o1.Content()	#--> [ "ccc", "bbb", "aaa" ]

proff()
# Executed in 0.05 second(s)

/*---------------

? StzListOfStringsQ([ "aaa", "bbb", "ccc" ]).SortInDescendingQ().Content()
#--> [ "ccc", "bbb", "aaa" ]

/*---------------

o1 = new stzListOfStrings([ "ccc", "bbb", "aaa" ])
? o1.SortedInAscending() #--> [ "aaa", "bbb", "ccc" ]
#--> Content of the main lis is not sorted:
? o1.Content() #--> [ "ccc", "bbb", "aaa" ]

/*---------------

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
? o1.SortedInDescending() #--> [ "ccc", "bbb", "aaa" ]
? o1.Content()		  #--> [ "aaa", "bbb", "ccc" ]

/*---------------- TODO: check result correctness!

pr()

o1 = new stzList([ "tunis", "tripoli", "cairo", "casablanca" ])

o1.SortByInDescending('len(This[@item])')
? o1.Content()

proff()

/*----------------

pr()

o1 = new stzListOfStrings([ "12", "12345", "123", "1" ])

? o1.SortedByInAscending('Q(@string).NumberOfChars()')
#--> [
#	"1",
#	"12",
#	"123",
#	"12345"
# ]

? o1.SortedByInDescending('Q(@string).NumberOfChars()')
#--> [
#	"12345",
#	"123",
#	"12",
#	"1"
# ]

proff()
# Executed in 0.05 second(s)

/*--------------- TODO/FUTURE

pr()

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "aaa vvv", "nn yyy", "aa bb c" ])
? o1.WordsOfEachStringAreSortedInAscending()	#--> _TRUE_

o1 = new stzListOfStrings([ "ccc bbb aaa", "oo nnn mm", "vvv aaa", "yyy nn", "c bb aa" ])
? o1.WordsOfEachStringAreSortedInDescending()	#--> _TRUE_

proff()

/*--------------- TODO/FUTURE

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "vvv aaa", "yyy nn", "bb aa c" ])
? o1.WordsOfEachStringAreSortedInAscending() #--> _FALSE_

? o1.WordsOfEachStringSortedInAscending()
#--> [ "aaa bbb ccc", 
#	"mm nnn oo",
#	"aaa vvv",
#	"nn yyy",
	"aa bb c"
#     ]

? o1.WordsOfEachStringAreSortedInAscending() #--> _FALSE_

? o1.WordsOfEachStringSortedInDescending()
#--> [ "ccc bbb aaa", 
#	"oo nnn mm",
#	"vvv aaa",
#	"yyy nn",
	"c bb aa"
#     ]

? o1.WordsSortingOrders()
#--> [ :Ascending,
# 	:Ascending,
# 	:Descending,
# 	:Unsorted,
#	:Unsorted
#     ]

? o1.NumberOfStringsWhereWordsAreSortedInAscending() 	#--> 2
? o1.NumberOfStringsWhereWordsAreSortedInDescending()	#--> 2
? o1.NumberOfStringsWhereWordsAreUnsorted()		#--> 1

/*---------------

pr()

o1 = new stzListOfStrings([ "abcde", "bdace", "ebadc", "debac", "edcba" ])
? o1.AreAnagrams()
#--> _TRUE_

? o1.IsListOfAnagrams()
#--> _TRUE_

proff()
# Executed in 1.49 second(s)

/*================

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? o1.ContainsCS("sam", _TRUE_)	#--> _TRUE_
? o1.ContainsCS("SAM", _TRUE_)	#--> _FALSE_
? o1.ContainsCS("SAM", :CS = _FALSE_)	#--> _TRUE_

/*================

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? o1.Uppercased()	#--> [ "TOM", "SAM", "DAN" ]

o1 = new stzListOfStrings([ "TOM", "SAM", "DAN" ])
? o1.Lowercased()	#--> [ "tom", "sam", "dan" ]

/*---------------

pr()

o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
? @@(o1.Unicodes())
#--> [ [ 116,111,109 ],[ 115,97,109 ],[ 100,97,110 ] ]


proff()
# Executed in 0.07 second(s)

/*=============

pr()

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
002F;SOLIDUS"

? @@(
	StzStringQ(cUnicodeNames).
	SplitQRT(NL, :stzListOfStrings).
	SplitQ(";").Content()
)
#--> [
#	[ "0020", "SPACE" ], 		[ "0021", "EXCLAMATION MARK" ],
#	[ "0022", "QUOTATION MARK" ], 	[ "0023", "NUMBER SIGN" ],
#	[ "0024", "DOLLAR SIGN" ], 	[ "0025", "PERCENT SIGN" ],
#	[ "0026", "AMPERSAND" ], 	[ "0027", "APOSTROPHE" ],
#	[ "0028", "LEFT PARENTHESIS" ], [ "0029", "RIGHT PARENTHESIS" ],
#	[ "002A", "ASTERISK" ], 	[ "002B", "PLUS SIGN" ],
#	[ "002C", "COMMA" ], 		[ "002D", "HYPHEN-MINUS" ],
#	[ "002E", "FULL STOP" ], 	[ "002F", "SOLIDUS" ]
# ]
proff()
# Executed in 0.24 second(s)

/*-------------------

pr()

o1 = new stzListOfStrings([ "abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp" ])

? o1.Split(";")
#--> [
# 	[ "abc", "123", "tunis", "rgs" ],
# 	[ "jhd", "343", "gafsa", "ghj" ],
# 	[ "lki", "112", "beja" , "okp" ]
# ]

? o1.Split(";")[1]
#--> [ "abc", "123", "tunis", "rgs" ]

? o1.Split(";")[2]
#--> [ "jhd", "343", "gafsa", "ghj" ]

? o1.Split(";")[3]
#--> [ "lki", "112", "beja" , "okp" ]

? o1.NthSubstringsAfterSplittingStringsUsing(3, ";")
#--> [ "tunis", "gafsa", "beja" ]

# The same function can be expressed like this
? o1.NthSubstrings(3, :AfterSplittingStringsUsing = ";")
#--> [ "tunis", "gafsa", "beja" ]

proff()
# Executed in 0.12 second(s)

/*-------------------

pr()

o1 = new stzList([ "a", "b", "c", "d" ])

? o1.NumberOfCombinations() + NL
#--> 6

? @@( o1.Combinations() )
#--> [
#	[ "a", "b" ], [ "a", "c" ], [ "a", "d" ],
#	[ "b", "c" ], [ "b", "d" ], [ "c", "d" ]
# ]

proff()
# Executed in almost 0 second(s).

/*==============

pr()

o1 = new stzList([
	"TUNIS", "GAFSA", "SFAX", "BEJA", "GABES", "REGUEB"
])

? o1.IsUppercase() #--> _TRUE_

proff()
# Executed in 0.06 second(s).

/*------------------

pr()

o1 = new stzList([
	"tunis", "gafsa", "sfax", "beja", "gabes", "regueb"
])

? o1.IsLowercase()

proff()
# Executed in 0.06 second(s).

/*================

pr()

o1 = new stzListOfStrings([
	"Medianet", "ST2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape", "avionav",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"ISIE", "HNEC", "HAICA", "kalidia", "triciti", "maxeam", "Ring" ])

? o1.ContainsEachCS([ "IFES", "HAICA" ], _TRUE_ )
#--> _FALSE_ (because 'ifes' is lowercase)

? o1.ContainsEach([ "Ring", "keyrus" ])
#--> _TRUE_

? o1.ContainsBothCS("WHITECAPE", "MEDIANET", :CS = _FALSE_)
#--> _TRUE_

? o1.ContainsBothCS( "WHITECAPE", "Medianet", :CS = _FALSE_ )
#--> _TRUE_

? o1.ContainsBoth("Medianet", "ST2i")
#--> _TRUE_

proff()
# Executed in 0.08 second(s)

/*---------------

pr()

o1 = new stzListOfStrings([
	:tunis, :tunis, :tunis, :gatufsa, :tunis, :tunis, :gabes,
	:tunis, :tunis, :regueb, :tuta, :regueb, "Tunis"
])

? @@( o1.FindAllCS("Tunis", :CS = _FALSE_) )
#--> [ 1, 2, 3, 5, 6, 8, 9, 13 ]

proff()
# Executed in 0.04 second(s)

/*-------------

pr()

o1 = new stzList([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

? @@(o1.FindAll("tunis"))
#--> [ 6, 7, 14 ]

? @@(o1.FindAllCS("tunis", _TRUE_))
#--> [ 6, 7, 14 ]

? @@( o1.FindAllCS("tunis", :cs = _FALSE_) )
#--> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

proff()
# Executed in 0.02 second(s).

/* =================== MANAGING DUPLICATED STRINGS
*/
pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])


? o1.ContainsDuplicatedItems() + NL
#--> _TRUE_
# Executed in 0.10 second(s)

	//? o1.NumberOfDuplicatedItems()

? @@( o1.DuplicatedItems() ) + NL
#--> [ "tunis", "regueb" ]
# Executed in 0.24 second(s)

? @@SP( o1.DuplicatedItemsZ() ) + NL
# [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.37 second(s)

? @@( o1.FindDuplicatedItems() ) + NL
#--> [ 2, 3, 5, 6, 8, 9, 12 ]
# Executed in 0.41 second(s)

//? o1.ContainsDuplicatedItem("tunis")
//? o1.ContainsDuplicationsOf("tunis")
#--> _TRUE_
# Executed in 0.10 second(s)

? @@( o1.FindDuplicationsOf("tunis") ) + NL
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

	//? @@( o1.FindDuplicatedItem("tunis") )
	#--> [ 1, 2, 3, 5, 6, 8, 9 ]
	# Executed in 0.12 second(s)

proff()
# Executed in 0.01 second(s).

/*-----------------

pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.FindDuplicationsOfItemCS("tunis", :CS = _FALSE_) )
#--> [ 2, 3, 5, 6, 8, 9, 13 ]
# Executed in 0.12 second(s)

? o1.ContainsDuplicatedString("regueb") #--> _TRUE_
#--> _TRUE_
# Executed in 0.06 second(s)

? o1.FindDuplicatedString("regueb")
#--> [10, 12]
# Executed in 0.07 second(s)

#--

? o1.NumberOfDuplicatedStrings()
#--> 2
# Executed in 0.25 second(s)

? o1.DuplicatedStrings()
#--> [ "tunis", "regueb" ]
# Executed in 0.24 second(s)

proff()

#----------------

pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.NumberOfDuplicatesOfString("tunis")
#--> 6
#--> Executed in 0.17 second(s)

? o1.NumberOfDuplicatesOfString("regueb")
#--> 1
# Executed in 0.10 second(s)

? o1.StringIsDuplicatedNTimes("tunis", 6)	#--> _TRUE_
? o1.StringIsDuplicatedNTimes("regueb", 1)	#--> _TRUE_

? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]

? @@( o1.FindDuplicatesOfString("regueb") )
#--> [ 12 ]

? @@( o1.FindDuplicatesXT() )
#--> [ "tunis" = [ 2, 3, 5, 6, 8, 9 ], [ "regueb" = [ 12 ] ]


proff()

/*===============


pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]
# Executed in 0.11 second(s)

? @@( o1.FindDuplicatesOfStringCS("tunis", :CS = _FALSE_) )
#--> [ 2, 3, 5, 6, 8, 9, 13 ]
# Executed in 0.12 second(s)

proff()
# Executed in 0.20 second(s)

/*===============

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.NumberOfDuplicates()
#--> 7
# Executed in 0.24 second(s)

? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]
# Executed in 0.37 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.37 second(s)

#-- Same thing but with case sensitivity
? NL + "--" + NL


? o1.NumberOfDuplicatesCS(_FALSE_)
#--> 8
# Executed in 0.67 second(s)

? @@( o1.FindDuplicatesCS(_FALSE_) )
#--> [ 2, 3, 5, 6, 8, 9, 12, 13 ]
# Executed in 0.47 second(s)

? @@( o1.DuplicatesCSZ(_FALSE_) ) # Or DuplicatesAndTheirPositions()
#--> [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9, 13 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.47 second(s)

proff()
# Executed in 2.46 second(s)

/*===============

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ "tunis", "gatfsa", "gabes", "regueb", "sfax", "Tunis" ]

proff()
# Executed in 0.03 second(s): so fast because it uses Qt

/*--------------

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

o1.RemoveDuplicatesCS(_FALSE_)
? @@(o1.Content())
#--> [ "tunis", "gatfsa", "gabes", "regueb", "sfax" ]

proff()
# Executed in 0.49 second(s): takes a while because it's not based on Qt

/*===============

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.DuplicatedStringsCS(_FALSE_) )
#--> [ "tunis", "regueb" ]
# Executed in 0.38 second(s)

? @@( o1.FindDuplicatedStringsCS(_FALSE_) )
#--> [ 1, 2, 3, 5, 6, 8, 9, 13, 10, 12 ]
# Executed in 0.50 second(s)

? @@( o1.DuplicatedStringsCSZ(_FALSE_) )
#--> [
#	[ "tunis",  [ 1, 2, 3, 5, 6, 8, 9, 13 ] ],
#	[ "regueb", [ 10, 12 ] ]
# ]
# Executed in 0.52 second(s)

#--
? NL + "--" + NL

? @@( o1.DuplicatedStringsCS(_TRUE_) )
#--> [ "tunis" ]
# Executed in 0.27 second(s)

? @@( o1.FindDuplicatedStringsCS(_TRUE_) )
#--> [ 1, 2, 3, 5, 6, 8, 9 ]
# Executed in 0.35 second(s)

? @@( o1.DuplicatedStringsCSZ(_TRUE_) )
#--> [ [ "tunis", [ 1, 2, 3, 5, 6, 8, 9 ] ] ]
# Executed in 0.35 second(s)

proff()
# Executed in 2.22 second(s)

/*--------------

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.DuplicatedStringsCS(_FALSE_) )
#--> [ "tunis", "regueb" ]
# Executed in 0.36 second(s)

o1.RemoveDuplicatedStringsCS(_FALSE_)
? @@( o1.Content() )
#--> [ "gatfsa", "gabes", "sfax" ]

proff()
# Executed in 0.87 second(s)

/*=========

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? o1.ContainsNonDuplicatedStrings()
#--> _TRUE_
# Executed in 0.26 second(s)

? @@( o1.NumberOfNonDuplicatedStrings() )
#--> 6
# Executed in 0.34 second(s)

? @@( o1.FindNonDuplicatedStrings() )
#--> [ 4, 7, 10, 11, 12, 13 ]
#--> Executed in 0.34 second(s)

? @@( o1.NonDuplicatedStrings() )
#--> [ "gatfsa", "gabes", "Regueb", "sfax", "regueb", "Tunis" ]
# Executed in 0.34 second(s)

? @@( o1.NonDuplicatedStringsZ() ) # Or NonDuplicatedStringsAndTheirPositions()
#--> [
#	[ "gatfsa", 4  ],
#	[ "gabes",  7  ],
#	[ "Regueb", 10 ],
#	[ "sfax",   11 ],
#	[ "regueb", 12 ],
#	[ "Tunis",  13 ]
# ]
# Executed in 0.36 second(s)

proff()
# Executed in 1.59 second(s)

/*-------------- #Note stzList has a more performant implementation (see example after this)

pr()

o1 = new stzListOfStrings([ "one", "ONE", "two", "TWO" ])

? o1.ContainsNonDuplicatedStringsCS(_TRUE_)
#--> _TRUE_: In fact all strings are different when case sensitivity applies

? o1.ContainsNonDuplicatedStringsCS(_FALSE_)
#--> _FALSE_: In fact, "one" equals "ONE" and "two" equals "TWO" when case sensitiviy
# is applied. So, the list contains duplicated strings and the result is _FALSE_.

? @@( o1.NumberOfNonDuplicatedStringsCS(_TRUE_) )
#--> 4

? @@( o1.FindNonDuplicatedStringsCS(_TRUE_) )
#--> [ 1, 2, 3, 4 ]

? @@( o1.NonDuplicatedStringsCS(_TRUE_) )
#--> [ "one", "ONE", "two", "TWO" ]

? @@( o1.NonDuplicatedStringsCSZ(_TRUE_) ) # Or NonDuplicatedStringsAndTheirPositionsCS()
#--> [
#	[ "one", 1 ],
#	[ "ONE", 2 ],
#	[ "two", 3 ],
#	[ "TWO", 4 ]
# ]

proff()
# Executed in 0.07 second(s)

/*--------------

pr()

o1 = new stzList([ "one", "ONE", "two", "TWO" ])

? o1.ContainsNonDuplicatedItemsCS(_TRUE_)
#--> _TRUE_: In fact all strings are different when case sensitivity applies

? o1.ContainsNonDuplicatedItemsCS(_FALSE_)
#--> _FALSE_: In fact, "one" equals "ONE" and "two" equals "TWO" when case sensitiviy
# is applied. So, the list contains duplicated strings and the result is _FALSE_.

? @@( o1.NumberOfNonDuplicatedItemsCS(_TRUE_) )
#--> 4

? @@( o1.FindNonDuplicatedItemsCS(_TRUE_) )
#--> [ 1, 2, 3, 4 ]

? @@( o1.NonDuplicatedItemsCS(_TRUE_) )
#--> [ "one", "ONE", "two", "TWO" ]

? @@( o1.NonDuplicatedItemsCSZ(_TRUE_) ) # Or NonDuplicatedStringsAndTheirPositionsCS()
#--> [
#	[ "one", 1 ],
#	[ "ONE", 2 ],
#	[ "two", 3 ],
#	[ "TWO", 4 ]
# ]

proff()
# Executed in 0.02 second(s)

/*=========

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

//? @@( o1.DuplicatedStringsCS(_TRUE_) )
#--> [ "tunis" ]
# Executed in 0.26 second(s)

o1.RemoveDuplicatedStringsCS(_TRUE_)
? @@( o1.Content() )
#--> [ "gatfsa", "gabes", "Regueb", "sfax", "regueb", "Tunis" ]
# Executed in 0.35 second(s)

proff()
# Executed in 0.58 second(s)

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
? o1.FindNthOccurrenceCS(2, "tunis", _TRUE_) #--> 5

? @@(o1.StringsContainingCS("tu", _TRUE_)) # Same as o1.FilterCS("tu", _TRUE_)
#--> [ "gatufsa","tunis","tunis","tuta" ]

? @@( o1.UniqueStringsContainingCS("tu", _TRUE_) )
#--> [ "gatufsa", "tunis", "tuta" ]

/*--------------

? StzStringQ("CAIRO").BoxedXT([ :EachChar = _TRUE_, :AllCorners = :Round ])

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

o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])

? o1.BoxXT([ :AllCorners = :Round, :EachChar = _TRUE_ ])
/*
? o1.BoxedXT([ :AllCorners = :Round, :EachChar = _FALSE_, :Width = 10, :TextAdjustedTo = :Right ])
? o1.VizFindBoxed("I")

? o1.boxedXT([ :line = :dashed,
		:corners = [ :round, :rectangular, :round, :round ]
	    ])


/* ---------------------

o1 = new stzListOfStrings([ "bingo", "tongo", "congo" ])
o1.ReplaceStringAtPosition(3,"fongo")
? @@( o1.Content() )
#--> [ "bingo", "tongo", "fongo" ]

/*----------------------

o1 = new stzListOfStrings(["12-120-0", "100-10-76", "87-458-20"])
o1.ReplaceSubString("-", :With = "_")
? o1.Content()
#--> [ "12_120_0", "100_10_76", "87_458_20" ]

/*====================

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? @@( o1.FindSubString("aa") )
#--> [ [ 1, [ 1 ] ], [ 2, [ 4 ] ], [ 3, [ 1, 5 ] ] ]

/*-------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindSubString("name") )
#--> [
#	[ 1, [ 13 ]    ],
#	[ 3, [ 6, 18 ] ]
#    ]

? @@( o1.FindNthOccurrenceOfSubString(3, "name") )
#--> [ 2, 18 ]

/*-------------------

o1 = new stzListOfStrings([
	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindSubStringsCS([ "name", "mabrooka" ], :CaseSensitive = _FALSE_) )
#-->
# [
#	[ [ 1, [ 13 ] ], [ 3, [ 6, 18 ] ] ],	#>>> "name" is found here
#	[ [ 2, [ 1 ] ], [ 6, [ 1 ] ] ]		#>>> "mabrooka" is found here
# ]

/*=======================

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.NumberOfOccurrence("aabc") 		 #--> 1

/*===================

o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])

# How many occurrence are there of the substring "ring" in the list?
? o1.NumberOfOccurrenceOfSubString("ring") #--> 3

# Show these 3 in detail, string by string:
? @@( o1.NumberOfOccurrenceOfSubStringXT("ring") )
#--> [ [ 1, 1 ], [ 3, 2 ] ]

/*--------------------

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.NumberOfOccurrenceOfSubString("aa") #--> 4
? @@(o1.NumberOfOccurrenceOfSubStringXT("aa"))
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 2 ] ]

/*===================

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? @@( o1.NumberOfOccurrenceOfManySubstrings(["a","f","x"]) ) 
#--> [ 9, 0, 2 ]
? @@( o1.NumberOfOccurrenceOfManySubstringsXT(["a","f","x"]) ) 
#--> [
#	[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ] ], #>>> There are 2"a"s in string 1, 3 in string 2, and 4 in string 
#	[ ],				  #>>> "f" does'nt exist!
#	[ [ 2, 2 ] ]			  #>>> There is 2 "x"s in string number 2
#    ]

/*====================

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
? o1.ContainsSubStringInEachString("aa") #--> _TRUE_

? @@( o1.UniqueChars() )	#TODO // fix performance lag!
#--> [ "a", "b", "c", "x", "z", "t", "v" ]


? @@( o1.CommonChars() )
#--> ["a", "c"]

