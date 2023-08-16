load "stzlib.ring"



/*========= SWAPPING TWO SECTIONS

pron()

o1 = new stzString(">>>word<<<")
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? o1.Content()
#--> <<<word>>>

proff()
# Executed in 0.06 second(s)

/*----------
*/
pron()

o1 = new stzList([ ">", ">", ">", "w", "o", "r", "d", "<", "<", "<" ])
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? @@( o1.Content() )
#--> [ "<", "<", "<", "w", "o", "r", "d", ">", ">", ">" ]

proff()
# Executed in 0.06 second(s)

/*=========

pron()

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
? o1.NumberOfSectionsBetween("word", "<<", ">>")
#--> 3
	
? @@( o1.FindSubStringBetweenAsSections("word", "<<", ">>") )
#--> [ [11, 14], [28, 31], [41, 44] ]
	
? @@( o1.FindNthBetweenAsSection(2, "word", "<<", ">>") )
#--> [28, 31]
	
? @@( o1.FindFirstBetweenAsSection("word", "<<", ">>") )
#--> [11, 14]
	
? @@( o1.FindLastBetweenAsSection("word", "<<", ">>") )
#--> [41, 44]

proff()
# Executed in 0.11 second(s)

/*---------

pron()

o1 = new stzString("123 ABC 901 DEF")
o1.ReplaceSections([ [1, 3], [9, 11] ], "***")
? o1.Content()
#--> *** ABC *** DEF

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 123 DEF")

o1.ReplaceSection( 11, 13, :With@ = ' Q("*").RepeatedNTimes( Q(@Section).Size() ) ' )
? o1.Content()
#--> 12345 ABC *** DEF

o1.ReplaceSection( 1, 5, :With@ = ' Q("*").RepeatedNTimes( Q(@Section).Size() ) ' )
? o1.Content()
#--> ***** ABC *** DEF

proff()
# Executed in 0.36 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 1234 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 14] ],

	:With = '***'
)

? o1.Content()
#--> *** ABC *** DEF

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzString("12345 ABC 123 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 13] ],

	:With@ = '{
		Q("*").RepeatedNTimes( Q(@Section).Size() )
	}'
)

? o1.Content()

#--> *** ABC *** DEF

proff()
# Executed in 0.22 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.FirstItems()
#--> [ 4, 3, 8 ]

? o1.SecondItems()
#--> [ 7, 1, 9 ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [9, 8] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 9 ] ]

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@( o1.Content() )
#--> [ [ 9, 8 ], [ 7, 4 ], [ 3, 1 ] ]

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.IsSortedInAscending()
#--> FALSE

o1 = new stzListOfPairs([ [1,3], [4, 7], [8, 9] ])
? o1.IsSortedInAscending()
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])

? o1.IsSortedInDescending()
#--> FALSE

o1 = new stzListOfPairs([ [9,8], [7,4], [3,1] ])
? o1.IsSortedInDescending()
#--> TRUE

proff()

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.FindPair([3, 1])
#--> 2

proff()

/*======================

pron()

o1 = new stzList("A":"J")

? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ [ "C", "D", "E" ], [ "G", "H" ] ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "F" ], [ "I", "J" ] ]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ "A", "B" ], [ "C", "D", "E" ], [ "F" ], [ "G", "H" ], [ "I", "J" ] ]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.13 second(s)

/*----------------

pron()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1.Sections( [ [3,5], [7,8] ] ) )
#--> [ "CDE", "GH" ]

? @@( o1.AntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "F", "IJ"]

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ "AB", "CDE", "F", "GH", "IJ"]

? @@( o1.FindAsSectionsAndAntiSections( :Of = [ [3,5], [7,8] ] ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.15 second(s)

/*=================

pron()

? @@( SectionToRange([3, 4]) )
#--> [3, 2]

? @@( RangeToSection([3, 2]) )
#--> [3, 4]

? @@( SectionsToRanges([ [3, 4], [8, 10] ]) )
#--> [ [3, 2], [8, 3] ]

? @@( RangesToSections([ [3, 2], [8, 3] ]) )
#--> [ [3, 4], [8, 10] ]

proff()
# Executed in 0.03 second(s)

/*=================

pron()

o1 = new stzList([ [ "ONE", "TWO" ], [ "THREE", "FOUR" ], [ "FIVE", "SIX" ] ])
? o1.IsListOfLists()
#--> TRUE

? o1.IsListOfPairs()
#--> TRUE

? o1.IsListOfPairsOfStrings()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList([ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ])
? o1.IsListOfLists()
#--> TRUE

? o1.IsListOfPairs()
#--> TRUE

? o1.IsListOfPairsOfNumbers()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*=================

pron()

o1 = new stzString("AB♥CD♥EF♥GH")

? @@( o1.Split("♥") )
#--> [ "AA", "CD", "EF", "GH" ]

? @@( o1.SplitAfter("♥") )
#--> [ "AB♥", "CD♥", "EF♥", "GH" ]

? @@( o1.SplitBefore("♥") )
#--> [ "AB", "♥CD", "♥EF", "♥GH" ]

proff()
# Executed in 0.07 second(s)

/*----------------

pron()

o1 = new stzString("AB♥♥C♥♥D♥♥E")

? o1.SplitToPartsOfNChars(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥", "E" ]

? o1.SplitToPartsOfExactlyNChars(2) # OR SplitToPartsOfNCHarsXT(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

proff()
# Executed in 0.06 second(s)

/*=================

pron()

o1 = new stzString("ABCDE")
? @@( o1.SubStrings() )
#--> [
#	"A", "AB", "ABC", "ABCD", "ABCDE", "B",
#	"BC", "BCD", "BCDE", "C", "CD", "CDE",
#	"D", "DE", "E"
# ]

proff()
# Executed in 0.17 second(s)

/*================ WORKING WITH BOUNDS OF THE STRING

pron()

o1 = new stzString("<<<word>>>")

? o1.ContainsLeadingChars()
#--> TRUE

? o1.NumberOfLeadingChars()
#--> 3

? o1.LeadingCharsAsString() + NL
#--> "<<<"

#--

? o1.ContainsTrailingChars()
#--> TRUE

? o1.NumberOfTrailingChars()
#--> 3

? o1.TrailingCharsAsString()
#--> ">>>"

proff()
# Executed in 0.12 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.FindBounds() )
#--> [ 1, 8 ]

? @@( o1.FindBoundsAsSections() )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()

/*------------------
*/
pron()

