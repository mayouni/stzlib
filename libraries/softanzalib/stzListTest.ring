load "stzlib.ring"

/*-------------

pron()

o1 = new stzList(1:299_000)
o1.Stringified()

proff()
# Executed in 4.08 second(s)

/*=============

pron()

o1 = new stzList("A" : "C")
o1.ExtendWith(["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

proff()
# Executed in 0.04 second(s)
# Including 0.02 seconds consumed by the Show() function

/*----------------

pron()

o1 = new stzList("A" : "C")
o1.ExtendTo(5)
o1.Show()
#--> [ "A", "B", "C", "", "" ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList(1 : 3)
o1.ExtendTo(5)
o1.Show()
#--> [ 1, 2, 3, 0, 0 ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList("A" : "C")
o1.ExtendToWith(5, "*")
o1.Show()
#--> [ "A", "B", "C", "*", "*" ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsRepeated(8)
o1.Show()
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2 ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsIn( 8, "A":"C" )
o1.Show()
#--> [ 1, 2, 3, "A", "B", "C", "A", "B" ]

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :List, :With = ["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ])

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :List, :ToPosition = 5 )
o1.Show()
#--> [ "A", "B", "C", "", "" ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :ByItemsRepeated )
// ByItemsRepeated

o1.Show()
#--> [ "A", "B", "C", "A", "B" ])

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :With = "*" )
o1.Show()
#--> [ "A", "B", "C", "*", "*" ]

proff()
# Executed in 0.04 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :WithItemsIn = [ "D", "E" ])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.05 second(s)

/*================

pron()

Q([ "A", "B", "C" ]) {

	ExtendXT( :To = 5, :WithItemsIn = [ "A", "B" ] )
	Show()
	#--> [ "A", "B", "C", "A", "B" ]

}

proff()
# Executed in 0.06 second(s)

/*================

pron()

o1 = new stzList([
	"*", '"*"', "*4", [ "A", "B" , "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", [ "A", "B", "'C'" ], 12 ]

proff()
# Executed in 0.04 second(s)

/*------------------

pron()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.ToCode()

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", '"*"', "3", "34", "4", '"*"'
])

? o1.NumberOfOccurrence('"*"')
#--> 3

? o1.Find('"*"')
#--> [2, 14, 18]

proff()
# Executed in 0.15 second(s)

/*===========

pron()

o1 = new stzList([
	"*", "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.NumberOfDuplicates()
#--> 2

? @@( o1.FindDuplicates() )
#--> [ 10, 15 ]

? @@( o1.Duplicates() )
#--> [ "*", 4 ]

? @@( o1.DuplicatesZ() )
#--> [ "*" = 10, "4" = 15 ]

proff()
# Executed in 0.90 second(s)

/*=========

pron()

o1 = new stzList([ "a", "bcd", "♥", 5, "b", "♥♥♥", [1, 2] ])

#--

? o1.NumberOfChars()
#--> 3

? @@( o1.Chars() )
#--> [ "a", "♥" , "b" ]

//? @@( o1.CharsZ() ) # Or CharsAndTheirPositions()

#--

? o1.NumberOfLetters()
#--> 2

? @@( o1.Letters() )
#--> [ "a", "b" ]

//? @@( o1.LettersZ() ) # TODO

#--

? o1.NumberOfNumbers()
#--> 1

? @@( o1.Numbers() )
#--> [ 5 ]

# ? @@( o1.NumbersZ() ) # TODO

#--

? o1.NumberOfStrings()
#--> 5

? @@( o1.Strings() )
#--> [ "a", "bcd", "♥", "b", "♥♥♥" ]

# ? @@( o1.StringsZ() ) # TODO

#--

? o1.NumberOfLists()
#--> 1

? @@( o1.Lists() )
#--> [ [ 1, 2 ] ]

# ? @@( o1.ListsZ() ) # TODO

#--

? o1.NumberOfPairs()
#--> 1

? @@( o1.Pairs() )
#--> [ [ 1, 2 ] ]
# ? @@( o1.PairsZ() ) # TODO

#--

? o1.NumberOfObjects()
#--> 0

? @@( o1.Objects() )
#--> []

# ? @@( o1.ObjectsZ() ) # TODO

proff()
# Executed in 0.12 second(s)

/*========= Ring List2Code() VS Softanza ListToCode()

pron()

? List2Code([ [ 6, 8 ], [ 16, 18 ] ]) # Ring standard function
#--> "[
#	[
#		6,
#		8
#	],
#	[
#		16,
#		18
#	]
# ]"

? ListToCode([ [ 6, 8 ], [ 16, 18 ] ]) # Softanza function
#--> "[ [ 6, 8 ], [ 16, 18 ] ]"

#--

? List2Code([ "A", '"B"', "'C'" ]) # Ring standard function
#--> [
#	"A",
#	""+char(34)+"B"+char(34)+"",
#	"'C'"
# ]

? ListToCode([ "A", '"B"', "'C'" ]) # Softanza function
#--> [ "A", '"B"', "'C'" ]

proff()
# Executed in 0.04 second(s)

# NOTE: Also, Softanza version is more performant (testit for a large list)

/*==================

pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindLast("*")
#--> 7

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindFirst("*")
#--> 4

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindNext("*", :StartingAt = 4)
#--> 7

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

? ring_find( 1:100_000, 67_000 )
#--> 67000

proff()
# Executed in 0.02 second(s)

/*-----------------

pron()

aList = 1: 100_000
nLen = len(aList)

bResult = TRUE
for i = 1 to nLen
	if NOT isNumber(aList[i])
		bResult = FALSE
		exit
	ok
next

? bResult

proff()
# Executed in 0.22 second(s)

/*-----------------

pron()

o1 = new stzList(1: 100_000)
? o1.IsListOfNumbers()
#--> TRUE

? o1.FindFirst(67_000)
#--> 67000

proff()
#--> Executed in 0.54

/*-----------------

pron()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

? @@( o1.Find(14) )
#--> [ 1, 3, 4 ]

? o1.FindFirst(14)
#--> 1

? o1.FindLast(14)
#--> 4

? o1.FindNext(14, :StartingAt = 2)
#--> 3

proff()
# Executed in 0.05 second(s)

/*-----------------

o1 = new stzString([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
#!--> Should return an error!
# Incorrect param! You must provide a list of strings.

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1.RemoveSection(3, 8)
? @@( o1.Content() )
#--> [ 1, 2, 9, 10 ]

proff()


/*-----------------

pron()

o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveSection(3, 5)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

proff()
# Executed in 0.03 second(s)

*-----------------

pron()

o1 = new stzList([ "1", "2", "_", "_", "_", "3", "4" ])
o1.RemoveRange(3, 3)
? @@( o1.Content() )
#--> [ "1", "2", "3", "4" ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzList(1:299_000)
o1.RemoveSection(73_900, 120_010)
? len( o1.Content() )
#--> 252889

proff()
# Executed in 0.99 second(s)

/*-----------------

pron()

o1 = new stzList(1:10)
oListInStr = o1.ToCodeQ()

n1 = oListInStr.FindNth(3, ",")
n2 = oListInStr.FindNth(7, ",")

? oListInStr.Section(n1-1, n2-1)
#--> "3, 4, 5, 6, 7"

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzList(1:10)
? @@( o1.Section(3, 10) )
#--> [ 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

Q(1:299_000).Section(100, 299_000)

proff()
# Executed in 0.45 second(s)

/*-----------------

pron()

o1 = new stzList([ 14, 10, 14, 14, 20 ])

? QR([2, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> TRUE

? QR([0, 4], :stzPairOfNumbers).BothAreBetween(1, o1.NumberOfItems())
#--> FALSE

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()


o1 = new stzList([ 14, 10, 14, 14, 20 ])

//? o1.Section(0, :Last)
#--> Error message: Array Access (Index out of range) !

? o1.FindNext(14, :StartingAt = 1)
#--> 3
# Executed in 0.06 second(s)

? @@( o1.Find(14) )
#--> [ 1, 3, 4 ]

? o1.FindFirst(4)
#--> 0

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

o1 = new stzList(1:14 + 12)
? o1.NumberOfOccurrence(12)
#--> 2

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzList(1:299_000 + 120000)

? o1.Contains(120000)
#--> TRUE
# Executed in 0.84 second(s)

? o1.NumberOfOccurrence(120000)
#--> 2
# Executed in 1.37 second(s)

proff()
# Executed in 2.44 second(s)

/*-----------------

pron()

? ring_find(1:299_000, 40_000)
#--> 40000
proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

? Q([1, 2, 3, 4, 5, 3, 7]).Find(3)
#--> [ 3, 6 ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzList( 1:7 + "str1" + "str2" + [ "+", "-" ] )
? @@( o1.OnlyNumbers() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzList( 10:12 + "str1" + "str2" + [ "+", "-" ] + o1 )

? @@( o1.NumbersAndStrings() )
#--> [ 10, 11, 12, "str1", "str2" ]

? @@( o1.NumbersAndStringsZ() )
#--> [ [ 10, 1 ], [ 11, 2 ], [ 12, 3 ], [ "str1", 4 ], [ "str2", 5 ] ]

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

aLarge = []
for i = 1 to 299_000
	aLarge + "*"
next

? ElapsedTime()
#--> Extecuted in 0.14 second(s)

o1 = new stzList( aLarge + 10 + 20 + [ "+", "-" ] )
? len( o1.OnlyStrings() )
#--> 299000
# Executed in 2 second(s)

proff()
# Executed in 2.25 second(s)

/*-----------------

pron()

aLarge = []
for i = 1 to 299_000
	aLarge + "*"
next

? ElapsedTime()
#--> Extecuted in 0.14 second(s)

o1 = new stzList( aLarge + 10 + 20 + [ "+", "-" ] + 30 + 40 + [ "*" ] )
? len( o1.NumbersAndStringsZ() )
#--> 299004
# Executed in 2 second(s)

proff()
# Executed in 3.72 second(s)

/*----------------

pron()

o1 = new stzList( 1:299_000 + "str1" + "str2" + [ "+", "-" ] )
? len( o1.OnlyNumbers() )
#--> 299000

proff()
# Executed in 1.01 second(s)

/*-----------------

pron()

o1 = new stzList(1 : 299_000 + 4)

? o1.FindFirst(4)
#--> 4
# Executed in 0.88 second(s)

? o1.FindLast(4)
#--> 299001
# Executed in 0.94 second(s)

? o1.FindNth(:First, 4)
#--> 4
# Executed in 0.89 second(s)

? o1.FindNth(:Last, 4)
#--> 299001
# Executed in 0.92 second(s)

proff()
# Executed in 3.56 second(s)

/*-----------------

pron()

o1 = new stzList(1:299_000+4)

? len( o1.Section(80_002, 210_001) )
#--> 130_000
# Executed in 0.22 second(s)

? o1.FindNext(120_001, :StartingAt = 2)
#--> 120001
# Executed in 1.38 second(s)

proff()
# Executed in 1.78 second(s)

/*-----------------

pron()

o1 = new stzList(1:299_000+4)

? o1.FindNext(120_001, :StartingAt = 2)
#--> 120_001
# Executed in 1.53 second(s)

? o1.FindPrevious(4, :StartingAt = 180_000)
#--> 4
# Executed in 0.92 second(s)

? o1.FindNthNext(2, 4, :StartingAt = 2)
#--> 299001
# Executed in 2.82 second(s)

proff()
# Executed in Executed in 4.88 second(s)

/*---------------

pron()

o1 = new stzList( 1:299_000 + "str1" + "str2" + 12 + [ "+", "-" ]  + o1 )

? o1.Find(12)
#--> [12, 299003]

proff()
# Executed in 2.67 second(s)

/*---------------

pron()

o1 = new stzList( 1:299_000 + "str1" + "str2" + 12 + [ "+", "-" ] + "str1" + o1 )

? o1.Find("str1")
#--> [299001, 299005]

proff()
# Executed in 0.84 second(s)

/*---------------

pron()

o1 = new stzList(
	1:299_000 + "str1" + "str2" + 12 + [ "*", "+" ] + "str1" + o1 +  [ "*", "+" ]
)

? o1.Find([ "*", "+" ] )
#--> [299004, 299007]

proff()
# Executed in 0.84 second(s)

/*==============

pron()

o1 = new stzList([ 12, 88 ])
? o1.BothAreNumbers()
#--> TRUE

o1 = new stzList([ "hi", "ring" ])
? o1.BothAreStrings()
#--> TRUE

o1 = new stzList([ :name = "Dan", :job = "Programmer" ])
? o1.BothAreLists()
#--> TRUE

o1 = new stzList([ o1, o1 ])
? o1.BothAreObjects()
#--> TRUE

proff()
# Executed in 0.05 second(s)

/*============

pron()

o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7" ])

? o1.Section(3, 5)
#--> [ "3", "4", "5" ]

? o1.Section(5, 3)
#--> [ "3", "4", "5" ]

? o1.Section(3, -3)
#--> [ "3", "4", "5" ]

? o1.Section(-3, 3)
#--> [ "3", "4", "5" ]

? o1.Range(3, 3)
#--> [ "3", "4", "5" ]

? o1.Range(3, -3)
#--> [ "1", "2", "3" ]

? o1.Range(-5, -3)
#--> [ "1", "2", "3" ]

proff()
# Executed in 0.04 second(s)

/*===========

pron()

? Association([ [ 1, 2, 3 ], [ "One", "Two", "Three" ] ])
#--> [ [ 1, "One" ], [ 2, "Two" ], [ 3, "Three" ] ]

proff()
# Executed in 0.04 second(s)

/*===========

pron()

o1 = new stzList([ :StartingAt, 5 ])
? o1.IsAPairQ().Where('{ isString(@pair[1]) and isNumber(@pair[2]) }')

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzList([ "ONE", "TWO", "THREE" ])
? o1.AllItemsAre([ :Uppercase, :Strings ])
#--> TRUE

proff()
# Executed in 0.34 second(s)

/*------------

pron()

o1 = new stzList([ "ONE", "TWO", "THREE" ])

? o1.IsAPairQ().Where('{
	Q(@Pair).AllItemsAre([ :Uppercase, :Strings ])
}')
#--> FALSE

proff()
# Executed in 0.03 second(s)

/*============

pron()
   
o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ])

# FIRST HALF

	? @@( o1.FirstHalf() )
	#--> [ "1", "2", "3", "4" ]
	? @@( o1.FirstHalfXT() )
	#--> [ "1", "2", "3", "4", "5" ]
	
	? @@( o1.FirstHalfAndItsPosition() )
	#--> [ [ "1", "2", "3", "4" ], 1 ]
	? @@( o1.FirstHalfAndItsSection() )
	#--> [ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	
	? @@( o1.FirstHalfAndItsPositionXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], 1 ]
	? @@( o1.FirstHalfAndItsSectionXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ]

# SECOND HALF

	? @@( o1.SecondHalf() )
	#--> [ "5", "6", "7", "8", "9" ]
	? @@( o1.SecondHalfXT() )
	#--> [ "6", "7", "8", "9" ]
	
	? @@( o1.SecondHalfAndItsPosition() )
	#--> [ [ "5", "6", "7", "8", "9" ], 5 ]
	? @@( o1.SecondHalfAndItsSection() )
	#--> [ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ]
	
	? @@( o1.SecondHalfAndItsPositionXT() )
	#--> [ [ "6", "7", "8", "9" ], 6 ]
	? @@( o1.SecondHalfAndItsSectionXT() )
	#--> [ [ "6", "7", "8", "9" ], [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@( o1.Halves() )
	#--> [ [ "1", "2", "3", "4" ], [ "5", "6", "7", "8", "9" ] ]

	? @@( o1.HalvesXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], [ "6", "7", "8", "9" ] ]

	? @@( o1.HalvesAndPositions() )
	#--> [
	# 	[ [ "1", "2", "3", "4" ], 1 ],
	# 	[ [ "5", "6", "7", "8", "9" ], 5 ]
	# ]

	? @@( o1.HalvesAndPositionsXT() )
	#--> [
	# 	[ [ "1", "2", "3", "4", "5" ], 1 ],
	# 	[ [ "6", "7", "8", "9" ], 6 ]
	# ]

	? @@( o1.HalvesAndSections() )
	#--> [
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ],
	# 	[ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ]
	# ]

	? @@( o1.HalvesAndSectionsXT() )
	#--> [
	# 	[ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ],
	# 	[ [ "6", "7", "8", "9" ], [ 6, 9 ] ]
	# ]

proff()
# Executed in 0.32 second(s)

/*============

pron()

o1 = new stzListOfStrings([ "programming", "is" ])
? o1.SortedInAscendingBy('Q(@string).NumberOfChars()')
#--> [ "is", "programming" ]

proff()
# Executed in 0.20 second(s)

/*------------
*/
pron()

o1 = new stzString("Ringprogramminglanguageispowerful!")
o1.SpacifySubStrings([ "programming", "is" ]) # Test with "isaa"!!
? o1.Content()
#--> Ring programming language is powerful!

