load "stzlib.ring"

/*----------------

o1 = new stzList([ [ "ONE", "TWO" ], [ "THREE", "FOUR" ], [ "FIVE", "SIX" ] ])
? o1.IsListOfLists()		#--> TRUE
? o1.IsListOfPairs()		#--> TRUE
? o1.IsListOfPairsOfStrings()	#--> TRUE

/*----------------

o1 = new stzList([ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ])
? o1.IsListOfLists()		#--> TRUE
? o1.IsListOfPairs()		#--> TRUE
? o1.IsListOfPairsOfNumbers()	#--> TRUE

/*----------------

o1 = Q("AB♥♥C♥♥D♥♥E")
? o1.SplitToPartsOfNCharsXT(2, :ExcludeRemaining = TRUE)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

? o1.SplitToPartsOfNCharsXT(2, :ExcludeRemaining = FALSE)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥", "E" ]

? o1.SplitToPartsOfNChars(2)
#--> [ "AB", "♥♥", "C♥", "♥D", "♥♥" ]

/*----------------

o1 = new stzString("ABCDE")
? @@( o1.SubStrings() )
#--> [ "A", "B", "C", "D", "E", "AB", "CD", "ABC", "ABCD", "ABCDE" ]

/*================ WORKING WITH BOUNDS

o1 = new stzString("<<word>> and {{word}}")
? o1.BoundsOf( "word", :UpToNChars = 2 )
#--> [ [ "<<", ">>" ], [ "{{", "}}" ] ]

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

/*----------------

str =
"one
two
three"

? @@(str)
/*-->
"one
two
three"
*/

/*----------------

? @@( Q([ "abc", 120, "cdef", 14, "opjn", 988 ]).ToString() )
/*-->
abc
120
cdef
14
opjn
988
*/

/*----------------

? QQ(["abc","cdef","opjn"]).ToString() // QQ() generates a stzListOfStrings object
/*-->
abc
cdef
opjn
*/

/*----------------
*/
o1 = new stzString("Av♥♥c♥♥")
//? @@( o1.FindAll("♥♥") ) #--> [ 3, 6, 9 ]
//? @@( o1.FindSubStringW('{ @SubString = "♥♥" }') ) #--> [ 3, 6, 9 ]

? @@( o1.FindSubStringW('{ len(@SubString) = 2 }') )

/*
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

/*----------------

# What are the unique letters in this sentence?

# To solve it, you can say:
? @@( Q("sun is hot but fun").RemoveSpacesQ().UniqueChars() )
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# And what if the words are provided in a list of string?
? @@( Q([ "sun", "is", "hot", "but", "fun" ]).
	YieldQR('{ Q(@String).Chars() }', :stzListOfLists).
	MergeQ().UniqueItems()
)
#--> [ "s", "u", "n", "i", "h", "o", "t", "b", "f" ]

# The solution above uses "strings" and "chars" concepts which both
# belong to the stzString domain. But if you want to solve it in
# a higher semantic level, you can rely on "text" and "letter" concepts
# from the stzText domain:

? TQ("sun is hot but fun").UniqueLetters()
# Which turns out to be more natural, isn't it?

/*----------------

? len("طيبة")
? StzStringQ("طيبة").NumberOfChars()

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
//? o1.Section("A", "T")
/*
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
? o1.ItemOccurrenceByPosition(5, "ring") #--> 3

? o1.ItemPositionByOccurrence(3, "ring") #--> 5
# Alternativcely to this, you can say:
? o1.FindNthOccurrence(3, "ring")

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

# In Softanza, you can divide the content of a string to 3 parts
cNumbers = "ABCDEFG"
? Q(cNumbers) / 3 #--> [ "ABC", "DEF", "G" ]

# Those 3 parts can be "named" parts:

? Q(cNumbers) / [ "Hussein", "Haneen", "Teeba" ]
#--> [ :Hussein = "ABC", :Haneen = "DEF", :Teeba = "G" ]

# And you can configure the share of each part at your will:
? Q(cNumbers) / [ :Hussein = 3, :Haneen = 1, :Teeba = 3 ]
#--> [ :Hussein = "ABC", :Haneen = "D", :Teeba = "EFG" ]