o1 = new stzString("<<<word>>>")

? o1.LeftBound()
#--> 

? @@( o1.FindLeftBound() )
#--> 

? @@( o1.FindLeftBoundAsSection() )
#--> 

? @@( o1.LeftBoundZ() )
#--> 

? @@( o1.LeftBoundZZ() )
#--> 

? @@( o1.FindRightAndLeftBounds() )

proff()
# Executed in 0.13 second(s)

/*================ WORKING WITH BOUNDS INSIDE THE STRING

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")
? @@( o1.FindSubStringBoundsAsSections("word") )
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindSubStringBounds("word") )
#--> [ 1, 8, 13, 20, 28, 35 ]

proff()

/*------------------

*/
pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Bounds of the entire string

? @@( o1.FindStringBoundsAsSections() )
#--> [ [ 1, 0 ], [ 38, 37 ] ]

//? @@( o1.FindBoundsAsSections
# Bounds of a particular substring inside the string

? @@( o1.FindSubStringBoundsAsSections(:Of = "word") ) + NL
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindFirstBoundsAsSections(:Of = "word") ) + NL
#--> [ [ 1, 3 ], [ 13, 15 ], [ 28, 30 ] ]

? @@( o1.FindFirstBounds(:Of = "word") ) + NL
#--> [ 1, 13, 28 ]

proff()

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

? @@( o1.FindSubStringSecondBoundsAsSections(:of = "word") )

? @@( o1.FindSubStringSecondBounds(:of = "word") )

proff()