proff()
# Executed in 0.21 second(s)

/*------------

pron()

? StzCCodeQ(' Q(@NextItem).IsNotANumber()').Transpiled()
#--> Q( This[@i + 1] ).IsNotANumber(  )

proff()
#--> Executed in 0.30 second(s)

/*------------

pron()

? StzCCodeQ('NOT isNumber( This[@i + 1] )').ExecutableSection()
#--> [1, -1]

proff()
# Executed in 0.12 second(s)

/*-----------
*/
pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 7 ])

? @@( o1.ToString() )
#-->
# "1
#  2
#  3
#  *
#  5
#  6
#  *
#  7"
# Executed in 0.03 second(s)

? @@( o1.Stringified() )
#--> [ "1", "2", "3", "*", "5", "6", "*", "7" ]
# Executed in 0.02 second(s)

? o1.ToCode()
#--> [ 1, 2, 3, "*", 5, 6, "*", 7 ]
# Executed in 0.02 second(s)

proff()
# Executed in 0.04 second(s)

/*-----------

pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8 ])

? o1.HowMany("*")
#--> 2

? o1.FindFirst("*")
#--> 4
# Executed in 0.02 second(s)

? o1.FindLast("*")
#--> Executed in 0.02 second(s)

proff()
# Executed in 0.03 second(s)

/*-----------//////

pron()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])
? o1.FindW('NOT isNumber(This[@i + 1])')
#--> [2, 6]
# Executed in 0.08 second(s)

? o1.FindWXT(' Q(@NextItem).IsNotANumber() ')
#--> [2, 6]
#--> Executed in 0.24 second(s)

proff()
# Executed in 0.32 second(s)

/*===========

StartProfiler()

? Q("A").RepeatedXT(:InAString, :OfSize = 3)
#--> "AAA"

? Q("A").RepeatedXT(:InAList, :OfSize = 3)
#--> ["A", "A", "A"]

StopProfiler()

/*===========

StartProfiler()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])
? @@( o1.BoundsOf("*", :UpToNItems = 2) )
#--> [
#	[ [ 1, 2 ], [ 4, 5 ] ],
#	[ [ 5, 6 ], [ 8, 9 ] ]
# ]

StopProfiler()
# Executed in 0.07 second(s)

/*===========

StartProfiler()

 # Extract(item) removes the item from the list and returns it

o1 = new stzList([ "A", "B", "_", "C" ])

? o1.Extract("_")
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
#--> Executed in 0.03 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ "A", "B", "_", "C", "*" ])
? o1.ExtractMany(["_", "*"])
#--> ["_", "*"]

? o1.Content()
#--> #--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ "A", "B", "C" ])

? o1.ExtractAll()
#--> [ "A", "B", "C" ]

? @@( o1.Content() )
#--> []

StopProfiler()
# Executed in 0.01 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ "A", "_", "B", "C" ])
? o1.ExtractAt(2)
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ "_", "A", "B", "C" ])

? o1.ExtractFirst("_")

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ "A", "B", "C", "_" ])

? o1.ExtractLast("_")
#--> "_"

? o1.Content()
#--> ["A", "B", "C"]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 3, "*", 4, "_" ])

? o1.ExtractW('{ NOT isNumber(@item) }')
#--> [ "♥", "*", "_" ]

? o1.Content()
#--> [ 1, 2, 3, 4 ]

StopProfiler()
# Executed in 0.44 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", "♥", "♥", 3, 4 ])

? o1.ExtractSection(3, 5)
#--> ["♥", "♥", "♥"]

? o1.Content()
#--> [1, 2, 3, 4]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", "♥", "♥", 3, 4 ])

? o1.ExtractRange(3, 3)
#--> ["♥", "♥", "♥"]

? o1.Content()
#--> [1, 2, 3, 4]

StopProfiler()

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractNext("♥", :StartingAt = 4)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 6, "♥" ]

StopProfiler()

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractPrevious("♥", :StartingAt = 6)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6, "♥" ]

StopProfiler()

/*===========

StartProfiler()

? Q([ "ONE", "ONE", "ONE" ]).ItemsHave('{ len(@item) = 3 }')
#--> TRUE

? Q([ "One", "Two", "Three" ]).ItemsAre(:Strings)
#--> TRUE

? Q(1:5).ItemsAre(:Numbers)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:Lists)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:ListsOfStrings)
#--> TRUE

StopProfiler()
# Executed in 0.47 second(s)

/*----------

StartProfiler()

	? Q([ "♥", "♥", "♥" ]).AllItemsAre("♥")
	#--> TRUE
	# Executed in 0.08 second(s)

	? Q([ 12, 12, 12 ]).AllItemsAre(12)
	#--> TRUE
	# Executed in 0.02 second(s)

	? Q([ 1:3, 1:3, 1:3 ]).AllItemsAre(1:3)
	#--> TRUE
	# Executed in 0.02 second(s)
	
	? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, :Latin, :Strings ])
	#--> TRUE
	# Executed in 0.17 second(s)

	? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Strings ])
	#--> TRUE
	# Executed in 0.16 second(s)

StopProfiler()
#--> Executed in 0.41 second(s)

/*----------

StartProfiler()

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, :Where = '{ len(@item) <= 5 }', :Strings ])
#--> TRUE

StopProfiler()
#--> Executed in 0.05 second(s)

/*==========

pron()

o1 = new stzList([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6, 9 ]
# Executed in 0.18 second(s)

? @@( o1.Duplicates() )
#--> [ "_", "_", "_", "*" ]
# Executed in 0.22 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ "_", [ 3, 4, 6 ] ], [ "*", [ 9 ] ] ]
# Executed in 0.19 second(s)

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ "_", "ONE", "TWO", "THREE", "*" ]
# Executed in 0.04 second(s)

proff()
# Executed in 0.55 second(s)

/*======= MANAGING DUPLICATES

pron()

o1 = new stzList([ 5, 7, 5, 5, 4, 7 ])

# NOTE: the same code shown here can work as-is for stzListOfStrings!
# to test it just replace the line above with the following:
// o1 = new stzListOfStrings([ "5", "7", "5", "5", "4", "7" ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates()
#--> 3
# Executed in 0.06 second(s)

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6 ]
# Executed in 0.06 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ 5, 3 ], [ 5, 4 ], [ 7, 6 ] ]
#--> the number 5 is duplicated at position 3, and then
#    the number 5 is duplicated (again) at position 4, and finally,
#    the number 7 is duplicated at position 6.
# Executed in 0.25 second(s)

? @@( o1.DuplicatesUZ() )
#--> [ [ 5, [ 3, 4 ] ], [ 7, [ 6 ] ] ]
#--> The number 5 is duplicated at positions 3 and 4, and
#    the number 7 is duplicated at position 6.
# Executed in 0.17 second(s)

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ 5, 7, 4 ]
# Executed in 0.07 second(s)

proff()
# Executed in 0.54 second(s)

/*======= MANAGING DUPLICATED ITEMS: Check errros
*/
pron()

o1 = new stzList([ 5, 7, 5, 5, 4, 7 ])

# NOTE: the same code shown here can work as-is for stzListOfStrings!
# to test it just replace the line above with the following:
// o1 = new stzListOfStrings([ "5", "7", "5", "5", "4", "7" ])
/*
? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates()
#--> 3
# Executed in 0.09 second(s)

? o1.FindDuplicates()
#--> [ 3, 4, 6 ]

? o1.Duplicates()
#--> [5, 7]

? o1.HowManyDuplicatedItems()
#--> 2

? o1.DuplicatedItems()
#--> [5, 7]
*/
? @@( o1.DuplicatedItemsZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ 5, [ 1, 3, 4 ] ], [ 7, [ 2, 6 ] ] ]
#--> the number 5 is duplicated at position 1, 3 and 4, and,
#    the number 7 is duplicated at positions 2 and 6?
# Executed in 0.17 second(s)

o1.RemoveDuplicatedItems()
? @@( o1.Content() )
#--> [ 4 ]
# Executed in 0.17 second(s)

proff()
# Executed in 0.54 second(s)

/*-----------
*/
pron()

o1 = new stzList([ "*", "4", "*", "3", "4" ])

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.06 second(s)

/*==========

pron()

o1 = new stzList(1:7)
o1 - 4:6

? @@( o1.Content() )
#--> [ 1, 2, 3, 7 ]

proff()
# Executed in 0.10 second(s)

/*==========

pron()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3, 5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.AntiSections(:Of = [ [3, 5], [7, 8] ] ) )
#--> [ ["A", "B"], ["F"], ["I", "J"] ]

proff()
# Executed in 0.10 second(s)

/*-------------

pron()

o1 = new stzList([ "Ring", "Ruby", "Python" ])

? o1.CommonItems(:With = [ "Julia", "Ring", "Go", "Python" ])
#--> [ "Ring", "Python" ]

proff()
#--> Executed in 0.06 second(s)

/*==========

pron()

o1 = new stzList([ "a", "ab", "abnA", "abAb" ])

? o1.Contains("n")
#--> FALSE

? o1.FindFirst("n")
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*----------

pron()
o1 = new stzList([ "a", "ab", 1:3, "abA", "abAb", 1:3 ])

? o1.ContainsCS("ab", TRUE)
#--> TRUE

? o1.FindFirstCS("AB", FALSE)
#--> 2

? o1.FindLastCS("ABA", FALSE)
#--> 4

? o1.FindFirst(1:3)
#--> 3

? o1.FindLast(1:3)
#--> 6

proff()
# Executed in 0.09 second(s)

/*==========

pron()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3,"c" ])

? o1.FindDuplicates()
#--> [ 5, 6, 8, 10 ]
# Executed in 0.11 second(s)

? @@( o1.ItemsAtPositions( o1.FindDuplicates() ) )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]
# Executed in 0.02 second(s)

? @@( o1.Duplicates() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]
# Executed in 0.14 second(s)

? @@( o1.DuplicatesZ() )
#--> [ [ "a", 5 ], [ "ab", 6 ], [ "b", 8 ], [ [ 1, 2, 3 ], 10 ] ]
# Executed in 0.23 second(s)

proff()
# Executed in 0.44 second(s)

/*-------------

pron()

o1 = new stzList([ "a", "ab", "b" ])
? o1.Intersection(:with = [ "a", "ab", "abc", "b", "bc", "c" ]) # Or CommonItems()
#--> [ "a", "ab", "b" ]

proff()
# Executed in 0.04 second(s)

/*==========

StartProfiler()
#                   1    2    3    4    5    6    7     8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "_", "♥", "_" , "♥", "_", "_" ])

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 7)
#--> 3

? o1.FindNthPrevious(3, "♥", :StartingAt = 9)
#--> 3

StopProfiler()
# Executed in 0.03 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = ["_", "_", "♥"]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Finding previous "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindNext("♥", :StartingAt = 12_000)
	#--> 100_004
	# Executed in 2.25 second(s)
	
	? o1.FindNthNext(6, "♥", :StartingAt = 1)
	#--> 150_011
	# Executed in 3.50 second(s)
	
	? o1.FindNthNext(3, "♥", :StartingAt = 12_000)
	#--> 150_008
	# Executed in 2.71 second(s)

StopProfiler()
# Executed in 7.55 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = ["_", "_", "♥"]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

	# NOTE: Internally, FindNthPrevious() useses native
	# ring_revers() function which has a good performance:
	# 
	# ring_reverse(aLargeListOfStr)
	# Executed in 0.16 second(s)
# 

# Finding previous "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindPrevious("♥", :StartingAt = 5)
	#--> 3
	# Executed in 0.12 second(s)

	? o1.FindNthPrevious(2, "♥", :StartingAt = 120_000)
	#--> 100_004
	# Executed in 3.58 second(s)

	? o1.FindNthPrevious(3, "♥", :StartingAt = 150_000)
	#--> 3
	# Executed in 4.70 second(s)

StopProfiler()
# Executed in 7.51 second(s)

/*------------

StartProfiler()

o1 = new stzList([ "_", "_", "♥", "_", "_", "♥", "_" ])

? o1.FindFirst("♥")
#--> 3

? o1.FindLast("♥")
#--> 6

? o1.FindNext("♥", :StartingAt = 3)
#--> 6

? o1.FindPrevious("♥", :StartingAt = 6)
#--> 3

? o1.FindNthNext(1, "♥", :StartingAt = 3)
#--> 6

? o1.FindNthPrevious(2, "♥", :StartingAt = 7)
#--> 3

StopProfiler()
# Executed in 0.03 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_" ]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i

# Find "♥" in several ways
	o1 = new stzList(aLargeListOfStr)

	? o1.NumberOfOccurrence("♥")
	#--> 2
	# Executed in 1.66 second(s)

	? o1.FindFirst("♥")
	#--> 100003
	# Executed in 2.92 second(s)
	
	? o1.FindLast("♥")
	#--> 100006
	# Executed in 3.09 second(s)

	? o1.FindNth(2, "♥")
	#--> 100006
	# Executed in 5.32 second(s)

	? o1.FindNext("♥", :StartingAt = 3)
	#--> 100003
	# Executed in 2.92 second(s)


	? o1.FindNthNext(2, "♥", :StartingAt = 3)
	#--> 100006
	# Executed in 8.92 second(s)
	
	? o1.FindPrevious("♥", :StartingAt = 120_000)
	#--> 100006
	# Executed in 3.27 second(s)

	? o1.FindNthPrevious(2, "♥", :StartingAt = 33)
	#--> 3
	# Executed in 2.90 second(s)

StopProfiler()
# Executed in 31.56 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = []
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + "ME"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	o1.RemoveDuplicates()
	? o1.Content()
	#--> [ "_", "HI", "ME", "YOU" ]

StopProfiler()
# Executed in 3.58 second(s)

/*============

StartProfiler()
#                   1    2    3    4    5    6    7    8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "♥", "_", "_", "♥", "_", "_" ])
? o1.FindNth(3, "♥")
#--> 8

StopProfiler()
# Executed in 0.02 second(s)

/*------------

StartProfiler()
#                   1    2      3      4      5     6     7      8     9    10
o1 = new stzList([ "_", "_", "A":"C", "_", "A":"C", "_", "_", "A":"C", "_", "_" ])
? o1.FindNth(3, "A":"C")
#--> 8

StopProfiler()
# Executed in 0.15 second(s)

/*------------

StartProfiler()
o1 = new stzList([ 1, 2, 3, "A":"C", 5, 7, 8, 9, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 0

StopProfiler()
# Executed in 0.22 second(s)

/*------------

StartProfiler()

o1 = new stzList([ 1, 2, 3, "A":"C", "A":"C", 6, 7, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 4

StopProfiler()
# Executed in 0.25 second(s)

/*------------

StartProfiler()

# Fabricating a large list
	aLargeList = 1:100_000
	aLargeList + "A":"C" + "A":"C"
	
	aMyList = [ "_", "_", "A":"C", "_", "_", "A":"C", "_", "_", "A":"C", "_" ]
	for i = 1 to len(aMyList)
		aLargeList + aMyList[i]
	next

	o1 = new stzList(aLargeList)
	? o1.FindNth(2, "A":"C")
	#--> 100002
	# Executed in 3.30 second(s)

	? o1.FindNext("A":"C", :StartingAt = 89_000)
	#--> 100001
	# Executed in 0.45 second(s)

	? o1.FindNthPrevious(3, "A":"C", :StartingAt = 100_010)
	#--> 100002
	# Executed in 4.69 second(s)

StopProfiler()
# Executed in 8.38 second(s)

/*------------

StartProfiler()

o1 = new stzList([ 1, 2, "A":"C", 4, 5, "A":"C", 7, "A":"C"])
? o1.FindFirst("A":"C")
#--> 3
? o1.FindNth(2,"A":"C")
#--> 6
? o1.FindLast("A":"C")
#--> 8

StopProfiler()
# Executed in 0.38 second(s)

/*----------

StartProfiler()

# Fabricating a large list

	aLargeList = 1 : 100_000

	aMyList = [ 1, 2,
		    ["A", "B", "C", "عربي", "كلام", "D"],
		    3, 4, 5,
		    ["A", "B", "C", "عربي", "كلام", "D"],
		    6, 7,
		    ["A", "B", "C", "عربي", "كلام", "D"]
	]

	for i = 1 to len(aMyList)
		aLargeList + aMyList[i]
	next
	# Executed in 0.02 second(s)

# Finding the first occurrence
	o1 = new stzList(aLargeList)

	? o1.FindFirst(["A", "B", "C", "عربي", "كلام", "D"])
	#--> 100003
	# Executed in 2.26 second(s)

# Finding the last occurrence

	? o1.FindLast(["A", "B", "C", "عربي", "كلام", "D"])
	#--> 100010
	# Executed in 2.24 second(s)

# Finding the 2nd occurrence

	? o1.FindNth(2, ["A", "B", "C", "عربي", "كلام", "D"])
	#--> 100007
	# Executed in 3.35 second(s)

StopProfiler()
# Executed in 8.50 second(s)

/*============

StartProfiler()

o1 = new stzString( '[ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "♥"] ] ]' )
? o1.FindPreviousNthOccurrence(1, :Of = "[", :StartingAt = 21)
#--> 13
? o1.FindNextNthOccurrence(1, :Of = "]", :StartingAt = 21)
#--> 28

? o1.FindFirstPrevious("[", :StartingAt = 21)
#--> 13
? o1.FindFirstNext(:Of = "]", :StartingAt = 21)
#--> 28

StopProfiler()
#--> Executed in 0.04 second(s)

/*----

StartProfiler()

o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.NumberOfOccurence("♥") # Note that this is a misspelled form (lacks an "r")
			    # but Softanza is kind to accept it
#--> 4

o1 = new stzList(["__", 1:3, "_", "__", 1:3, 1:3, "__", 1:3 ])
? o1.NumberOfOccurrence(1:3)
#--> 4

StopProfiler()
# Executed in 0.02 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = []
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + "ME"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? o1.NumberOfOccurrence("_")
	#--> 150010
	
StopProfiler()
#--> Executed in 3.65 second(s)

/*------------

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ [ "ME", "YOU"] ]

	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + [ "ME", "YOU"]
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

	aLargeListOfStr + [ "ME", "YOU"]

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? o1.FindAll([ "ME", "YOU"])
	#-->  [1, 100003, 150016]
	
StopProfiler()
#--> Executed in 9.01 second(s)

/*----

StartProfiler()

o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.FindAll("♥")
#--> [2, 5, 6, 8 ]
# Executed in 0.04 second(s)

o1 = new stzList(["__", 1:3, "_", "__", 1:3, 1:3, "__", 1:3 ])
? o1.FindAll(1:3)
#--> [2, 5, 6, 8 ]
# Executed in 0.58 second(s)

StopProfiler()
# Executed in 0.60 second(s)

/*==========


TODO - NAMING REFORM

..RemoveBetweenIB() : removes also bounds
#--> DONE

...Bounds  --> ...( [b1,b2] )	why? to be able to use ...( b ) if the 2 bounds are sale
...Between --> ...( b1, b2 )	why? because they are always 2 bounds
#--> DONE

...SubString --> ...Section

AddXT()
#--> DONE

FindXT()

InsertXT()

ReplaceXT()
#--> DONE

RemoveXT()
#--> DONE

/*-----------

StartProfiler()

o1 = new stzList([0, 0, 1, 0, 1])
? o1.FindLast(0)
#--> 4

StopProfiler()
# Executed in 0.01 second(s)

/*-----------

pron()
#                     3 5
o1 = new stzString("12•4•67")

? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 5

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 3

proff()
# Executed in 0.08 second(s)

/*-----------

StartProfiler()
#                   1    2    3    4    5    6    7
o1 = new stzList([ "_", "_", "•", "_", "•", "_", "_" ])

? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 5

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 3

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

#vv : Personal note : these tow letters (vv) are introduced
# on the keyborad by my 10 months-old child Hussein, while
# he is playing on my desktop :)

/*-----------

StartProfiler()
#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? o1.FindNext("[", :StartingAt = 17)
#--> 0

? o1.FindPrevious("]", :StartingAt = 13)
#--> 9

StopProfiler()
# Executed in 0.03 second(s)

/*==============

StartProfiler()

o1 = new stzString("---456---")

? o1.DistanceTo("6", :StartingAt = 4)
#--> 1

? o1.DistanceToXT("6", :StartingAt = 4)
#--> 3

StopProfiler()
# Executed in 0.04 second(s)

/*-----------

StartProfiler()
#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

#--

? o1.DistanceTo("[", :StartingAt = 1)
#--> 2

? o1.DistanceTo( :Next = "[", :StartingAt = 1 )
#--> 2

? o1.DistanceTo( :NextNth = [ 2, "[" ], :StartingAt = 1 )
#--> 2

#--
? NL + "--" + NL

? o1.DistanceToXT("[", :StartingAt = 1)
#--> 4

? o1.DistanceToXT( :Next = "[", :StartingAt = 1 )
#--> 4

? o1.DistanceToXT( :NextNth = [2, "["], :StartingAt = 1 )
#--> 4

? NL + "--" + NL

? o1.DistanceToXT( :Previous = "[", :StartingAt = 9 )
#--> 4

? o1.DistanceToXT( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 6

? o1.DistanceTo( :Previous = "[", :StartingAt = 9 )
#--> 2

? o1.DistanceTo( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 4

StopProfiler()
# Executed in 0.16 second(s)

/*-----------

StartProfiler()
#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? @@( o1.FindAnyBetweenAsSections("[","]") )
#--> [ [ 2, 8 ], [ 5, 12 ], [ 7, 13 ], [ 12, 19 ], [ 18, 20 ] ]

StopProfiler()
#--> Executed in 0.02 second(s)

/*-----------

StartProfiler()
#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? @@( o1.FindAnyBetweenAsSections("[","]") )

StopProfiler()
#--> [ [ 7, 8 ], [ 12, 12 ], [ 18, 19 ] ]

/*============

StartProfiler()

aList1 = [ 1,  4,  6, 11, 17 ]
aList2 = [ 9, 13, 14, 20, 21 ]

nLen1 = len(aList1)
nLen2 = len(aList2)

aSections = [] 
aSections + [ aList1[1], aList2[nLen2] ]

del(aList2, nLen2)
nLen2 = len(aList2)

for i = 1 to nLen1 - 1
	
	for q = 1 to nLen2
		if aList2[q] < aList1[i+1]
			aSections + [ aList1[i], aList2[q] ]
			del(aList2, q)
			exit
		ok
	next

next

for q = 1 to nLen2
	if aList2[q] > aList1[i]
		aSections + [ aList1[i], aList2[q] ]
		exit
	ok
next

? @@(aSections)

StopProfiler()

/*-----------

StartProfiler()

o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])
? o1.NeighborsOf(5)
#--> [4, 6]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzList([1,2,3,4,5])
o1 - [3,5]

? o1.Content()
#--> [ 1, 2, 4 ]

# Executed in 0.04 second(s)

/*-----------


StartProfiler()

aList1  = [ 1, 4, 6,   11,        18        ,    24  ]
aList2  = [          9,    14, 15,    21, 22, 23     ]

aList = Q(aList1).MergeWithQ(aList2).Sorted()


aSections = []
bContinue = TRUE


while TRUE

	for i = 2 to len(aList)
	
		if find(aList1, aList[i-1]) > 0 and
		   find(aList2, aList[i]) > 0
	
			aSections + [ aList[i-1], aList[i] ]
			if len(aSections) = 5
				exit 2
			ok

		ok
	next
	
	aList = Q(aList).ManyRemoved(Q(aSections).Merged())

end

? @@(aSections)



StopProfiler()

/*============
*/
StartProfiler()
 #                  ...4.6...v...4.v.v..1.v..
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                   ...^.^...0...^.6.8..^.3..

