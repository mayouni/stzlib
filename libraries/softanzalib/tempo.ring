load "stzlib.ring"

/*==========

pron()

? Q([]).IsListOfLists()
#--> FALSE

? Q([ 1:3, 4:7, 8:10 ]).IsListOfLists()
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*========== PARTS ON STZLISTS

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.Parts() )
#--> [
#	[ "m", "m", "m" ],
#	[ "M", "M", "M" ],
#	[ "a", "a" ],
#	[ "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

? @@NL( o1.PartsCS(FALSE) )
#--> [
#	[ "m", "m", "m", "M", "M", "M" ],
#	[ "a", "a", "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@( o1.FindParts() ) + NL
#--> [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsAsSections() ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsCS(FALSE) ) + NL
#--> [ 1, 7, 12 ]

? @@( o1.FindPartsAsSectionsCS(FALSE) )
#--> [ [ 1, 6 ], [ 7, 11 ], [ 12, 14 ] ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.PartsZ() ) + NL
#--> [
#	[ [ "m", "m", "m" ], 1 ],
#	[ [ "M", "M", "M" ], 4 ],
#	[ [ "a", "a" ], 7 ],
#	[ [ "A", "A", "A" ], 9 ],
#	[ [ "i", "i", "i" ], 12 ]
# ]

? @@NL( o1.PartsCSZ(FALSE) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M" ], 1 ],
#	[ [ "a", "a", "A", "A", "A" ], 7 ],
#	[ [ "i", "i", "i" ], 12 ]
# ]

? @@NL( o1.PartsZZ() ) + NL
#--> [
#	[ [ "m", "m", "m" ], [ 1, 3 ] ],
#	[ [ "M", "M", "M" ], [ 4, 6 ] ],
#	[ [ "a", "a" ], [ 7, 8 ] ],
#	[ [ "A", "A", "A" ], [ 9, 11 ] ],
#	[ [ "i", "i", "i" ], [ 12, 14 ] ]
# ]

? @@NL( o1.PartsCSZZ(FALSE) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M" ], [ 1, 6 ] ],
#	[ [ "a", "a", "A", "A", "A" ], [ 7, 11 ] ],
#	[ [ "i", "i", "i" ], [ 12, 14 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@NL( o1.PartsUsing('Q(@item).CharCase()') ) + NL
#--> [
#	[ "m", "m", "m" ],
#	[ "M", "M", "M" ],
#	[ "a", "a" ],
#	[ "A", "A", "A" ],
#	[ "i", "i", "i" ]
# ]

? @@NL( o1.PartsUsingXT('Q(@item).CharCase()') ) + NL
#--> [
#	[ [ "m", "m", "m" ], "lowercase" ],
#	[ [ "M", "M", "M" ], "uppercase" ],
#	[ [ "a", "a" ], "lowercase" ],
#	[ [ "A", "A", "A" ], "uppercase" ],
#	[ [ "i", "i", "i" ], "lowercase" ]
# ]

proff()
# Executed in 0.19 second(s)

/*---------------

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

? @@( o1.FindPartsUsing('Q(@item).CharCase()') )
#--> [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsAsSectionsUsing('Q(@item).CharCase()') ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

proff()
# Executed in 0.20 second(s)

/*---------------

pron()

o1 = new stzList([
	"m", "m", "m",
	"M", "M", "M",
	"a", "a",
	"A", "A", "A",
	"i", "i", "i"
])

# If you deactivate CaseSensitivity with CS = FALSE and
# try to partition the list using CharCase(), then
# Softanza detects it and return the hole list as one part

? @@( o1.FindPartsUsingCS('Q(@item).CharCase()', FALSE) )
#--> [ 1 ]

? @@( o1.FindPartsAsSectionsUsingCS('Q(@item).CharCase()',FALSE) )
#--> [ [ 1, 14 ] ]

? @@( o1.PartsUsingCS('Q(@item).CharCase()', FALSE) ) + NL
#--> [
#	[ [ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ] ]
# ]

? @@( o1.PartsUsingCSZZ('Q(@item).CharCase()', FALSE) ) + NL
#--> [
#	[
#	[ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ],
#	[ 1, 14 ]
#	]
# ]

proff()
# Executed in 0.02 second(s)

/*======== PARTS ON STZSTRING

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.FindParts() ) + NL
# [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsCS(FALSE) ) + NL
# [ 1, 7, 12 ]

? @@( o1.FindPartsAsSections() ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsAsSectionsCS(FALSE) )
#--> [ [ 1, 6 ], [ 7, 11 ], [ 12, 14 ] ]

proff()
# Executed in 0.02 second(s)

/*--------

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.Parts() )
#--> [ "mmm", "MMM", "aa", "AAA", "iii" ]

? @@( o1.PartsCS(FALSE) )
#--> [ "mmmmmm", "aaaaa", "iii" ]

proff()
# Executed in 0.02 second(s)

/*--------

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@NL( o1.PartsZ() ) + NL
#--> [
#	[ "mmm", 1 ],
#	[ "MMM", 4 ],
#	[ "aa", 7 ],
#	[ "AAA", 9 ],
#	[ "iii", 12 ]
# ]

? @@NL( o1.PartsCSZ(FALSE) ) + NL
#--> [
#	[ "mmmmmm", 1 ],
#	[ "aaaaa", 7 ],
#	[ "iii", 12 ]
# ]

? @@NL( o1.PartsZZ() ) + NL
#--> [
#	[ "mmm", [ 1, 3 ] ],
#	[ "MMM", [ 4, 6 ] ],
#	[ "aa", [ 7, 8 ] ],
#	[ "AAA", [ 9, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

? @@NL( o1.PartsCSZZ(FALSE) )
#--> [
#	[ "mmmmmm", [ 1, 6 ] ],
#	[ "aaaaa", [ 7, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

proff()
# Executed in 0.02 second(s)

/*===-----

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.FindPartsUsing('Q(@Char).CharCase()') ) + NL
# [ 1, 4, 7, 9, 12 ]

? @@( o1.FindPartsUsingCS('Q(@Char).CharCase()', FALSE) ) + NL
# [ 1 ]

? @@( o1.FindPartsAsSectionsUsing('Q(@Char).CharCase()') ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 11 ], [ 12, 14 ] ]

? @@( o1.FindPartsAsSectionsUsingCS('Q(@Char).CharCase()', FALSE) )
#--> [ [ 1, 14 ] ]

proff()
# Executed in 0.21 second(s)

/*--------

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@( o1.PartsUsing('Q(@Char).CharCase()') ) + NL
#--> [ "mmm", "MMM", "aa", "AAA", "iii" ]

? @@( o1.PartsUsingCS('Q(@Char).CharCase()', FALSE) ) + NL
#--> [ [ "mmmMMMaaAAAiii" ] ]

? @@NL( o1.PartsUsingXT('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", "lowercase" ],
#	[ "MMM", "uppercase" ],
#	[ "aa", "lowercase" ],
#	[ "AAA", "uppercase" ],
#	[ "iii", "lowercase" ]
# ]

? @@( o1.PartsUsingCSXT('Q(@Char).CharCase()', FALSE) )
#--> [ [ "mmmMMMaaAAAiii", "" ] ]

proff()
# Executed in 0.20 second(s)

/*--------

pron()

o1 = new stzString("mmmMMMaaAAAiii")

? @@NL( o1.PartsUsingZ('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", 1 ],
#	[ "MMM", 4 ],
#	[ "aa", 7 ],
#	[ "AAA", 9 ],
#	[ "iii", 12 ]
# ]

? @@( o1.PartsUsingCSZ('Q(@Char).CharCase()', FALSE) ) + NL
#--> [[ "mmmMMMaaAAAiii", 1 ] ]

? @@NL( o1.PartsUsingZZ('Q(@Char).CharCase()') ) + NL
#--> [
#	[ "mmm", [ 1, 3 ] ],
#	[ "MMM", [ 4, 6 ] ],
#	[ "aa", [ 7, 8 ] ],
#	[ "AAA", [ 9, 11 ] ],
#	[ "iii", [ 12, 14 ] ]
# ]

? @@NL( o1.PartsUsingCSZZ('Q(@Char).CharCase()', FALSE) )
#--> [ [ "mmmMMMaaAAAiii", [ 1, 14 ] ] ]

proff()
# Executed in 0.24 second(s)

/*=======

pron()

o1 = new stzString("Abc285XY&من")
		
? @@( o1.PartsUsing( 'Q(@char).IsLetter()' ) ) + NL
#--> [ "Abc", "285", "XY", "&", "من" ]

? @@NL( o1.PartsUsingXT( 'Q(@char).IsLetter()' ) ) + NL
#--> [
#	[ "Abc", TRUE ],
#	[ "285", FALSE ],
#	[ "XY", TRUE ],
#	[ "&", FALSE ],
#o	[ "من", TRUE ]
# ]

? @@( o1.PartsUsing('Q(@char).Orientation()' ) ) + NL
#--> [ "Abc285XY&", "من" ]
		
? @@( o1.PartsUsing( 'Q(@char).IsUppercase()' ) ) + NL
#--> [ "A", "bc", "285", "XY", "&من" ]

? @@( o1.PartsUsingXT( 'Q(@char).IsUppercase()' ) ) + NL
#--> [
#	[ "A", TRUE ],
#	[ "bc", FALSE ],
#	[ "285", NULL ],
#	[ "XY", TRUE],
#o	[ "&من", NULL ]
# ]

? @@( o1.PartsUsing( 'Q(@char).CharCase()' ) ) + NL
#--> [ "A", "bc", "285", "XY", "&من" ]

? @@( o1.PartsUsingXT( 'Q(@char).CharCase()' ) )
#--> [
#	[ "A", "uppercase" ],
#	[ "bc", "lowercase" ],
#	[ "285", NULL ],
#	[ "XY", "uppercase" ],
#o	[ "&من", NULL ]
# ]

proff()
# Executed in 0.47 second(s)

/*----- #perf

pron()

cLargeStr = ""
for i = 1 to 1_000
	cLargeStr += "mmMMMaaAA"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)

o1.PartsUsing('Q(@Char).CharCase()')
#--> [ "mm", "MMM", "aa", "...", "MMM", "aa", "AA" ]

#NOTE: to show a part of the output, use ShowShortXT( )
         
proff()
# Executed in 62.34 second(s)

/*========

pron()

? @@( Q("285").IsLowercase() )
#--> NULL

? Q("a285").IsLowercase()
#--> TRUE

? @@( Q("@&#!").IsUppercase() )
#--> NULL

? Q("@&#!ABC").IsUppercase()
#--> TRUE

? @@( Q("محمود").IsLowercase() )
#--> NULL

proff()
# Executed in 0.06 second(s)

/*-----

pron()

? Q("mmm").CharsCase() # Or StringCase() or Kase() (Case() is reserved!)
#--> lowercase

? Q("Amm").CharsCase()
#--> capitalcase

? Q("MMM").CharsCase()
#--> uppercase

? Q("mmmAAA").CharsCase()
#--> hybridcase

proff()
# Executed in 0.12 second(s)

/*=====

pron()

o1 = new stzString("ring")
? o1.NthChar(3)
#--> "n"

? @@( o1.NthChar(0) )
#--> NULL

? @@( o1.NthChar(77) )
#--> NULL

? @@( o1.Chars() )
#--> [ "r", "i", "n", "g" ]

proff()
# Executed in 0.01 second(s)

/*-----

pron()

o1 = new stzString("mmmMMMaaAAAiii")
? @@( o1.Chars() )
#--> [ "m", "m", "m", "M", "M", "M", "a", "a", "A", "A", "A", "i", "i", "i" ]

? @@( o1.CharsCS(false) )
#--> [ "m", "a", "i" ]

? @@( o1.CharsU() ) # Or UniqueChars() or CharsWithoutDupplication()
#--> [ "m", "M", "a", "A", "i" ]

proff()
# Executed in 0.02 second(s)

/*----- #perf

pron()

cLargeStr = ""
for i = 1 to 100_000
	cLargeStr += "mmmMMMaaAAAiii"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)
o1.Chars()
#NOTE: to show the ouutput use ShowShort()

proff()
# Executed in 7.80 second(s)

/*----- #perf

pron()

cLargeStr = ""
for i = 1 to 100_000
	cLargeStr += "mmmMMMaaAAAiii"
next
# Take 0.10 second(s)

o1 = new stzString(clargeStr)
o1.CharsU() # Or UniqueChars()
#NOTE: to show the output use ShowShort()

proff()
# Executed in 11.90 second(s)

/*=======================

pron()

o1 = new stzString("abc")
? o1.CharCase() # Same as StringCase()
#--? "lowercase"

proff()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzList([ "Hello", "there!", ANullObject(), Q("9") ])

o1.StringifyObjects()
#--> [ "Hello", "there!", "@nullobject", "@noname" ]

? o1.Content()

proff()
# Executed in 0.02 second(s)

/*=========== CLASSIFYING A LIST

pron()

o1 = new stzList([
	:Arabic,
	:Arabic,
	:French,
	:English,

	[ 1, 2, 3 ],
 	Q("Hello!"),
	AFalseObject(),
	ATrueObject(),

	:Spanish,
	:Spanish,
	:English,
	:Arabic,

	Q(12),
	12,
	110,

	StzNamedObjectQ( :Italian = Q("Gracia!") ),
	"PERSIAN",

	ANullObject()
])

? @@NL( o1.Classify() )
#--> [
#	[ "arabic", 	[ 1, 2, 12 ] ],
#	[ "french", 	[ 3 ] ],
#	[ "english", 	[ 4, 11 ] ],
#	[ "spanish", 	[ 9, 10 ] ],
#	[ "italian", 	[ 16 ] ],
#	[ "persian", 	[ 17 ] ],
#	[ "@undefined", [ 5, 6, 7, 8, 13, 14, 15, 18 ] ]
# ]


proff()
# Executed in 0.03 second(s)

/*====== #ring

pron()

aList = [ "m", "mmm", "mm" ]
swap(aList, 2, 3)
? @@(aList)

proff()
# Executed in 0.02 second(s)

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2, 22 ],
	[ "C", 3, 33 ]
])

o1.SwapCols(3, 1) # Or SwapNthItems()

? @@NL( o1.Content() )
#--> [
#	[ 11, 1, "A" ],
#	[ 22, 2, "B" ],
#	[ 33, 3, "C" ]
# ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.SwapCols(3, 1) # Or SwapNthItems()

? @@NL( o1.Content() )
#--> [
#	[ 11, 1, "A" ],
#	[ "B", 2 ],
#	[ 33, 3, "C" ]
# ]


proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCol(3) # Or RemoveNthItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", 1 ],
#	[ "B", 2 ],
#	[ "C", 3 ]
# ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCol(2) # Or RemoveNthItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", 11 ],
#	[ "B" ],
#	[ "C", 33 ]
# ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.RemoveCols([ 2, 3 ])

? @@NL( o1.Content() )
#--> [
#	[ "A" ],
#	[ "B" ],
#	[ "C" ]
# ]

proff()

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B", 2 ],
	[ "C", 3, 33 ]
])

o1.InsertCol(2, [ "a", "b", "c" ]) # Or InsertItems()

? @@NL( o1.Content() )
#--> [
#	[ "A", "a", 1, 11 ],
#	[ "B", "b", 2 ],
#	[ "C", "c", 3, 33 ]
# ]

proff

/*------
*/
pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B" ],
	[ "C", 3, 33 ]
])