/*================

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Finding the bounds of "word" up to 3 chars

? @@( o1.FindSubStringBoundsUpToNCharsAsSections(3, "word") )
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

	o1.FindBoundsAsSectionsXT( :Of = "word", :UpToNChars = 3 )

? @@( o1.FindSubStringBoundsUpToNChars(3, "word") )
#--> [ 1, 8, 13, 20, 28, 35 ]

	o1.FindBoundsXT( :Of = "word", :UpToNChars = 3 )

# Finding the first bounds of "word" up to 3 chars

? @@( o1.FindSubStringFirstBoundsUpToNCharsAsSections(3, "word") )
#--> [ [ 1, 3 ], [ 13, 15 ], [ 28, 30 ] ]

	o1.FindFirstBoundsAsSectionsXT( :Of = :Word, :UpToNChars = 3)

? @@( o1.FindSubStringFirstBoundsUpToNChars(3, "word") )
#--> [ 1, 13, 28 ]

	o1.FindFirstBoundsXT( :Of = :Word, :UpToNChars = 3)

# Finding the seconds bounds of "word" up to 3 chars

? @@( o1.FindSubStringSecondBoundsUpToNCharsAsSections(3, "word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

	o1.FindSecondBoundsAsSectionsXT( :Of = :Word, :UpToNChars = 3)

? @@( o1.FindSubStringSecondBoundsUpToNChars(3, "word") )
#--> [ 8, 20, 35 ]

	o1.FindSecondBoundsXT( :Of = :Word, :UpToNChars = 3)

# Finding the left bounds of "word" up to 3 chars

? @@( o1.FindSubStringLeftBoundsUpToNCharsAsSections(3, "word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

	o1.FindLeftBoundsAsSectionsXT( :Of = Word, :UpToNChars = 3 )

? @@( o1.FindSubStringLeftBoundsUpToNChars(3, "word") )
#--> [ 1, 13, 28 ]

	o1.FindLeftBoundsXT( :Of = Word, :UpToNChars = 3 )

# Finding the right bounds of "word" up to 3 chars

? @@( o1.FindSubStringRightBoundsUpToNCharsAsSections(3, "word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

	o1.FindRightBoundsAsSectionsXT( :Of = Word, :UpToNChars = 3 )

? @@( o1.FindSubStringRightBoundsUpToNChars(3, "word") )
#--> [ 1, 13, 28 ]

	o1.FindRightBoundsXT( :Of = Word, :UpToNChars = 3 )

proff()
# Executed in 0.34 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Getting the bounds of the substring "word" up to 3 chars

? @@( o1.SubStringBoundsUpToNChars(3, "word") )
#--> [ "<<<", ">>>", "(((", ")))", "{{{", "}}}" ]

	o1.BoundsXT( :Of = "word", :UpToNChars = 3 )

# Getting the first bounds of "word" up to 3 chars

? @@( o1.SubStringFirstBoundsUpToNChars(3, "word") )
#--> [ "<<<", "(((", "{{{" ]

	o1.FirstBoundsXT( :Of = "word", :UpToNChars = 3 )

# Getting the seconds bounds of "word" up to 3 chars

? @@( o1.SubStringSecondBoundsUpToNChars(3, "word") )
#--> [ ">>>", ")))", "}}}" ]

	o1.SecondBoundsXT( :Of = "word", :UpToNChars = 3 )

# Getting the left bounds of "word" up to 3 chars

? @@( o1.SubStringLeftBoundsUpToNChars(3, "word") )
#--> [ "<<<", "(((", "{{{" ]

	o1.LeftBoundsXT( :Of = "word", :UpToNChars = 3 )

# Getting the right bounds of "word" up to 3 chars

? @@( o1.SubStringRightBoundsUpToNChars(3, "word") )
#--> [ ">>>", ")))", "}}}" ]

	o1.EightBoundsXT( :Of = "word", :UpToNChars = 3 )

proff()
# Executed in 0.20 second(s)

/*=================

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

//? o1.BoundsOfXT( "word", :UpToNChars = 2 )

proff()

/*----------------

o1 = new stzString("<<word>>> and {{word}}}")
? o1.BoundsOf( "word", :UpToNChars = [ 2, 3 ] )
#--> [ [ "<<", ">>" ], [ "{{", "}}" ] ]

/*----------------

o1 = new stzString("<<word>>> and  {word}}")
? o1.BoundsOf( "word", :UpToNChars = [ [ 2, 3 ], [ 1, 2 ] ] )
#--> [ [ "<<", ">>>" ], [ "{", "}}" ] ]

/*----------------

o1 = new stzList([ "<<", ">>" ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> TRUE

/*----------------

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__ @word@")
#--> TRUE

/*----------------

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> FALSE

/*----------------

? Q("_").IsBoundOf( "world", :In = "hello _world_ and <world>" ) #--> TRUE
? Q("<").IsBoundOf( "world", :In = "hello _world_ and <world>" ) #--> FALSE
? Q([ "<", ">" ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" ) #--> TRUE
? Q([ ["<",">"], ["_","_"] ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" ) #--> TRUE

/*----------------

o1 = new stzString("aa♥♥aaa bb♥♥bbb")

? o1.SubStringIsBoundedBy("♥♥", "aa") #--> TRUE
? o1.SubStringIsBoundedBy("♥♥", "bb") #--> TRUE

? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] ) #--> TRUE
? o1.SubStringIsBoundedBy("♥♥", [ [ "aa","aaa" ], ["bb","bbb"] ]) #--> TRUE

/*================= POSSIBLE SUBSTRINGS IN THE STRING

o1 = Q("ABAAC")
? @@( o1.SubStrings() )
#--> [
# 	"A", "B", "C", "B", "B", "D", "A",
# 	"AB", "CB", "BD", "ABC", "BBD",
# 	"ABCB", "ABCBB", "ABCBBD", "ABCBBDA"
# ]

? @@( o1.SubStringsAndTheirPositions() ) # TODO: Optimise performance!
#--> [
# 	[ "A", [ 1, 3, 4 ] ], [ "B", [ 2 ] ], [ "C", [ 5 ] ],
# 	[ "AB", [ 1 ] ], [ "AA", [ 3 ] ], [ "ABA", [ 1 ] ],
# 	[ "ABAA", [ 1 ] ], [ "ABAAC", [ 1 ] ] ]

STOP()

/*=================

? @@( Q([ "abc", 120, "cdef", 14, "opjn", 988 ]).ToString() )

/*-->
"abc
120
cdef
14
opjn
988"

*/

