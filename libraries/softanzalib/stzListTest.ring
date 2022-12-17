load "stzlib.ring"


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

? @@S( o1.FindSmallest() ) #--> [2, 3]
? o1.NumberOfOccurrencesOfSmallestItem() #--> 2
# or more simply
? o1.NumberOfSmallest() #--> 2

? @@S( o1.FindLargest() ) #--> [ 4 ]

? o1.NthSmallest(3) #--> 8
? @@S( o1.FindNthSmallest(3) ) #--> [ 5, 6 ]

/*=================

o1 = new stzList([ ".", ".", "3", "4", ".", ".", "7", "8", "9", ".", "." ])

//? o1.YieldXT( '@item', :FromPosition = 4, :To = -3)
#--> [ ".", ".", "7", "8", "9" ]

? o1.YieldXT( '@char', :StartingAt = 3, :Until = ' @item = "." ' )
#--> [ "3", "4" ]

? o1.YieldXT( '@char', :StartingAt = 3, :UntilXT = ' @item = "." ' )
#--> [ "3", "4", "." ]


/*=================

? @@S( Q([ "AB", 12, ["A", "B"] ]).TypesXT() )
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

? @@S(o1.Content())
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
? @@S( o1.Content() ) + NL
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
? @@S( o1.Content() )
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
? @@S( o1.Content() )
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

? @@S( List( :From = "A", :To = "E" ) )
#--> [ "A", "B", "C", "D", "E" ]

? @@S( List( :From = "ا", :To = "ث" ) )
o#--> [ "ا", "ب", "ة", "ت", "ث" ]

? @@S( ListXT( ' "A" : "E" ' ) )
#--> [ "A", "B", "C", "D", "E" ]

? @@S( ListXT( ' "ا" : "ث" ' ) )
o#--> [ "ا", "ب", "ة", "ت", "ث" ]

/*-----------------

# As we all know, Ring provides us with this elegant syntax:

aList = "A" : "D"
? @@S( aList )	#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# And if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? @@S( aList )	# --> "ا"

# Fortunately, Softanza solves this by the List() function:

? @@S( List( :From = "ا", :To = "ج" ) )
#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? @@S( List("A", "D")	) #--> [ "A", "B", "C", "D" ]

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

? @@S( o1.Classify() )	# Same as Categorize()
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

? StzListQ([]).IsListOfStrings() # --> FALSE
? StzListQ([]).IsListOfNumbers() # --> FALSE

/*-----------------

? StzListQ([ [ "name", "Mansour"], [ "age", 45] ]).IsHashList()	# --> TRUE
? StzListQ([ :name ="Mansour", :age = 45 ]).IsHashList()	# --> TRUE

# But

? StzListQ([ "name" = "Mansour", "age" = 45 ]).IsHashList()	# --> FALSE

/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {
	? Numbers() # --> [ 1, 2, 3, 4, 5 ]
	# You can also say ? OnlyNumbers()

	? NonNumbers() # [ "A", "B", "C", "D" ]
	# You can also say OnlyNonNumbers()

	? Content() # --> [ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]
	# Note that the list is not altered by Numbers() and NonNumbers() functions
}

/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	RemoveNumbers() # --> You can also say RemoveOnlyNumbers()
	? Content() # --> [ "A", "B", "C", "D" ]

}


/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? NonNumbers() # --> [ "A", "B", "C", "D" ]
	# You can also say ? OnlyNonNumbers()

	RemoveNonNumbers()
	# You can also say RemoveOnlyNonNumbers() or RemoveAllExceptNumbers()

	? Content() # --> [ 1, 2, 3, 4, 5 ]
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
? o1.Content() # -->  [ 1, 2, 3, 4, 5 ]

/*================

StzListQ([ "by", "except"]) { 
	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ]) # --> TRUE

	# Same as
	? IsMadeOfSome([ :by, :except, :stopwords ]) # --> TRUE
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

? @@S( [ "q", "r", [ 2, 1 ] ] ) # S for Simplified. Same as ComputerFormSimplified()
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

? StzListQ([ NULL, NULL, NULL]).IsListOfStrings() # --> TRUE

/*==================

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
o1 - [ "bo", "wo" ]
? o1.Content()
#--> [ "fa", "wy" ]

/*==================

? IsListOfStrings([ "baba", "ommi", "jeddy" ])		# --> TRUE
? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()	# --> TRUE

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}

# -->
#	 [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#	  --^--------------^---------^-------------------^------------

# WARINING: works only for list of chars
# TODO : Generalize it for list of strings and other types

/*------------------ TODO: Add this function

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindXT("A")
}

# --> Returns a string like this:

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
	? Content() # --> [ "A" , "B", "C", "A", "D", "*" ]
}

/*------------------

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of = "A", :By = "*", :StartingAt = 5)
	? Content() # --> [ "*" , "B", "C", "A", "D", "A" ]
}

/*------------------

StzListQ([ -1 , 2, 3, 4 ]) {
	? NumberOfItemsW("Q(@item).IsBetween(1, 4)") # --> 3
}

/*------------------

o1 = new stzList([ "1", "2", "*", "4", "5" ])
o1.ReplaceItemAtPosition(3, :By = "3")
? @@S( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "2", "*", "4", "5" ])
o1.ReplaceItemAtPosition(3, :By@ = '{ 8 - 5 }' )
? @@S( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrence( 2, :Of = "_", :With = "5", :StartingAt = 3)
? @@S( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrence( 2, :Of = "_", :With@ = '{ 8 - 3 }', :StartingAt = 3)
? @@S( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
	? @@S( Content() ) # --> [ "A" , "B", "A", "C", "*", "D", "*" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? @@S( NextNthOccurrencesReplaced([2, 3], :Of = "A", :With = "*",  :StartingAt = 3) )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrences([1, 2, 3], :of = "A", :with = "*",  :StartingAt = 5)
	? @@S( Content() ) # --> [ "*" , "B", "*", "C", "*", "D", "A" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrences([3, 1], "A", :With = [ "#3", "#1" ], :StartingAt = 5)
	? @@S( Content() ) # --> [ [ "#3", "#1" ], "B", "A", "C", [ "#3", "#1" ], "D", "A" ]
}

/*------------------

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content() # --> [ "A", "-", "-", "A", "-", "-", "A" ]
}

/*------------------

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6)
	? Content() # --> [ "A", "-", "-", "-", "A", "-", "A" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 3)
	? Content() #--> [ "A" , "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 3)
	# --> [ "A" , "B", "A", "C", "D" ]
}

/*-----------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindNextOccurrences(:Of = "A", :StartingAt = 3) # --> [ 3, 5, 7 ]

	? FindPreviousOccurrences(:Of = "A", :StartingAt = 5) # --> [ 1, 3, 5 ]

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

	? Content() # --> [ "#", "B", "C", "#", "D", "B", "#" ]

}

# In case you need to make many replacements at once, then you are covered:
# just provide the list of items to replace and the value of replacement...

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceMany([ "A", "B" ], :With = "#")
	? Content() # --> [ "#", "#", "C", "#", "D", "#", "#" ]

}

# You can even replace exitant items by many other new values, one by one,
# like this (useful in many scenarios of text interpolation and processing):

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceManyByMany([ "A", "B" ], :With = [ "#1", "#2" ])
	? Content() # --> [ "#1", "#2", "C", "#1", "D", "#2", "#1" ]

}

# And if you want to replace the occurrences of a given item by alternating
# between several other items you provide, then this is possible:

StzListQ([ "A", "A", "A" , "A", "A" ]) {
	
	ReplaceItemByAlternance("A", :With = [ "#1", "#2" ])

	? Content() # --> [ "#1", "#2", "#1", "#2", "#1" ]

}

/*---------------------

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content() # --> [ "A", "B", "C", "A", "D", "B", "#" ]

}

/*====================

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending() # --> [ 2, 5, 7, 9 ]

/*=====================

o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])
? o1.DuplicatesRemoved() # --> [ "teeba", "hussein", "haneen" ])
? o1.NumberOfItems()     # --> 4

/*=====================

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	# --> TRUE
# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		# --> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	# --> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	# --> TRUE

/*=====================

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a" ] 
? @@S( o1.Content() ) # --> [ "c" ]

/*-----------------------

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a", "c" , "q" ]
? @@S( o1.Content() ) # --> [ ]

/*=====================

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])
? o1.FindMany([ "a", "e" ])	# --> [ 1, 3, 4, 7 ]
? o1.FindManyXT([ "a", "e" ])	# --> [ "a" = [ 1, 4 ], "e" = [ 3, 7 ] ]

/*-----------------------

o1 = new stzList([ "a", "E", "a", "c", "V", "E" ])
? o1.FindMany([ "a", "c" ]) # --> [1, 3, 5]

o1 - [ "a", "c" ] # Same as: o1.RemoveItemsAtPositions([ 1, 3, 5 ])

? o1.Content() # --> [ "E", "V", "E" ]

/*=====================

o1 = new stzList([ "a", "b", "c" ])

? o1.IsEqualTo([ "c", "b", "a" ])		# --> TRUE

? o1.IsStrictlyEqualTo([ "c", "b", "a" ])	# --> FALSE
# Because
? o1.HasSameTypeAs([ "c", "b", "a" ])		# --> TRUE
? o1.HasSameContentAs([ "c", "b", "a" ])	# --> TRUE
? o1.HasSameSortingOrderAs([ "c", "b", "a" ])	# --> FALSE

/*---------------------

o1 = new stzList([ "a", "b", "c" ])
? o1.IsStrictlyEqualTo([ "a", "b" ])	# --> FALSE
# Because
? o1.HasSameTypeAs([ "a", "b" ])	# --> TRUE
? o1.IsEqualTo([ "a", "b" ])		# --> FALSE
? o1.HasSameSortingOrderAs([ "a", "b" ])# --> TRUE

/*=====================

? StzListQ([ "a", "b", [] ,"c", NULL ]).ToCodeSimplified()
# --> [ "a","b",[ ],"c", "" ]

? StzListQ([ "a", "b", [ [] ] ,"c", NULL ]).ToCodeSimplified()
# --> [ "a","b",[ [ ] ],"c", "" ]

/*---------------------

? @@S( StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened() )
# --> [ "a","b","c","d","e","f" ]

/*---------------------

? StzStringQ("ab []    cd").Simplified()
# --> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
#--> [ "a",[ [ ] ],"b" ]

/*---------------------

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {
	Flatten()
	? @@S( Content() )
	# --> [ "a",[ ],"c",1,[ ],2,"b" ]

	? NumberOfItems() 		# --> 7
	? ItemAtPosition(3)		# --> "c"
	? @@S(ItemAtPosition(5))	# --> [ ]
	
}

/*=====================

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
# --> [ 1, 2, 3, 5, 6 ]

? @@S(o1.FindManyXT([ :one, :five ]))
# --> [ :one = [1, 3, 5], :five = [ ] ]

/*---------------------

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
# --> [ 1, 2, 3, 5, 6 ]

? o1.FindManyXT([ :one, :two, :four ])
# --> [ :one = [1, 3, 5], :two = [2], :four = [6] ]

/*---------------------

o1 = new stzList([ 1, 2, 3])

o1.ExtendToPosition(5)
? o1.Content() # --> [ 1, 2, 3, 0, 0 ]

o1.ExtendToPositionXT( 8, :With = 5 )
? @@S(o1.Content())
#--> [ 1, 2, 3, 0, 0, 5, 5, 5 ]

/*=====================

oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType() 	# --> 1
? oList.ItemsAreAllEmptyLists() # --> 0

/*=====================

o1 = new stzList(1:5)
o1.AddItemAt(7, 9)
? o1.Content() # --> [ 1, 2, 3, 4, 5, 0, 0, 9 ]

/*---------------------

o1 = new stzList("A":"E")
o1.AddItemAt(7,"X")
? o1.Content() # --> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

/*=====================

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsW( '{ @item >= 8 }' ) # --> [ 8, 11, 11, 10, 8, 8 ]

/*---------------------

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence("2") 	# --> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence([ 2 ])	# --> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence( 2 )	# --> 2

? Q(2).IsOneOfThese([ 3, 2, 5 ]) 	# --> TRUE
? Q("2").IsOneOfThese([ 3, 2, 5 ]) 	# --> FALSE
? Q([2]).IsOneOfThese([ 3, 2, 5 ])	# --> FALSE

/*======================

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 8 ])

? o1.FindW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
# --> [ 1, 3, 5, 8, 9, 12 ]

? o1.ItemsW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
# --> [ 2, 2, 2, 4, 2, 2 ]

? o1.UniqueItemsW( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
# --> [ 2, 4 ]

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

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsW( :Where = 'Q(@item).IsAnUppercase()')
# --> [ "A", "B", "A", "C", "B" ]

? o1.ItemsPositionsW('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...) or .FindW(...)
# --> [ 1, 4, 5, 7, 9 ]

? o1.ItemsAndTheirPositionsW('Q(@item).IsUppercase()')
# --> [ "A" = [1, 5], "B" = [4, 9], "C" = [7] ]

/*=========================
*/
# Finding positions where next number is double of previous number
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.FindW( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' )
# --> [ 8, 11 ]

# that you can also write like this:
? o1.FindW( :Where = '{ Q( @NextItem ).IsDoubleOf( @PreviousItem ) }' )
# --> [ 8, 11 ]

# or like this:
? o1.FindWhere( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' )
# --> [ 8, 11 ]

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])
? o1.FindW( '{ @Number = @NextNumber }' ) # --> [ 3, 8, 17, 18 ]

# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindW( '{ This[@i] = This[@i+1] }' ) # --> [ 2, 5, 6 ]

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? @@S( o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') ) #--> [ 4 ]


/*---------------------

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? o1.PreviousNthOccurrence(3, :Of = 0, :StartingAt = 5) # --> 1
? o1.PreviousNthOccurrence(2, :Of = 8, :StartingAt = :LastItem) # --> 2

/*-----------------------

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])
? o1.FindAll(120) # --> [ 3, 6 ]
? o1.NumberOfOccurrence(120) # --> 2

/*-----------------------

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])
? o1.FindNthNextOccurrence( 2, :Of = 120, :StartingAt = 1 ) # --> 6

/*-----------------------

o1 = new stzList([ "mio", "mia", "mio", "mix", "miz", "mix" ])
? o1.FindNthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 ) # --> 6

# Other alternatives are:
? o1.FindNextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 ) # --> 6
? o1.NthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 ) # --> 6
? o1.NextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 ) # --> 6

/*-----------------------

o1 = new stzList([ "mio", "mix", "mia", "mio", "mix", "miz", "mix" ])
? o1.FindPreviousNthOccurrence( 2, :Of = "mix", :StartingAt = 6) # --> 2

/*-----------------------

o1 = new stzList([ :Char, :String, :Number, :List, :Object, :CObject, :QObject, :Byte ])
? o1.RemoveItemsAtThesePositionsQ( 6:8 ).Content()
# --> [ :Char, :String, :Number, :List, :Object ]

/*----------------------- TODO: REFACTORED: Revisit after comleting stzWalker //////////////////////////////


o1 = new stzList([ 12, 24, 36, "A", "B", 12, "C", "D", "E", 24, "F", 25, "G", "H" ])
o1 {

	// Walking the list UNTIL a condition is verified
		aWalk1 = WalkUntil("@item = 'D'") # TODO: add WalkUntilW()
		? aWalk1 # --> 1:8
	
		aWalk2 = WalkUntil("isNumber(@item)")
		? aWalk2 # --> [ 1 ]
	
		aWalk3 = WalkUntil("isNumber(@item) and @item > 30")
		? aWalk3 # --> 1:3
	
		aWalk4 = WalkUntil("isNumber(@item) and Q(@item).IsDividorOf(36)")
		? aWalk4 # --> [ 1 ]

	// Walking the list WHILE a condition is verified
		aWalk5 = WalkWhile("StzcharQ(@item).IsLetter()") # TODO: add WalkWhileW()
		? aWalk5 # --> NULL	# ERROR: should return all the list! ( 1:14 )
	
		aWalk6 = WalkWhile("isNumber(@item) and Q(@item).IsDividableBy(12)")
		? aWalk6 # --> 1:3

	// Walking on each item verifying the provided condition
		aWalk7 = WalkEachW("isNumber(@item)") # TODO: add WalkEach()
		? aWalk7 # --> [ 1, 2, 3, 6, 10, 12 ]

	// Walking the list forth and back
		aWalk8 = WalkForthAndBack()
		? aWalk8 # --> [ 1,2,3..., 14,13,12...,1 ]

	// Walking the list back and forth
		aWalk9 = WalkBackAndForth()
		? aWalk9  # --> [ 14,13,12..., 1,2,3...,14 ]

	// Walking n steps forward
		aWalk12 = WalkNStepsForward(2)
		? aWalk12 # --> [ 1,3,5,7,9,11,13 ]

	// Walking n steps backward
		aWalk13 = WalkNStepsBackward(2)
		? aWalk13 # --> [ 14,12,10,8,6,4,2 ]

	// Walking n progressive steps forward	# TODO: CUMULATIVE instead of PROGRESSIVE
		aWalk14 = WalkNProgressiveStepsForward(2)
		? aWalk14 # --> [ 1,3,7,13 ]

	// Walking n progressive steps backward # TODO: CUMULATIVE instead of PROGRESSIVE
		aWalk15 = WalkNProgressiveStepsBackward(2)
		? aWalk15 # --> [ 14, 12, 8, 2 ]

	// Walking n steps forward and then n steps backward --> ERROR
		aWalk10 = WalkNStepsForwardNStepsBackward(3,1)
		? aWalk10 # --> [ 1, 4,3, 6,5, 8,7, 10,9, 12,11, 14,13 ]
		# TODO: check it should return [ 1,2,3, 2, 3,4,5, 4, 5,6,7, 6... ]

	// Walking n steps from start and n steps from end --> ERROR
		aWalk11 = WalkNStepsFromStartNStepsFromEnd(1,2) 
		? aWalk11 # --> [ 1,14, 2,12, 3,10, 4,8, 5,6, 7,9, 11, 13 ]
		# TODO: check it should return [ 1,14,13,  2,12,11, 3,10,9, 4,8,7, 5,6 ]

}

/*-----------------------

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSection(4, 6, [ "*", "*", "*", "*" ])
? o1.Content()
# --> [ "A", "B", "C", "*", "*", "*", "*", "D", "E" ]

/*-----------------------

? StzListQ([ 1, 2, 3 ]).RepeatNTimes(3)

/*-----------------------

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems() # --> TRUE
	? NumberOfLeadingItems() # 3
	? LeadingItems() # --> [ "*", "*", "*" ]
	
	? HasTrailingItems() # --> TRUE
	? NumberOfTrailingItems() # 2
	? TrailingItems() # --> [ "+", "+" ]

	ReplaceRepeatedLeadingItemWith("+")
	? Content() # --> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingItemAndTrailingItemWith("*","*")
	? Content() # --> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
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
# --> "compagon"

STOP()

/*-----------------------

# In Softanza, two lists are equal when they have same
# number of items and have same content
 
o1 = new stzList(1:3)
? o1.HasSameContentAs(3:1)		# --> TRUE
? o1.HasSameNumberOfItemsAs(3:1)	# --> TRUE
? o1.IsEqualTo(3:1)			# --> TRUE

/*-----------------------

# In Softanza, two lists are STRICTLY equal when they have
# same number of items, have same content, and same sorting order

# ==> In other terms: when they are Equal (in the sense of
# IsEqualTo()) and have same sorting order
 
# This beeing said, 1:3 is equal to its reversed list 3:1
# but it is not STRICTLY equal to it

? Q(1:3).IsEqualTo(3:1)		# --> TRUE
? Q(1:3).IsStrictlyEqualTo(3:1)	# --> FALSE

# In fact, the two lists don't have the same sorting order!

? Q(1:3).SortingOrder()	# --> :Ascending

? Q(3:1).SortingOrder()	# --> :Descending

# Hence, 1:3 is STRICTLY equal only to itself

? Q(1:3).IsStrictlyEqualTo(1:3)	# --> TRUE

/*-----------------------

# Softanza can compare lists (and string sofar), in an approximative way.
# Of course, the degree of approximation can be tuned to fit with your need.

o1 = new stzList([ "f","a","y","e","d" ])
? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])	# --> FALSE
? QuietEqualityRatio()	# --> 0.09

SetQuietEqualityRatio(0.41)
? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])	# --> TRUE

/*-----------------------

# Softanza can sort a list, whatever data types it contains (not only
# numbers and strings), in ascending and descending orders (see
# comments in corresponding methods in stzList class).

# Also, it can retrieve the sorting of a list using SortingOrder()
# method (returns :Ascending, :Descending, or :Unsorted).

# And it can compare the sorting orders of two lists using
# HasSameSortingOrderAs() method.

? Q(3:1).SortInAscendingQ().Content()	# --> [ 1, 2, 3 ]
? Q(1:3).SortInDescendingQ().Content()	# --> [ 3, 2, 1 ]

? Q(1:3).SortingOrder()	# --> :Ascending

? Q(1:3).HasSameSortingOrderAs(3:1)	# --> FALSE
? Q(1:3).HasSameSortingOrderAs(1:3)	# --> TRUE
? Q(1:3).HasSameSortingOrderAs(1:5)	# --> TRUE

/*-----------------------

# Operators on stzString

o1 = new stzList([ "S","O","F","T","A","N","Z","A" ])

# Getting a char by position
? o1[5]		# --> "A"


# Finding the occurrences of a substring in the string
? o1["A"]	# --> [ 5, 8 ]

# Getting occurrences of chars verifying a given condition
? o1[ '{ Q(@item).IsOneOfThese(["A", "T", "Z"]) }' ]	# --> [ 4, 5, 7, 8 ]

STOP()

/*-----------------------

o1 = new stzList([ 10, 1, 2, 3, 10 ])
o1.Remove(10)
? o1.Content() # --> [ 1, 2, 3 ]

/*---------------- TODO: enhance finding objects inside lists

obj = new Person { name = "sun" }

o1 = new stzList([ 10, "A":"E", 12, obj, 10, "A":"E", obj, "Ring" ])
? o1.FindAll(10)	# --> [ 1, 5 ]
? o1.FindAll("Ring")	# --> [ 8 ]
? o1.FindAll("A":"E")	# --> [ 2, 6 ]

? o1.FindAll(obj)	# --> [ 4, 7 ]
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
? o1.FindAll([ "L1", "L1" ]) # --> [ 6 ]

# Not only list are findable, they are also sortable and comparable.

? o1.SortedInAscending() # --> [ 10, 12, "ten", "twelve", [ "L2", "L2" ], [ "L1", "L1" ] ]

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
? oStr.IsBoundedBy([ "|<--", "-->|" ]) # --> TRUE

# And then we can delete these bounds:
? oStr.BoundsRemoved([ "|<--", "-->|" ]) # --> "Scope of Life"

# The same semantics apply to lists, like this:

oList = new stzList([ "|<--", "Scope", "of", "Life", "-->|" ])
? oList.IsBoundedBy([ "|<--", "-->|" ]) # --> TRUE

# And we can remove all these bounds, exactly like we did for strings:
? oList.BoundsRemoved([ "|<--", "-->|" ]) # --> [ "Scope", "of", "Life" ]

STOP()
/*-----------------------

o1 = new stzList([ "{", "A", "B", "C", "}" ])
? o1.IsBoundedBy([ "{", "}" ]) # --> TRUE

o1.RemoveBounds([ "{", "}" ])
? o1.Content() # --> [ "A", "B", "C" ]

/*-----------------------

o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])
? o1.BoundsUpToNItems(1) # --> [ "{","}" ]
? o1.BoundsUpToNItems(2) # --> [ [ "{", "<" ], [ ">", "}" ] ]

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
]) # --> TRUE

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
}').NumberOfItems() # --> 3

/*----------------------

? @@S( StzListQ("A":"E").Reversed() )		#--> [ "E", "D", "C", "B", "A" ]
? @@S( StzListQ("A":"E").ItemsReversed() )	#--> [ "E", "D", "C", "B", "A" ]

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsW('isNumber(@item)')
# --> 3

? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsW('
	isString(@item) and Q(@item).isLetter()
') # --> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsW('Q(@item).IsDividableBy(2)') # --> 3

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW(' isNumber(@item) ')
# --> [1, 2, 3]

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW('
	isString(@item) and _(@item).@.IsLetter()
') # --> ["A", "B", "C"]

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsW('Q(@item).IsDividableBy(2)')
# --> [2, 4, 6]

/*----------------------

o1 = new stzList( [ "1", "2", [ 1, [ "x" ], 2 ],  "3" ] )

? o1.ToCode()
#--> [
#	"1",
#	"2",
#	[
#		1,
#		[
#			"x"
#		],
#		2
#	],
#	"3"
#    ]

? o1.ToCodeSimplified() # Or ToCodeS()
# --> Returns [ "1", "2", [ 1, [ "x" ], 2 ], "3" ]

# Note that the string has been simplified (no extra spaces)
# and beautified by adding spaces after commas.

/*----------------------

# You can replace the nth item of a list
# by a given value by writing:

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, "B")
? o1.Content()	# --> [ "A", "B", "C" ]

# Or you can be a bit more expressive by using :With

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, :With = "B")
? o1.Content() # --> [ "A", "B", "C" ]

# Or you can use the dynamic form of :With@ to evaluate
# a piece of Ring code that returns the replaced value

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceItemAtPosition(2, :With@ = ' Q(@item).Uppercased() ')
? o1.Content()	# --> [ "A", "B", "C" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By = "A")
? o1.Content() # --> [ "A", "A", "A" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By@ = "Q(@item).Uppercased()")
? o1.Content()  # --> [ "A", "A", "A" ]

/*----------------------

# Conditional replacement of items can happen for all the items
# in the same time like this:

StzListQ( [1, "a", 2, "b", 3, "c" ] ) {
	ReplaceItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By = "*"
	)

	? Content() #--> [ 1, "*", 2, "*", 3, "*" ]
}

# If you want to evalute a Ring code that sets the replace value dynamically then
# you should use :With@ like this:

StzListQ( [1, "a", 2, "b", 3, "c" ]) {
	ReplaceItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By@ = '{ Q(@item).Uppercased() }'
	)

	? Content() #--> [ 1, "A", 2, "B", 3, "C" ]
}

/*--------------------

o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3) #--> [ "a", "b", "c" ]

/*---------------

? ListsMerge([ [ 1, 2 ], [ 3 ] ])
# --> [ 1, 2, 3 ]

? ListsMerge([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
])
# --> [ [ 1, 2], [3, 4] ]

? ListsFlatten([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
])
# --> [ 1, 2, 3, 4 ]

/*--------------

? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).
	ItemsW('StzCharQ(@item).IsArabic()') #--> [ "ض", "س", "ط" ]

/*--------------

? @@S( StzListQ([ "a", 1, "b", 2, "c", 3 ]).Types() )
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
}') # --> Gives [ 2, 5 ]

? o1.FindWhere('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] != DoubleOf(@item)	
}') # --> Gives [ 8 ]

class Person name

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
? o1.FindAllW('{ Q(@item).IsUppercase() }')
  # --> Gives [3, 4, 6]

? o1.ItemsW('{ Q(@item).IsUppercase() }')
  # --> Gives ["C#", "RING", "RUBY"]

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
o1.InsertAfterW( :Where = '{ Q(@item).IsLowercase() }' , :With = "*")
? o1.Content() # --> ["c", "*", "c++", "*", "C#", "RING", "Python", "RUBY"]

/*-------------

o1 = new stzList( [ "c", "c++", "C#", "RING", "Python", "RUBY" ] )
? o1.ItemsW('{ Q(@item).IsLowercased() }') # --> [ "c", "c++" ]

? o1.FirstItemW('{ Q(@item).IsLowercased() }') # --< "c"
? o1.NthItemW(2, '{ Q(@item).IsLowercased() }') # --> "c++"
? o1.LastItemW('{ Q(@item).IsLowercased() }') # --> "c++"

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "python", "ruby"])
? o1.FindW("   ") #--> [1, 2, 3, 4, 5, 6]

? o1.CountW('{ isLower(@item) }') #--> 3
o1.NumberOfOccurrenceW('{  }') #--> 6

/*==============

o1 = new stzSplitter( 1:5 )

? @@S(o1.SplitToPartsOfNItems(2))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@S(o1.SplitBeforePositions( [ 3, 5 ] ))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@S(o1.SplitAfterPositions( [ 3, 5 ] ))
#--> [ [ 1, 3 ], [ 4, 5 ], [ 5, 5 ] ]

/*-------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

? @@S( o1.SplitToPartsOfNItems(2) )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "e" ] ]

? @@S( o1.SplitAfterPositions([ 3, 5 ]) )
#--> [ [ "a", "b", "c" ], [ "d", "e" ], [ "e" ] ]

? @@S( o1.SplitBeforePositions([ 3, 5 ]) )
# Returns [ ["a","b"], ["c", "d"], ["e"] ]

/*------------- TEST IT

o1 = new stzString("abcde")

? @@S( o1.SplitToPartsOfNChars(2) )
#--> [ "ab", "cd", "e" ]
? @@S( o1.SplitToPartsOfNCharsXT(2, :ExcludeRemaining = TRUE) )
#--> [ "ab", "cd" ]

? @@S( o1.SplitAfterPositions([ 3, 5 ]) )
#--> [ "abc", "de", "e" ]

? @@S( o1.SplitBeforePositions([ 3, 5 ]) )
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
o1 * ".ring"	# --> [ "file1.ring", "file2.ring", "file3.ring" ]
//o1 + ".ring"	# --> [ "file1", "file2", "file3", ".ring" ]
? o1.Content()

/*---------------

o1 = new stzList([ "medianet", "st2i", "webgenetix", "equinoxes", "groupe-lsi",
		   "prestige-concept", "sonibank", "keyrus", "whitecape",
		   "lyria-systems", "noon-consulting", "ifes", "mourakiboun",
		   "isie", "hnec", "haica", "kalidia", "triciti", "avionav",
		   "maxeam", "nextav", "ring" ])

? o1.ContainsMany([ "medianet", "st2i" ]) # --> TRUE
? o1.ContainsEach([ "ifes", "haica"]) 	  # --> TRUE
? o1.ContainsBoth("ifes", "haica")	  # --> TRUE

/*-----------------

//? ListReverse([ 1, 2, 3 ])

o1 = new stzList([ "tunis", 1:3, 1:3, "gafsa", "tunis", "tunis", 1:3, "gabes", "tunis", "regueb", "regueb" ])
//o1.ReverseItems() # Note: Softanza does not use Reverse() because it is reserved by Ring
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
? o1.Content() # --> [ "theater", "stranger" ]
                                              
/*---------------------

o1 = new stzList([ "A", "B", "C" ])
? o1.ExtendToPositionNWithQ(5, "0").Content() # --> [ "A", "B", "C", "0", "0" ]

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

? StzListQ([ 2, 3, 2, :f ]).IsListOfNumbers()
? ListOfNumbersSum([ 2, 3, 2 ])

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
? StzListQ([ "a", "b", "c" ]).ExistsIn([ "a", "b", "c", "x", "z" ]) # --> FALSE

# In fact, there are no occurrences of [ "a", "b", "c" ] in the list
? StzListQ([ "a", "b", "c", "x", "z" ]).FindAll([ "a", "b", "c" ]) # --> []

# Now if you say:

? StzListQ([ "a", "b", "c" ]).ExistsIn([ "a", "b", "c", "x", "z", [ "a", "b", "c" ] ]) # --> TRUE

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
? o1.IsIncludedIn([ "green", "red", "blue" ]) # --> TRUE

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
# --> [ :name = "Ali", :age = 24, :job = "Programmer"	]

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

? o1.NumberOfLevels() # --> 4

? @@S( o1.ItemsThatAreLists_AtAnyLevel_XT() )
# -->
#	[
#		[ :Path = [ 2 ], :Level = 1, :Position = 2 ],
#		[ :Path = [ 4 ], :Level = 1, :Position = 4 ],
#		[ :Path = [ 4, 3 ], :Level = 2, :Position = 3 ],
#		[ :Path = [ 3 ], :Level = 1, :Position = 3 ],
#		[ :Path = [ 3, 2 ], :Level = 2, :Position = 2 ],
#		[ :Path = [ 3, 2, 2 ], :Level = 3, :Position = 2 ]
#	]

? o1.ItemsThatAreLists_AtAnyLevel() # !!!--> ERROR TODO