? o1.DeepFindBetweenAsSections("[", "]")

StopProfiler()

/*-----------

StartProfiler()
# NOTE: In this example, it is better to use DeepBetween

#                   1..4.6..v.1..vv..8..vv
o1 = new stzString("[••[•[••]•[••]]••[••]]")
#                   ^..^.^..9.^..45..^..21

? @@( o1.FindAnyBetweenAsSections("[","]") )
#--> [ [ 2, 8 ], [ 5, 13 ], [ 7, 14 ], [ 12, 20 ], [ 19, 21 ] ]

? @@( o1.AnyBetweenZZ("[","]") )
#--> [
#	[ "••[•[••", 	[ [ 2, 8 ] ] ],
#	[ "•[••]•[••", 	[ [ 5, 13 ] ] ],
#	[ "••]•[••]", 	[ [ 7, 14 ] ] ],
#	[ "••]]••[••", 	[ [ 12, 20 ] ] ],
#	[ "••]", 	[ [ 7, 9 ], [ 12, 14 ], [ 19, 21 ] ] ]
# ]

StopProfiler()

/*-----------

StartProfiler()
 #                  ...4.6...v...4.v.v..1.v..
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                   ...^.^...0...^.6.8..^.3..

? @@( o1.FindAnyBetween("[","]") )
#--> [ 5, 7, 15, 22 ]

? @@( o1.FindAnyBetweenAsSections("[","]") )
#--> [ [ 5, 9 ], [ 7, 15 ], [ 15, 17 ], [ 22, 22 ] ]

? @@( o1.BetweenZZ("[","]") )
#--> [
#	[ " [===", 	[ [ 5, 9 ] ] ],
#	[ "===]---[=", 	[ [ 7, 15 ] ] ],
#	[ "=] ", 		[ [ 15, 17 ] ] ],
#	[ "=", 		[ [ 7, 7 ], [ 8, 8 ], [ 9, 9 ], [ 15, 15 ], [ 22, 22 ] ] ]
#]

StopProfiler()
# Executed in 0.22 second(s)

/*-----------

StartProfiler()
	o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
	? o1.SubstringsBetween("<<", ">>")

	#--> [ "word1", "word2" ]

StopProfiler()
# Executed in 0.04 second(s)

/*----------- TODO

StartProfiler()

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


aList = o1.SectionsBetweenIB("[", "]")
nLen = len(aList)
for i = 1 to nLen
	? aList[i] + NL + NL + "--" + NL
next

StopProfiler()
#--> Executed in 0.05 second(s)

/*-----------

StartProfiler()

o1 = new stzString('[[[
	"1", "1",
		[[["2", "♥", "2"]]],
	"1",
		[[["2",
			[[["3", "♥",
				[[["4",
					[[["5", "♥"]]],
				"4",
					[[["5","♥"]]],
				"♥"]]],
			"3"]]]
		]]]

]]]')

? o1.SectionsBetween("[", "]")
# Executed in 12.72 second(s)

StopProfiler()

/*-----------

StartProfiler()

o1 = new stzString('[[[
	"1", "1",
		[[["2", "♥", "2"]]],
	"1",
		[[["2",
			[[["3", "♥",
				[[["4",
					[[["5", "♥"]]],
				"4",
					[[["5","♥"]]],
				"♥"]]],
			"3"]]]
		]]]

]]]')

//? o1.FindDeepSectionsBetween("[", "]")
aList = o1.SectionsBetween("[[[", "]]]")
nLen = len(aList)
for i = 1 to nLen
	? aList[i] + NL + "--" + NL
next
# Executed in 0.64 second(s)

	//o1.ReplaceAnyBetween("[", "]", "***")
	//o1.RemoveSubStringsBetweenIB("]","[")
	//? o1.SubStringsBetween("]","[") # ..BoundedBy
	//? o1.SubStringsBoundedBy(["]","["])  # Add it
	//o1.RemoveSubStringsBetweenIB("]","[")
	//o1.RemoveAnySectionsBoundedByIB("]","[")
	//? o1.Content()

StopProfiler()
# Executed in 0.63 second(s)
/*-----------

StartProfiler()

o1 = new stzList(
[ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "♥", ["4", [ "5", "♥" ], "4", ["5","♥"], "♥"], "3"] ] ])

? o1.NumberOfLevels()
#--> 5
# Executed in 0.04s

? @@( o1.DeepFind("♥") )
#--> [ [ 2, 2 ], [ 3, 2 ], [ 5, 2 ], [ 5, 2 ], [ 4, 3 ] ]
# Executed in 0.07s

StopProfiler()
#--> Executed in 0.12 second(s)

/*==============

StartProfiler()

o1 = new stzList([ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "🌞"] ] ])

? o1.DeepContains("🌞")
#--> TRUE

? o1.DeepContainsMany([ "1", "♥", "3", "🌞" ])
#--> TRUE

? o1.DeepContainsBoth("♥", :And = "🌞")
#--> TRUE

? o1.DeepContainsOneOfThese(["_", "🌞", "0" ])
#--> TRUE

? o1.DeepContainsNOfThese(2, ["_", "🌞", "0", "♥" ])
#--> #--> TRUE

StopProfiler()

/*==============

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortBy('len(@item)')
? o1.Content()

#--> [ "a", "ab", "abc", "abcd", "abcde" ]


/*==============

/* NOTE :
	- RemoveNthItem(n) : Remove item at position n

	- RemoveNthXT(n, pItem) : Remove nth occurrence of pItem
  	  (you can also use RemoveNthOccurrence(n, pItem)

	- RemoveThisNthItem(n, pItem) : remove nth item only if it
	  is equal to pItem
*/
/*
o1 = new stzList([ "_", "A", "B", "C", "_", "D", "E", "_" ])

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

o1.RemoveThisFirstItemCS("b", :CS = FALSE)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last)
? @@( o1.Content() )
#--> [ "C", "D" ]

/*-----------------

StartProfiler()

	o1 = new stzList([ "A", "B", "A", "C", "C", "D", "A", "E" ])
	
	? @@( o1.IndexBy(:NumberOfOccurrence) ) + NL
	#--> [ [ "A", 3 ], [ "B", 1 ], [ "C", 2 ], [ "D", 1 ], [ "E", 1 ] ]
	
	? @@( o1.IndexBy(:Position) )
	#--> [
	#	[ "A", [ 1, 3, 7 ] ],
	#	[ "B", [ 2 ] ],
	#	[ "C", [ 4, 5 ] ],
	#	[ "D", [ 6 ] ],
	#	[ "E", [ 8 ] ]
	# ]

StopProfiler() #--> Executed in 0.49 seconds seconds.

/*-----------------

# Extending a list of numbers to a given position

o1 = new stzList([ 1, 2, 3 ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

# Extending a list of strings to a given position

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ "A", "B", "C", "", "" ]


# Extending a list by a given item

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With = "♥")
? @@( o1.Content() )
#--> [ "A", "B", "C", "♥", "♥" ]

# Extending a list by its own items

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With@ = "@items" )
? @@( o1.Content() )
#--> [ "A", "B", "C", "A", "B" ]

# Extending a list by the items of an other list
o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(8, :With@ = [1, 2, 3] )
? @@( o1.Content() )
#--> [ "A", "B", "C", 1, 2, 3, 0, 0 ]

/*-----------------

o1 = new stzList([ ".",".",".","4","5","6",".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 4)
#--> [ "4", "5", "6" ]

? o1.PreviousNItems(3, :StartingAtPosition = 6)
#--> [ "4", "5", "6" ]

/*=================

o1 = new stzList([ 7, 3, 3, 10, 8, 8 ])

? o1.Smallest() #--> 3
? o1.Largest() #--> 10

? @@( o1.FindSmallest() ) #--> [2, 3]
? o1.NumberOfOccurrencesOfSmallestItem() #--> 2
# or more simply
? o1.NumberOfSmallest() #--> 2

? @@( o1.FindLargest() ) #--> [ 4 ]

? o1.NthSmallest(3) #--> 8
? @@( o1.FindNthSmallest(3) ) #--> [ 5, 6 ]

/*=================

o1 = new stzList([ ".", ".", "3", "4", ".", ".", "7", "8", "9", ".", "." ])

//? o1.YieldXT( '@item', :FromPosition = 4, :To = -3)
#--> [ ".", ".", "7", "8", "9" ]

? o1.YieldXT( '@char', :StartingAt = 3, :Until = ' @item = "." ' )
#--> [ "3", "4" ]

? o1.YieldXT( '@char', :StartingAt = 3, :UntilXT = ' @item = "." ' )
#--> [ "3", "4", "." ]


/*=================

? @@( Q([ "AB", 12, ["A", "B"] ]).TypesXT() )
#--> [ [ "AB", "STRING" ], [ 12, "NUMBER" ], [ [ "A", "B" ], "LIST" ] ]

/*-----------------

o1 = new stzList(["1","2","3","4","5"])

? o1.Section(2, 4)
#--> [ "2","3","4" ]

? o1.Section(2, -2)
#--> [ "2","3","4" ]

? o1.Section(:First, :Last)
#--> ["1","2","3","4","5"]

? o1.Section(3, :@)
#--> [ "3" ]

? o1.Section(:@, 3)
#--> [ "3" ]


/*-----------------

o1 = new stzList([ "T", "A", "Y", "O", "U", "B", "T", "A" ])
? o1.SectionsXT( :From = "T", :To = "A" )
#--> [ ["T", "A"], [ "T", "A", "Y", "O", "U", "B", "T", "A" ], ["T", "A"] ]

/*-----------------

o1 = new stzList([ "1", "2", "abc", "4", "5", "abc", "7", "8", "abc" ])

? o1.FindAll("abc")
#--> [3, 6, 9]

# Note: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

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

/*------------------

# The W() function takes a string and tries its best to return a well
# formed conditaional Ring expression used in several Softanza functions:
? W(' len(@item)=3')		#--> "{'len(@item)=3'}"
? W('"len(@item)=3"')		#--> "{'len(@item)=3'}"
? W("{'len(@item)=3'}")		#--> "{'len(@item)=3'}"
? W("{'len(@item)=3' ")		#--> "{'len(@item)=3'}"
? W("'len(@item)=3'")		#--> "{'len(@item)=3'}"
? W("{ 'len(@item)=3'")		#--> "{'len(@item)=3'}"

/*------------------

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('len(@item)')
#--> [10, 10, 10]

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('StzLen(@item)')
#--> [5, 5, 5]

/*------------------

? StzTextQ("你好").Script()
#--> :Han

/*------------------

? Stz(:Text, :Attributes)
#--> [
#	"@oobject",
#	"@cobjectvarname",
#	"@oqstring",
#	"@@aconstraints",
#	"@clanguage"
# ]

/*------------------

? Q([ "واحد", "اثنان", "ثلاثة" ]).AllItemsAre(:Strings)
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).AllItemsAre([ :Arabic, :Strings ])
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).AllItemsAre(:Texts)
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).AllItemsAre([ :ArabicScript, :RightToLeft, :Texts ])
#--> TRUE

? Q([ "واحـد", "اثنان", "ثلاثة" ]).AllItemsAre([ :ArabicScript, W('Q(@item).Size()=5'), :Texts ])
#--> TRUE

/*------------------

? Q([ "你好", "亲", "朋友们" ]).AllItemsAre([ :HanScript, :Texts ])
#--> TRUE

/*------------------

? W('len(@item)=3') #--> {'len(@item)=3'}

/*------------------

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre(:Strings)
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, :Latin, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, :Strings ])

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre([ :Uppercase, W('len(@item)=3'), :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).AllItemsAre( W('len(@item)=3') )
#--> TRUE

/*------------------

? Q([ 1, 2, 3 ]).AllItemsAre(:Numbers)
#--> TRUE

? Q([ -2, -4, -8 ]).AllItemsAre([ :Even, :Negative, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).AllItemsAre([ :Even, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).AllItemsAre([ :Even, :Positive, :Numbers ])
#--> TRUE

? Q([ "(",";", ")" ]).AllItemsAre([ :Punctuation, :Chars ])
#--> TRUE

/*------------------

# Transforming the list structure so it becomes
# a list of pairs of numbers. To do so, the numbers
# are duplicated inside a list of two items.

o1 = new stzList([ 0, 2, 0, 3, [1,2] ])
o1.PerformW(
	:do = '{ @item = Q(@item).RepeatedInAPair() }',
	:if = '{ Q(@item).IsANumber() }'
)

? @@(o1.Content())
#--> [ [ 0, 0 ], [ 2, 2 ], [ 0, 0 ], [ 3, 3 ], [ 1, 2 ] ]

/*------------------

o1 = new stzList([ "A", 0, 0, "B", "C", 0, "D", 0, 0 ])
? o1.ZerosRemoved() #--> [ "A", "B", "C", "D" ]

/*=============

# In Ring, it's impossible to make a comparison between two lists
# using the = operator like this:

? [1,2] = [1,2]
#--> Error (R21) : Using operator with values of incorrect type 

# In Softanza you can, just elevate the list to a stzList object
# using the Q() function like this:

? Q([1,2]) = [1,2] #--> TRUE

# This seems to be a minor feature, but it isn't. In fact, the Ring
# version breaks the programmer's train of thought when writing
# a code like this:

aMyList = [1,2]

if aMyList = [1,2]
	? "I'm done :)"
else
	? "Ooops!"
ok
#--> Error (R21) : Using operator with values of incorrect type

# Here is the same code enabled with Softanza Q() magic:
aMyList = [1,2]

if Q(aMyList) = [1,2]
	? "I'm really done! Thanks Softanza :)"
else
	? "Ooops!"
ok
#--> "I'm really done! Thanks Softanza :)"

/*---------

o1 *= new stzList([ 0, 2, 0, 3, [1,2] ])
? o1.IsListOfNumbersAndPairsOfNumbers() #--> TRUE

/*========= Deep finding items at any level : TODO
*/
o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? o1.NumberOfLevels() #--> 3
/* TODO
? o1.DeepFind("you")
#--> "you" is found in the following positions:
# [
#	[ "1",      [1, 5] ],
#	[ "1.3",    [ 2  ] ],
#	[ "1.3.3",  [ 1  ] ],
#	[ "1.5",    [ 1  ] ]
# ]

/*========= Replace and DeepReplace

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.Replace("me", :By = "you")
? @@( o1.Content() ) + NL
#--> [
#	"you",
#	"other",
#	[ "other", "me", [ "me" ], "other" ],
#	"other",
#	"you"
#    ]

/*------------

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.DeepReplace("me", :By = "you")
? @@( o1.Content() )
#--> [
#	"you",
#	"other",
#	[ "other", "you", [ "you" ], "other" ],
#	"other"
#    ]

/*================

# to get the background of this sample, read this:
# https://groups.google.com/g/ring-lang/c/_33L7miE3QM

# First way: Substring first
o1 = new stzString("ACD")
o1.Insert("B", :AtPosition = 2)
? o1.Content() #--> "ABCD"

# Second way: Position first
o1 = new stzString("ACD")
o1.InsertAt( :Position = 2, :SubString = "B")
? o1.Content() #--> "ABCD"

# Short forms:
o1.Insert("B", 2)
o1.InsertAt(2, "B")

# TODO: add ( :Position = ... and :SubString = ... ) everywhere!

/*--------------

# Same example above in stzList

o1 = new stzList([ "A", "C", "D" ])
o1.InsertAt(:Position = 2, :Item = "B")
//o1.Insert(:Item = "B", :BeforePosition = 2) # or for short: o1.Insert("B", 2)

? o1.Content()
#--> [ "A", "B", "C", "D" ]

/*--------------

# Same example above in stzListOfStrings

o1 = new stzListOfStrings([ "A", "C", "D" ])
o1.Insert("B", :AtPosition = 2)			# or you can say: o1.InsertAt(2, "B")
? o1.Content()
#--> [ "A", "B", "C", "D" ]

/*--------------

o1 = new stzList([ "A1", "A2", "A3" ])
o1.InsertAfter( :ItemAtPosition = 3, "A4" )
? o1.Content() #--> [ "A1", "A2", "A3" ]

/*================ MOVING AND SWAPPING

o1 = new stzList([ "C", "B", "A" ])
o1.Move( :From = 3, :To = 1 )
? o1.Content() #--> [ "A", "C", "B" ]

o1.Swap( :Items = 2, :AndItem = 3 )
? o1.Content() #--> [ "A", "B", "C" ]

/*--------------- Writablilty VS Readablility VS Both of them!

# Softanza coding style is designed with a double promise in mind:
#  - Your code is WRITABLE, hence easy to you while your are crafting it
#  - As well as READBALE, hence easy to your reader to understand it without a hassele!

# I'll explain this in action.

# Let's have a list, and then take two items inorder to swap them:
o1 = new stzList([ "C", "B", "A" ])

# You can quickly write:
o1.Swap(1, 3)
? o1.Content() #--> ["A", "B", "C"]

# And you are done! Which means litterally: "swap items at positions 1 and 3".

# The point is that Softanza talks in near natural language tongue,
# and the sentence above can be written as-is in plain Ring code:

o1.SwapItems( :AtPositions = 1, :And = 3)
# It's What You Think Is What You Get.
? o1.Content() #--> [ "C", "B", "A" ]
# Let's recapitulate:

# WRITABILITY: you quickly write a function, always in a short form,
# without complications, because you need to be focused on how to solve
# the case in hand and not in beautifying your code with any syntactic sugar!

# READBILITY : Others, or yourself in the future, can read the function
# and understand the intent of its writer without referring
# to any external documentation).

# And in Softanza, you have them both...

/*---------------

o1 = new stzList([ "ONE", "TWO", "THREE" ])
o1 - "TWO"
? o1.Content()
#--> [ "ONE", "THREE" ])

/*---------------

? Q([ "I", "B", "M" ]).HasSameContent( :As = [ "B", "M", "I" ] )
? Q([ "I", "B", "M" ]).HasSameContentCS( :As = [ "b", "m", "i" ], :CS = FALSE )

/*---------------

? Q("SFTANZA").IsLarger(:Then = "RING")		#--> TRUE
# or if you want to precise:
? Q("SFTANZA").HasMoreChars(:Then = "RING")	#--> TRUE

? Q("RING").IsSmaller(:Then = "SFTANZA")	#--> TRUE
# or if you want to precise:
? Q("RING").HasLessChars(:Then = "SFTANZA")	#--> TRUE

/*---------------

? Q([1, 2, 3, 4, 5]).IsLarger(:Then = [8, 9])		#--> TRUE
# or if you want to precise:
? Q([1, 2, 3, 4, 5]).HasMoreItems(:Then = [8, 9])	#--> TRUE

? Q([8, 9]).IsSmaller(:Then = [1, 2, 3, 4, 5])		#--> TRUE
# or if you want to precise:
? Q([8, 9]).HasLessItems(:Then = [1, 2, 3, 4, 5])	#--> TRUE

/*---------------

o1 = new stzList([ "arem", "mohsen", "AREM" ])
? o1.FindAll("arem") #--> 1

? o1.FindAllCS("arem", :CS = FALSE) #--> [1, 3]

? o1.FindNth(2, "arem") #--> 0
? o1.FindNthCS(2, "arem", :CS = FALSE) #--> 3

/*---------------

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])
? o1.NthToLast(2)
#--> "N"

/*---------------

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])

? o1.Section(1, 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(4, 1)
#--> [ "T", "F", "O", "S" ]

? o1.Section(:From = 1, :To = 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(:From = (:NthToLastItem = 3), :To = :LastItem)
#--> [ "A", "N", "Z", "A" ]

? o1.Section(:From = "F", :To = "A")
#--> [ "F", "T", "A" ]

? o1.Section( :From = "A", :To = :EndOfList )
#--> [ "A", "N", "Z", "A" ]

? o1.Section(-99, 99)
#--> [ ]

? o1.Section(4, :@)
#--> "T"

? o1.Section(:NthToLast = 3, :@)
#--> "A"

? o1.Section(:@, :@)
#--> [ "S", "O", "F", "T", "A", "N", "Z", "A" ]

/*=======================

# In Softanza, you can find lists inside lists:
o1 = new stzList([ "A", "B", [1, 2], "C", "D", [1, 2], "E" ])
? o1.FindAll([1, 2])	#--> [3, 6]
? o1.FindFirst([1, 2])	#--> 3

# And you can go deep and find even more complicated lists:
o1 = new stzList([
		"A", "B",
		[ 1, ["v", ["u"] ], 2 ],
		"C", "D",
		[ 1, ["v", ["u"] ], 2 ],
		"E"
])

? o1.FindAll( [ 1, ["v", ["u"] ], 2 ] ) #--> [ 3, 6]
? o1.FindFirst([ 1, ["v", ["u"] ], 2 ])	#--> 3

/*-----------------------

o1 = new stzList([ 1, 2 ])
? o1.IsEqualTo([ 1, 2 ])	 #--> TRUE
? o1.IsEqualTo([ 2, 1 ])	 #--> TRUE
? o1.IsStrictlyEqualTo([ 2, 1 ]) #--> FALSE
? o1.IsStrictlyEqualTo([ 1, 2 ]) #--> TRUE

/*-----------------------

o1 = new stzList([ [1,2], [3, [1], 4], [5,6], [ 2, 10 ], [3,4], [3, [1], 4] ])
? o1.FindAll( [3, [1], 4] ) #--> [2, 6]

? o1.FindFirst( [3, [1], 4] ) #--> 2

/*===============

? StzListQ( 4:8 ).ToListInStringQ().Simplified() 	#--> "[ 4, 5, 6, 7, 8 ]"
? StzListQ( 4:8 ).ToListInStringInShortForm() 		#--> "4:8"

/*---------------

o1 = new stzList([ 4, 1, 2, 1, 1, 2, 3, 3, 3 ])
? o1.DuplicatesRemoved() #--> [ 4, 1, 2, 3 ]

/*---------------

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])
? o1.FindAll(1:3) 	#--> [1, 3, 4]

? o1.Contains(7:10)	#--> TRUE	

/*---------------

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

o1.Removeduplicates()
? @@( o1.Content() )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9, 10 ] ]

/*================

? Q(' [ "A", "B", 3 ] ').IsListInString() 	#--> TRUE

? Q(' 1 : 3 ').IsListInString()			#--> TRUE

? Q(' "A" : "C" ').IsListInString() 		#--> TRUE

? Q(' "ا" : "ج" ').IsListInString() 		#--> TRUE

/*-----------------

? Q(' "A" : "C" ').ToList() #--> [ "A", "B", "C" ]
? Q(' "ا" : "ج" ').ToList() #--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

/*===============

# In Ring, you can declare a "contiguous" list of chars
# from "A" to "F" like this:

StzListQ("A":"F") {
	? Content()
	#--> Gives [ "A", "B", "C", "D", "E", "F" ]

	? ItemAtPosition(4) #--> "D"
}

# This beeing working only for ASCII chars, Softanza comes
# with a general solution for any "contiguous" UNIOCDE char:

StzListQ(' "ا" : "ج" ') {
	? Content()
	#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

	? ItemAtPosition(4) #--> "ت"
}

/*-----------------

? @@( List( :From = "A", :To = "E" ) )
#--> [ "A", "B", "C", "D", "E" ]

? @@( List( :From = "ا", :To = "ث" ) )
o#--> [ "ا", "ب", "ة", "ت", "ث" ]

? @@( ListXT( ' "A" : "E" ' ) )
#--> [ "A", "B", "C", "D", "E" ]

? @@( ListXT( ' "ا" : "ث" ' ) )
o#--> [ "ا", "ب", "ة", "ت", "ث" ]

/*-----------------

# As we all know, Ring provides us with this elegant syntax:

aList = "A" : "D"
? @@( aList )	#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# And if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? @@( aList )	#--> "ا"

# Fortunately, Softanza solves this by the List() function:

? @@( List( :From = "ا", :To = "ج" ) )
#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? @@( List("A", "D")	) #--> [ "A", "B", "C", "D" ]

# Interestingly, you can put the list in a string and mimics
# the "_" : "_" Ring syntax, by using the ..XT() form of the function:

? ListXT('"ا" : "ج"')	#--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]
? ListXT(' "ج" : "ا" ') 	#--> [ "ج", "ث", "ت", "ة", "ب", "ا" ]

/*================

aList = [
	:Arabic,
	:Arabic,
	:French,
	:English,
	:Spanish,
	:Spanish,
	:English,
	:Arabic
]

StzListQ(aList) {
 	? Classify()
		#--> [
		# 	:Arabic  = [ 1, 2, 8 ],
		# 	:French  = [ 3 ],
		# 	:Enslish = [ 4, 7 ],
		#    	:Spanish = [ 5, 6 ]
		#    ]

	? Classes() 		#--> [ :Arabic, :French, :English, :Spanish ]
	? NumberOfClasses() 	#--> 4
}


/*-----------------

o1 = new stzList([
	1982, 1964, 1992, 1982, 1964, 2001, 1982, 1992, 2000
])

? o1.Classify()
	#--> [
	# 	:1982 = [ 1, 4, 7 ],
	# 	:1964 = [ 2, 5 ],
	# 	:1992 = [ 3, 8 ],
	# 	:2001 = [ 6 ],
	# 	:2000 = [ 9 ]
	#    ]

# NOTE that classes are transformed to strings!

/*-----------------

o1 = new stzList([
	1:5, 3:9, 1:5, 10:15, 3:9, 12:20, 10:15, 1:5, 12:20
])

? @@( o1.Classify() )	# Same as Categorize()
#--> [
#	[ "[ 1, 2, 3, 4, 5 ]",   [1, 3, 8 ] ],	
#	[ "[ 3, 4, 5, 6, 7, 8, 9 ]",   [2, 5 ] ],
#	[ "[ 10, 11, 12, 13, 14, 15 ]", [4, 7 ] ],
#	[ "[ 12, 13, 14, 15, 16, 17, 18, 19, 20 ]", [6, 9 ]
#    ]

# Note that lists are transformed to strings so we can use them
# as keys for idenfifying their positions in the hash string.

# Hence we can say:

? o1.Klass("[ 1, 2, 3, 4, 5 ]") #--> [1, 3, 8 ]

# Here, I used "K" because "Class" is a reserved name by Ring.
# If you don't like that, use Category() instead.

# If you prefer getting the classes in "short form" (i.e. "1:5"
# instead of normal form "[1, 2, 3, 4, 5 ]", then use this:

? o1.ClassifySF() #--> "@C" for "Contiguous"
#--> [
#	[ "1:5",   [1, 3, 8 ] ],	
#	[ "3:9",   [2, 5 ] ],
#	[ "10:15", [4, 7 ] ],
#	[ "12:20", [6, 9 ]
#    ]

? o1.ClassesSF() #--> [ "1:5", "3:9", "10:15", "12:20" ]
	
? o1.KlassSF("1:5") #--> [1, 3, 8]

/*=================

? StzStringQ(:stzList).IsStzClassName() #--> TRUE
? StzListQ( :ReturnedAs = :stzList ).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ]) #--> TRUE

/*-----------------

? StzListQ([]).IsListOfStrings() #--> FALSE
? StzListQ([]).IsListOfNumbers() #--> FALSE

/*-----------------

? StzListQ([ [ "name", "Mansour"], [ "age", 45] ]).IsHashList()	#--> TRUE
? StzListQ([ :name ="Mansour", :age = 45 ]).IsHashList()	#--> TRUE

# But

? StzListQ([ "name" = "Mansour", "age" = 45 ]).IsHashList()	#--> FALSE

/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {
	? Numbers() #--> [ 1, 2, 3, 4, 5 ]
	# You can also say ? OnlyNumbers()

	? NonNumbers() # [ "A", "B", "C", "D" ]
	# You can also say OnlyNonNumbers()

	? Content() #--> [ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]
	# Note that the list is not altered by Numbers() and NonNumbers() functions
}

/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	RemoveNumbers() #--> You can also say RemoveOnlyNumbers()
	? Content() #--> [ "A", "B", "C", "D" ]

}


/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? NonNumbers() #--> [ "A", "B", "C", "D" ]
	# You can also say ? OnlyNonNumbers()

	RemoveNonNumbers()
	# You can also say RemoveOnlyNonNumbers() or RemoveAllExceptNumbers()

	? Content() #--> [ 1, 2, 3, 4, 5 ]
}

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
o1 - o1.NonNumbers()
? o1.Content() #-->  [ 1, 2, 3, 4, 5 ]

/*-----------------

o1 = new stzListOfStrings([ "A", "B", "1", "C", "2", "3", "D", "4", "5" ])
? o1.FindFirstCS("b", :CS = TRUE)	#--> 0
? o1.FindFirstCS("b", :CS = FALSE)	#--> 2

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1.Contains("a") #--> FALSE
? o1.Contains("A") #--> TRUE

? o1.ContainsNo("C") #--> FALSE
? o1.ContainsNo("X") #--> TRUE

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1.ItemsW('Q(@item).IsNotANumber()')
#--> [ "A", "B", "C", "D" ]

/*-----------------

o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

o1 - "A":"B"
? o1.Content()
#--> [ 1, 2, 3, "X", "Y", "Z" ]

o1 - [ "X", "Y", "Z" ]
? o1.Content()
#--> [ 1, 2, 3 ]

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
o1 - [ "A", "B", "C", "D" ]
? o1.Content()
#--> [ 1, 2, 3, 4, 5 ]

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
o1 - o1.ItemsW( :Where = 'Q(@item).IsNotANumber()' )
? o1.Content() #-->  [ 1, 2, 3, 4, 5 ]

/*================

StzListQ([ "by", "except"]) { 
	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ]) #--> TRUE

	# Same as
	? IsMadeOfSome([ :by, :except, :stopwords ]) #--> TRUE
}

/*-----------------

? IsBoolean(FALSE)	#--> TRUE
? Q(TRUE).IsBoolean()	#--> TRUE

/*-----------------

o1 = new stzList([ "by", "except", "stopwords" ])
? o1.IsMadeOfThese([ :by, :except, :stopwords ]) #--> TRUE

/*================

? StzListQ([ "q", "r", [ 2, 1 ] ]).ToCode() # Default output by Ring list2code()
#--> [
#	"q",
#	"r",
#	[
#		2,
#		1
#	]
#    ]

# Or you can use this alternative short form:
? @@( [ "q", "r", [ 2, 1 ] ] )
#--> same as ComputableForm()

# If you want to simplify the output by eliminating spaces:

? @@( [ "q", "r", [ 2, 1 ] ] ) # S for Simplified. Same as ComputerFormSimplified()
#--> [ "q", "r", [ 2, 1 ] ]

/*===============

? StzListQ([ "q", "r", [ 2, 1 ] ]).Contains([ 2, 1 ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameContentAs([ "r", [ 2, 1], "q" ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameSortingOrderAs([ "r", [ 2, 1], "q" ])
#--> FALSE

? StzListQ([ "q", "r", [ 2, 1] ]).IsEqualTo([ "q", "r", [2, 1] ])
#--> TRUE

/*-----------------

? StzListQ([]).Contains(NULL)		#--> FALSE
? StzListQ([NULL]).Contains(NULL)	#--> TRUE

? StzListQ([]).IsListOfStrings()	#--> FALSE

? StzListQ([ NULL, NULL, NULL]).IsListOfStrings() #--> TRUE

/*==================

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
o1 - [ "bo", "wo" ]
? o1.Content()
#--> [ "fa", "wy" ]

/*==================

? IsListOfStrings([ "baba", "ommi", "jeddy" ])		#--> TRUE
? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()	#--> TRUE

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}

#-->
#	 [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#	  --^--------------^---------^-------------------^------------

# WARINING: works only for list of chars
# TODO : Generalize it for list of strings and other types

/*------------------ TODO: Add this function

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindXT("A")
}

#--> Returns a string like this:

#	     1    2    3    4    5    6    7    8    9    0    1    2
#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^--------------^---------^-------------------^------------ (4)

/*------------------ (TODO)

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindMany([ "A", "B", "C", "D" ])
}

# !--> Returns a string like this:

#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^----.----.----^----.----^---------.----.----^---------.--
#   "B" :  -------^----.---------.--------------^----.--------------.--
#   "C" :  ------------.---------^-------------------.--------------^--
#   "D" :  ------------^-----------------------------.-----------------

/*------------------ (TODO)

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindManyXT([ "A", "B", "C", "D" ])
}

# !--> Returns a string like this:

#	     1    2    3    4    5    6    7    8    9    0    1    2
#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^----.----.----^----.----^---------.----.----^---------.-- (4)
#   "B" :  -------^----.---------.--------------^----.--------------.-- (2)
#   "C" :  ------------.---------^-------------------.--------------^-- (2)
#   "D" :  ------------^-----------------------------^----------------- (2)

/*===================

StzListOfStringsQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrence(2, :Of = "A", :With = "*", :StartingAt = 2 )
	? Content() #--> [ "A" , "B", "C", "A", "D", "*" ]
}

/*------------------

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of = "A", :By = "*", :StartingAt = 5)
	? Content() #--> [ "*" , "B", "C", "A", "D", "A" ]
}

/*------------------

StzListQ([ -1 , 2, 3, 4 ]) {
	? NumberOfItemsW("Q(@item).IsBetween(1, 4)") #--> 3
}

/*------------------

o1 = new stzList([ "1", "2", "*", "4", "5" ])
o1.ReplaceItemAtPosition(3, :By = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "2", "*", "4", "5" ])
o1.ReplaceItemAtPosition(3, :By@ = '{ 8 - 5 }' )
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrence( 2, :Of = "_", :With = "5", :StartingAt = 3)
? @@( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrence( 2, :Of = "_", :With@ = '{ 8 - 3 }', :StartingAt = 3)
? @@( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
	? @@( Content() ) #--> [ "A" , "B", "A", "C", "*", "D", "*" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? @@( NextNthOccurrencesReplaced([2, 3], :Of = "A", :With = "*",  :StartingAt = 3) )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrences([1, 2, 3], :of = "A", :with = "*",  :StartingAt = 5)
	? @@( Content() ) #--> [ "*" , "B", "*", "C", "*", "D", "A" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrences([3, 1], "A", :With = [ "#3", "#1" ], :StartingAt = 5)
	? @@( Content() ) #--> [ [ "#3", "#1" ], "B", "A", "C", [ "#3", "#1" ], "D", "A" ]
}

/*------------------

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content() #--> [ "A", "-", "-", "A", "-", "-", "A" ]
}

/*------------------

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6)
	? Content() #--> [ "A", "-", "-", "-", "A", "-", "A" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 3)
	? Content() #--> [ "A" , "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 3)
	#--> [ "A" , "B", "A", "C", "D" ]
}

/*-----------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindNextOccurrences(:Of = "A", :StartingAt = 3) #--> [ 3, 5, 7 ]

	? FindPreviousOccurrences(:Of = "A", :StartingAt = 5) #--> [ 1, 3, 5 ]

}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 5)
	? Content() #!--> [ "B" , "C", "A", "D", "A" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? PreviousNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 5)
	#!--> [ "B" , "C", "A", "D", "A" ]
}

/*=================

# In Softanza, you can replace all occurrences of an item
# in the list by a provided value, by saying:

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	Replace("A", :With = "#")
	# Or ReplaceAll("A", :With = "#") or ReplaceAllOccurrences(:Of = "A", :With = "#')

	? Content() #--> [ "#", "B", "C", "#", "D", "B", "#" ]

}

# In case you need to make many replacements at once, then you are covered:
# just provide the list of items to replace and the value of replacement...

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceMany([ "A", "B" ], :With = "#")
	? Content() #--> [ "#", "#", "C", "#", "D", "#", "#" ]

}

# You can even replace exitant items by many other new values, one by one,
# like this (useful in many scenarios of text interpolation and processing):

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceManyByMany([ "A", "B" ], :With = [ "#1", "#2" ])
	? Content() #--> [ "#1", "#2", "C", "#1", "D", "#2", "#1" ]

}

# And if you want to replace the occurrences of a given item by alternating
# between several other items you provide, then this is possible:

StzListQ([ "A", "A", "A" , "A", "A" ]) {
	
	ReplaceItemByAlternance("A", :With = [ "#1", "#2" ])

	? Content() #--> [ "#1", "#2", "#1", "#2", "#1" ]

}

/*---------------------

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content() #--> [ "A", "B", "C", "A", "D", "B", "#" ]

}

/*====================

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending() #--> [ 2, 5, 7, 9 ]

/*=====================

o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])
? o1.DuplicatesRemoved() #--> [ "teeba", "hussein", "haneen" ])
? o1.NumberOfItems()     #--> 4

/*=====================

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	#--> TRUE
# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		#--> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	#--> TRUE

/*=====================

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a" ] 
? @@( o1.Content() ) #--> [ "c" ]

/*-----------------------

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a", "c" , "q" ]
? @@( o1.Content() ) #--> [ ]

/*=====================

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])
? o1.FindMany([ "a", "e" ])	#--> [ 1, 3, 4, 7 ]
? o1.FindManyXT([ "a", "e" ])	#--> [ "a" = [ 1, 4 ], "e" = [ 3, 7 ] ]

/*-----------------------

o1 = new stzList([ "a", "E", "a", "c", "V", "E" ])
? o1.FindMany([ "a", "c" ]) #--> [1, 3, 5]

o1 - [ "a", "c" ] # Same as: o1.RemoveItemsAtPositions([ 1, 3, 5 ])

? o1.Content() #--> [ "E", "V", "E" ]

/*=====================

o1 = new stzList([ "a", "b", "c" ])

? o1.IsEqualTo([ "c", "b", "a" ])		#--> TRUE

? o1.IsStrictlyEqualTo([ "c", "b", "a" ])	#--> FALSE
# Because
? o1.HasSameTypeAs([ "c", "b", "a" ])		#--> TRUE
? o1.HasSameContentAs([ "c", "b", "a" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "c", "b", "a" ])	#--> FALSE

/*---------------------

o1 = new stzList([ "a", "b", "c" ])
? o1.IsStrictlyEqualTo([ "a", "b" ])	#--> FALSE
# Because
? o1.HasSameTypeAs([ "a", "b" ])	#--> TRUE
? o1.IsEqualTo([ "a", "b" ])		#--> FALSE
? o1.HasSameSortingOrderAs([ "a", "b" ])#--> TRUE

/*=====================

? @@( StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened() )
#--> [ "a","b","c","d","e","f" ]

/*---------------------

? StzStringQ("ab []    cd").Simplified()
#--> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
#--> [ "a",[ [ ] ],"b" ]

/*---------------------

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {
	Flatten()
	? @@( Content() )
	#--> [ "a",[ ],"c",1,[ ],2,"b" ]

	? NumberOfItems() 		#--> 7
	? ItemAtPosition(3)		#--> "c"
	? @@(ItemAtPosition(5))	#--> [ ]
	
}

/*=====================

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
#--> [ 1, 2, 3, 5, 6 ]

? @@(o1.FindManyXT([ :one, :five ]))
#--> [ :one = [1, 3, 5], :five = [ ] ]

/*---------------------

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
#--> [ 1, 2, 3, 5, 6 ]

? o1.FindManyXT([ :one, :two, :four ])
#--> [ :one = [1, 3, 5], :two = [2], :four = [6] ]

/*---------------------

o1 = new stzList([ 1, 2, 3])

o1.ExtendToPosition(5)
? o1.Content() #--> [ 1, 2, 3, 0, 0 ]

o1.ExtendToPositionXT( 8, :With = 5 )
? @@(o1.Content())
#--> [ 1, 2, 3, 0, 0, 5, 5, 5 ]

/*=====================

oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType() 	#--> 1
? oList.ItemsAreAllEmptyLists() #--> 0

/*=====================

o1 = new stzList(1:5)
o1.AddItemAt(7, 9)
? o1.Content() #--> [ 1, 2, 3, 4, 5, 0, 0, 9 ]

/*---------------------

o1 = new stzList("A":"E")
o1.AddItemAt(7,"X")
? o1.Content() #--> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

/*=====================

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsW( '{ @item >= 8 }' ) #--> [ 8, 11, 11, 10, 8, 8 ]

/*---------------------

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence("2") 	#--> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence([ 2 ])	#--> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence( 2 )	#--> 2

? Q(2).IsOneOfThese([ 3, 2, 5 ]) 	#--> TRUE
? Q("2").IsOneOfThese([ 3, 2, 5 ]) 	#--> FALSE
? Q([2]).IsOneOfThese([ 3, 2, 5 ])	#--> FALSE

/*====== YIELD AND CUMULATE

StartProfiler()

o1 = new stzList([ "one", "two", "three" ])
? o1.Yield("len(@item)")
#--> [ 3, 3, 5 ]

? o1.YieldAndCumulate('len(@item)', :ReturnLast = FALSE)
#--> [ 3, 6, 11 ]

? o1.YieldAndCumulate('len(@item)', :ReturnLast )
#--> 11

StopProfiler()
#--> Executed in 0.07 seconds seconds.

/*-----------------

StartProfiler()

o1 = new stzList([ "I", "love", "Ring!" ])
? @@( o1.YieldAndCumulate('{ @item +  " " }', :ReturnEach ) )
#--> [ [ "I ", "I love ", "I love Ring!" ]

? o1.YieldAndCumulateQ('{ @item +  " " }', :ReturnLast).Trimmed()
#--> "I love Ring!"

StopProfiler()
#--> Executed in 0.06 seconds seconds.

/*======================

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 8 ])

? o1.FindW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 1, 3, 5, 8, 9, 12 ]

? o1.ItemsW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 2, 2, 4, 2, 2 ]

? o1.UniqueItemsW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 4 ]

? o1.ItemsAndTheirPositionsW(:Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }')
#--> [
#	:2 = [ 1, 3, 5, 9, 12 ], 
#	:4 = [ 8 ]
#    ]

/*---------------------

o1 = new stzList([ "_", "_", 1:3, "_", 5:9, "_" ])
? o1.FindW( :Where = '{ Q(@item).IsOneOfThese([ 1:3, 5:9 ]) }' )
#--> [ 3, 5 ]

/*---------------------

StartProfiler()

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsW( :Where = 'Q(@item).IsAnUppercase()')
#--> [ "A", "B", "A", "C", "B" ]

# Executesin less then 0.08 second:
? ElapsedTime() + NL

# The other extended form (provides more features, like code transpilation
# and executable section identification) takes more time ( about 0.92 second).
? o1.ItemsWXT( :Where = 'Q(@item).IsAnUppercase()')

/*---------------------

StartProfiler()

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsPositionsW('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...) or .FindW(...)
#--> [ 1, 4, 5, 7, 9 ]

? o1.ItemsAndTheirPositionsW('Q(@item).IsUppercase()')
#--> [ "A" = [1, 5], "B" = [4, 9], "C" = [7] ]

StopProfiler()

/*=========================

StartProfiler()

o1 = new stzList([ "A", "B", "_", "C", "D", "E", "F" ])
? o1.AllItemsExcept("_")

StopProfiler() # 0.03 second

/*=========================

StartProfiler()

o1 = new stzList([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])
? o1.CheckOnW([1, 3, 5], :That = 'Q(@item).IsLeftToRight()' ) #--> TRUE

StopProfiler()
#--> Executed in 0.03 second.

/*=========================

StartProfiler()

o1 = new stzString ('{ This[ @i - 3 ] = This[ @i + 3 ] .... @i -12233.87  @i + 764.3322 }')
//? o1.NumbersAfter("@i")
#--> [ "-3", "3", "-12233.87", "764.3322" ]

? o1.NumberComingAfter("@")
#--> "-3"

StopProfiler()

/*=========================

? StzCCodeQ('{ This[ @i - 3 ] = This[ @i + 3 ] }').ExecutableSection()
#--> [4, -4]

/*========================= ...W() and ..WXT() forms in Conditional Code

# In conditional code, there are always to forms:
#	- the ...W(pcCondition) form, which is more performant, but less expressive
#	- the ...WXT(pcCondition) form, which is less performant, but more expressive

# In the first form, you can only use the the @item, @string, ... and the @i keywords.
# While in the second, you can use keywords sutch as @NextItem, @PreviousItem, and others.

# You can always express these additional keywords, while option for the more performant
# form, by transalating them to This[@i-1] for @PreviousItem, for example, and to
# This[@i+1] for @NextItem, etc.

StartProfiler()

# Finding positions where next number is double of previous number
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? @@( o1.FindWXT( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' ) ) #--> [ 8, 11 ]
? ElapsedTime() + NL #--> Takes 0.40s

? @@( o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) )  #--> [ 8, 11 ]
# Takes 0.05s only!

StopProfiler()

/*-----------

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

# The function above you can also write like this:
? o1.FindWXT( :Where = '{ Q( @NextItem ).IsDoubleOf( @PreviousItem ) }' )
#--> [ 8, 11 ]

# or like this:
? o1.FindWhere( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' )
#--> [ 8, 11 ]

/*-----------

StartProfiler()

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])

? o1.FindWXT( '{ @Number = @NextNumber }' ) #--> [ 3, 8, 17, 18 ]
? ElapsedTime() #--> Takes 0.41s

? o1.FindW( '{ This[@i] = This[@i+1] }' ) #--> [ 3, 8, 17, 18 ]
#--> Takes as little as 0.05s!

StopProfiler()

/*-----------

StartProfiler()

# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 2, 5, 6 ]

StopProfiler()
#--> Executed in 0.04 second(s)

/*-----------

StartProfiler()

? StzCCodeQ('{ This[ @i - 3 ] = This[ @i + 3 ] }').ExecutableSection()

StopProfiler()
#--> Executed in 0.22 second(s)

/*-----------

StartProfiler()

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? @@( o1.FindWXT('{ This[ @i - 3 ] = This[ @i + 3 ] }') ) #--> [ 4 ]
? ElapsedTime()
#--> 0.57 second(s)

? @@( o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') ) #--> [ 4 ]
#--> 0.22 second(s)

StopProfiler()
#--> Executed in 0.74 second(s)

/*========================

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? o1.PreviousNthOccurrence(3, :Of = 0, :StartingAt = 5) #--> 1
? o1.PreviousNthOccurrence(2, :Of = 8, :StartingAt = :LastItem) #--> 2

/*-----------------------

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])
? o1.FindAll(120) #--> [ 3, 6 ]
? o1.NumberOfOccurrence(120) #--> 2

/*-----------------------

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])
? o1.FindNthNextOccurrence( 2, :Of = 120, :StartingAt = 1 ) #--> 6

/*-----------------------

o1 = new stzList([ "mio", "mia", "mio", "mix", "miz", "mix" ])
? o1.FindNthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 ) #--> 6

# Other alternatives are:
? o1.FindNextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 ) #--> 6
? o1.NthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 ) #--> 6
? o1.NextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 ) #--> 6

/*-----------------------

o1 = new stzList([ "mio", "mix", "mia", "mio", "mix", "miz", "mix" ])
? o1.FindPreviousNthOccurrence( 2, :Of = "mix", :StartingAt = 6) #--> 2

/*-----------------------

o1 = new stzList([ :Char, :String, :Number, :List, :Object, :CObject, :QObject, :Byte ])
? o1.RemoveItemsAtThesePositionsQ( 6:8 ).Content()
#--> [ :Char, :String, :Number, :List, :Object ]

/*-----------------------

StartProfiler()

	o1 = new stzList([ "A", "b", "C" ])
	o1.ReplaceItemAtPosition(2, :With@ = "upper(@item)")
	? o1.Content()	#--> [ "A", "B", "C" ]

StopProfiler()
#--> Executed in 0.08 second(s)

/*==========================

/*--------- WALKING WHERE

StartProfiler()

StzListQ([ 1, 2, "A", "B", 5, "C", 7 ]) {

	? WalkWhere(' isNumber(@item) ')
	#--> [1, 2, 5, 7]

	? WalkWhereXT(' NOT isNumber(@item) ', :Backward, :Walkeditems)
	#--> ["C", "B", "A"]

	? WalkWhereXT(' isNumber(@item) ', :Default, :Default)
	#--> [1, 2, 5, 7]
}

StopProfiler()
#--> Executed in 0.24 second(s)

/*--------- WALKING UNTIL (AND UNTIL BEFORE)

StartProfiler()

StzListQ([ 1, 2, 3, "A", "B", 6, "C", "D", "E" ]) {

	? WalkUntil(' isString(@item) ')
	#--> [1, 2, 3, 4]

	? WalkUntil(:Before = ' isString(@item) ')
	#--> [1, 2, 3]

	? WalkUntilXT(:Before = ' isNumber(@item) ', :Backward, :WalkedItems)
	#--> ["E", "D", "C"]

	? WalkUntilXT(' isString(@item) ', :Default, :Default)
	#--> [1, 2, 3, 4]
}

StopProfiler()
#--> Executed in 0.24 second(s)

/*--------- WALKING WHILE

StartProfiler()

StzListQ([ 1, 2, 3, "A", "B", 6, "C", "D", "E" ]) {

	? WalkWhile(' isNumber(@item) ')
	#--> [1, 2, 3]

	? WalkWhileXT(' isString(@item) ', :Backward, :WalkedItems)
	#--> ["E", "D", "C"]

	? WalkWhileXT(' isNumber(@item) ', :Default, :Default)
	#--> [1, 2, 3]
}

StopProfiler()
#--> Executed in 0.23 second(s)

/*--------- OTHER WALKING TECHNIQUES

StartProfiler()

StzListQ([ "A", "B", "C", "D", "E", "F", "G" ]) {

	// Walking the list from the postion where a condition is verified

		? @@( WalkWhen( ' @item = "D" ' ) )
		#--> [ 4, 5, 6, 7 ]

		? @@( WalkWhenXT( ' @item = "D" ', :Forward, :WalkedItems ) )
		#--> [ "D", "E", "F", "G" ]

		? @@( WalkWhenXT( ' @item = "D" ', :Backward, :WalkedItems ) )
		#--> [ "D", "C", "B", "A" ]

	// Walking the list from the postion where a condition is verified

		? @@( WalkBetween( 3, 5 ) )
		#--> [ 3, 4, 5 ]

		? @@( WalkBetweenIB( 3, 5, :WalkedItems ) )
		#--> [ "C", "D", "E" ]

		? @@( WalkBetweenIB( 5, 3, :WalkedItems ) )
		#--> [ "E", "D", "C" ]

	// Walking the list forth and back
		? @@( WalkForthAndBack() ) + NL
		#--> [ 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1 ]

		? @@( WalkForthAndBackXT(:Return = :WalkedItems) ) + NL
		#--> [ "A", "B", "C", "D", "E", "F", "G", "F", "E", "D", "C", "B", "A" ]


	// Walking the list back and forth
		? @@( WalkBackAndForth() ) + NL
		#--> [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7 ]

		? @@( WalkBackAndForthXT(:Return = :WalkedItems) ) + NL
		#--> [ "G", "F", "E", "D", "C", "B", "A", "B", "C", "D", "E", "F", "G" ]

	// Walking n steps forward
		? @@( WalkNForward(2) ) + NL
		#--> [ 1, 3, 5, 7 ]

		? @@( WalkNForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "E", "G" ]

	// Walking n steps backward
		? @@( WalkNBackward(2) ) + NL
		#--> [ 7, 5, 3, 1 ]

		? @@( WalkNBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "C", "A" ]

	// Walking n progressive steps forward
		? @@( WalkNMoreForward(2) ) + NL
		#--> [ 1, 3, 7 ]

		? @@( WalkNMoreForwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "A", "C", "G" ]

	// Walking n progressive steps backward
		? @@( WalkNMoreBackward(2) ) + NL
		#--> [ 7, 5, 1 ]

		? @@( WalkNMoreBackwardXT(2, :Return = :WalkedItems) ) + NL
		#--> [ "G", "E", "A" ]

	// Walking n steps forward and then n steps backward

		? @@( WalkForwardBackward(1, 1) )
		#--> [ ]

		? @@( WalkForwardBackward(1, 2) )
		#--> [ 2, 3, 1 ]

		? @@( WalkForwardBackwardXT(1, 2, :Return = :WalkedItems) )
		#--> [ "B", "C", "A" ]

		#--

		? @@( WalkForwardBackward(3, 1) )
		#--> [ 1, 4, 3, 6, 5 ]

		? @@( WalkForwardBackwardXT(3, 1, :Return = :WalkedItems) )
		#--> [ "A", "D", "C", "F", "E" ]

	// Walking n steps backward n steps forward

		? @@( WalkBackwardForward(1, 2) )
		#--> [ 6, 5, 7 ]

		? @@( WalkBackwardForwardXT(1, 2, :WalkedItems) )
		#--> [ "F", "E", "G" ]

		#--

		? @@( WalkBackwardForward(3, 2) )
		#--> [ 7, 4, 6, 3, 5, 2, 4, 1, 3 ]

		? @@( WalkBackwardForwardXT(3, 2, :WalkedItems) )
		#--> [ "G", "D", "F", "C", "E", "B", "D", "A", "C" ]

	// Walking n steps from the start and n steps from the end

		? @@( WalkNStartNEnd(1, 1) )
		#--> [ 1, 2, 6, 3, 5, 4 ]

		? @@( WalkNStartNEnd(2, 3) )
		#--> [ 1, 3, 4 ]

		? @@( WalkNStartNEndXT(2, 3, :WalkedItems) )
		#--> [ "A", "C", "D" ]

		#--

		? @@( WalkNEndNStart(1, 1) )
		#--> [ 7, 6, 1, 5, 2, 4, 3 ]

		? @@( WalkNEndNStartXT(1, 1, :WalkedItems) )
		#--> [ "G", "F", "A", "E", "B", "D", "C" ]

}

StopProfiler()

/*========================

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSection(4, 6, [ "*", "*", "*", "*" ])
? o1.Content()
#--> [ "A", "B", "C", "*", "*", "*", "*", "D", "E" ]

/*-----------------------

? StzListQ([ 1, 2, 3 ]).RepeatNTimes(3)

/*-----------------------

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems() #--> TRUE
	? NumberOfLeadingItems() # 3
	? LeadingItems() #--> [ "*", "*", "*" ]
	
	? HasTrailingItems() #--> TRUE
	? NumberOfTrailingItems() # 2
	? TrailingItems() #--> [ "+", "+" ]

	ReplaceRepeatedLeadingItemWith("+")
	? Content() #--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingItemAndTrailingItemWith("*","*")
	? Content() #--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

STOP()

/*-----------------------

# All these return TRUE

? StzListQ([ :DefaultLocale ]).IsLocaleList()

? StzListQ([ :SystemLocale ]).IsLocaleList()
? StzListQ([ :CLocale ]).IsLocaleList()

? StzListQ([ :Language = :Arabic, :Script = :Arabic, :Country = :Tunisia ]).IsLocaleList()

? StzListQ([ :Language = :Arabic, :Country = :Tunisia ]).IsLocaleList()
? StzListQ([ :Country = :Tunisia ]).IsLocaleList()

STOP()

/*-----------------------

# All these return TRUE

? Q( 1:5 ).IsListOf(:Numbers)
? Q( "A":"E" ).IsListOf(:Strings)
? Q([ 1:5, "A":"E" ]).IsListOf(:Lists) 

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListOfNumbers)
? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListsOfNumbers) # Note the support of plural form

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListOfStrings)
? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListsOfStrings) # Note the support of plural form

STOP()

/*-----------------------

# All these return TRUE

oNumber1 = StzNumberQ(7)
oNumber2 = StzNumberQ(12)
oNumber3 = StzNumberQ(24)

? Q([ oNumber1, oNumber2, oNumber3 ]).IsListOf(:StzNumbers)
? Q([ [oNumber1, oNumber2], [oNumber2, oNumber3] ]).IsListOf(:ListsOfStzNumbers)

oString1 = StzStringQ("Win")
oString2 = StzStringQ("Loose")
oString3 = StzStringQ("Don't care!")

? Q([ oString1, oString2, oString3 ]).IsListOf(:StzStrings)
? Q([ [oString1, oString2], [oString2, oString3] ]).IsListOf(:ListsOfStzStrings)

STOP()

/*-----------------------

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemW(3, :Where = '{ isString(@item) and Q(@item).IsLowercase() }')
#--> "compagon"

STOP()

/*-----------------------

# In Softanza, two lists are equal when they have same
# number of items and have same content
 
o1 = new stzList(1:3)
? o1.HasSameContentAs(3:1)		#--> TRUE
? o1.HasSameNumberOfItemsAs(3:1)	#--> TRUE
? o1.IsEqualTo(3:1)			#--> TRUE

/*-----------------------

# In Softanza, two lists are STRICTLY equal when they have
# same number of items, have same content, and same sorting order

# ==> In other terms: when they are Equal (in the sense of
# IsEqualTo()) and have same sorting order
 
# This beeing said, 1:3 is equal to its reversed list 3:1
# but it is not STRICTLY equal to it

? Q(1:3).IsEqualTo(3:1)		#--> TRUE
? Q(1:3).IsStrictlyEqualTo(3:1)	#--> FALSE

# In fact, the two lists don't have the same sorting order!

? Q(1:3).SortingOrder()	#--> :Ascending

? Q(3:1).SortingOrder()	#--> :Descending

# Hence, 1:3 is STRICTLY equal only to itself

? Q(1:3).IsStrictlyEqualTo(1:3)	#--> TRUE

/*-----------------------

# Softanza can compare lists (and string sofar), in an approximative way.
# Of course, the degree of approximation can be tuned to fit with your need.

o1 = new stzList([ "f","a","y","e","d" ])
? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])	#--> FALSE
? QuietEqualityRatio()	#--> 0.09

SetQuietEqualityRatio(0.41)
? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])	#--> TRUE

/*-----------------------

# Softanza can sort a list, whatever data types it contains (not only
# numbers and strings), in ascending and descending orders (see
# comments in corresponding methods in stzList class).

# Also, it can retrieve the sorting of a list using SortingOrder()
# method (returns :Ascending, :Descending, or :Unsorted).

# And it can compare the sorting orders of two lists using
# HasSameSortingOrderAs() method.

? Q(3:1).SortInAscendingQ().Content()	#--> [ 1, 2, 3 ]
? Q(1:3).SortInDescendingQ().Content()	#--> [ 3, 2, 1 ]

? Q(1:3).SortingOrder()	#--> :Ascending

? Q(1:3).HasSameSortingOrderAs(3:1)	#--> FALSE
? Q(1:3).HasSameSortingOrderAs(1:3)	#--> TRUE
? Q(1:3).HasSameSortingOrderAs(1:5)	#--> TRUE

/*-----------------------

# Operators on stzString

o1 = new stzList([ "S","O","F","T","A","N","Z","A" ])

# Getting a char by position
? o1[5]		#--> "A"


# Finding the occurrences of a substring in the string
? o1["A"]	#--> [ 5, 8 ]

# Getting occurrences of chars verifying a given condition
? o1[ '{ Q(@item).IsOneOfThese(["A", "T", "Z"]) }' ]	#--> [ 4, 5, 7, 8 ]

STOP()

/*-----------------------

o1 = new stzList([ 10, 1, 2, 3, 10 ])
o1.Remove(10)
? o1.Content() #--> [ 1, 2, 3 ]

/*---------------- TODO: enhance finding objects inside lists

obj = new Person { name = "sun" }

o1 = new stzList([ 10, "A":"E", 12, obj, 10, "A":"E", obj, "Ring" ])
? o1.FindAll(10)	#--> [ 1, 5 ]
? o1.FindAll("Ring")	#--> [ 8 ]
? o1.FindAll("A":"E")	#--> [ 2, 6 ]

? o1.FindAll(obj)	#--> [ 4, 7 ]
# TODO: this won't work corretcly if we add other objects different from
# obj in the list. We should think of an other algorithm other then relying
# on the empty spaces generated, for objects, by list2code() function of Ring!

o1.Remove("A":"E")
#--> [ 10, 12, obj, 10, "A":"E", obj, "Ring" ]

class Planet Person

/*-----------------------

# Ring can find (and sort) items inside a list (respectively
# using find() and sort() functions), but only if these items
# are of type "NUMBER" or "STRING".

# Softanza makes it posible to find (and sort) all the three
# types: numbers, strings, lists (--> TODO: not yet for objects).

o1 = new stzList([ "twelve", 12, [ "L2", "L2" ], "ten", 10, [ "L1", "L1" ] ])
? o1.FindAll([ "L1", "L1" ]) #--> [ 6 ]

# Not only list are findable, they are also sortable and comparable.

? o1.SortedInAscending() #--> [ 10, 12, "ten", "twelve", [ "L2", "L2" ], [ "L1", "L1" ] ]

# As you can see, the logic of sorting applied by Softanza is:
#	--> Putting numbers first and sorting them
#	--> Adding strings after that and sorting them
#	--> Adding lists as they occure in the main list

# Same thing should be possible for objects but not yet implemented (TODO)

STOP()

/*-----------------------

# Softanza works consistently on lists and strings: What works
# for a string, would generally work for a list, when it makes
# sense, using the same semantics.

# For example, in strings, we can check if the string is bounded
# by two given substrings, or even by many of them. So, we say:

oStr = new stzString("|<--Scope of Life-->|")
? oStr.IsBoundedBy([ "|<--", "-->|" ]) #--> TRUE

# And then we can delete these bounds:
? oStr.BoundsRemoved([ "|<--", "-->|" ]) #--> "Scope of Life"

# The same semantics apply to lists, like this:

oList = new stzList([ "|<--", "Scope", "of", "Life", "-->|" ])
? oList.IsBoundedBy([ "|<--", "-->|" ]) #--> TRUE

# And we can remove all these bounds, exactly like we did for strings:
? oList.BoundsRemoved([ "|<--", "-->|" ]) #--> [ "Scope", "of", "Life" ]

STOP()
/*-----------------------

o1 = new stzList([ "{", "A", "B", "C", "}" ])
? o1.IsBoundedBy([ "{", "}" ]) #--> TRUE

o1.RemoveBounds([ "{", "}" ])
? o1.Content() #--> [ "A", "B", "C" ]

/*-----------------------

o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])
? o1.BoundsUpToNItems(1) #--> [ "{","}" ]
? o1.BoundsUpToNItems(2) #--> [ [ "{", "<" ], [ ">", "}" ] ]

/*-----------------------

o1 = new stzList([ "{", "A", "B", "C", "}" ])
? o1.BoundsRemoved([ "{", "}" ]) #--> [ "A", "B", "C" ]

/*-----------------------

o1 = new stzList([ "1", "2", "A", "B", "C", "3", "4" ])
? o1.ContainsEach([ "A", "B", "C" ]) #--> TRUE
? o1.ContainsEachOneOfThese([ "A", "B", "C" ]) #--> TRUE

/*-----------------------

o1 = new stzList([ "A", "B", "C" ])
? o1.EachItemExistsIn([ "1", "2", "A", "B", "C", "3", "4" ]) #--> TRUE

/*-----------------------

? ListIsListOfHashLists([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
]) #--> TRUE

o1 = new stzList([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
])
? o1.Show()
#-->
#   name: "mansour"
#   job: "programmer"
#   age: 45
#   
#   name: "selmen"
#   job: "manager"
#   age: 45
#   
#   name: "mahran"
#   job: "manager"
#   age: 45

/*-----------------------

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWQ('{
	isNumber(@item) and
	Q(@item).IsDividableBy(2)
}').NumberOfItems() #--> 3

/*----------------------

? @@( StzListQ("A":"E").Reversed() )		#--> [ "E", "D", "C", "B", "A" ]
? @@( StzListQ("A":"E").ItemsReversed() )	#--> [ "E", "D", "C", "B", "A" ]

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsW('isNumber(@item)')
#--> 3

? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsW('
	isString(@item) and Q(@item).isLetter()
') #--> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsW('Q(@item).IsDividableBy(2)') #--> 3

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW(' isNumber(@item) ')
#--> [1, 2, 3]

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW('
	isString(@item) and _(@item).@.IsLetter()
') #--> ["A", "B", "C"]

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsW('Q(@item).IsDividableBy(2)')
#--> [2, 4, 6]

/*----------------------

o1 = new stzList( [ "1", "2", [ 1, [ "x" ], 2 ],  "3" ] )

? o1.ToCode()
#--> '[ "1", "2", [ 1, [ "x" ], 2 ],  "3" ]'

/*----------------------

# You can replace the nth item of a list
# by a given value by writing:

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, "B")
? o1.Content()	#--> [ "A", "B", "C" ]

# Or you can be a bit more expressive by using :With

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, :With = "B")
? o1.Content() #--> [ "A", "B", "C" ]

# Or you can use the dynamic form of :With@ to evaluate
# a piece of Ring code that returns the replaced value

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, :With@ = ' Q(@item).Uppercased() ')
? o1.Content()	#--> [ "A", "B", "C" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By = "A")
? o1.Content() #--> [ "A", "A", "A" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By@ = "Q(@item).Uppercased()")
? @@( o1.Content() )  #--> [ "A", "A", "A" ]

o1 = new stzList([ "1", "2", "_", "_", "_", "4", "5" ])
o1.ReplaceSection(3, 5, :With = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

/*=======================

StartProfiler()

o1 = new stzList([ 1, "a", 2, "b", 3, "c" ])
? o1.FindW('{ isString(@item) and Q(@item).isLowercase() }')
#--> [2, 4, 6]

StopProfiler()
# Executed in 0.26 second(s)

/*========================

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt(2, "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", 5 ]

/*----------------------

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt([2, 5], "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

/*----------------------

StartProfiler()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemAtPosition(5, :with@ = '{ @item * 2 }')
? @@( o1.Content() )
#--> [ "♥", 2, "♥", "♥", 10 ]

StopProfiler()
#--> Executed in 0.01 second(s)

/*----------------------

StartProfiler()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemsAtPositions([2, 5], :With = "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

StopProfiler()
#--> Executed in 0.01 second(s)

/*----------------------

StartProfiler()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemsAtPositions([1, 3, 4], :With@ = '@Position')
? @@( o1.Content() )
#--> [ "♥", "A", "♥", "♥", "A" ]

StopProfiler()
#--> Executed in 0.08 second(s)

/*----------------------

StartProfiler()

# Conditional replacement of items can happen for all the items defined by a
# given condition, and by replacing themn with the same given value like this:

StzListQ( [ 1, "a", 2, "b", 3, "c" ] ) {
	ReplaceItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By = "*"
	)

	? Content() #--> [ 1, "*", 2, "*", 3, "*" ]
}

? ElapsedTime() #--> 0.28 second(s)

# Or by a dynamic value given in a conditional code after :By@ or :With@, like this:

StzListQ( [1, "a", 2, "b", 3, "c" ]) {
	ReplaceItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By@ = '{ Q(@item).Uppercased() }'
	)

	? Content() #--> [ 1, "A", 2, "B", 3, "C" ]
}

StopProfiler()
#--> Executed in 0.60 second(s)

/*=================

o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3) #--> [ "a", "b", "c" ]

/*---------------

? ListsMerge([ [ 1, 2 ], [ 3 ] ])
#--> [ 1, 2, 3 ]

? ListsMerge([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
])
#--> [ [ 1, 2], [3, 4] ]

? ListsFlatten([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
])
#--> [ 1, 2, 3, 4 ]

/*--------------

? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).
	ItemsW('StzCharQ(@item).IsArabic()') #--> [ "ض", "س", "ط" ]

/*--------------

? @@( StzListQ([ "a", 1, "b", 2, "c", 3 ]).Types() )
#--> [ "STRING", "NUMBER", "STRING", "NUMBER", "STRING", "NUMBER" ]

? StzListQ([ "a", 1, "b", 2, "c", 3 ]).UniqueTypes()
#--> [ "STRING", "NUMBER" ]

/*--------------

StzListQ([ "one", "two", "three" ]) {
	ReplaceItemAtPosition(2, :With = "TWO")
	? Content() #--> [ "one", "TWO", "three" ]

	ReplaceAllItems( :With = "***")
	? Content() #--> [ "***", "***", "***" ]
}

/*--------------

StzListQ([ "a", 1, "b", 2, "c", 3 ]) {
	ReplaceW( :Where = '{ isNumber(@item) }', :By = "*" )
	? Content() #--> [ "q", "*", "b", "*", "c" ]
}

/*--------------

o1 = new stzList([ "a", 1, "b", 2, "c", 3 ])
o1.RemoveW('Not isNumber(@item)')
? o1.Content() #--> [ 1, 2, 3 ]

/*--------------

obj1 = new Person { name = "salem" age = 34 }
obj2 = new Person { name = "kai" age = 24 }

o1 = new stzList([ "a", 1, 3, "b", ["A1", "A2"], obj1, "c", 3, ["B1", "B2"], obj2 ])

? o1.OnlyStrings()	#--> [ "a", "b", "c" ]
? o1.OnlyNumbers()	#--> [ 1, 3, 3 ]
? o1.OnlyLists()	#--> [ "A1", "A2", "B1", "B2" ]
? o1.OnlyObjects()	# TODO: Not yet implemented!

class Person name age

/*--------------

StzListQ([ "a", "b", [], "c", [] ]) {
	? OnlyWhere('{ isString(@item) }') #--> [ "a", "b", "c" ]
}

/*--------------

StzListQ([ "a", "b", [], "c", [] ]) {
	RemoveW('{
		isList(@item) and Q(@item).IsEmpty()
	}')

	? Content() #--> [ "a", "b", "c" ]
}

/*--------------

StzListQ([ 1, "a", "b", 2, 3, "c", 4, [ "..." ], "d" ]) {

	RemoveW('{
		isNumber(@item) or
		isString(@item)
	}')

	? Content() #--> [ "..." ]
}

/*-------------

o1 = new stzList(["_", "A", "*", "_", "B", "*", "_", "C", "*" ])
? o1.FindW( :Where = ' @NextItem = "*" ' )	#--> [ 2, 5, 8 ]
? o1.ItemsW( :Where = ' @NextItem = "*" ' )	#--> [ "A", "B", "C" ]

/*-------------

person1 = new person { name = "obj1" }
person2 = new person { name = "obj2" }

o1 = new stzList([
	"_", 3, "_" , person1, 6, "*",
	[ "L1", "L1" ], 12, person2,
	[ "L2", "L2" ], 25, "*"
])

? o1.FindWhere('{
	( NOT isObject(@item) ) and
	( isString(@NextItem) and @NextItem = "*" )
}') #--> [ 5, 11]

? o1.FindWhere('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] = DoubleOf(@item)	
}') #--> Gives [ 2, 5 ]

? o1.FindWhere('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] != DoubleOf(@item)	
}') #--> Gives [ 8 ]

class Person name

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
? o1.FindAllW('{ Q(@item).IsUppercase() }')
  #--> Gives [3, 4, 6]

? o1.ItemsW('{ Q(@item).IsUppercase() }')
  #--> Gives ["C#", "RING", "RUBY"]

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
o1.InsertAfterW( :Where = '{ Q(@item).IsLowercase() }' , :With = "*")
? o1.Content() #--> ["c", "*", "c++", "*", "C#", "RING", "Python", "RUBY"]

/*-------------

o1 = new stzList( [ "c", "c++", "C#", "RING", "Python", "RUBY" ] )
? o1.ItemsW('{ Q(@item).IsLowercased() }') #--> [ "c", "c++" ]

? o1.FirstItemW('{ Q(@item).IsLowercased() }') # --< "c"
? o1.NthItemW(2, '{ Q(@item).IsLowercased() }') #--> "c++"
? o1.LastItemW('{ Q(@item).IsLowercased() }') #--> "c++"

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "python", "ruby"])
? o1.FindW("   ") #--> [1, 2, 3, 4, 5, 6]

? o1.CountW('{ isLower(@item) }') #--> 3
o1.NumberOfOccurrenceW('{  }') #--> 6

/*==============

o1 = new stzSplitter( 1:5 )

? @@(o1.SplitToPartsOfNItems(2))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@(o1.SplitBeforePositions( [ 3, 5 ] ))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@(o1.SplitAfterPositions( [ 3, 5 ] ))
#--> [ [ 1, 3 ], [ 4, 5 ], [ 5, 5 ] ]

/*-------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

? @@( o1.SplitToPartsOfNItems(2) )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "e" ] ]

? @@( o1.SplitAfterPositions([ 3, 5 ]) )
#--> [ [ "a", "b", "c" ], [ "d", "e" ], [ "e" ] ]

? @@( o1.SplitBeforePositions([ 3, 5 ]) )
# Returns [ ["a","b"], ["c", "d"], ["e"] ]

/*------------- TEST IT

o1 = new stzString("abcde")

? @@( o1.SplitToPartsOfNChars(2) )
#--> [ "ab", "cd", "e" ]
? @@( o1.SplitToPartsOfNCharsXT(2, :ExcludeRemaining = TRUE) )
#--> [ "ab", "cd" ]

? @@( o1.SplitAfterPositions([ 3, 5 ]) )
#--> [ "abc", "de", "e" ]

? @@( o1.SplitBeforePositions([ 3, 5 ]) )
# Returns [ "ab", "cd", "e" ]

/*================

o1 = new stzList([ "*", "a", "*", "b", "C", "D", "*", "e" ])
? o1.Find("*") 		#--> [1, 3, 7]
? o1.FindItem("*")	#--> [1, 3, 7]
? o1.Find(:Item = "*")	#--> [1, 3, 7]

/*================

o1 = new stzList([ "a", "b", "a", "a", "c", "d", "a" ])
o1.RemoveOccurrences([ 4, 1, 3 ], "a")
? o1.Content()
# Returns [ "b", "a", "c", "d" ]

/*---------------

o1 = new stzList([ "a", "b", "C", "D", "e" ])
? o1.FindAllW('{ Q(@item).IsLowercase() }')
# Returns [ 1, 2, 5 ]

/*---------------

o1 = new stzList([ "a", "b", "C", "D", "e" ])

o1.InsertAfterW( '{ StzStringQ(@item).IsLowercase() }', "*" )
? o1.Content()

# Returns [ "a", "*", "b", "*", "C", "D", "e" ]

/*----------------

o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeW( '{ StzStringQ(@item).IsLowercase() }', "*" )
? o1.Content()

# Returns [ "*", "a", "*", "b", "C", "D", "*", "e" ]

/*----------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertAfterManyPositions([ 2, 4, 5 ], "*")
? o1.Content()
# Returns [ "a", "b", "*", "c", "d", "*", "e" ]

/*---------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertBeforeManyPositions([ 2, 4, 5 ], "*")
? o1.Content()
# Returns [ "a", "*", "b",  "c", "*", "d", "*", "e" ]

/*---------------

o1 = new stzList([ 5, 4, 3, 7 ])
o1.SortInAscending()
? o1.Content()
# Returns [ 3, 4, 5, 7 ]

/*---------------

o1 = new stzList([ 5, 4, "tunis", 3, 7, "cairo" ])
o1.SortInAscending()
? o1.Content()
# Returns [ 3, 4, 5, 7, "cairo", "tunis" ]

/*---------------

o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", 3, 7, [ :them, :others ], "cairo"  ])
o1.SortInAscending()
? ListToCode( o1.Content() )
# Returns [ 3, 4, 5, 7, "cairo", "tunis", [ "me", "you" ], [ "them", "others" ] ]

/*--------------

obj1 =  new person { name = "obj1" }
obj2 = new person { name = "obj2" }

o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", new stzObject(:obj2), 3, 7, [ :them, :others ], "cairo", obj1  ])
o1.SortInAscending()
? o1.Content()
# Returns [ 3, 4, 5, 7, "cairo", "tunis", [ :me, :you ], [ :them, :others ], obj2, obj1 ]

class Person name
/*--------------

obj1 = new person { name = "obj1" }
obj2 = new person { name = "obj2" }

o1 = new stzList([ 3, 6, 9, 12, "a", "b", [ "List1" ], [ "List0" ] ])
? o1.IsSortedInAscending()

class Person name

/*------------

person1 = new person { name = "obj1" }
person2 = new person { name = "obj2" }

o1 = new stzList([ "_", 3, "_" , person1, "*", 6, [ "L1", "L1" ], 12, person2, [ "L2", "L2" ], 24, "*" ])
o1.SortInAscending()
? o1.Content()

class Person name

/*---------------

o1 = new stzList(1:5)
o1.ExcludeNumbersGreaterThan(3)
? o1.Content()

/*----------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])
o1 - []
? o1.Content()

/*---------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])
o1 - [ "b", "c" ]
? o1.Content()

/*--------------- TODO: Works only for strings --> Move it to stzListOfStrings

o1 = new stzList(["file1", "file2", "file3" ])
o1 * ".ring"	#--> [ "file1.ring", "file2.ring", "file3.ring" ]
//o1 + ".ring"	#--> [ "file1", "file2", "file3", ".ring" ]
? o1.Content()

/*---------------

o1 = new stzList([ "medianet", "st2i", "webgenetix", "equinoxes", "groupe-lsi",
		   "prestige-concept", "sonibank", "keyrus", "whitecape",
		   "lyria-systems", "noon-consulting", "ifes", "mourakiboun",
		   "isie", "hnec", "haica", "kalidia", "triciti", "avionav",
		   "maxeam", "nextav", "ring" ])

? o1.ContainsMany([ "medianet", "st2i" ]) #--> TRUE
? o1.ContainsEach([ "ifes", "haica"]) 	  #--> TRUE
? o1.ContainsBoth("ifes", "haica")	  #--> TRUE

/*-----------------

//? ListReverse([ 1, 2, 3 ])

o1 = new stzList([ "tunis", 1:3, 1:3, "gafsa", "tunis", "tunis", 1:3, "gabes", "tunis", "regueb", "regueb" ])
//o1.Reverse()
//? o1.Content()
//? o1.NumberOfDuplicates("tunis")
? o1.DuplicatedItems()

? o1.DuplicatedItems() # TODO: CaseSensitive! in stzListOfStrings + Objects are not covered!
? o1.DuplicatesOfItem(1:3)

//? o1.DuplicatedItemsXT()
//? o1.RemoveDuplicatesQ().Content()
//? o1.DuplicatesRemoved()

/*---------------------

o1 = new stzList([ "poetry", "music", "theater", "stranger" ])
o1 - [ "poetry", "music" ]
? o1.Content() #--> [ "theater", "stranger" ]
                                              
/*---------------------

o1 = new stzList([ "A", "B", "C" ])
? o1.ExtendToPositionNWithQ(5, "0").Content() #--> [ "A", "B", "C", "0", "0" ]

/*--------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//obj = new stzstring("x")

//o1 = new stzList( [ "A", "B", [ 1, "v", 2 ], "X" ] )
o1 = new stzList([ "A", "B", "C" ])
? o1.ContainsNo("v")		# ERROR: method undefined but it exists!!!
? o1.ContainsNoObjects()	# idem
//? o1.Flattened() # can also be written: o1.FlattenQ().Content()

/*---------------------

o1 = new stzList([ "A", 1:3, obj, "B", [ "C", 4:5, [ "V", 6:8, ["T", 9:12 ,"K"] ] ], "D" ])
? o1.ListsAtAnyLevelQ().Content()


/*---------------------
*/
//? StzListQ([ 1:3, 4:7, 8:10 ]).MergeQ().Content()
# NOTE: lists are merged only when they are lists of lists (Why? Think of it - TODO)