/*----------------

pron()

? @@( Q(["abc","cdef","opjn"]).ToString() ) # Q() creates a stzList object
/*-->
abc
cdef
opjn
*/

# Same thing can be done wit stzListOfStrings

? @@( QQ(["abc","cdef","opjn"]).ToString() ) // QQ() generates a stzListOfStrings object
/*-->
abc
cdef
opjn
*/

proff()
# Executed in 0.05 second(s)


/*=================

o1 = new stzListOfStrings(["A", "AA", "B", "BB", "C", "CC", "CC" ])
? o1.StringsW('len(@string) = 2')
#--> [ "AA", "BB", "CC", "CC" ])

? o1.UniqueStringsW('len(@string) = 2')
#--> [ "AA", "BB", "CC" ]

/*----------------

o1 = new stzListOfStrings([
	"A", "v", "♥", "c",
	"Av", "♥♥", "c♥", "Av♥",
	"♥c♥",
	"Av♥♥", "Av♥♥c",
	"Av♥♥c♥",
	"Av♥♥c♥♥"
])

? o1.StringsW(' Q(@String).NumberOfChars() = 2 ')
#--> [ "Av", "♥♥", "c♥" ]

? o1.StringsW('
	Q(@String).BeginsWith("A") and Q(@String).NumberOfChars() > 4
')
#--> [ "Av♥♥c", "Av♥♥c♥", "Av♥♥c♥♥" ]

/*================

o1 = new stzString("Av♥♥c♥♥")
? o1.FindAll("♥♥") #--> [ 3, 6 ]
? o1.FindSubStringsW('{ @SubString = "♥♥" }') #--> [ 3, 6 ]

/*===============

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBetween("<<", ">>")
#--> [ "word1", "word2" ]

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? o1.SubstringsBetween('"', '"')
#--> [ "    value ", " 12   " ]

STOP()

/*----------------

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? @@( o1.SubStringsBetween('"','"') )
#--> [ " value ", " 12 " ]

? @@( o1.SubStringsBetweenIB('"','"') )
#--> [ [ " value ", [ 16, 25 ] ], [ " 12 ", [ 42, 47 ] ] ]

? @@( o1.FindSubStringsBetween('"','"') )
#--> [ 16, 42 ]

? @@( o1.FindSubStringsBetweenIB('"','"') )
#--> [ [ 16, " value " ], [ 42, " 12 " ] ]

STOP()

/*================

o1 = new stzString("blabla bla <<word>> bla bla <<word>>")
? o1.FindSubStringAsSections("word", "<<", ">>")
#--> [ [14, 17], [31, 34] ]

/*----------------

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetween("<<", ">>")
#--> [ 14, 32 ]

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetweenAsSections("<<", ">>")
#--> [ [14, 18], [32, 36] ]

/*----------------

o1 = new stzString(' this code:   txt1  = "    withspaces    "   and txt2="nospaces"  ')
aSections = o1.FindAnyBetweenAsSections('"', '"')
#--> [ [24 ,41], [56, 63] ]

aAntiSections = o1.FindAntiSections(aSections)
#--> [ [1, 23], [42, 55], [64, 66] ]

? o1.Sections(aAntiSections)
#--> [
#	' this code:   txt1  = "',
#	'"   and txt2="',
#	'"  '
#    ]

/*----------------

o1 = new stzString(' this code:   txt1  = "    withspaces    "   and txt2="nospaces"  ')
aBetween = o1.FindAnyBetweenAsSections('"', '"')
#--> [ [24 ,41], [56, 63] ]

? o1.Sections( aBetween )
#--> [ '    withspaces    ', 'nospaces' ]

? o1.SectionsXT( aBetween )
#--> [
#	[ '    withspaces    ', [24 ,41] ],
#	[ ''nospaces', [56, 63] ]
#    ]

? o1.AntiSections( aBetween )
#--> [
#	' this code:   txt1  = "',
#	'"   and txt2="',
#	'"  '
#    ]

? o1.AntiSectionsXT( aBetween )
#--> [
#	[ ' this code:   txt1  = "', [1, 23] ],
#	[ '"   and txt2="', [42, 55] ],
#	[ '"  ', [64, 66] ]
#    ]

? o1.SectionsAndAntiSections( aBetween )
#--> [
#	' this code:   txt1  = "',
#	'    withspaces    ',
#	'"   and txt2="',
#	'nospaces',
#	'"  '
#    ]

? o1.SectionsAndAntiSectionsXT( aBetween )
#--> [
#	[ ' this code:   txt1  = "', [1, 23] ],
#	[ '    withspaces    ', [24, 41] ],
#	[ '"   and txt2="', [42, 55] ],
#	[ 'nospaces', [56, 63] ],
#	[ '"  ', [64, 66] ]
#    ]

/*---------------

? Q(" this code:   txt1  = ").Simplified()
#--> "this code: txt1 ="

/*---------------

o1 = new stzString(' this code:   txt1  = "<    withspaces    >"   and txt2="<nospaces>"  ')
aAntiSections = o1.FindAntiSections( o1.FindAnyBetweenAsSections('"','"') )

o1.ReplaceSections(aAntiSections, :With = '|***|')
? o1.Content()
#--> '|***|<    withspaces    >|***|<nospaces>|***|'

/*----------------

o1 = new stzString(' this code    :   txt1  = "<    leave spaces    >"   and this    code:  txt2 =   "< leave spaces >"  ')
aAntiSections = o1.FindAntiSections( o1.FindAnyBetweenAsSections('"','"') )

o1.ReplaceSections(aAntiSections, :With@ = ' Q(@Section).Simplified() ')
? o1.Content()
#--> this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"

/*==============

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***THREE")	#--> TRUE
? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***THREE")	#--> FALSE

/*----------------

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])	#--> TRUE
? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])	#--> FALSE

/*----------------

? Q("*").OccursNTimes(3, :In = "a*b*c*d") #--> TRUE
? Q("*").OccursNTimes(3, :In = [ "a", "*", "b", "*", "c", "*", "d" ]) #--> TRUE

/*----------------

? Q("*").OccursForTheFirstTime( :In = "a*b*c*d", :AtPosition = 2 ) #--> TRUE
? Q("*").OccursForTheLastTime( :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 ) #--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 ) #--> TRUE
? Q("*").OccursForTheNthTime( 2, :In = "a*b*c*d", :AtPosition = 4 ) #--> TRUE
? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 ) #--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 2 ) #--> TRUE
? Q("*").OccursForTheNthTime( 2, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 4 ) #--> TRUE
? Q("*").OccursForTheNthTime( 3, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 ) #--> TRUE

/*----------------

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 1 )	#--> TRUE
? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 2 )	#--> TRUE
? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 3 )	#--> FALSE
? Q("bag").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 4 )	#--> TRUE
? Q("hat").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 5 )	#--> TRUE
? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 6 )	#--> FALSE

/*----------------

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q(aShoppingCart).FindW('{
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )
}')
#--> [ 1, 2, 4, 5 ]

/*----------------

  load "stzlib.ring"

  # Suppose a customer added all these items to his shopping cart in an
  # ecommerce website:

  aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

  # You are asked, as a programmer of the website, to extract the number of times
  # each item has been added...

  # In Softanza, using the Yielder Metaphor, you can solve it naturally like this:

  ? Q(aShoppingCart).YieldW('
	[ @item, This.NumberOfOccurrence( :Of = @item ) ]',

	:Where = '
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )'
  )

  #--> [ [ "Shirt", 2 ], [ "shoes", 2 ], [ "bag", 1 ], [ "hat", 1 ] ]

/*=========

? ComputableForm('len    var1 = "    value "  and var2 =  " 12   " ')
#--> 'len var1 = "    value " and var2 = " 12   "'

? ComputableForm("len    var1 = '    value '  and var2 =  ' 12   ' ")
#--> 'len var1 = "    value " and var2 = " 12   "'

/*================= CHECK PERFORMANCE

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.FindSubStringsW('{
	Q(@SubString).NumberOfChars() = 2	
}') )
#--> [
#	[ "Av", [ 1 ] 	],
#	[ "♥♥", [ 3, 6] ],
#	[ "c♥", [ 5 ] 	],
#	[ "v♥", [ 2 ] 	],
#	[ "♥c", [ 4 ] 	]
# ]

/*------------- ERROR

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.FindSubStringsW('{
	Q(@SubString).NumberOfChars() = 2 and NOT Q(@SubString).Contains("♥")
}') )

#--> ERROR
# Line 11126 Error (R3) : Calling Function without definition !: 2andnotq 
# In method findallitemsw() in file D:\GitHub\SoftanzaLib\libraries\softanzalib\stzList.ring

# The problem is that the evaluated code has spaces removed, like this:
# bOk = ( Q( @item ).NumberOfChars()=2andNOTQ( @item ).Contains("♥") )

/*=================

o1 = new stzString("I love ")
o1.AddSubString("Ring")
? o1.Content() #--> I love Ring

#-----------------

o1 = new stzString("Ring")
o1.ExtendToNChars(10, :Using = ".")
? o1.Content() #--> "Ring.........."

/*=================

? Q("-♥-").IsBoundedBy("-") #--> TRUE
? Q("♥").IsBoundedByIB("-", :In = "... -♥- ...") # ERROR

/*---------------- ERROR

o1 = new stzString("Av♥♥c♥♥")

? o1.FindW('{
	Q(@SubString).NumberOfChars() = 2 and
	Q(@SubString).IsBoundedBy@_( "Q(@Char).IsLowercase()", "_" ) 

}')
/*

/*----------------

? StzCharQ(1049).Content() #--> Й

? @@( StzListOfCharsQ(1000 : 1009).Content() ) + NL
#--> [ "Ϩ", "ϩ", "Ϫ", "ϫ", "Ϭ", "ϭ", "Ϯ", "ϯ", "ϰ", "ϱ" ]

Q("℺℻ℚ") {

	? Unicodes() 	#--> [ 8506, 8507, 8474 ]
	? UnicodesXT() 	// Or alternatively UnicodesAndChars()
	#--> [ [ 8506, "℺" ], [ 8507, "℻" ], [ 8474, "ℚ" ] ]

	? CharsAndUnicodes()
	#--> [ [ "℺", 8506 ], [ "℻", 8507 ], [ "ℚ", 8474 ] ]

	? CharsNames()
	#--> [ "ROTATED CAPITAL Q", "FACSIMILE SIGN", "DOUBLE-STRUCK CAPITAL Q" ]

}

? @@( Q("℺℻ℚ").Yield('[ @char, Q(@char).Unicode(), Q(@char).CharName() ]') )
#--> [
# 	[ "℺", 8506, "ROTATED CAPITAL Q" ],
# 	[ "℻", 8507, "FACSIMILE SIGN" ],
# 	[ "ℚ", 8474, "DOUBLE-STRUCK CAPITAL Q" ]
#    ]

/*==============

# What are the unique letters in this sentence?
# "sun is hot but fun"

# To solve it, you can usz stzString and say:

? @@( Q("sun is hot but fun").RemoveSpacesQ().UniqueChars() )
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# Or you can use stzList and stzListOfStrings and say:

? @@( Q([ "sun", "is", "hot", "but", "fun" ]).
	YieldQR('{ Q(@String).Chars() }', :stzListOfLists).
	MergeQ().UniqueItems()
)
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# The solutions above uses "strings" and "chars" concepts which both
# belong to the stzString domain. But if you want to solve it in
# a higher semantic level, you can rely on "text" and "letter" concepts
# from the stzText domain:

? TQ("sun is hot but fun").UniqueLetters()
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]
# Which turns out to be more natural, isn't it?

/*----------------

? len("طيبة") #--> 8
? StzStringQ("طيبة").NumberOfChars() #--> 4
? StzStringQ("طيبة").NumberOfBytes() #--> 8

/*----------------

o1 = Q("TAYOUBAAOOAA")
? o1.LastAndFirstChars() #--> [ "A", "T" ]

/*----------------

o1 = new stzList([ "A", "B", "♥", "♥", "C", "♥", "♥", "D", "♥","♥" ])
? o1.FindW('{ @CurrentItem = @NextItem }')	#--> [ 3, 6, 9 ]

? o1.FindFirstW(' @CurrentItem = @NextItem ')	#--> 3
? o1.FindLastW(' @CurrentItem = @NextItem ')	#--> 9
? o1.FindNthW(2, ' @CurrentItem = @NextItem ')	#--> 6

/*---------------- TODO: FIX ERROR!

o1 = new stzList("A":"E")
? o1 / 3

/*---------------- TODO. Logical error in SplitToNParts()

o1 = Q("ABCDEFGHIJ")
? o1 / 10	#!--> [ "A" ,"B", "C", "D", "E", "F", "G", "H", "I", "J" ]
? o1 / 9	#!--> [ "AB", "C", "D", "E", "F", "G", "H", "I", "J" ]
? o1 / 8	#!--> [ "AB", "CD", "E", "F", "G", "H", "I", "J" ]
? o1 / 7	#!--> [ "ABC", "DE"", "F", "G", "H", "I", "J" ]
? o1 / 6	#!--> [ "ABC", "DEF", "G", "H", "I", "J" ]

/*----------------

o1 = Q("AB♥♥C♥♥D♥♥")
? o1.FindCharsW(' @Char = "♥" ') #--> [ 3, 4, 6, 7, 9, 10 ]

? o1.FindCharsW(' @CurrentChar = @NextChar ')	 #--> [ 3, 6, 9 ] 
? o1.FindNthCharW(2, '@CurrentChar = @NextChar') #--> 6
? o1.FindFirstCharW('@CurrentChar = @NextChar')	 #--> 3
? o1.FindLastCharW('@CurrentChar = @NextChar')	 #--> 9

/*----------------

@T = Q("TAYOUBA")
? @T.Section( :From = "A", :To = "B" ) #--> AYOUB
? @T.Section( :From = :FirstChar, :To = @T.First("A") )

/*----------------

o1 = new stzString("SOFTANZA")
? o1.Section( :From = o1.PositionOfFirst("A"), :To = :LastChar ) #--> ANZA
? o1.Section( :From = o1.First("A"), :To = :LastChar ) #--> ANZA

/*----------------

o1 = Q("TAYOUBTA")
? o1.SectionsXT( :From = "T", :To = "A" )

o1 = Q("TAYTOUBTA")
? o1.SectionsXT( :From = "T", :To = "A" )

o1 = Q("TAYTOAUBTA")
? o1.SectionsXT( :From = "T", :To = "A" )

/*----------------///////////////////////////////////////////////

o1 = Q([ "T","A","Y","T","O", "A", "U", "B", "T", "A" ])
? o1.Section(:From = "A", :Tp = "T")

? @@( o1.SectionsXT( :From = "T", :To = "A" ) )
#--> [ ["T", "A"], [ "T", "A", "Y", "O", "U", "B", "T", "A" ], ["T", "A"] ]

/*----------------

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])
? o1.ContainsInEachList("♥")
/*
? o1.ContainsInJustOneList("♥")
? o1.ContainsInNLists(3, "♥")
? o1.ContainsNOccurrencesInAllLists(3, "♥")
? o1.ConatinsNOccurrencesInEachList(1, "♥")
? o1.ContainsNOccurrencesInNLists(1, 3, "♥")
? o1.ContainsNOccurrencesInTheseLists([ [1, 1], [3, 2] ])

aListOfLists = [ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ]
? Q("♥").ExistsIn( aListOfLists  )
? Q("♥").ExistsInLists( aListOfLists  )
? Q("♥").ExistsInOnlyOneList( aListOfLists )
? Q("♥").ExistsInNLists(2, aListOfLists )
? Q("♥").ExistsNTimesInAllLists(3, aListOFLists )
? Q("♥").ExistsNTimesInEachList(3, aListOFLists )
? Q("♥").ExistsNTimesInNLists(3, 2, aListOFLists )
? Q("♥").ExistsNTimesInTheseLists([ [1, 1], [3, 2] ])


/*----------

? 3Hearts() #--> ♥♥♥
? 5Stars()  #--> ★★★★★

/*----------

o1 = new stzList([ "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindFirstNOccurrences(2, :Of = "ring") #--> [ 2, 4 ]
? o1.FindLastNOccurrences(2, :Of = "ring")  #--> [ 4, 6 ]

? o1.FindTheseOccurrences([2, 3], :Of = "ring") #--> [ 4, 6 ]

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindNthOccurrence(3, "ring") #--> 5

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring") #--> [ 1, 7 ]
? o1.FindTheseOccurrences([ 1, 4 ], "ring") #--> [ 1, 7 ]

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
anPos = o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring") #--> [ 1, 7 ]
o1.RemoveItemsAtPositions(anPos)
? @@( o1.Content() ) #--> [ "__", "ring", "__", "ring", "__" ]

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.RemoveOccurrences([ :First, :Last ], :Of = "ring" )
? @@( o1.Content() ) #--> [ "__", "ring", "__", "ring", "__" ]

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceOccurrences([ :First, :Last ], :Of = "ring", :With = 3Hearts() )
? @@( o1.Content() ) #--> [ "♥♥♥", "__", "ring", "__", "ring", "__", "♥♥♥" ]

/*----------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceFirstNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() ) #--> [ "★★", "__", "★★", "__", "ring", "__", "ring" ]

/*-------------------------------

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceLastNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() ) #--> [ "ring", "__", "ring", "__", "★★", "__", "★★" ]

/*

RemoveFirstNOccurrences
ReplaceFirstNOccurrences

/*==============

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.FindTheseOccurrences([ :First, :Last ], "ring") #--> [ 1, 25 ]
? o1.FindTheseOccurrences([ 1, 4 ], "ring") #--> [ 1, 25 ]

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.SubStringOccurrenceByPosition(9, "ring") #--> 2

? o1.SubStringPositionByOccurrence(2, "ring") #--> 9
# Alternativcely to this, you can say:
? o1.FindNthOccurrence(2, "ring")

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
o1.ReplaceSubStringAtPositions(anPos, "ring", Heart())
? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
o1.ReplaceFirstNOccurrences(3, "ring", Heart())
? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
o1.RemoveSubStringAtPosition(1, "ring")
? o1.Content()

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
o1.RemoveSubStringAtPositions(anPos, "ring")
? o1.Content() #--> " __  __  __ ring"

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.FindOccurrences([ 2, 3 ], "ring") #--> [ 9, 17 ]

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveOccurrences([2, 3], "ring")
? o1.Content()
#--> "ring __  __  __ ring"

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveFirstNOccurrences(3, "ring")
? o1.Content()
#--> " __  __  __ ring"

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveLastNOccurrences(3, "ring")
? o1.Content()
#--> "ring __  __  __ "

/*----------

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.SubStringOccurrenceByPosition(9, "ring") #--> 2

? o1.SubStringPositionByOccurrence(2, "ring") #--> 9
# Alternativcely to this, you can say:
? o1.FindNthOccurrence(2, "ring")

/*=========================================
*/

pron()

# In Softanza, you can divide the content of a string to 3 parts
cNumbers = "ABCDEFG"
? Q(cNumbers) / 3 #--> [ "ABC", "DEF", "G" ]

# Those 3 parts can be "named" parts:

? Q(cNumbers) / [ "Hussein", "Haneen", "Teeba" ]
#--> [ :Hussein = "ABC", :Haneen = "DEF", :Teeba = "G" ]

# And you can configure the share of each part at your will:
? Q(cNumbers) / [ :Hussein = 3, :Haneen = 1, :Teeba = 3 ]
#--> [ :Hussein = "ABC", :Haneen = "D", :Teeba = "EFG" ]

proff()
#--> Executed in 0.07 second(s)