? o1.NthCol(2) # Or NthItems(2)
#--> [ 1, 3 ]

proff()

/*------

pron()

o1 = new stzListOfLists([
	[ "A", 1, 11 ],
	[ "B" ],
	[ "C", 3, 33 ]
])

o1.InsertCol(2, [ "a", "b", "c" ])

? @@NL( o1.Content() )
#--> [
#	[ "A", "a", 1, 11 ],
#	[ "B" ],
#	[ "C", "c", 3, 33 ]
# ]

proff()
# Executed in 0.03 second(s)

/*======

*/
pron()

o1 = new stzListOfLists([
	[ :Arabic, "arb1", "A100" ],
	[ :Arabic, "arb2", "A200" ],
	[ :French, "frn1", "F100" ],
	[ :English, "eng1", "E100" ],

	[ [ 1, 2, 3 ], "lst1", "L100" ],
	[ ANullObject(), "nul1", "N100" ],
 
	[ :Spanish, "spn1", "S100" ],
	[ :Spanish, "spn2", "S200" ],
	[ :English, "eng2", "E200" ],
	[ :Arabic, "arb3", "A300" ],

	[ 12, "num1", "N100" ],
	[ 110, "num2", "N200" ],
	[ Q("hi!"), "non1", "X100" ],

	[ "PERSIAN", "per1", "P100" ]
])

? @@NL( o1.Classify() )
#--> [
#	[ "arabic", 	[ "arb1", "A100", "arb2", "A200", "arb3", "A300" ] ],
#	[ "french", 	[ "frn1", "F100" ] ],
#	[ "english", 	[ "eng1", "E100", "eng2", "E200" ] ],
#	[ "spanish", 	[ "spn1", "S100", "spn2", "S200" ] ],
#	[ "persian", 	[ "per1", "P100" ] ],
#	[ "@undefined", [ "lst1", "L100", "nul1", "N100", "num1", "N100", "num2", "N200", "non1", "X100" ] ]
# ]


proff()
# Executed in 0.04 second(s)