/*----------------------

o1 = new stzList([ :Water, :Milk, :Cofee, :Tea, :Sugar, " ",:Honey ])
? o1.WalkUntil('@Item = :Milk') #--> [ 1, 2 ]
? o1.WalkUntil('@Item = " "')	#--> [ 1, 2, 3, 4, 5, 6 ]

/*---------------------- TODO: refactored: reveiw it after completing stzWalker

StzListQ( "A":"J" ) {
	AddWalker( :Named = :Walker1, :StartingAt = 1, :EndingAt = 10, :NStep = 1 )
	? WalkedItems( :By = :Walker1 )
	? WalkedPositions( :By = :Walker1 )
	? WalkedLastItem( :By = :Walker1 )
	? WalkedLastPosition( :By = :Walker1 )
	? NumberOfWalkedItems( :By = :Walker1 )

	? Yield( 'type(@item)', :WhileWalkingListBy = :Walker1 )
}


/*----------------------

o1 = new Person
//myList = "A":"J"
myList = [ "A", 1, "BB", 2, [ "W", 12, "V" ], "C", 10, o1, "D", o1]

#myList = [ "Tunis", "Cairo", "Niamey", "Paris", "Rome", "Mosko" ]
o1 = new stzList(myList)

// Working with walkers...

o1 {
	AddWalker( Named(:Walker1), StartingAt(1), EndingAt(10), NStepsATime(1) )

	AddWalker( :Walker2, 6, 10,   [ :NStepsATime , 3 ] )

	AddWalker( Named(:Walker3), StartingAt(1), EndingAt(10), TakingNEqualMoves(3) )

	? Walkers()

	? Yield( '{ StzLen(item) }', WhileWalking(:Walker1) )
	? Yield( '{ ring_type(item) }', WhileWalking(:Walker1) )
	? Yield( '{ [ UPPER(Item), StringContains(Item,"o") ] }', WhileWalking(:Walker1) )

	? Yield( '{ [ UPPER(Item), StringNumberOfOccurrence(Item,"o") ] }', WhileWalking(:Walker1) )

	//? Content()
}

class Person

/*----------------------

// Declaring a list of things
o1 = new stzList([ :Water, :Milk, :Cofee, :Tea, :Sugar, :Honey ])

// Removing one thing
o1 - :Honey

? o1.IsStrictlyEqualTo([ :water, :coca, :milk, :spice, :cofee, :tea, :honey ])

#====================== DISTRIBUTING ITEMS OVER THE ITEMS OF AN OTHER LIST

/*
Softanza can distribute the items of a list over the items of an other,
called metaphorically 'Beneficiary Items'  as they benfit from that
distribution.
		
The distribution is defined by the share of each item.
		
The share of each item determines how many items should be given to
the each beneficiary item.
		
Let's see:	
*/
/*
o1 = new stzList([ "water", "coca", "milk", "spice", "cofee", "tea", "honey" ] )
? @@( o1.DistributeOver([ "arem", "mohsen", "hamma" ]) ) + NL
#--> :
# [
#	[ "arem",   [ "water", "coca", "milk" ] ],
#	[ "mohsen", [ "spice", "cofee" ],
#	[ "hamma",  [ "tea", "honey" ]
# ]

# Same can be made using the extended form of the function, that allows
# us to specify how the items are explicitly shared:

? @@( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 3, 2, 2 ] ) ) + NL


# And so you can change the share at your will:
? @@( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 1, 2, 4 ] ) ) + NL
#--> 
# [
#	[ "arem",   [ "water" ] ],
#	[ "mohsen", [ "coca", "milk" ] ],
#	[ "hamma",  [ "spice", "cofee", "tea", "honey" ] ]
# ]

# But if you try to share more items then it exists in the list (1 + 2 + 6 > 7!):
? @@( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 1, 2, 6 ] ) )
# Softanza won't let you do so and tells you why:

#   	What : Can't distribute the items of the main list over the items of
#	       the provided list!
#   	Why  : Sum of items to be distributed (in anShareOfEachItem) must be
#	       equal to number of items of the main list.
#   	Todo : Provide a share list where the sum of its items is equal to
#	       the number of items of the list.

/*-----------------

# The distribution of the items of a list can be made directly using
# the "/" operator on the list object:

o1 = new stzList(' "♥1" : "♥6" ')
? @@( o1 / 8 )
#--> [ [ "♥1" ], [ "♥2" ], [ "♥3" ], [ "♥4" ], [ "♥5" ], [ "♥6" ], [ ], [ ] ]

# NOTE
#--> The beneficiary items can be of any type. In practice, they are
# strings and hence the returned result is a hashlist.

/*-----------------

o1 = new stzList(1:12)
? @@( o1.DistributeOver([ "Mansoor", "Teeba", "Haneen", "Hussein", "Sherihen" ]) )
#-->
# [
#	[ "Mansoor",  [ 1, 2, 3 ] ],
#	[ "Teeba",    [ 4, 5, 6 ] ],
#	[ "Haneen",   [ 7, 8    ] ],
#	[ "Hussein",  [ 9, 10   ] ],
#	[ "Sherihen", [ 11, 12  ] ]
# ]

/*-----------------

o1 = new stzList(' "♥1" : "♥9" ')
? @@( o1 / [ "Mansoor", "Teeba", "Haneen" ] )
#-->
# [
#	[ "Mansoor", 	[ "♥1", "♥2", "♥3" ] ],
#	[ "Teeba", 	[ "♥4", "♥5", "♥6" ] ],
#	[ "Haneen", 	[ "♥7", "♥8", "♥9" ] ]
# ]

/*---------------------

o1 = new stzString("Python")
o2 = new stzString("Ring")

oList = new stzList([ o1, o2 ])
? oList.ApplyCode("oEachObject.Content()", :ToObjects)

/*---------------------

? AreEqual([ 1:3, 1:3, 1:3, 1:3 ])

# ? AreEqual([ ["A", 1:5], 1:3, 1:3, 1:3 ]) # TODO: can't process deep lists
? AreEqual([ new person, new person, new person ])
class person

/*---------------------

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])
o1.RemoveAll("a")
? o1.Content()

/*---------------------

# All these return TRUE

o1 = new stzList([ "a", "b", "c", "A", "B", "C" ])
? o1.AllItemsAre("isString(@item)")
? o1.AllItemsAre("Q(@item).IsAString()")

# You can also say:

? o1.ContainsOnly("isString(@item)")
? o1.ContainsOnly("Q(@item).IsAString()")

# Or also:

? o1.AllItemsVerify("isString(@item)")
? o1.AllItemsVerify("Q(@item).IsAString()")

# Or also:

? o1.AllItemsVerifyThisCondition("isString(@item)")
? o1.AllItemsVerifyThisCondition("Q(@item).IsAString()")

/*---------------------

o1 = new stzList([ "A", "B", "C" ])
? o1.AllItemsAre("isString(@item) and StringIsUppercase(@item)")

*---------------------

# All items are lists with 3 items

o1 = new stzList([ 1:3, 1:3, 1:3 ])
? o1.AllItemsAre('isList(@item) and len(@item) = 3')

/*---------------------

# All items are lLists having same number of items

o1 = new stzList([ 1:3, 1:3, 1:3 ])
? o1.AllItemsAre('isList(@item) and len(@item) = len(o1[1])')

/*-------------------- ///////<<<<<<<//////////////////////////////////////////////

# Sublists_Have_SameNumberOfItems()

o1 = new stzList([ "a", 1:3, "b", 1:3, "c", 1:3 ])
? o1.TheseItems('{ isList(@item) }', :Are = '{ len(@item) = len(@items[1]) }')

+ RemoveManyBounds + --> In lists

/*---------------------

# In the following, we check if the hole list [ "a", "b", "c" ] exists in
# the list [ "a", "b", "c", "x", "z" ].

# You may answer TRUE but wait, it's FALSE
? StzListQ([ "a", "b", "c" ]).ExistsIn([ "a", "b", "c", "x", "z" ]) #--> FALSE

# In fact, there are no occurrences of [ "a", "b", "c" ] in the list
? StzListQ([ "a", "b", "c", "x", "z" ]).FindAll([ "a", "b", "c" ]) #--> []

# Now if you say:

? StzListQ([ "a", "b", "c" ]).ExistsIn([ "a", "b", "c", "x", "z", [ "a", "b", "c" ] ]) #--> TRUE

# then you get TRUE, because we have an an item of type list at the end of the second
# list which is equal to [ "a", "b", "c" ]

/*---------------------

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])
? o1.IsMadeOf([ "a", "b", "c" ])
? o1.IsMadeOfSome([ "a", "b", "c", "x", "z" ])

/*---------------------

o1 = new stzList([ :monday, :monday, :monday ])
? o1.IsMadeOfOneOfThese([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])

/*---------------------

o1 = stzList([ :Language = "arabic", :Country = "tn", :Script = "arabic" ])
? o1.IsLocalenList()

o1 = new stzList([ :Language = "ar", :Country = "TN", :script = "arabic" ])
? o1.IsLocaleList()

? StringIsScriptName("latin")

/*---------------------

o1 = new stzList([ :english = "house", :french = "maison", :arabic = "منزل" ])
? o1.IsMultilingualString()

o1 = new stzList([ :en = "house", :fr = "maison", :ar = "منزل" ])
? o1.IsMultilingualString()

/*---------------------

o1 = new stzList([ "green", "red", "blue" ])

? o1.ContainsOneOfThese(["red", "t", "cv"])

// Checking containment (all these return TRUE)
? o1.IsContainedIn([ "green", "red", "blue", "magenta", "gray" ])

? o1.Contains([ "red", "blue" ])

? o1.ContainsOneOfThese([ "yelloW", "GREEN", "magenta" ])
? o1.ContainsNoOneOfThese([ "yellow", "magenta", "gray" ]) + NL

// Checking common and different items
? o1.CommonItemsWith([ "yellow", "red", "blue", "gray" ]) 
see NL
? o1.DifferentItemsWith([ "yellow", "red", "blue", "gray" ])
see NL
? o1.DifferenceWith([ "yellow", "red", "blue", "gray" ])
                                                        
/*--------------------------

o1 = new stzList([ "green", "red" ])
? o1.IsIncludedIn([ "green", "red", "blue" ]) #--> TRUE

/*--------------------------

? o1.DifferenceWith([ "b","x", "a", "f"])

? o1.DifferentItemsWith([ "b","x", "a", "f"])
? o1.CommonItemsWith([ "b","x", "a", "f"])
? o1.ContainsSameItemsAs([ "a", "b", "c", "f" ])

/*--------------------------

=> [ :language] or [:country] or [:script] or
//			 [:language, :country] or [ :alanguage....
// To Solve o1.IsLanuageIdentification()
// ---> ListTemplate/Form

/*--------------------------

o1 = new stzList([ "a", "b", "b", "b", "c" ])
? o1 - "b"
? o1 - [ "b", "c", "b" ]

/*--------------------------

o1.Minus([ "b", "b" ])
? o1.Content()

/*--------------------------

o1 = new stzList([ "a", "b", "b", "b", "c" ])
 o1.RemoveMany([2,3,4])
? o1.Content()

/*--------------------------

? o1 - [ "b", "b" ]
//? o1.DifferenceWith([ "a", "c" ])

/*--------------------------

aList = [ :name = "mansour", :job = "programmer", :name = "xe" ]
o1 = new stzList(aList)

? o1.IsHashList()

/*--------------------------

o1 = new stzList([ "a", "c", 12 ])
? o1.HasSameContentAs([ "a", 12, "c" ])

/*--------------------------

o1 = new stzList([ :ring, 5, :php, :ruby, :python, :ring, 5 ])
? o1.NumberOfOccurrence(5)
? o1.NumberOfOccurrence(:ring)

/*--------------------------

o1 = new stzList([ "a", "c" ])
? o1.ItemsHaveSameOrderAs([ "a", "c", "f" ])

/*--------------------------

o1 = new stzList([ 1, 2, 3, 6 ])
? o1.IsReverseOf([ 6, 3, 2, 1 ])

/*--------------------------

? o1.IsEqualTo([ 3, 1, 2 ])
? o1.IsStrictlyEqualTo([ 3, 1, 2 ])
? o1.IsStrictlyEqualTo([ 1, 2, 3 ])

/*--------------------------

o1 = new stzList([ 2, 1, 3 ])
? o1.ItemsHaveSameOrderAs([ 2, 1, 3, 6 ])

/*--------------------------

aList = [ 12,
	[ "A", [ 1, 2, 3] ], # 1st sublist
	[ "B", [ 3, 5, 3 ] ], # 2nd sublist
	[ "C", [ 1, 4, [1,2,3], 4] ] # 3d sublist
]

# aList = [ 2, 7, 10 ]

o1 = new stzList(aList)
? o1.WalkUntilItem(7)
? aList

? StzListQ(aList).ContainsOneOrMoreLists()

/*--------------------------

aList = [ 2, 7, 10 ]
? StzListQ(aList).Contains(7)
? StzListQ(aList).Content()
? StzListQ(aList).WalkUntilItem(7)

/*--------------------------

o1 = new stzList(aList)
? o1.Sublists()
? o1.ItemsThatAre_Lists_AtAnyLevel()
# Getting the 3 sublists
#? len(o1.Sublists())
# Checking if they have the same number of items
#? o1.Sublists_Have_SameNumberOfItems()

# Getting the 
#? len(o1.ListsAtAnyLevel())
#? o1.SublistsAtAnyLevel_Have_SameNumberOfItems()

/*--------------------------

o1 = new stzList(  [	:name, :age, 	:job		])
? o1.AssociateWith([ 	"Ali", 	24, 	"Programmer" 	])
? o1.Content()
#--> [ :name = "Ali", :age = 24, :job = "Programmer"	]

/*--------------------------

o1 = new stzList([ 1, 1, 1 ])
? o1.AllItemsAreEqualTo(1)

/*--------------------------

o1 = new stzList("a":"t")
? o1.Contains("x")

/*============ TODO: Levels functions need a reflection, see code.
# To be replaced with DeepFind

o1 = new stzList([
	1, [ "A", "B"], 2,
	[ 3, 4, [ "B", "C" ] ],
	[ 5, [ 6, [ "D", "E" ], 7 ], 8 ]
])

? o1.NumberOfLevels() #--> 4

? @@( o1.ItemsThatAreLists_AtAnyLevel_XT() )
#-->
#	[
#		[ :Path = [ 2 ], :Level = 1, :Position = 2 ],
#		[ :Path = [ 4 ], :Level = 1, :Position = 4 ],
#		[ :Path = [ 4, 3 ], :Level = 2, :Position = 3 ],
#		[ :Path = [ 3 ], :Level = 1, :Position = 3 ],
#		[ :Path = [ 3, 2 ], :Level = 2, :Position = 2 ],
#		[ :Path = [ 3, 2, 2 ], :Level = 3, :Position = 2 ]
#	]

? o1.ItemsThatAreLists_AtAnyLevel() # !!!--> ERROR TODO