/*-------

pron()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])
aClasses = o1.ClassifyBy(' Q(@item).HowMany(0) ')

? @@NL( aClasses )
#--> [
#	[ 2, [ 3007, 2100 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 0, [ 8, 2 ] ],
#	[ 3, [ 10001 ] ]
# ]

# If you want the first column to be sorted  you can do it like this

? @@NL( @SortLists( aClasses ) ) # or direcly @SortLists(aClasses)
#--> [
#	[ 0, [ 8, 2 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 2, [ 3007, 2100 ] ],
#	[ 3, [ 10001 ] ]
# ]

# It's also possible to pass throw stzListOfLists like this:

? @@NL( StzListOfListsQ(aClasses).SortedOn(1) ) # or directly .Sorted()
#--> [
#	[ 0, [ 8, 2 ] ],
#	[ 1, [ 170, 0, 150 ] ],
#	[ 2, [ 3007, 2100 ] ],
#	[ 3, [ 10001 ] ]
# ]

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])
? @@NL( o1.ClassifiedByQR(' Q(@item).HowMany(0) ', :stzListOflists).SortedOn(1) )
#--> [
# 	[ "0", [ 8, 2 ] ],
#	[ "1", [ 170, 0, 150 ] ],
#	[ "2", [ 3007, 2100, 2100 ] ],
#	[ "3", [ 10001 ] ]
# ]

proff()
#--> Executed in 0.06 second(s)





/*====== #ring

pron()

# Some Ring standard functions make the action in place and does not
# return anything. Others do the action and return the result.

#~>
# The ring_...() functions always do the action and return
# the result. So you are free to say:

	aList = [ 2, 3 ]
	ring_insert(aList, 1, 1)
	? aList
	#--> [ 1, 2, 3 ]

# Or directly:

	? ring_insert([ 2, 3 ], 1, 1)
	#--> [ 1, 2, 3 ]

proff()
# Executed in 0.01 second(s)

/*====== #ring

pron()

# ring_insert() corrects the behaviour of the standard insert()
# function, since the standard function, as is, meanse actually
# InsertAfter() and not insert (before, which what we expect)

? ring_insert(2:3, 1, 1)
#--> [ 1, 2, 3 ]

# In fact, if we use the standart function

alist = 2:3
insert(aList, 1, 1)
? aList
#--> [ 2, 1, 3 ]

proff()
# Executed in 0.01 second(s)

/*======

pron()

? @@SP( SortLists([
	[ "Dog", 	370 ],
	[ "Fox", 	120 ],
	[ "Charlie", 	1:3 ],
	[ "Baker",	493 ],
	[ "Easy", 	5:8 ]	 
]) )
#--> [
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ] ],
#	[ "Dog", 370 ],
#	[ "Easy", [ 5, 6, 7, 8 ] ],
#	[ "Fox", 120 ]
# ]

proff()
# Executed in 0.04 second(s)

#------

pron()

? @@SP( SortListsBySize([ 1:7, 1:3, 1:5 ]) )
#--> [
#	[ 2, 3, 4, 5, 6, 1, 7 ],
#	[ 2, 1, 3 ],
#	[ 2, 3, 4, 1, 5 ]
# ]

proff()
# Executed in 0.03 second(s)

#------

pron()

aLists = [
	[ "Dog", 	370,	"white",	TRUE	],
	[ "Fox", 	120,	"blue",		FALSE	],
	[ "Charlie", 	1:3,	"white" 		],
	[ "Baker",	493 				],
	[ "Easy", 	5:8 				],
	[ "Alpha",	 45,	"green" 		],
	[ "King"					]
]

? @@SP( SortListsOn(aLists, 2) )
#--> [
#	[ "King" ],
#	[ "Alpha", 45, "green" ],
#	[ "Fox", 120, "blue", 0 ],
#	[ "Dog", 370, "white", 1 ],
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ], "white" ],
#	[ "Easy", [ 5, 6, 7, 8 ] ]
# ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

? @@NL( SortList([ "charlie", 17, 10, 4:7, "fox", 1:3, "aplha" ]) )
#--> [
#	10,
#	17,
#	"aplha",
#	"charlie",
#	"fox",
#	[ 1, 2, 3 ],
#	[ 4, 5, 6, 7 ]
# ]

proff()
# Executed in 0.03 second(s)

/*---------

pron()

? SortBy([ "a", "abcde", "abc", "ab", "abcd" ], 'len(@item)')
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

proff()
# Executed in 0.04 second(s)

/*===

pron()

? @IsHashList([ [ "uppercase", [ ] ] ])
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*=====

pron()

aList = [ [1,2,3], [4,5,6], 7:9 ]

? "List content: " + NL + @@(aList) # Or ListToCode()
#--> List content: 
# [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

proff()
# Executed in 0.02 second(s)

/*------ #TODO future

pron()

o1 = new stzTable([
	[ :Company, :Username, :Active, :Email, :EmailValid, :Firstname, :Infix, :Lastname,
	  :Gender, :2FA_Status, :Last_Login, :Creation_Date, :Accounts, :Roles ]
])



o1.FromCSV(str) # Or LoadCSVString()
o1.FromCSV(file) # Or LoadCSVFile

o1.FromJSON(str) # Or LoadJSONString()
o1.FromJSONXT(file) # Or LoadJSONFile()


o1.Show()
give any
proff()

/*=========

pron()

o1 = new stzString("the last mile")

o1.InsertAfterPosition(8, ">>")
o1.InsertBeforePosition(5, "<<")

? o1.Content()
#--> the <<last>> mile

proff()
# Executed in 0.02 second(s)

#---

pron()

o1 = new stzString("the last mile")

o1.BoundSection(5, 8, [ "<<", ">>" ])
? o1.Content()
#--> the <<last>> mile

proff()
# Executed in 0.02 second(s)

#---

pron()

o1 = new stzString("its the last mile now")
o1.BoundSections([ [5, 7], [9, 12], [14, 17] ], "_")
? o1.Content()
#--> its _the_ _last_ _mile_ now

proff()
# Executed in 0.04 second(s)

#---

pron()

o1 = new stzString("its the last mile now")
o1.Bound("last", :By = [ "<<", :and = ">>" ]) # or BoundSubString() or InsertAroundSubString()
? o1.Content() + NL
#--> its the <<last>> mile now

o1.Bound([ "the", "mile" ], :By = [ "<<", ">>" ]) # or BoundSubStrings()
? o1.Content()
#--> its <<the>> <<last>> <<mile>> now

proff()
# Executed in 0.09 second(s)

/*-----------------

pron()

o1 = new stzString("IbelieveinRingfutureandengageforit!")

o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()
#--> I believe in Ring future and engage for it!

proff()
# Executed in 0.07 second(s)

/*-----------------

pron()

o1 = new stzHashList([
	[ "#1", [ 12, 66 ] ],
	[ "#2", [ 26 ] ],
	[ "#3", [ 44, 66 ] ]
])

? @@( o1.FindKeysByValue(66) )
#--> [ 1, 3 ]

? @@( o1.KeysByValue(66) )
#--> [ "#1", "#3" ]

? o1.KeyByValue(66)
#--> #1

proff()
# Executed in 0.02 second(s)

/*-----------------

pron()

o1 = new stzString("{{ring}}")
? o1.Bounds()

? @@( o1.FindTheseBoundsAsSections("{{","}") )
#--> [ [ 1, 2 ], [ 8, 8 ] ]

? @@( o1.FindTheseBounds("{{", "}") )
#--> [ 1, 8 ]

o1.RemoveTheseBounds("{{","}")
? o1.Content()
#--> ring}

proff()
# Executed in 0.03 second(s)

/*------------

pron()

o1 = new stzList([ "A", "B", "A", "A", "B", "B", "C" ])

? o1.NumberOfItemsU() # Or NumberOfUniqueItems()
#--> 3

? o1.ItemsU()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.02 second(s)

/*------------

pron()

o1 = new stzString("ABCAAB")

? o1.CharsQ().WithoutDuplicates()

? o1.CharsU()

? U( o1.Chars() )

proff()
# Executed in 0.04 second(s)

/*------- TODO: fix it

? StzCharQ("🔻")
#!--> ERROR MESSAGE: Can't create the char object


/*-------- TODO: erronous char name

pron()

? StzCharQ(63).Content()
#--> ?

? Q("🔻").Unicode()

? StzStringQ("🔻").CharName() #TODO: Correct this
#!--> QUESTION MARK

proff()

/*================

pron()

o1 = new stzString("---,---;---[---]---:---")

? @@( o1.SplitAt([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", "---", "---", "---", "---", "---" ]

? @@( o1.SplitBefore([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---", ",---", ";---", "[---", "]---", ":---" ]

? @@( o1.SplitAfter([ ",", ";", "[", "]", ":" ]) ) + NL
#--> [ "---,", "---;", "---[", "---]", "---:", "---" ]

proff()
# Executed in 0.08 second(s)

/*================ #TODO check it after including ContainsBetween() and
#		         containssubstringbetweenpositionscs

pron()

//? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :Position = 3, :AndPosition = 5)
#--> TRUE

//? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenPositions = [ 3, :And = 5])
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

? Q("^^♥♥♥^^").ContainsInSection("♥♥♥", 3, 5)
#--> TRUE

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :InSection = [3, 5])
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*-------------- # TODO: check after including ContainsBetween()

pron()

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", "^^", "^^")
#--> TRUE

? Q("^^♥♥♥^^").ContainsBetween("♥♥♥", :SubString = "^^", :AndSubString = "^^")
#--> TRUE

proff()
# Executed in 0.49 second(s)

/*-------------- #TODO check it after including ContainsSubstringBetweencs()

pron()

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :Between = [ "^^", "^^" ] )

? Q("^^♥♥♥^^").ContainsXT("♥♥♥", :BetweenSubStrings = [ "^^", :And = "^^" ] )
#--> TRUE

proff()
#--> Executed in 0.48 second(s)

/*-------------- #TODO check it after including ContainsSubstringBetweencs()

pron()

? Q("..<<--♥♥♥-->>..").ContainsXT("♥♥♥", :InBetween = ["<<", ">>"])
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*==================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")
? o1.FindNthAsSection(2, "♥♥♥")
#--> [9, 11]

StopProfiler()
# Executed in 0.01 second(s)

/*================

StartProfiler()

o1 = new stzString("__♥♥♥__/♥♥♥\__♥♥♥__")

? o1.Sit(
	:InSection = o1.FindNthAsSection(2, "♥♥♥"),

	:AndYield = [
		:NCharsBefore = 3,
		:NCharsAfter  = 3
	]
)
#--> [ "__/", "\__" ]

StopProfiler()
# Executed in 0.03

/*========= CHECKING BOUNDS - XT

StartProfiler()
		
	o1 = new stzString("♥")
	? o1.IsBoundedByIB("-", :In = "...-♥-...") # You can use :Inside instead of :In
	#--> TRUE
	
	? o1.IsBoundedByIB(["/", "\"], :InSide = "__/♥\__")
	#--> TRUE
		
	? o1.IsBetweenIB(["/", "\"], :InSide = "__/♥\__")
	#--> TRUE
	
	? o1.IsBetweenIB(["/", :And = "\"], :InSide = "__/♥\__")
	#--> TRUE
	
StopProfiler()
# Executed in 0.12 second(s)

/*====  FINDING SUBSTRING, BASIC & EXTENDED

StartProfiler()

	o1 = new stzListOfStrings([
		"What's your name please?",
		"Mabrooka!",
		"Your name and my name are not the same...",
		"I see.",
		"Nice to meet you,",
		"Mabrooka!"
	])
	
	? @@( o1.FindSubString("name") )
	#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

	? @@( o1.FindSubstringXT("name") )
	#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

StopProfiler()
# Executed in 0.04 second(s)

/*========== CHECKING CONTAINMENT

StartProfiler()
	
	? Q("\__♥__/").Contains("♥")
	#--> TRUE
	
	? Q("\__♥__/").ContainsMany("_") # Or .ContainsMoreThenOne("_")
	#--> TRUE
	
	? Q("\__♥__/").ContainsThese(["_","♥"])
	#--> TRUE
	
	? Q("\__♥__/").IsMadeOf(["\", "_", "♥", "/" ])
	#--> TRUE
	
StopProfiler()
# Executed in 0.02 second(s)

/*======== CHECKING CONTAINMENT - EXTENDED

StartProfiler()

	? Q("__♥__").ContainsXT("♥", "_")
	#--> TRUE

	? Q("__♥__♥__").ContainsXT(2, "♥")
	#--> TRUE

	? Q("__♥__").ContainsXT("♥", [])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(["_", "-", "♥"], [])
	#--> TRUE

	? Q("__♥__").ContainsXT([], "♥")
	#--> TRUE

StopProfiler()
# Executed in 0.02 second(s)

/*---------- #TODO test it after including ContainsSubStringBoundedBy()

pron()

	? Q("_-♥-_").ContainsXT("♥", :BoundedBy = "-")
	#--> TRUE

	? Q("_/♥\_").ContainsXT("♥", :Between = ["/", :And = "\"])
	#--> TRUE

	? Q("__-♥-__-•-__").ContainsXT(["♥", "•"], :BoundedBy = "-")
	#--> TRUE
	
	? Q("__/♥\__/•\__").ContainsXT(["♥", "•"], :Between = ["/", :And = "\"])
	#--> TRUE

	? Q("__/♥\__/^^^\__").ContainsXT( [], :BoundedBy = ["/", :And = "\"] )
	#--> TRUE

	? Q("__/♥\__/^^\__").ContainsXT( [], :Between = ["/", "\"] )	
	#--> TRUE
 proff()

/*----------

StartProfiler()

	? Q("").ContainsXT(:Chars, []) # You can use NULL or FALSE instead of []
	#--> FALSE
	? Q("").ContainsXT([], :Chars) # You can use NULL or FALSE instead of []
	#--> FALSE

	? Q("__-♥-__").ContainsXT(:Chars, ["_", "-"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:TheseChars, ["♥", "-"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:SomeOfTheseChars, ["_", "-", "_"])
	#--> TRUE

	? Q("__-♥-__").ContainsXT(:OneOfTheseChars, ["A", "♥", "B"])
	#--> TRUE
	? Q("__-♥-__").ContainsXT(:NoneOfTheseChars, ["A", "*", "B"])
	#--> TRUE

	? Q("__---_^_").ContainsXT(:CharsWhere, 'Q(@char).IsEither("A", :Or = "^")' )
	#--> TRUE
	? Q("__---__").ContainsXT(:CharsW, 'Q(@Char).IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, :Where = 'Q(@Char).IsEither("_", :Or = "-")')
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, Where(' Q(@Char).IsEither("_", :Or = "-") ') )
	#--> TRUE
	? Q("__---__").ContainsXT(:Chars, W('Q(@Char).IsEither("_", :Or = "-")'))
	#--> TRUE

#NOTE: Conditional code will be quicker if you replace Q(@Char) with Q(This[@i])

StopProfiler()
# Executed in 0.41 second(s) in Ring 1.20
# Executed in 0.44 second(s) in Ring 1.19

/*------

StartProfiler()
	
Pron()

	? Q("_softanza_loves_ring_").ContainsXT(:SubStrings, ["softanza", "ring"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:TheseSubStrings, ["softanza", "ring"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfTheseSubStrings, ["ring", "php", "softanza"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:SomeOfThese, ["ring", "php", "softanza"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:OneOfTheseSubStrings, ["python", "php", "ring"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:OneOfThese, ["python", "php", "ring"])
	#--> TRUE

	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfTheseSubStrings, ["python", "php", "ruby"])
	#--> TRUE
	? Q("_softanza_loves_ring_").ContainsXT(:NoneOfThese, ["python", "php", "ruby"])
	#--> TRUE
Proff()
# Executed in 0.03 second(s)

/*------------ #perf

#TODO: Check performance! Rethink the subStrings() design
#UPDATE: done! After redesigning SubStrings() function,
# performance went down from 144.36 seconds to 0.32 seconds!

StartProfiler()

	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsWhere, 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, :Where = 'Q(@SubString).IsUppercase()')
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, Where('Q(@SubString).IsUppercase()') )
	#--> TRUE
	? Q("_softanza_LOVES_ring_").ContainsXT(:SubStringsW, W('Q(@SubString).IsUppercase()') )
	#--> TRUE

StopProfiler()
# Executed in 0.32 second(s)

/*======== USING ADDXT() - EXTENDED

StartProfiler()
	
	Q("Ring programmin language.") {
	
		AddXT("g", :After = "programmin") # You can use :To instead of :After
		? Content()
		#--> Ring programming guage.
	
	}

StopProfiler()
#--> Ring programming Language.

/*-----------

StartProfiler()
	
	Q("__(♥__(♥__(♥__") {
	
		AddXT( ")", :AfterEach = "♥" ) # ... you can also say :After = "♥"
		? Content()
		#--> __(♥)__(♥)__(♥)__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.05 second(s) in Ring 1.19

/*-----------

StartProfiler()
	
	Q("__♥__(♥__♥__") {
	
		AddXT( ")", :AfterNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.10 second(s) in Ring 1.19

/*-----------------

StartProfiler()
	
	Q("__(♥__♥__♥__") {
	
		AddXT( ")", :AfterFirst = "♥" ) # ... or :ToFirst
		? Content()
		#-->__(♥)__♥__♥__
	}
	
StopProfiler()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19
	
/*-----------------

StartProfiler()
	
	Q("__♥__♥__(♥__") {
	
		AddXT( ")", :AfterLast = "♥" ) # ... or :ToLast
		? Content()
		#--> __♥__♥__(♥)__
	}
	
StopProfiler()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.19

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
# Executed in 0.04 second(s)

/*---------

StartProfiler()
	
	Q("__♥__♥)__♥__") {
	
		AddXT( "(", :BeforeNth = [2, "♥"] )
		? Content()
		#--> __♥__(♥)__♥__
	}
	
StopProfiler()
# Executed in 0.04 second(s)

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
	
		AddXT([ "/", "\" ], :AroundEach = "♥") # ... or just :Around = "♥" if you want
		? Content()
		#--> __/♥\__/♥\__/♥\__
	}
	# Executed in 0.05 second(s)
	
StopProfiler()

/*-----------------

StartProfiler()
	
	Q("__♥__♥__♥__") {
	
		AddXT([ "/","\" ], :AroundNth = [2, "♥"])
		? Content()
		#--> __♥__/♥\__♥__
	}
	
StopProfiler()
# Executed in 0.05 second(s)

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

#=======

pron()

o1 = new stzList(1:8)
? @@( o1.SplitToListsOfNItems(2) )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ] ]

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList([ [ 1, 3 ], [ 8, 10 ], [ 12, 13 ], [ 18, 19 ], [ 21, 21 ], [ 26, 26 ] ])
? @@SP( o1.SplitToListsOfNItems(2) )
#--> [ 
#	[ [ 1, 3 ], [ 8, 10 ] ],
#	[ [ 12, 13 ], [ 18, 19 ] ],
#	[ [ 21, 21 ], [ 26, 26 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*========

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.StringBounds() ) # Or simply Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.StringBoundsZZ() ) # Or simply BoundsZZ()
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

? @@( o1.FindStringBoundsAsSections() )  + NL # Or Simply FindBoundsAsSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBoundsAsSections("***", "***") )
#--> [ [ ], [ ] ]

? @@( o1.FindTheseBoundsAsSections("<<<", "***") )
#--> [ [ 1, 3 ], [ ] ]

? @@( o1.FindTheseBoundsAsSections("***", ">>>") )
#--> [ [ ], [ 8, 10 ] ]

? @@( o1.FindTheseBoundsAsSections("<<<", ">>>") ) + NL
#--> [ [ 1, 3 ], [ 8, 10 ] ]

#--

? @@( o1.FindTheseBounds("***", "***") )
#--> []

? @@( o1.FindTheseBounds("<<<", "***") )
#--> [ 1, 0 ]

? @@( o1.FindTheseBounds("***", ">>>") )
#--> [ 0, 8 ]

? @@( o1.FindTheseBounds("<<<", ">>>") ) + NL
#--> [ 1, 8 ]

#--

? @@( o1.TheseBoundsZ("***", "***") )
#--> [ [ '', 0 ], [ "", 0 ] ]

? @@( o1.TheseBoundsZ("<<<", "***") )
#--> [ [ "<<<", 1 ], [ "", 0 ] ]

? @@( o1.TheseBoundsZ("***", ">>>") )
#--> [ [ "", 0 ], [ '>>>', 8 ] ]

? @@( o1.TheseBoundsZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

#--

? @@( o1.TheseBoundsZZ("***", "***") )
#--> [ [ "", [ ] ], [ "", [ ] ] ]

? @@( o1.TheseBoundsZZ("<<<", "***") )
#--> [ [ "<<<", [ 1, 3 ] ], [ "", [ ] ] ]

? @@( o1.TheseBoundsZZ("***", ">>>") )
#--> [ [ "", [ ] ], [ '>>>', [ 8, 10 ] ] ]

? @@( o1.TheseBoundsZZ("<<<", ">>>") ) + NL
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

proff()
# Executed in 0.05 second(s)

/*============

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([ [8,10], [1,3] ])
? o1.Content()
#--> word

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveSections([])
? o1.Content()
#--> <<<word>>>

proff()
# Executed in 0.01 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
? o1.FindLeadingChars()
#--> 0

? @@( o1.FindLeadingCharsAsSection() )
#--> [ ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([ [ ], [ 5, 7 ] ])
? o1.IsListOfPairsOfNumbers()
#--> FALSE

proff()
# Executed in 0.01 second(s)

/*--------- TODO/FUTURE: add _ for more readable numbers

pron()

? @@(1587345327)
#--> '1_587_345_327'

? @@([ 1, 2, 999997, 999998, 1000000 ])
#--> [ 1, 2, 999_997, 999_998, 1_000_000 ]

proff()
# Executed in 0.02 second(s)

/*--------- #perf

pron()	

o1 = new stzList( 1 : 1_000_000 )
o1.RemoveSection(5, 999_996)
? ShowShortXT( o1.Content(), 7 )
#--> [ 1, 2, 3, 4, 999_997, 999_998, 999_999, 1_000_000 ]

proff()
# Executed in 0.38 second(s)

/*--------- #perf

pron()	

o1 = new stzList( 1 : 1_000_000 )
o1.RemoveSection(1, 1_000_000)
? @@( o1.Content() )
#--> [ ]

proff()
# Executed in 0.47 second(s)

/*---------

pron()

o1 = new stzList([ "w", "o", "r", "d", ">", ">", ">" ])
o1.RemoveSection(1, 4)
? @@( o1.Content() )
#--> [ ">", ">", ">" ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([ "<", "<", "w", "o", "r", "d", ">", ">", ">" ])

o1.RemoveSections([ [ 1, 2 ], [ 7, 9 ] ])
? @@( o1.Content() )
#--> [ "w", "o", "r", "d" ]

proff()
# Executed in 0.07 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
o1.RemoveSections([ [ ], [ 5, 7 ] ])
? o1.Content()
#--> ERR: Incorrect param type! paSections must be a list of pairs of numbers.

proff()

/*---------

pron()

o1 = new stzString("word>>>")
o1.RemoveSection(5, 7)
? o1.Content()
#--> word

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzString("<<<word")
o1.RemoveSections([ [ 1, 3 ], [ ] ])
? o1.Content()
#--> ERR: Incorrect param type! paSections must be a list of pairs of numbers.

proff()
# Executed in 0.05 second(s)

/*---------

pron()

o1 = new stzString("<<<word")
o1.RemoveSection(1, 3)
? o1.Content()
#--> word

proff()
# Executed in 0.05 second(s)

/*---------

pron()

# Each string is bounded by default by its first and last chars

o1 = new stzString("word>>>")
? @@( o1.Bounds() )
#--> [ "w", ">" ]

? o1.ContainsBounds() # Or ? o1.IsBounded()
#--> TRUE

# When the string contains some leading and trailing repeated chars,
# then they are considered to be the bounds of that string

o1 = new stzString("<<<word>>>")
? @@( o1.Bounds() )
#--> [ "<<<", ">>>" ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzString("word>>>")
o1.RemoveBounds() # There's no leading and trailing chars (both), so
		  # the first and last chars are considered bound ~> removed
? o1.Content()
#--> ord>>

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")

o1.RemoveTheseBounds("***", "***") # Nothing happens
? o1.Content()
#--> <<<word>>>

o1.RemoveTheseBounds("<<<", "***") # Remove only the first bound
? o1.Content()
#--> word>>>

o1.RemoveBounds() # First and last chars are considered the bounds ~> removed
? o1.Content()
#--> ord>>

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveFirstBound()
? o1.Content()
#--> word>>>

proff()
# Executed in 0.03 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>>")
o1.RemoveLastBound() # Or o1.RemovesecondBound()
? o1.Content()
#--> <<<word

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

? @@( o1.FirstBounds(:Of = "word") )
#--> [ "<<<", "<<", "<" ]

? @@( o1.SecondBounds(:Of = "word") )
#--> [ ">>>", ">>", ">" ]

proff()
# Executed in 0.05 second(s)

/*------

pron()

o1 = new stzString("[word] <word> (word)")
o1.RemoveBoundsOf("word")
? o1.Content()
#--> word word word

proff()
# Executed in 0.05 second(s)

/*------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")
o1.RemoveBoundsOf("word")
? o1.Content()
#--> word word word

proff()
# Executed in 0.07 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveFirstBounds(:Of = "word") # Or o1.RemoveLeftBounds(:Of = "word")
#--> word>>> word>> word>

? o1.Content()

proff()
# Executed in 0.05 second(s)

/*---------

pron()

o1 = new stzString("<<<word>>> <<word>> <word>")

o1.RemoveLastBounds(:Of = "word") # Or o1.RemoveRightBounds(:Of = "word")
? o1.Content()
#--> <<<word <<word <word

proff()
# Executed in 0.05 second(s)

/*========= SWAPPING TWO SECTIONS

pron()

o1 = new stzString(">>>word<<<")
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? o1.Content()
#--> <<<word>>>

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ ">", ">", ">", "w", "o", "r", "d", "<", "<", "<" ])
o1.SwapSections([1, 3], [8, 10]) # or o1.SwapSections([8, 10], [1, 3])
? @@( o1.Content() )
#--> [ "<", "<", "<", "w", "o", "r", "d", ">", ">", ">" ]

proff()
# Executed in 0.05 second(s)

/*---------

pron()
#                   12345678901234567
o1 = new stzString("...>>>word<<<....")

? o1.Section(4, 6)
#--> >>>

? o1.Section(11, 13)
#--> <<<

o1.SwapSections([4, 6], [11, 13])
? o1.Content()
#--> ...<<<word>>>....

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzString(">>>word<<< >>word<< >word<")
o1.SwapBoundsOf("word")
? o1.Content()
#--> <<<word>>> <<word>> <word>

proff()
# Executed in 0.05 second(s)

/*========= #TODO Test after including ...Between()

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

o1 = new stzString("12345 ABC 1234 DEF")

o1.ReplaceSections(
	[ [1, 5] , [11, 14] ],

	:With = '***'
)

? o1.Content()
#--> *** ABC *** DEF

proff()
# Executed in 0.03 second(s)

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
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@( o1.Content() )
#--> [ [ 9, 8 ], [ 7, 4 ], [ 3, 1 ] ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.IsSortedInAscending()
#--> FALSE

o1 = new stzListOfPairs([ [1,3], [4, 7], [8, 9] ])
? o1.IsSortedInAscending()
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.IsSortedInDescending()
#--> FALSE

o1 = new stzListOfPairs([ [9,8], [7,4], [3,1] ])
? o1.IsSortedInDescending()
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
? o1.FindPair([3, 1])
#--> 2

proff()
# Executed in 0.03 second(s)

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
# Executed in 0.04 second(s)

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
# Executed in 0.04 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzString("AB♥♥C♥♥D♥♥E")

? o1.SplitToPartsOfNChars(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥", "E" ]

? o1.SplitToPartsOfExactlyNChars(2) # OR SplitToPartsOfNCHarsXT(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

proff()
# Executed in 0.03 second(s)

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
# Executed in 0.03 second(s)

/*================ LEADING AND TRAILING CHARS

pron()

o1 = new stzString("<<<word>>>")

? o1.ContainsLeadingChars()
#--> TRUE

? o1.NumberOfLeadingChars()
#--> 3

? o1.LeadingChars() + NL
#--> "<<<"

#--

? o1.ContainsTrailingChars()
#--> TRUE

? o1.NumberOfTrailingChars()
#--> 3

? o1.TrailingChars()
#--> ">>>"

proff()
# Executed in 0.03 second(s)

/*================ WORKING WITH BOUNDS OF THE STRING

pron()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? @@( o1.FindBounds() )
#--> [ 1, 8 ]

? @@( o1.FindBoundsAsSections() )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? o1.LeftBound()
#--> <<<

? o1.FindLeftBound()
#--> 1

? @@( o1.FindLeftBoundAsSection() )
#--> [ 1, 3 ]

? @@( o1.LeftBoundZ() )
#--> [ "<<<", 1 ]

? @@( o1.LeftBoundZZ() ) + NL
#--> [ "<<<", [ 1, 3 ] ]

#--

? o1.RightBound()
#--> >>>

? o1.FindRightBound()
#--> 8

? @@( o1.FindRightBoundAsSection() )
#--> [ 8, 10 ]

? @@( o1.RightBoundZ() )
#--> [ ">>>", 8 ]

? @@( o1.RightBoundZZ() ) + NL
#--> [ ">>>", [ 8, 10 ] ]

proff()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.18

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.FindBounds() ) # Same as o1.FindFirstAndLastBounds()
			# You can also use Riht and Left instead of First and Last
#--> [ 1, 8 ]

	? @@( o1.FindLastAndFirstBounds() )
	#--> [ 8, 1 ]

? @@( o1.FindBoundsAsSections() ) # Same as o1.FindFirstAndLastBoundsSasSections()
#--> [ [ 1, 3 ], [ 8, 10 ] ]

	? @@( o1.FindLastAndFirstBoundsAsSections() )
	#--> [ [ 8, 10 ], [ 1, 3 ] ]

proff()
# Executed in 0.04 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>")

? @@( o1.Bounds() )
#--> [ "<<<", ">>>" ]

	? @@( o1.FirstAndLastBounds() )
	#--> [ "<<<", ">>>" ]

	? @@( o1.LastAndFirstBounds() ) + NL
	#--> [ ">>>", "<<<" ]

#--

? @@( o1.BoundsZ() )
#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.FirstAndLastBoundsZ() )
	#--> [ [ "<<<", 1 ], [ ">>>", 8 ] ]

	? @@( o1.LastAndFirstBoundsZ() ) + NL
	#--> [ [ ">>>", 8 ], [ "<<<", 1 ] ]

#--

? @@( o1.BoundsZZ() )
#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

	? @@( o1.FirstAndLastBoundsZZ() )
	#--> [ [ "<<<", [ 1, 3 ] ], [ ">>>", [ 8, 10 ] ] ]

	? @@( o1.LastAndFirstBoundsZZ() )
	#--> [ [ ">>>", [ 8, 10 ] ], [ "<<<", [ 1, 3 ] ] ]

proff()
# Executed in 0.09 second(s)

/*================ WORKING WITH BOUNDS INSIDE THE STRING

pron()

o1 = new stzString(">>word<<")
o1.SwapBounds()
? o1.Content()
#--> <<word>>

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")
? @@( o1.FindSubStringBoundsAsSections("word") ) # Or FindSubStringBoundsZZ()
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindSubStringBounds("word") )
#--> [ 1, 8, 13, 20, 28, 35 ]

proff()
# Executed in 0.06 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

# Bounds of the entire string

? @@( o1.FindStringBoundsAsSections() ) + NL # Or FindStringBoundsZZ()
#--> [ [ 1, 3 ], [ 35, 37 ] ]

# Bounds of a particular substring inside the string

? @@( o1.FindSubStringBoundsAsSections("word") ) + NL # Or FindSubStringBoundsZZ()
#--> [ [ 1, 3 ], [ 8, 10 ], [ 13, 15 ], [ 20, 22 ], [ 28, 30 ], [ 35, 37 ] ]

? @@( o1.FindFirstBoundsOfAsSections("word") ) + NL # Or FindFirstBoundsOfZZ()
#--> [ [ 1, 3 ], [ 13, 15 ], [ 28, 30 ] ]

? @@( o1.FindFirstBoundsOf("word") ) + NL
#--> [ 1, 13, 28 ]

proff()
# Executed in 0.07 second(s)

/*------------------

pron()

o1 = new stzString("<<<word>>>, (((word))) and {{{word}}}")

? @@( o1.FindSubStringSecondBoundsAsSections("word") )
#--> [ [ 8, 10 ], [ 20, 22 ], [ 35, 37 ] ]

? @@( o1.FindSubStringSecondBounds("word") )
#--> [ 8, 20, 35 ]

proff()
# Executed in 0.07 second(s)

/*=============

pron()

o1 = new stzString("123♥^♥789")

? o1.Sit( :OnSection = [4, 6], :AndYield = [ 20, 30 ] )
#--> [ "123", "789" ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")
		
? o1.SubStringIsBoundedBy("♥♥", "aa")
#--> TRUE

? o1.SubStringIsBoundedBy("♥♥", "bb")
#--> TRUE
	
? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] )
#--> TRUE

proff()
# Executed in 0.54 second(s)

/*================

pron()

o1 = new stzList([ Q(4), Q("Ring"), Q(1:3) ])
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

o1 = new stzList([ 6, "hi!", 1:3 ])
o1.Objectify()
? @@( o1.StzTypes() )
#--> [ "stznumber", "stzstring", "stzlist" ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

o1 = new stzList([ 5, "12", 1:3, "Ring" ])
o1.Numberify()
? @@(o1.Content())
#--> [ 5, 12, 3, 4 ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzList([ 1, "hi", [], NULL ])
o1.Listify()
? @@( o1.Content() )
#--> [ [ 1 ], [ "hi" ], [ ], [ "" ] ]

proff()
# Executed in 0.02 second(s)

/*---------------

# Personal note :This sample has been porposed by Teeba (my daughther). She helped me
# identify the [] case and solve it.

pron()
#			vv
o1 = new stzList([ 957, [], [ 1:3, 4:5, 9:12 ], "Hussein", ["Haneen"] ])
o1.Pairify()
? @@( o1.Content() )
#--> [
#	[ 957, "" ],
#	[ "", "" ],
#	[ [ 1, 2, 3 ], [ 4, 5 ] ],
#	[ "Hussein", "" ],
#	[ "Haneen", "" ]
# ]

proff()
# Executed in 0.02 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], "__", [ "--", "--", "--" ] ])
o1.Pairify() # transform all items to pairs
? @@( o1.Content() )
#--> [
#	[ "<<", ">>" ],
#	[ "__", "" ],
#	[ "--", "--" ]
# ]

proff()
# Executed in 0.02 second(s)

/*--------------

pron()

o1 = new stzList(["<<", ">>"])
o1.Pairify()
#--> [ [ "<<", "" ], [ ">>", "" ] ]

? @@( o1.Content() )

proff()
# Executed in 0.02 second(s)

/*--------------

pron()

o1 = new stzList([ ["<<", ">>"] ])
o1.Pairify()
? @@( o1.Content() )
#--> [ [ "<<", ">>" ] ]

proff()
# Executed in 0.02 second(s)

/*--------------

pron()

? @@( Q([ ["<<", ">>"], "__" ]).Pairified() )
#--> [ [ "<<", ">>" ], [ "__", "" ] ]

proff()
# Executed in 0.02 second(s)

/*==============

pron()

o1 = new stzString("<<word>> and __word__")

? o1.SubStringIsBoundedBy("word", ["<<", ">>"])
#--> TRUE

? o1.SubStringIsBoundedBy("word", "__")
#--> TRUE

? o1.SubStringIsBoundedByMany("word", [ ["<<", ">>"], "__" ])
#--> TRUE

proff()
# Executed in 0.12 second(s)

/*------ #TODO: check it after including ContainsSubStringBoundedBy()

pron()

o1 = new stzString("<<word>> and __word__")
? o1.SubStringQ( "word" ).IsBoundedBy(["<<", ">>"])
#--> TRUE

proff()
# Executed in 0.27 second(s)

/*----------------

pron()

	o1 = new stzList([ "<<", ">>" ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> TRUE

	o1 = new stzList([ [ "<<", ">>" ], [ "__", "__" ] ])
	? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
	#--> TRUE

proff()
# Executed in 0.10 second(s)

/*----------------

pron()

o1 = new stzList([ "<<", ">>" ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> __word__ @word@")
#--> TRUE

proff()
# Executed in 0.11 second(s)

/*----------------

pron()

o1 = new stzList([ [ "<<", ">>" ], ["__", "__" ], [ "@", "@" ] ])
? o1.AreBoundsOf("word", :In = "<<word>> and __word__")
#--> FALSE

proff()
# Executed in 0.11 second(s)

/*----------------

pron()

? Q("_").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

? Q("<").IsBoundOf( "world", :In = "hello _world_ and <world>" )
#--> FALSE

? Q([ "<", ">" ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

? Q([ ["<",">"], ["_","_"] ]).AreBoundsOf( "world", :In = "hello _world_ and <world>" )
#--> TRUE

proff()
# Executed in 0.10 second(s)

/*----------------

pron()

o1 = new stzString("aa♥♥aaa bb♥♥bbb")

? o1.SubStringIsBoundedBy("♥♥", "aa")
#--> TRUE
? o1.SubStringIsBoundedBy("♥♥", "bb")
#--> TRUE

? o1.SubStringIsBoundedBy("♥♥", [ "aa", "aaa" ] )
#--> TRUE
? o1.SubStringIsBoundedBy("♥♥", [ [ "aa","aaa" ], [ "bb","bbb" ] ])
#--> TRUE

proff()
# Executed in 0.14 second(s)

/*================= POSSIBLE SUBSTRINGS IN THE STRING

pron()

o1 = Q("ABAAC")
? @@NL( o1.SubStrings() ) + NL
#--> [
# 	"A", "AB", "ABA", "ABAA",
# 	"ABAAC", "B", "BA", "BAA",
# 	"BAAC", "A", "AA", "AAC", "A", "AC", "C"
# ]

? @@NL( o1.SubStringsZ() ) + NL
#--> [
# 	[ "A", [ 1, 3, 4 ] ],
# 	[ "AB", [ 1 ] ],
# 	[ "ABA", [ 1 ] ],
#	[ "ABAA", [ 1 ] ],
#	[ "ABAAC", [ 1 ] ],
#	[ "B", [ 2 ] ],
#	[ "BA", [ 2 ] ],
#	[ "BAA", [ 2 ] ],
#	[ "BAAC", [ 2 ] ],
#	[ "AA", [ 3 ] ],
#	[ "AAC", [ 3 ] ],
#	[ "AC", [ 4 ] ],
#	[ "C", [ 5 ] ]
# ]

? @@NL( o1.SubStringsZZ() )
#--> [
#	[ "A", [ [ 1, 1 ], [ 3, 3 ], [ 4, 4 ] ] ],
#	[ "AB", [ [ 1, 2 ] ] ],
#	[ "ABA", [ [ 1, 3 ] ] ],
#	[ "ABAA", [ [ 1, 4 ] ] ],
#	[ "ABAAC", [ [ 1, 5 ] ] ],
#	[ "B", [ [ 2, 2 ] ] ],
#	[ "BA", [ [ 2, 3 ] ] ],
#	[ "BAA", [ [ 2, 4 ] ] ],
#	[ "BAAC", [ [ 2, 5 ] ] ],
#	[ "AA", [ [ 3, 4 ] ] ],
#	[ "AAC", [ [ 3, 5 ] ] ],
#	[ "AC", [ [ 4, 5 ] ] ],
#	[ "C", [ [ 5, 5 ] ] ]
# ]

proff()
# Executed in 0.02 second(s)

/*=================

pron()

? Q([ "abc", 120, "cdef", 14, "opjn", 988 ]).ToString()

#-->
#	"abc
#	120
#	cdef
#	14
#	opjn
#	988"

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

? Q(["abc","cdef","opjn"]).ToString() + NL # Q() creates a stzList object
#-->
#	abc
#	cdef
#	opjn

proff()
# Executed in 0.03 second(s)

/*================= #Todo: check after including SubstringsBetween()

pron()

o1 = new stzList(["A", "AA", "B", "BB", "C", "CC", "CC" ])
? o1.ItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC", "CC" ])

? o1.UniqueItemsW('len(@item) = 2')
#--> [ "AA", "BB", "CC" ]

proff()

/*---------------- #Todo: check after including SubstringsBetween()

pron()

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

proff()

/*================ #Todo: check after including SubstringsBetween()

pron()

o1 = new stzString("Av♥♥c♥♥")
? o1.FindAll("♥♥") #--> [ 3, 6 ]
? o1.FindSubStringsW('{ @SubString = "♥♥" }') #--> [ 3, 6 ]

proff()

/*=============== #Todo: check after including SubstringsBetween()

pron()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBetween("<<", ">>")
#--> [ "word1", "word2" ]

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? o1.SubstringsBetween('"', '"')
#--> [ "    value ", " 12   " ]

proff()

/*---------------- #Todo: check after including SubstringsBetween()
pron()

o1 = new stzString('len    var1 = "    value "  and var2 =  " 12   " ')
? @@( o1.SubStringsBetween('"','"') )
#--> [ " value ", " 12 " ]

? @@( o1.SubStringsBetweenIB('"','"') )
#--> [ [ " value ", [ 16, 25 ] ], [ " 12 ", [ 42, 47 ] ] ]

? @@( o1.FindSubStringsBetween('"','"') )
#--> [ 16, 42 ]

? @@( o1.FindSubStringsBetweenIB('"','"') )
#--> [ [ 16, " value " ], [ 42, " 12 " ] ]

proff()

/*================

pron()

o1 = new stzString("blabla bla <<word>> bla bla <<word>>")
? @@( o1.FindAsSections("word") ) # Or FindSubStringAsSections() or FindZZ()
#--> [ [14, 17], [31, 34] ]

proff()
# Executed in 0.04 second(s)

/*---------------- #Todo: Check after including findanybetween()

pron()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetween("<<", ">>")
#--> [ 14, 32 ]

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.FindAnyBetweenAsSections("<<", ">>")
#--> [ [14, 18], [32, 36] ]

proff()

/*---------------- #Todo: Check after including findanybetween()

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

/*---------------- #Todo: Check after including findanybetween()

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

pron()

? Q(" this code:   txt1  = ").Simplified()
#--> "this code: txt1 ="

proff()
# Executed in 0.04 second(s)

/*--------------- #Todo: Check after including findanybetween()

pron()

o1 = new stzString(' this code:   txt1  = "<    withspaces    >"   and txt2="<nospaces>"  ')
aAntiSections = o1.FindAntiSections( o1.FindAnyBetweenAsSections('"','"') )

o1.ReplaceSections(aAntiSections, :With = '|***|')
? o1.Content()
#--> '|***|<    withspaces    >|***|<nospaces>|***|'

proff()

/*==============

pron()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***THREE")
#--> TRUE

? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***THREE")
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*----------------

pron()

o1 = new stzString("ONE")

? o1.Occurs( :Before = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> TRUE

? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***", "THREE" ])
#--> FALSE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzNumber(10)
? o1.Occures( :Before = "TEN", :In = [ 2, "TWO", 10, "TEN" ] ) # NOTE: OccurEs is misspelled!
#--> TRUE

o1 = new stzList(1:3)
? o1.Occurs( :Before = 1:7, :In = [ 1:2, "TWO", 1:3, 1:7, "THREE" ] )
#--> TRUE

o1 = new stzObject(ANullObject())
? o1.Comes( :Before = "NULL", :In = [ 1, 2, ANullObject(), "NULL" ] )
#--> TRUE

o1 = new stzString("one")
? o1.Happens( :Before = "two", :In = [ "one", "two", "three" ] )
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*----------------

pron()

? Q("*").OccursNTimes(3, :In = "a*b*c*d")
#--> TRUE

? Q("*").OccursNTimes(3, :In = [ "a", "*", "b", "*", "c", "*", "d" ])
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*----------------

pron()

? Q("*").OccursForTheFirstTime( :In = "a*b*c*d", :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheLastTime( :In = "a*b*c*d", :AtPosition = 6 )
#--> TRUE

? Q("*").OccursForTheLastTime( :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 ) #--> TRUE
#--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheNthTime( 2, :In = "a*b*c*d", :AtPosition = 4 )
#--> TRUE

? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 )
#--> TRUE

? Q("*").OccursForTheNthTime( 1, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 2 )
#--> TRUE

? Q("*").OccursForTheNthTime( 2, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 4 )
#--> TRUE

? Q("*").OccursForTheNthTime( 3, :In = [ "a", "*", "b", "*", "c", "*", "d" ], :AtPosition = 6 )
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*----------------

pron()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 1 )
#--> TRUE

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 2 )
#--> TRUE

? Q("shirt").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 3 )
#--> FALSE

? Q("bag").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 4 )
#--> TRUE

? Q("hat").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 5 )
#--> TRUE

? Q("shoes").OccursForTheFirstTime( :In = aShoppingCart, :AtPosition = 6 )
#--> FALSE

proff()
# Executed in 0.04 second(s)

/*---------------- #TODO: check it after including substringsbetween()

pron()

aShoppingCart = [ "shirt", "shoes", "shirt", "bag", "hat", "shoes" ]

? Q(aShoppingCart).FindW('{
	Q(@item).OccursForTheFirstTime( :In = aShoppingCart, :At = @CurrentPosition )
}')
#--> [ 1, 2, 4, 5 ]

proff()

/*================ #TODO: check it after including substringsbetween()

pron()

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

proff()

/*=========

pron()

? ComputableForm('len    var1 = "    value "  and var2 =  " 12   " ') + NL
#--> 'len var1 = "    value " and var2 = " 12   "'

? ComputableForm("len    var1 = '    value '  and var2 =  ' 12   ' ")
#--> "len    var1 = '    value '  and var2 =  ' 12   ' "

proff()
# Executed in 0.01 second(s)

/*================= CHECK PERFORMANCE
#TODO: check it after including FindSubStringsW()

pron()

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

proff()

/*------------- # TODO: check ERROR
#TODO: check it after including FindSubStringsW()

pron()

o1 = new stzString("Av♥♥c♥♥")
? @@( o1.FindSubStringsW('{
	Q(@SubString).NumberOfChars() = 2 and NOT Q(@SubString).Contains("♥")
}') )

#--> ERROR
# Line 11126 Error (R3) : Calling Function without definition !: 2andnotq 
# In method findallitemsw() in file D:\GitHub\SoftanzaLib\libraries\softanzalib\stzList.ring

# The problem is that the evaluated code has spaces removed, like this:
# bOk = ( Q( @item ).NumberOfChars()=2andNOTQ( @item ).Contains("♥") )

proff()

/*=================

pron()

o1 = new stzString("I love ")
o1.AddSubString("Ring")
? o1.Content()
#--> I love Ring

proff()
# Executed in 0.01 second(s)

#-----------------

pron()

o1 = new stzString("Ring")
o1.ExtendToNCharsXT(10, :Using = ".")
? o1.Content()
#--> "Ring.........."

proff()
# Executed in 0.02 second(s)

/*=================

pron()

? Q("-♥-").IsBoundedBy("-")
#--> TRUE

? Q("♥").IsBoundedByIB("-", :In = "... -♥- ...")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*---------------- #TODO: check it again after including findsubstringsbetween()

pron()

o1 = new stzString("Av♥♥c♥♥")

? o1.FindW('{
	Q(@SubString).NumberOfChars() = 2 and
	Q(@SubString).IsBoundedBy@_( "Q(@Char).IsLowercase()", "_" ) 

}')

proff()

/*----------------

pron()

? StzCharQ(1049).Content() + NL
#--> Й

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

proff()
# Executed in 0.17 second(s)

/*-------------- #TODO: Use the normal way (ExecutableSection) and check for perf

pron()

? @@( Q("℺℻ℚ").Yield('[ @char, Q(@char).Unicode(), Q(@char).CharName() ]') )
#--> [
# 	[ "℺", 8506, "ROTATED CAPITAL Q" ],
# 	[ "℻", 8507, "FACSIMILE SIGN" ],
# 	[ "ℚ", 8474, "DOUBLE-STRUCK CAPITAL Q" ]
#    ]

proff()
# Executed in 0.14 second(s)

/*============== #TODO: check it again after including substringsbetween()

pron()

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

proff()

/*----------------

pron()

? len("طيبة") #--> 8

? StzStringQ("طيبة").NumberOfChars()
#--> 4

? StzStringQ("طيبة").NumberOfBytes()
#--> 8

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = Q("TAYOUBAAOOAA")
? o1.LastAndFirstChars()
#--> [ "A", "T" ]

proff()
# Executed in 0.01 second(s)

/*---------------- #TODO: Check it after including between()

pron()

o1 = new stzList([ "A", "B", "♥", "♥", "C", "♥", "♥", "D", "♥","♥" ])
? o1.FindWXT('{ @CurrentItem = @NextItem }')
#--> [ 3, 6, 9 ]

? o1.FindFirstWXT(' @CurrentItem = @NextItem ')
#--> 3
? o1.FindLastWXT(' @CurrentItem = @NextItem ')
#--> 9
? o1.FindNthWXT(2, ' @CurrentItem = @NextItem ')
#--> 6

proff()

/*----------------

pron()

o1 = new stzList("A":"E")
? @@( o1 / 3 )
#--> [ [ "A", "B" ], [ "C", "D" ], [ "E" ] ]

proff()
# Executed in 0.04 second(s)

/*------- #ring

pron()

aList = []
for i = 1 to 5
	aList + [1]
next

? @@(aList)
#--> [ [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]

proff()

/*=======

pron()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(0) ) + NL
#--> [ ]

? @@( o1.SplitToNParts(1) ) + NL
#--> [ [ 1, 12 ] ]

? @@( o1.SplitToNParts(2) ) + NL
#--> [ [ 1, 6 ], [ 7, 12 ] ]

? @@( o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 12 ] 

? @@( o1.SplitToNParts(4) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 12 ] ]

? @@( o1.SplitToNParts(5) ) + NL
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(6) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToNParts(7) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(8) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(9) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(10) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(11) ) + NL
#--> [ [ 1, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

? @@( o1.SplitToNParts(12) ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 3 ], [ 4, 4 ], [ 5, 5 ], [ 6, 6 ], [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 10, 10 ], [ 11, 11 ], [ 12, 12 ] ]

proff()
# Executed in 0.04 second(s)

/*---------

pron()

o1 = new stzSplitter(12)

? @@( o1.SplitToNParts(13) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

? @@( o1.SplitToNParts(-2) )
#--> Error message: Incorrect value! n must be between 0 and 12 (the size of the list)

proff()

/*---------

pron()

o1 = new stzSplitter(10)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 7 ], [ 8, 10 ] ]

o1 = new stzSplitter(11)
? @@(o1.SplitToNParts(3) ) + NL
#--> [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ] ]

o1 = new stzSplitter(17)
? @@(o1.SplitToNParts(5) ) + NL
# [ [ 1, 4 ], [ 5, 8 ], [ 9, 11 ], [ 12, 14 ], [ 15, 17 ] ]

o1 = new stzSplitter(78)
? @@(o1.SplitToNParts(12) )
#--> [
# 	[  1,  7 ], [  8, 14 ], [ 15, 21 ],
# 	[ 22, 28 ], [ 29, 35 ], [ 36, 42 ],
#	[ 43, 48 ], [ 49, 54 ], [ 55, 60 ],
#	[ 61, 66 ], [ 67, 72 ], [ 73, 78 ]
# ]

o1 = new stzSplitter(0)
? @@(o1.SplitToNParts(5) )
#--> []

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzString("ABCDEFGHIJ")

? @@( o1 / 10 ) + NL
#--> [ "A" ,"B", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 9 ) + NL
#--> [ "AB", "C", "D", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 8 ) + NL
#--> [ "AB", "CD", "E", "F", "G", "H", "I", "J" ]

? @@( o1 / 7 ) + NL
#--> [ "AB", "CD", "EF", "G", "H", "I", "J" ]

? @@( o1 / 6 ) + NL
#--> [ "AB", "CD", "EF", "GH", "I", "J" ]

? @@( o1 / 5 ) + NL
#--> [ "AB", "CD", "EF", "GH", "IJ" ]

? @@( o1 / 4 ) + NL
#--> [ "ABC", "DEF", "GH", "IJ" ]

? @@( o1 / 3 ) + NL
#--> [ "ABCD", "EFG", "HIJ" ]

? @@( o1 / 2 ) + NL
#--> [ "ABCDE", "FGHIJ" ]

? @@( o1 / 1 ) + NL
#--> [ "ABCDEFGHIJ" ]

? @@( o1 / 0 )
#--> [ ]

proff()
# Executed in 0.12 second(s)

/*---------

pron()

o1 = new stzString("ABCDEFGHIJ")
? @@( o1 / 89 )
#--> Error message: Incorrect value! n must be between 0 and 10 (the size of the list).

proff()

/*=============

pron()

o1 = Q("AB♥♥C♥♥D♥♥")
? o1.FindCharsW(' @Char = "♥" ')
#--> [ 3, 4, 6, 7, 9, 10 ]

? o1.FindCharsW(' @CurrentChar = @NextChar ')
#--> [ 3, 6, 9 ] 

? o1.FindNthCharW(2, '@CurrentChar = @NextChar') + NL
#--> 6

? o1.FindFirstCharW('@CurrentChar = @NextChar') + NL
#--> 3

? o1.FindLastCharW('@CurrentChar = @NextChar')	 #--> 9
#--> 9

proff()
# Executed in 0.99 second(s) in Ring 1.20
# Executed in 1.38 second(s) in Ring 1.18

/*----------------

pron()

@T = Q("TAYOUBA")
? @T.Section( :From = "A", :To = "B" )
#--> AYOUB

? @T.Section( :From = :FirstChar, :To = @T.First("A") )
#--> TA

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzString("SOFTANZA")

? o1.Section( :From = o1.PositionOfFirst("A"), :To = :LastChar )
#--> ANZA

? o1.Section( :From = o1.First("A"), :To = :LastChar )
#--> ANZA

proff()
# Executed in 0.02 second(s)


/*----------------

pron()

o1 = new stzList([ "T","A","Y","T","O", "A", "U", "B", "T", "A" ])
? @@( o1.Section(:From = "A", :To = "T") ) + NL
#--< [ "A", "Y", "T", "O", "A", "U", "B", "T" ]

? @@SP( o1.SectionsBetween( "T", :And = "A" ) )
#--> [
#	[ "T", "A" ],
#	[ "T", "A", "Y", "T", "O", "A" ],
#	[ "T", "A", "Y", "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "O", "A" ],
#	[ "T", "O", "A", "U", "B", "T", "A" ],
#	[ "T", "A" ]
# ]

proff()
# Executed in 0.02 second(s)

/*---------------- #TODO/FUTURE: Implement these functions

pron()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])
? o1.ContainsInEachList("♥")

? o1.ContainsInJustOneList("♥")

? o1.ContainsInNLists(3, "♥")
? o1.ContainsNOccurrencesInAllLists(3, "♥")
? o1.ConatinsNOccurrencesInEachList(1, "♥")
? o1.ContainsNOccurrencesInNLists(1, 3, "♥")
? o1.ContainsNOccurrencesInTheseLists([ [1, 1], [3, 2] ])

proff()

/*---------------- #todo/future: add these functions

pron()

o1 = new StzListOfLists([ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ])

aListOfLists = [ [ "_", "♥", "_" ], [ "_", "_", "_" ],  [ "_", "♥", "_" ] ]
? Q("♥").ExistsIn( aListOfLists  )
? Q("♥").ExistsInLists( aListOfLists  )
? Q("♥").ExistsInOnlyOneList( aListOfLists )
? Q("♥").ExistsInNLists(2, aListOfLists )
? Q("♥").ExistsNTimesInAllLists(3, aListOFLists )
? Q("♥").ExistsNTimesInEachList(3, aListOFLists )
? Q("♥").ExistsNTimesInNLists(3, 2, aListOFLists )
? Q("♥").ExistsNTimesInTheseLists([ [1, 1], [3, 2] ])

proff()

/*----------

pron()

? 3Hearts() #--> ♥♥♥
? 5Stars()  #--> ★★★★★

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindFirstNOccurrences(2, :Of = "ring")
#--> [ 2, 4 ]

? o1.FindLastNOccurrences(2, :Of = "ring")
#--> [ 4, 6 ]

? o1.FindTheseOccurrences([2, 3], :Of = "ring")
#--> [ 4, 6 ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindNthOccurrence(3, "ring")
#--> 5

proff()
# Executed in 0.01 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

? o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
#--> [ 1, 7 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 7 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])

anPos = o1.FindTheseOccurrences([ :First, :Last ], :Of = "ring")
? anPos
#--> [ 1, 7 ]

o1.RemoveItemsAtPositions(anPos)
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
? o1.FindTheseOccurrences([1, 4], "ring")
#--> [ 1, 7 ]

o1.RemoveItemsAtPositions([1, 7])
? @@( o1.content() )
#--> [ "__", "ring", "__", "ring", "__" ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.RemoveOccurrences([ :First, :Last ], :Of = "ring" )
? @@( o1.Content() )
#--> [ "__", "ring", "__", "ring", "__" ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceOccurrences([ :First, :And = :Last ], :Of = "ring", :With = 3Hearts() )
? @@( o1.Content() )
#--> [ "♥♥♥", "__", "ring", "__", "ring", "__", "♥♥♥" ]

proff()
# Executed in 0.09 second(s)

/*----------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceFirstNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() )
#--> [ "★★", "__", "★★", "__", "ring", "__", "ring" ]

proff()
# Executed in 0.02 second(s)

/*------

pron()

o1 = new stzList([ "ring", "__", "ring", "__", "ring", "__", "ring" ])
o1.ReplaceLastNOccurrences(2, :Of = "ring", :With = 2Stars() )
? @@( o1.Content() )
#--> [ "ring", "__", "ring", "__", "★★", "__", "★★" ]

proff()
# Executed in 0.11 second(s)

/*==============

pron()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.FindTheseOccurrences([ :First, :And = :Last ], "ring")
#--> [ 1, 25 ]

? o1.FindTheseOccurrences([ 1, 4 ], "ring")
#--> [ 1, 25 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # or FindNthOccurrence(2, "ring")
#--> 9

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
? anPos
#--> [ 1, 9, 17 ]

o1.ReplaceSubStringAtPositions(anPos, "ring", Heart())

? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.ReplaceFirstNOccurrences(3, "ring", Heart())
? o1.Content()
#--> ♥ __ ♥ __ ♥ __ ring

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveSubStringAtPosition(1, "ring")
? o1.Content()
#-->  __ ring __ ring __ ring

proff()
# Executed in 0.01 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
anPos = o1.FindFirstNOccurrences(3, "ring")
? @@( anPos )
#--> [ 1, 9, 17 ]

o1.RemoveSubStringAtPositions(anPos, "ring")
? o1.Content()
#--> " __  __  __ ring"

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")
? o1.FindOccurrences([ 2, 3 ], "ring")
#--> [ 9, 17 ]

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveOccurrences([2, 3], "ring")
? o1.Content() + NL
#--> ring __  __  __ ring

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveFirstNOccurrences(3, "ring")
? o1.Content() + NL
#--> " __  __  __ ring"

o1 = new stzString("ring __ ring __ ring __ ring")
o1.RemoveLastNOccurrences(3, "ring")
? o1.Content()
#--> "ring __  __  __ "

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("ring __ ring __ ring __ ring")

? o1.SubStringOccurrenceByPosition(9, "ring")
#--> 2

? o1.SubStringPositionByOccurrence(2, "ring") # o1.FindNthOccurrence(2, "ring")
#--> 9

proff()
# Executed in 0.02 second(s)

/*========

pron()

o1 = new stzHashList([ [ "hussein", 3 ], [ "haneen", 1 ], [ "teeba", 3 ] ])
? o1.ValuesQR(:stzListOfNumbers).Sum()
#--> 7

proff()
# Executed in 0.03 second(s)

/*----

pron()

? sum(1:10)
#--> 55

proff()
# Executed in 0.02 second(s)

/*================ @narration

pron()

# In Softanza, you can divide the content of a string into 3 parts
cLetters = "ABCDEFG"

? Q(cLetters) / 3
#--> [ "ABC", "DE", "FG" ]

# Those 3 parts can be "named" parts:

? Q(cLetters) / [ "Hussein", "Haneen", "Teeba" ]
#--> [ :Hussein = "ABC", :Haneen = "DE", :Teeba = "FG" ]

# And you can configure the share of each part at your will:
? Q(cLetters) / [ :Hussein = 3, :Haneen = 1, :Teeba = 3 ]
#--> [ :Hussein = "ABC", :Haneen = "D", :Teeba = "EFG" ]

proff()
#--> Executed in 0.07 second(s)

/*====================

pron()

o1 = new stzSplitter(10)

? @@( o1.SplitBeforePositions([3,7]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :atPosition = 15) ) # Note that position 15 is out of the string
#-->[ "1234567890" ]

proff()
# Executed in 0.02 second(s)

/*------

pron()

o1 = new stzString("1234567890")

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ "1234", "67890" ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ "12", "456", "890" ]

? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ "1234", "567890" ]

? @@( o1.SplitXT( :before = [3, 7] ) ) + NL
#--> [ "12", "3456", "7890" ]

? @@( o1.SplitXT( :after = 5 ) ) + NL
#--> [ "12345", "67890" ]

? @@( o1.SplitXT( :after = [3, 7] ) ) + NL
#--> [ "123", "4567", "890" ]

? @@( o1.SplitXT( :ToPartsOfNChars = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ "123", "456", "789" ]

? @@( o1.SplitXT( :ToPartsOfNCharsXT = 3 ) ) + NL # remaining part is added
#--> [ "123", "456", "789", "0" ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ "123", "456", "78", "90" ]

proff()
# Executed in 0.39 second(s)

/*------

pron()

o1 = new stzList(1:10)

? @@( o1.SplitXT( :at = 5) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :at = [3, 7] ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
# List is returned as-is (no split) because the item [3, 7] does not exist in 1:10

# If you want to say by [3, 7] the positions 3 and 7, be explicit and write:
? @@( o1.SplitXT( :atPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 4, 5, 6 ], [ 8, 9, 10 ] ]


? @@( o1.SplitXT( :before = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :beforePositions = [3, 7] ) ) + NL
#--> [ [ 1, 2 ], [ 3, 4, 5, 6 ], [ 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPosition = 5 ) ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 6, 7, 8, 9, 10 ] ]

? @@( o1.SplitXT( :AfterPositions = [3, 7] ) ) + NL
#--> [ [ 1, 2, 3 ], [ 4, 5, 6, 7 ], [ 8, 9, 10 ] ]

? @@( o1.SplitXT( :ToPartsOfNItems = 3 ) ) + NL # or :ToPartsOfExactlyNChars
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

? @@( o1.SplitXT( :ToPartsOfNItemsXT = 3 ) ) + NL # remaining part is added
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

? @@( o1.SplitXT( :ToNParts = 4 ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

proff()
# Executed in 0.42 second(s)

/*================

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAt(4) )	# or SplitAtPosition(4)
#--> [ "ONE", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAt([ 4, 8 ]) ) # or SplitAtPositions([4, 8])
#--> [ "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitBefore(4) ) # or SplitBeforePosition(4)
#--> [ "ONE", "_TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitBefore([ 4, 8 ]) ) # or SplitBeforePositions([ 4, 8 ])
#--> [ "ONE", "_TWO", "_THREE" ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzString("ONE_TWO")
? @@( o1.SplitAfter(4) ) # or SplitAfterPosition(4)
#--> [ "ONE_", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@( o1.SplitAfter([ 4, 8 ]) ) # or SplitAfterPositions([ 4, 8 ])
#--> [ "ONE_", "TWO_", "THREE" ]

proff()
# Executed in 0.06 second(s)

/*==================

pron()

o1 = new stzString("ABCDE")
? @@( o1.SplitToNParts(5) ) + NL
#--> [ "A", "B", "C", "D", "E" ]

o1 = new stzString("AB12CD34")
? @@( o1.SplitToPartsOfNChars(2) ) + NL
#--> [ "AB", "12", "CD", "34" ]

o1 = new stzString("ABC123DEF456")
? @@( o1.SplitToPartsOfNChars(3)) + NL
#--> [ "ABC", "123", "DEF", "456" ]

o1 = new stzString("ABCD1234EF")
? @@( o1.SplitToPartsOfNChars(4)) + NL # SplitToPartsOfExactlyNChars
#--> [ "ABCD", "1234" ]

? @@( o1.SplitToPartsOfNCharsXT(4)) # The remaining part is also returned
#--> [ "ABCD", "1234", "EF" ]

proff()
# Executed in 0.04 second(s)

/*===================

pron()

? Q(0).IsMultipleOf(3) #--> FALSE

proff()
# Executed in 0.02 second(s)

/*------------------

pron()

o1 = new stzString("123456789012")
? @@( o1.SplitW( 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitW( :At = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) ) + NL
#--> [ "12", "45", "78", "012" ]

? @@( o1.SplitAtW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

proff()
# Executed in 0.85 second(s)

/*==================)

pron()

? Q("12_500").IsNumberInString()
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*------------------

pron()

o1 = new stzString("one = 12_500 two = 17_500 three = 88")
? o1.Numbers()
#--> [ "12_500", "17_500", "88" ]

proff()
# Executed in 0.06 second(s)

/*------------------

pron()

? ToNumber(5) # or Val(5)
#--> 5

? ToNumber("12.5")
#--> 12.50

? ToNumber("12_500")
#--> 12500

proff()
# Executed in 0.02 second(s)

/*------------------

pron()

? Numberify(5)
#--> 5

? Numberify("12.5")
#--> 12.50

? Numberify("12_550")
#--> 12550

? Numberify([ "5", "12.5", "12_550" ])
#--> [ 5, 12.50, 12550 ]

proff()
# Executed in 0.02

/*------------------

pron()

o1 = new stzString("12_500")
? o1.ToNumber()
#--> 12500

proff()
# Executed in 0.02 second(s)

/*------------------

pron()

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :Before = 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeW( 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@( o1.SplitBeforeW( :Where = 'StzCharQ(@char).IsANumber() and Q(0+ @char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

proff()
# Executed in 0.74 second(s)

/*------------------

pron()

o1 = new stzString("__3__6__9__")

? @@( o1.SplitW( :After = 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( :Where = 'StzCharQ(@char).IsANumber() and Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

proff()
# Executed in 0.66 second(s)

/*------------------ #TODO: check it after including SubStringsBetween()

pron()

o1 = new stzList([ "__", 3, "__", 6, "__", 9, "__" ])

? @@( o1.SplitW( :After = 'Q(@item).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( 'Q(@item).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@( o1.SplitAfterW( :Where = 'Q(@item).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

proff()
# Executed in 0.74 second(s)

/*==================

pron()

o1 = new stzList([ "a", "abcade", "abc", "ab", "b", "aaa", "abcdaaa" ])

o1.SortUpBy('len(@item)') + NL
? @@( o1.Content() )
#--> [ "a", "b", "ab", "aaa", "abc", "abcade", "abcade" ]

#TODO

? o1.SortDownBy('Q(@item).HowMany("a")') # or SortInDescendingBy()
? @@( o1.Content() )
#--> [ "aaa", "abcade", "abcade", "abc", "ab", "a", "b" ]

proff()
# Executed in 0.08 second(s)

/*------------------

pron()

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortDownBy('len(@item)')
? o1.Content()
#--> [ "abcde", "abcd", "abc", "ab", "a" ]

proff()
# Executed in 0.04 second(s)

/*==================

pron()

o1 = new stzString("TUNISiiiGAFSAIIIBEJAiiiSFAXIIIGBELLI")
? @@( o1.Splitcs("iii", :CS = FALSE) )
#--> [ "TUNIS", "GAFSA", "BEJA", "SFAX", "GBELLI" ]

proff()
# Executed in 0.02 second(s)

/*------------------

pron()

o1 = new stzString("TUNIS tunis GAFSA gafsa NABEUL nabeul BEJA beja")

? @@( o1.Words() ) + NL
#--> [ "TUNIS", "tunis", "GAFSA", "gafsa", "NABEUL", "nabeul", "BEJA", "beja" ]

? @@( o1.WordsCS(FALSE) ) + NL
#--< [ "TUNIS", "GAFSA", "NABEUL", "BEJA" ]

proff()
# Executed in 0.03 second(s)

/*------------ #ring #sort #narration
#NOTE: read this discussion with Mahmoud
# https://groups.google.com/g/ring-lang/c/bwWg4Qy6_e4

pron()

# Ring provides a powerful function for sorting a list of lists
# based on a given column. Here is an example:

aList = [
	[ "a", 1 ], [ "b", 1 ], [ "c", 1 ], [ "d", 1 ],
	[ "ab", 2 ], [ "cd", 2 ],
	[ "abc", 3 ],
	[ "abcd", 4 ],
	[ "bccd", 4 ],
	[ "bc", 2 ],
	[ "bcd", 3 ],
	[ "dda", 3 ]
]

? @@SP( sort(aList, 2) ) + NL
#--> [
#	[ "c", 1 ],
#	[ "d", 1 ],
#	[ "a", 1 ],
#	[ "b", 1 ],
#
#	[ "bc", 2 ],
#	[ "cd", 2 ],
#	[ "ab", 2 ],
#
#	[ "bcd", 3 ],
#	[ "abc", 3 ],
#	[ "dda", 3 ],
#
#	[ "abcd", 4 ],
#	[ "bccd", 4 ]
# ]

# Unfortunately, the lists with the same value in the nth column
# are not sorted. Not only that, but even their initial order
# (is not preserved! Softanza proposes a corrective function
# to deal with that:

? @@SP( ring_sort2(aList, 2) )
#--> [
#	[ "a", 1 ],
#	[ "b", 1 ],
#	[ "c", 1 ],
#	[ "d", 1 ],

#	[ "ab", 2 ],
#	[ "bc", 2 ],
#	[ "cd", 2 ],

#	[ "abc", 3 ],
#	[ "bcd", 3 ],
#	[ "dda", 3 ],

#	[ "abcd", 4 ],
#	[ "bccd", 4 ]
# ]

# This function is used in the background for sorting
# tables and lists of lists.

proff()
# Executed in 0.02 second(s)

/*------------

pron()

aList = [ "a", "b", "c", "d", "ab", "cd", "abc", "abcd", "bc", "bcd" ]
? @@SP( sorton(aList, 2) )

proff()

/*------------

pron()

? @@SP(
	StzListQ([ "D", "B", "A", "C", "B", "B" ]).ItemsZ()
)

#--> [
#	[ "D", [ 1 ] ],
#	[ "B", [ 2, 5, 6 ] ],
#	[ "A", [ 3 ] ],
#	[ "C", [ 4 ] ]
# ]

proff()
# Executed in 0.02 second(s)

/*------------

pron()

myObjName = StzNamedObjectQ(:myobjname = ANullObject())

aList = [
	[ "a", 1, "_" ], myObjName, 
	[ "f", 1, "_" ], [ "a", 1, "_" ], [ "b", 1, "_" ], [ "c", 1, "_" ], [ "d", 1, "_" ],
	[ "cd", 2, "_" ], [ "bc", 2, "_" ], [ "ab", 2, "_" ], 
	[ "bcd", 3, "_" ], [ "abc", 3, "_" ], myObjName,
	[ 5.7, 0, "_" ], [ "", 0, "_" ],
	[ "abcd", 4, "_" ], myObjName
]

? @@NL( StzListQ(aList).ItemsZ() )
#--> [
#	[ [ "a", 1, "_" ], [ 1, 4 ] ],
#	[ myobjname, [ 2, 13, 17 ] ],
#	[ [ "f", 1, "_" ], [ 3 ] ],
#	[ [ "b", 1, "_" ], [ 5 ] ],
#	[ [ "c", 1, "_" ], [ 6 ] ],
#	[ [ "d", 1, "_" ], [ 7 ] ],
#	[ [ "cd", 2, "_" ], [ 8 ] ],
#	[ [ "bc", 2, "_" ], [ 9 ] ],
#	[ [ "ab", 2, "_" ], [ 10 ] ],
#	[ [ "bcd", 3, "_" ], [ 11 ] ],
#	[ [ "abc", 3, "_" ], [ 12 ] ],
#	[ [ 5.70, 0, "_" ], [ 14 ] ],
#	[ [ "", 0, "_" ], [ 15 ] ],
#	[ [ "abcd", 4, "_" ], [ 16 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*==========

pron()

o1 = new stzListOfLists([
	[ 1 ],
	[ "one", "two" ],
	[ ]
])

o1.AddCol([ 2, "three", 0 ])
? @@NL( o1.Content() )
#--> [
#	[ 1, 2 ],
#	[ "one", "two", "three" ],
#	[ 0 ]
# ]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzListOfLists([
	[ 1 ],
	[ "one", "two" ],
	[ ]
])

o1.AddColXT([ 2, "three", 0 ])
? @@NL( o1.Content() )
#--> [[
	[ 1, 	 "", 	2 	],
	[ "one", "two", "three" ],
	[ "", 	 "", 	 0 	]
]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

aList = [
	[ "a", 1, "_" ],
	[ "f", 1, "_" ], [ "a", 1, "_" ], [ "b", 1, "_" ], [ "c", 0 ], [ "d", 1, "_" ],
	[ "cd", 2, "_" ], [ "bc", 2, "_" ], [ "ab", 2 ], 
	[ "bcd", 3, "_" ], [ "abc", 3 ], 
	[ 5.7, 0, "_" ], [ "", 0, "_" ],
	[ "abcd", 4, "_" ]
]

? @@NL( @SortOn2(aList, 2) ) + NL
#--> [
#	[ "", 		0, 	'_'  	],
#	[ 5.70, 	0, 	"_"  	],
#	[ "c", 		0 		],
#
#	[ "a", 		1, 	"_"  	],
#	[ "a", 		1, 	"_"  	],
#	[ "b", 		1, 	"_"  	],
#	[ "d", 		1, 	"_"  	],
#	[ "f", 		1, 	"_"  	],
#
#	[ "ab", 	2 		],
#	[ "bc", 	2, 	"_"  	],
#	[ "cd", 	2, 	"_"  	],
#
#	[ "abc", 	3 		],
#	[ "bcd", 	3, 	"_"  	],
#
#	[ "abcd", 	4, 	"_"  	]
# ]

? @@NL( @sorton2(aList, 1) )
#--> [
#	[     "", 	0, "_" ],
#	[   5.70, 	0, "_" ],
#
#	[    "a", 	1, "_" ],
#	[    "a", 	1, "_" ],
#	[   "ab", 	2 ],
#	[  "abc", 	3 ],
#	[ "abcd",  	4, "_" ],
#
#	[    "b",  	1, "_" ],
#	[   "bc", 	2, "_" ],
#	[  "bcd", 	3, "_" ],
#
#	[    "c", 	0 ],
#	[   "cd", 	2, "_" ],
#
#	[    "d", 	1, "_" ],
#
#	[    "f", 	1, "_" ]
# ]
# Takes 0.02 second(s)

proff()
# Executed in 0.02 second(s)

/*------------

pron()

o1 = new stzList([ "f", "a", "b", "c", "d", "ab", "cd", "abc", "abcd", "bc", "bcd" ])
? o1.SortedBy(' Q(@item).NumberOfChars() ')
#--> [ 
#	a
#	b
#	c
#	d
#	f
#
#	ab
#	bc
#	cd
#
#	abc
#	bcd
#	abcd
# ]

proff()
# Executed in 0.04 second(s)

/*----------- #ring

pron()


? @@NL( ring_sort2([
	[ [ 2100, 3007 ], 2 ],
	[ [ 0, 150, 170 ], 1 ],
	[ [ 2, 8 ], 0 ],
	[ [ 10001 ], 3 ]
], 2) )

#--> [
#	[ [ 2, 8 ], 		0 ],
#	[ [ 0, 150, 170 ], 	1 ],
#	[ [ 2100, 3007 ], 	2 ],
#	[ [ 10001 ], 		3 ]
# ]

proff()
# Executed in 0.02 second(s)

/*------------

pron()

? @IsListOfPairsOfNumbers([ [ 1, 2 ], [ 8, 10 ], [ 16, 17 ], [ 23, 25 ] ])
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*------------ #ring

pron()

? @@( ring_sort([]) )
#--> []

? @@( ring_sort2([], 3) )
#--> []

proff()
# Executed in 0.02 second(s)

/*------------

pron()

? @@( SortBy([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ], ' Q(@item).HowMany(0) ') )
#--> [
#	2,
#	8,
#	10001,
#	2100,
#	3007,
#	150,
#	170,
#	0
# ]

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])

? @@( o1.SortedBy(' Q(@item).HowMany(0) ') )
#--> [
#	2,
#	8,
#	10001,
#	2100,
#	3007,
#	150,
#	170,
#	0
# ]

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzList([ 3007, 2100, 170, 8, 10001, 2, 0, 150 ])

? @@( o1.SortedDownBy( ' Q(@item).HowMany(0) ') )
#--> [ 10001, 3007, 2100, 170, 150, 0, 8, 2 ]

proff()
#--> Executed in 0.06 second(s)

/*------------

pron()

o1 = new stzList([ 1:3, "tunis", [], 1:2, "t", "" ])
? @@( o1.SortedBy(' Q(@item).Size() ') )

#--> [ "", [ ], 't', [ 1, 2 ], [ 1, 2, 3 ], 'tunis' ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzString("abcd")
acSubStrings = o1.SubStrings()
? @@( acSubStrings )
#--> [ "a", "ab", "abc", "abcd", "b", "bc", "bcd", "c", "cd", "d" ]

# If you want, you can sort them :

? sort(acSubStrings) # Ring standar function is ised here
#--> [
#	"a",
#	"ab",
#	"abc",
#	"abcd",
#
#	"b",
#	"bc",
#	"bcd",
#
#	"c",
#	"cd",
#
#	"d"
# ]

# If you want to sort them by the number of chars :

? SortBy( acSubStrings, 'Q(@item).NumberOfChars()' ) # It's a Softanza function
#--> [
#	a
#	b
#	c
#	d
#
#	ab
#	bc
#	cd
#
#	abc
#	bcd
#
#	abcd
# ]

proff()
# Executed in 0.04 second(s)

/*================

pron()

o1 = new stzString( "ABCabcEFGijHI" )
? @@( o1.SubStringsW('Q(@SubString).IsUppercase()') )
#--> [ "A", "AB", "ABC", "B", "BC", "C", "E", "EF", "EFG", "F", "FG", "G", "H", "HI", "I" ]

? @@SP( o1.PartsUsing('Q(@char).CharCase()') )
#--> [
#	[ "ABC", "uppercase" ],
#	[ "abc", "lowercase" ],
#	[ "EFG", "uppercase" ],
#	[ "ij", "lowercase" ],
#	[ "HI", "uppercase" ]
# ]

proff()
#--> Executed in 0.68 second(s)

/*----------------

pron()

o1 = new stzString( "ABCabcEFGijHI" )
? o1.SplitW( 'Q(@SubString).IsLowercase()' )
#--> [ "ABC", "EFG", "HI" ]

proff()
#--> Executed in 0.32 second(s)

#NOTE
# This function was impossible to implement without implementing
# the MergeIncusive() in stzListOfPairs

#===========

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.SectionCS( :From = "RING", :To = :LastChar, :CaseSensitive = FALSE )
#--> Ring programming language

proff()
# Executed in 0.04 second(s)

/*-----------

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.Section(:From = "Ring", :To = "language")
#--> Ring programming language

proff()
# Executed in 0.04 second(s)

/*----------- @narration

pron()

# Softanza make programming in Ring even more expressive.

# To showcase this, let's consider how substr() function is used in Ring,
# and how Softanza offers it's way of making the same thing.

# In Ring, the substr() function does many things:
#	--> Finding a substring
#	--> Getting the substring starting at a given position
#	--> Getting the substring made of n given chars starting at a given position
#	--> Replacing a sbstring by an other substring (with or without casesensitivity)

# We are going to perform all these actions, using substr() and then Softanza,
# side by side, so you can make sense of the differences...

# Finding a substring

	cStr = "Welcome to the Ring programming language"
	? substr(cStr,"Ring")
	#--> 16

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.FindFirst("Ring")
	#--> 16

	# In Softanza, we can also return all the occurrences of cSubStr

	? oStr.Find("Ring") # or FindAll("Ring")
	#--> [ 16 ]

# Getting the substring starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr, "Ring") # gives 16
	? substr(cStr, nPos)
	#--> Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Section(:From = "Ring", :To = :LastChar) + NL # Or simply Section("Ring", :End)
	#--> Ring programming language

# Getting the substring made of n given chars starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr,"Ring") # Gives nPos = 16
	? substr(cStr, nPos, 4)
	#--> Ring

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Range("Ring", 4) + NL
	#--> Ring

# Replacing a sbstring by an other substring

	cStr = "Welcome to Python programming language"
	? substr(cStr, "Python", "Ring") # Replaces 'Python' with 'Ring'
	#--> Welcome to the Ring programming language

	# In Softanza we say:
	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content() + NL
	#--> Welcome to Ring programming language

# Replacing a sbstring by an other substring with Case Sensitivity

	cStr = "Welcome to the Python programming language"
	? substr(cStr,"PYTHON", "Ring", 0) #WARNING: This is should be 1 and not 0!
	#--> Welcome to the Python programming language
	
	cStr = "Welcome to the Python programming language"
	? substr(cStr, "PYTHON", "Ring", 1) #WARNING: This is should be 0 and not 1!
	#--> Welcome to the Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", :CaseSensitive = FALSE)
	? oStr.Content()
	#--> Welcome to Ring programming language

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", TRUE)
	? oStr.Content() + NL
	#--> Welcome to Python programming language

	# Or without specifying case sensitivty like this:

	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content()
	#--> Welcome to Ring programming language
	
proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.11 second(s) in Rin 1.17

/*--------- #perf #todo Check it after including FindBetween()

#NOTE
# Performance of stzString (using QString2 in background,
# and not QString ) is astonishing!

pron()

# Let's compose a large string

str = "1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

for i = 1 to 1_000_000
	str += "SomeStringHereAndThere"
next
# Takes 10.75 second(s) in Ring 1.20
# Executed in 13.31 second(s) in Ring 1.17

str += "|1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

o1 = new stzString(str)
# The construction of the Softanza object takes 0.12 second(s)

? @@(o1.FindThisBoundedBy("1", "|"))

#TODO: Try to compose the string by pushing the first part in the middle or a the end,
# and if stzString is still as performant!

proff()
# Executed in ... second(s)

/*=======

pron()

? IsRingSortable("ring")
#--> TRUE

? IsRingSortable(1:3)
#--> TRUE

? IsRingSortable("A":"C")
#--> TRUE

? IsRingSortable([ "Q", "t", 6 ])
#--> TRUE

? IsRingSortable([ "A", 1:3 ])
#--> FALSE

aList = [
	[ "mahmoud", 15000], [ "ahmed", 14000 ],
	[ "samir", 16000 ] , [ "mohammed", 12000 ],
	[ "ibrahim", 11000 ]
]
? IsRingSortable(aList)
#--> TRUE

aList = [
	[ "mahmoud", 15000], [ "ahmed", 14000 ],
	[ "samir", 16000 ] , [ "mohammed", 12000 ],
	[ "ibrahim", [], 11000 ]
]
? IsRingSortable(aList)
#--> FALSE

aList = [
	[ "mahmoud", 15000], [ "ahmed", 14000 ],
	[ "samir", 16000 ] , [" mohammed", 12000 ],
	"gary",
	[ "ibrahim" , 11000 ]
]
? IsRingSortable(aList)
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*-------

pron()

aList = [
	[ "ali", 12 ],
	[ "jed", 10 ],
	[ "sam",  8 ]
]
? IsRingSortableOn(aList, 2)
#--> TRUE

aList = [
	"kim",
	[ "ali", 12 ],
	[ "jed", 10 ],
	[ "sam",  8 ]
]
? IsRingSortableOn(aList, 2)
#--> FALSE

aList = [
	[ "ali", 12 	],
	[ "jed", 10, 22 ],
	[ "sam",  8 	]
]
? IsRingSortableOn(aList, 2)
#--> TRUE

aList = [
	[ "ali", 12 	],
	[ "jed", 10, 22 ],
	[ "sam",  8 	]
]
? IsRingSortableOn(aList, 3)
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*-------

pron()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

o1 = new stzListOfPairs(aList) # Or stzListOfLists() if you want

? @@NL( o1.Sorted() ) + NL
#--> [
#	[ "ahmed", 14000 ],
#	[ "ibrahim", 11000 ],
#	[ "mahmoud", 15000 ],
#	[ "mohammed", 12000 ],
#	[ "samir", 16000 ]
# ]

? @@NL( o1.SortedOn(2) )
#--> [
#	[ "ibrahim", 11000 ],
#	[ "mohammed", 12000 ],
#	[ "ahmed", 14000 ],
#	[ "mahmoud", 15000 ],
#	[ "samir", 16000 ]
# ]

proff()

#--> Executed in 0.04 second(s)

/*====== #todo check perf #update done!

pron()

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

o1 = new stzList(aList)
? o1.FindPrevious("*", :startingat = 1_900_008)
#--> 1900007

proff()
#--> Executed in 28.07 second(s)

/*====== #todo check perf #update done!

pron()

# Constructing the large list

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

? ElapsedTime()
#--> 0.82 second(s)

# Using the optimised @FindNthS() function (based on native Ring find())

? @FindNthS(aList, 3, "*", 1_000_000)
#--> 1900007

? @FindNext(aList, "*", 1_000_000)
#--> 1900002

? @@( @FindAll(aList, "*") )
#--> [ 1900002, 1900005, 1900007 ]

? ElpasedTime()
#--> 3.73 second(s)

# Creating the stzList object

o1 = new stzList(aList)
	
	? @@( o1.FindFirst("*") )
	#--> 1900002

	? o1.Findnext("*", :startingat = 1_000_000)
	#--> 1900002
	
	? o1.FindNextNthS(3, "*", 1_000_000)
	#--> 1900007

	? o1.FindAll("*")
	#--> [ 1900002, 1900005, 1900007 ]

proff()
#--> Executed in 10.49 second(s)

/*========== #perf

# Comparing two implementations of the concatenation of a large lists of strings:
# one with native Ring (list and += "") and one with Qt QStringList().join
# see the next 2 examples...

# NOTE: before Ring 1.19, the Ring-based implementation was faster, now the
# Qt-based one is faster.

# TODO: do the necessary to adopt it in all relevant places in the library.
# UpDATE done!

pron()

# Concatenating a large list of numbers and strings (1.9M items)
# takes about 10 seconds in Ring 1.19

# Preparing the large list to work on

	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 0.83 seconds in Ring 1.19
	# Took 1.20 seconds in Ring 1.17

	# Creating the stzList object

	o1 = new stzList(aList) # Takes 1.04 second(s)
	
	# Concatenating the items of the list
	
	aContent = aList
	nLen = len(aList)

	cSep = " "
	cResult = ""

	for i = 1 to nLen - 1
		cResult += aContent[i] + cSep
	next

proff()
# Executed in 10.99 second(s) in Ring 1.20
# Executed in 11.16 second(s) in Ring 1.19

/*-------------------- #perf

#NOTE
# Before Ring 1.19, adding large data inside a qstringlist() object was very slow.
# That's why I avoided it in concatenating lists of strings. In Ring 1.19, as we
# can see by running this example, this is done quicly.

#TODO
# Revist the places in Softanza where concatneation of list of strings is done
# and see if there will be performance gain by using QStringList().joint
#~> Look especially at Stringify() which is used in many finding algorithms!

#UPDATE done!

pron()

# Initializing the large list of strings

	o1 = new QStringList()
	for i = 1 to 1_900_000
		o1.append("sometext")
	next
	aList = [ "A", "*", "B", "C", "*", "D", "*", "E" ]
	nLen = len(aList)
	for i = 1 to nLen
		o1.append(aList[i])
	next
	
	# Takes 4.09 seconds in Ring 1.19
	# Took 11.87 seconds in Ring 1.17

# Concatenating the strings in one string

	str = o1.join("") # Take 0.32 seconds!

	//? ShowShortXT(str, 8)
proff()
# Executed in 3.98 second(s) in Ring 1.20
# Executed in 4.04 second(s) in Ring 1.19

/*--------- #perf

pron()

	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzListOfStrings(aList)

	str = o1.Concatenate()

	# To show a part of the large concatenated string
	# ? ShowShortXT(str, 7)

proff()
# Executed in 9.58 second(s)

/*--------- #perf

pron()

	aList = []
	for i = 1 to 1_900_000
		aList + i
	next
	for i = 1 to 400
		aList + 1:3
	next

	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzList(aList)
	o1.Stringify()

proff()
# Executed in 8.26 second(s)

/*--------- #perf

pron()

	aList = []
	for i = 1 to 1_900_000
		aList + i
	next
	for i = 1 to 400
		aList + 1:3
	next

	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

	o1 = new stzList(aList)
	o1.ToCode()

proff()
# Executed in 9.28 second(s)


/*====== #TODO check it after including FindBetween()

pron()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
?: @@( o1.FindXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ 6, 14 ]

proff()

/*---------- #TODO check it after including FindBetween()

pron()

# 		           8
o1 = new stzString("...<<--*-->>...")
? @@( o1.FindXT( "*", :InBetween = [ "<<", ">>" ]) ) # or :InSubStringsBetween

proff()

/*---------- #TODO check it after including FindBetween()

pron()

o1 = new stzString('..."*"..."*"...')
? o1.FindXT( "*", :BoundedBy = '"' )

proff()

/*----------

pron()

o1 = new stzString('..."*"..."*"...')

? o1.FindXT( "*", :InSection = [4 , 14 ] )
#--> [ 5, 11 ]

? o1.FindInSection("*", 4, 14)
#--> [ 5, 11 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("~*~~*--*-")

? o1.FindBefore("*", "--")
#--> [ 2, 5 ]

? o1.FindXT("*", :Before = "--")
#--> [ 2, 5 ]

? o1.FindAfter("*", "~")
#--> [ 5, 8 ]

? o1.FindXT("*", :After = "~")
#--> [ 5, 8 ]

? o1.FindInSection("*", 2, :lastchar)
#--> [ 2, 5, 8 ]

proff()
# Executed in 0.03 second(s)

/*----------

pron()

o1 = new stzString("~*~~*--")
? o1.FindXT( "*", :BeforePosition = 6)
#--> [ 2, 5 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzString("~--*~~*~~")

? o1.FindXT( "*", :After = "--")
#--> [ 4, 7 ]

? o1.FindXT( "*", :AfterPosition = 3)
#--> [ 4, 7 ]

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "~", "*", "~", "~", "*", "--", "*", "-" ])

? o1.FindBefore("*", "--")
#--> [ 2, 5 ]

? o1.FindXT("*", :Before = "--")
#--> [ 2, 5 ]

? o1.FindAfter("*", "~")
#--> [ 5, 7 ]

? o1.FindXT("*", :After = "~")
#--> [ 5, 7 ]

? o1.FindInSection("*", 2, :LastItem)
#--> [ 2, 5, 7 ]

proff()
# Executed in 0.02 second(s)

/*======

pron()

#                   1    6   0 2  15     22
o1 = new stzString("♥....♥...YOU..♥......♥")

? o1.FindNearestToPosition("♥", 10)
#--> 6

? o1.FindNearestToPositionXT("♥", 10)
#--> [ 6, 15 ]

? o1.FindNearestToSection("♥", 10, 12)
#--> 15

? o1.FindNearestToSectionXT("♥", 10, 12)
#--> [ 6, 15 ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

#                   1    6   0 2  15    21  25
o1 = new stzString("♥....♥...YOU..♥.....YOU.♥")

? o1.FindNearestToSections("♥", [ [ 10, 12 ], [ 21, 23 ] ])
#--> 25

proff()
# Executed in 0.02 second(s)

/*---------

pron()

#                   1    6   0 2  15    21  25
o1 = new stzString("♥....♥...YOU..♥.....YOU.♥")

? o1.FindNearest("♥", :To = 17 )
#--> 15

? o1.FindNearest("♥", :ToPosition = 17 )
#--> 15

? o1.FindNearest("♥", :To = [10, 12] )
#--> 15

? o1.FindNearest("♥", :ToSection = [10, 12] )
#--> 15

? o1.FindNearest("♥", :To = [ [ 10, 12 ], [ 21, 23 ] ] )
#--> 25

? o1.FindNearest("♥", :ToSections = [ [ 10, 12 ], [ 21, 23 ] ] )
#--> 25

? o1.FindNearest("♥", :To = "YOU")
#--> 25

? o1.FindNearest("♥", :ToSubString = "YOU")
#--> 25

proff()
# Executed in 0.07 second(s)

/*---------

pron()
#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestZZ("♥♥♥", :To = 14 )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :ToPosition = 14 )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :To = [14, 16] )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :ToSection = [14, 16] )
#--> [ 19, 21 ]

? o1.FindNearestZZ("♥♥♥", :To = [ [ 14, 16 ], [ 27, 29 ] ] )
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :ToSections = [ [ 14, 16 ], [ 27, 29 ] ] )
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :To = "YOU")
#--> [ 31, 33 ]

? o1.FindNearestZZ("♥♥♥", :ToSubString = "YOU")
#--> [ 31, 33 ]

proff()
# Executed in 0.07 second(s)

/*---------

pron()

#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestToSubString("♥♥♥", "YOU")
#--> 31

? o1.FindNearestToSubStringZZ("♥♥♥", "YOU")
#--> [ 31, 33 ]

proff()
# Executed in 0.04 second(s)

#=========

pron()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])

? o1.FindNearestToPosition("♥", 8)
#--> 10

? o1.FindNearestToPositionXT("♥", 8)
#--> [ 5, 10 ]

? o1.FindNearestToSection("♥", 8, 10)
#--> 10

? o1.FindNearestToSectionXT("♥", 5, 10)
#--> [ 6, 15 ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearestToSections("♥", [ [ 4, 7 ], [ 10, 12 ] ])
#--> 10

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearestToPosition("♥", 7)
#--> 5

? o1.FindNearestToPositions("♥", [ 3, 13 ])
#--> 14

? o1.findNearestToItem("♥", "YOU")
#--> 10

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([
	"♥", ".", ".", ".", "♥", ".", ".", "YOU", ".", "♥" ,".", ".", ".", "♥"
])


? o1.FindNearest("♥", :To = "YOU" )
#--> 10

? o1.FindNearest("♥", :ToItem = "YOU" )
#--> 10

? o1.FindNearest("♥", :ToPosition = 7 )
#--> 5

? o1.FindNearest("♥", :ToPositions = [7, 11] )
#--> 10

? o1.FindNearest("♥", :ToSection = [7, 10] )
#--> 10

? o1.FindNearest("♥", :ToSections =  [ [ 4, 7 ], [ 9, 12 ] ] )
#--> 14

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzList([
	"♥", ".", ".", "ME", "♥", ".", ".", "YOU", ".", "♥" ,".", "ME", ".", "♥"
])

? o1.FindNearest("♥", :ToItems = [ "YOU", "ME" ])
#--> 5

proff()

/*---------

pron()

#                                14           27
o1 = new stzString("♥♥♥....♥♥♥...YOU..♥♥♥.....YOU.♥♥♥")

? o1.FindNearestToSubString("♥♥♥", "YOU")
#--> 31

? o1.FindNearestToSubStringZZ("♥♥♥", "YOU")
#--> [ 31, 33 ]

proff()
# Executed in 0.04 second(s)

/*----

pron()

o1 = new stzString("...*...*...*...")
? o1.FindXT( "*", :InSection = [5, 10] )
#--> 8

proff()
# Executed in 0.01 second(s)

/*----------- #TODO Check after including findbetweencs() adn findboundedbycs()

pron()

o1 = new stzString("...<<*>>...<<*>>...<<*>>...")

? o1.FindXT( :AnySubString, :Between = ["<<", ">>"] )

? o1.FindXT( :Any, :BoundedBy = '"' )

proff()

/*======== #TODO/FUTURE: add the :3rd syntax to these functions

pron()

o1 = new stzString("...<<*>>...<<*>>...<<*>>...")

? o1.FindXT( :3rd = "*", :Between = [ "<<", ">>" ])

# ? o1.FindXT( :3rd = "*", :BoundedBy = '"' ])

# ? o1.FindXT( :3rd = "*", :InSection = [5, 24] ])

# ? o1.FindXT( :3rd = "*", :Before = '!' ])

# ? o1.FindXT( :3rd = "*", :BeforePosition = 12 ])

# ? o1.FindXT( :3rd = "*", :After = '!' ])

# ? o1.FindXT( :3rd = "*", :AfterPosition = 12 ])

proff()
