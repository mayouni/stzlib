load "stzlib.ring"

/*---------------

o1 = new stzList([ 1, 2, 1, 1, 2, 3, 3, 3 ])
? o1.DuplicatesRemoved() #--> [ 1, 2, 3 ]

/*---------------

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])
? o1.FindAll(1:3) 	#--> [1, 3, 4]

? o1.Contains(7:10)	#--> TRUE	

/*---------------

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

o1.Removeduplicates()
? o1.Content() #--> [ 1:3, 4:6, 7:10 ]

/*===============

# In Ring, you can declare a "continuous" list of chars
# from "A" to "F" like this:

StzListQ("A":"F") {
	? Content()
	#--> Gives [ "A", "B", "C", "D", "E", "F" ]

	? ItemAtPosition(4) #--> "D"
}

# This beeing working only for ASCII chars, Softanza comes
# with this solution for any "continuous" UNIOCDE chars:

StzListQ(' "ا" : "ج" ') {
	? Content()
	#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

	? ItemAtPosition(4) #--> "ت"
}

/*===========

? StzListQ(1:5).IsContinuous()		 #--> TRUE
? StzListQ([ "A","B" ]).IsContinuous()	 #--> TRUE
? StzListQ(' "ا" : "ج" ').IsContinuous() #--> TRUE

/*-----------------

# As we all know, Ring provides us with this elegant syntax:

aList = "A" : "D"
? @@( aList )	#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# And if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? @@( aList )	# --> "ا"

# Fortunately, Softanza solves this by the following function:

? @@( ContinuousList("ا" , "ج") )
#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? ContinuousList("A", "D")	#--> [ "A", "B", "C", "D" ]

# Interestingly, this short form mimics the "_" : "_" Ring syntax:

? @C('"ا" : "ج"')	# "C" for "Continuous"
#--> Gives [ "ا", "ب", "ة", "ت", "ث", "ج" ]

? @C(' "ج" : "ا" ')
#--> Gives [ "ج", "ث", "ت", "ة", "ب", "ا" ]

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

? o1.Classify()	# Same as Categorize()
#--> [
#	[ "[ 1, 2, 3, 4, 5 ]",   [1, 3, 8 ] ],	
#	[ "[ 3, 4, 5, 6, 7, 8, 9 ]",   [2, 5 ] ],
#	[ "[ 10, 11, 12, 13, 14, 15 ]", [4, 7 ] ],
#	[ "[ 12, 13, 14, 15, 16, 17, 18, 19, 20 ]", [6, 9 ]
#    ]

# Note that lists are transformed to strings so we can use them
# as keys for idenfifying the their positions in the hash string.

# Hence we can say:

? o1.Klass("[ 1, 2, 3, 4, 5 ]") #--> [1, 3, 8 ]
# Here, I used "K" because "Class" is a reserved name by Ring.
# If you don't like that, please use Category() instead.

# If you prefer getting the classes in "continuous form" (i.e. "1:5"
# instead of "[1, 2, 3, 4, 5 ]", then use this:

? o1.Classify@C() #--> "@C" for "Continuous" lists
#--> [
#	[ "1:5",   [1, 3, 8 ] ],	
#	[ "3:9",   [2, 5 ] ],
#	[ "10:15", [4, 7 ] ],
#	[ "12:20", [6, 9 ]
#    ]

? o1.Klass@C("1:5") #--> [1, 3, 8]

/*----------------

? StzListQ( :ReturnedAs = :stzList ).IsReturnedAsParamList() #--> TRUE

/*-----------------

? StzListQ([]).IsListOfStrings() # --> FALSE
? StzListQ([]).IsListOfNumbers() # --> FALSE

/*-----------------

? StzListQ([ [ "name", "Mansour"], [ "age", 45] ]).IsHashList() # --> TRUE
? StzListQ([ :name ="Mansour", :age = 45 ]).IsHashList() # --> TRUE

# But

? StzListQ([ "name" = "Mansour", "age" = 45 ]).IsHashList() # --> FALSE

/*-----------------

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {
	? Numbers() # --> [ 1, 2, 3, 4, 5 ]
	# You can also say ? OnlyNumbers()

	? NonNumbers() # [ "A", "B", "C", "D" ]
	# You can also say OnlyNonNumbers()

	? Content() # --> [ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]
	# Not that the list is not altered by Numbers() and NonNumbers()
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
? o1.Content() # -->  [ 1, 2, 3, 4, 5 ]

/*-----------------

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
o1 - o1.ItemsW('IsNotNumber(@item)')
? o1.Content() # -->  [ 1, 2, 3, 4, 5 ]

/*-----------------

StzListQ([ "by", "except"]) { 
	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ]) # --> TRUE
	# return FALSE --> ERROR  should return TRUE

	# Same as
	? IsMadeOfSome([ :by, :except, :stopwords ]) # --> TRUE
}

/*-----------------

# البعض من الشّيء يمتدّ من اللّاشيءِ إلى الشَّيء كلّه، وما بينهما.

StzListQ([ "by", "except", "stopwords"]) { 
	//? IsMadeOfThese([ :by, :except, :stopwords ])
	? IsMadeOfSome([ :by, :except, :stopwords ]) # TRUE

	# Same as
	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ]) # --> TRUE
}

/*-----------------
*/
//? list2code([ "q", "r", [ 2, 1 ] ])

//? StzListQ([ "q", "r", [ 2, 1 ] ]).ToCode()
/*
? StzListQ([ "q", "r", [ 2, 1 ] ]).Contains("x")
/*
? StzListQ([ "q", "r", [ 2, 1] ]).HasSameContentAs([ "q", "r", [ 2, 1] ])
//? StzListQ([ "q", "r", [ 2, 1] ]).IsEqualTo([ "q", "r", [2, 1] ])

/*----------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

o1 = new stzList([ 
	:By = :OrderOfOccurrenceOfWords,
	:Except = [ :names, :actually ]//, # try also :Except = :names
	//:StopWords = :MustBeRemoved # try also :MustNotBeRemoved
])


? o1.IsReplaceWordsWithMarquersParamList()


/*-----------------

? StzListQ([]).IsListOfStrings() # --> TRUE
? StzListQ([ NULL, NULL, NULL]).IsListOfStrings() # --> TRUE

/*-----------------

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
o1 - [ "bo", "wo" ]
? o1.Content()

/*-----------------

? IsListOfStrings([ "baba", "ommi", "jeddy" ])		# --> TRUE
? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()	# --> TRUE

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}

# --> Returns a string like this:

#	 [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#	  --^--------------^---------^-------------------^------------

# WARINING: works only for list of chars
# TODO : Generalize it for list of strings and other types

/*------------------

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

/*------------------

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrence(2, "A", "*", :StartingAt = 2)
	? Content() # --> [ "A" , "B", "C", "A", "D", "*" ]
}

/*------------------

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of="A", :by="*", :StartingAt = 5)
	? Content() # --> [ "*" , "B", "C", "A", "D", "A" ]
}

/*------------------

StzListQ([ -1 , 2, 3, 4 ]) {
	? NumberOfItemsW("Q(@item).IsBetween(1, 4)") # --> 3
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrences([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
	? Content() # !--> [ "A" , "B", "A", "C", "*", "D", "*" ]
}


StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesReplaced([2, 3], :of = "A", :with = "*",  :StartingAt = 3)
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrences([1, 2, 3], :of = "A", :with = "*",  :StartingAt = 5)
	? Content() # !--> [ "*" , "B", "*", "C", "*", "D", "A" ]
}

/*------------------

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrences([1, 3], "A", [ "*", "#" ], :StartingAt = 5)
	? Content() # !--> [ "A" , "B", "#", "C", "*", "D", "A" ]
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
	? Content() # !--> [ "A" , "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 3)
	? Content() # !--> [ "A" , "B", "A", "C", "D" ]
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

/*------------------

# In Softanza, you can replace all occurrences of an item
# in the list by a provided value, by saying:

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	Replace("A", :With = "#")
	# Or ReplaceAll("A", :With = "#") or ReplaceAllOccurrences(:Of = "A", :With = "#')

	? Content() # --> [ "#", "B", "C", "#", "D", "B", "#" ]

}

/*------------------

# In case you need to make many replacements at once, then you are covered:
# just provide the list of items to replace and the value of replacement...

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceMany([ "A", "B" ], :With = "#")
	? Content() # --> [ "#", "#", "C", "#", "D", "#", "#" ]

}

/*------------------

# You can even replace exitant items by many other new values, one by one,
# like this (useful in many scenarii of text interpolation and processing):

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceManyXT([ "A", "B" ], :With = [ "#1", "#2" ])
	? Content() # --> [ "#1", "#2", "C", "#1", "D", "#2", "#1" ]

}

/*------------------

# And if you want to replace the occurrences of a given item by alternating
# between several other items you provide, then this is possible:

StzListQ([ "A", "A", "A" , "A", "A" ]) {
	
	ReplaceManyXT("A", :With = [ "#1", "#2" ])
	# Equivalent to : ReplaceItemByAlternance("A", :With = [ "#1", "#2" ])

	? Content() # --> [ "#1", "#2", "#1", "#2", "#1" ]

}

/*---------------------

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content() # --> [ "A", "B", "C", "A", "D", "B", "#" ]

}

/*---------------------

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending() # --> [ 2, 5, 7, 9 ]

/*---------------------

o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])
? o1.DuplicatesRemoved() # --> [ "teeba", "hussein", "haneen" ])
? o1.NumberOfItems()     # --> 4

/*---------------------

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	# --> TRUE
# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		# --> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	# --> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	# --> TRUE

/*---------------------

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a" ] 
? @@( o1.Content() ) # --> [ "c" ]

/*-----------------------

o1 = new stzList([ "a", "b", "c" ])
o1 - [ "b", "a", "c" , "q" ]
? @@( o1.Content() ) # --> [ ]

/*-----------------------

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])
? o1.FindMany([ "a", "e" ])	# --> [ 1, 3, 4, 7 ]
? o1.FindManyXT([ "a", "e" ])	# --> [ "a" = [ 1, 4 ], "e" = [ 3, 7 ] ]

/*-----------------------

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])
? o1.FindMany([ "a", "c" ]) # --> [1, 4, 5]

o1 - [ "a", "c" ] # Same as: o1.RemoveManyAtPositions([ 1, 4, 5 ])

? o1.Content() # --> [ "b", "e", "v", "e" ]

/*-----------------------

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

/*---------------------

? StzListQ([ "a", "b", [] ,"c", NULL ]).ToCode()
# --> [ "a","b",[ ],"c", "" ]

? StzListQ([ "a", "b", [ [] ] ,"c", NULL ]).ToCode()
# --> [ "a","b",[ [ ] ],"c", "" ]

/*---------------------

? StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened()
# --> [ "a","b","c","d","e","f" ]

/*---------------------

? StzStringQ("ab []    cd").Simplified()
# --> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
[ "a",[ [ ] ],"b" ]

/*---------------------

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {
	Flatten()
	? @@( Content() )
	# --> [ "a",[ ],"c",1,[ ],2,"b" ]

	? NumberOfItems() 	# --> 7
	? ItemAtPosition(3)	# --> "c"
	? @@(ItemAtPosition(5))	# --> [ ]
	
}

/*---------------------

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
# --> [ 1, 2, 3, 5, 6 ]

? @@(o1.FindManyXT([ :one, :five ]))
# --> [ :one = [1, 3, 5], :five = [ ] ]

/*---------------------

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
# --> [ 1, 2, 3, 5, 6 ]

? o1.FindManyXT([ :one, :two, :four ])
# --> [ :one = [1, 3, 5], :two = [2], :four = [6] ]

/*---------------------

o1 = new stzList([ 1, 2, 3])

o1.ExtendToPositionNWith(5, 0)
? o1.Content() # --> [ 1, 2, 3, 0, 0 ]

/*---------------------

oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType() # --> 1
? oList.ItemsAreAllEmptyLists() # --> 0

/*---------------------

o1 = new stzList(1:5)
o1.AddItemAt(7, -1)
? o1.Content() # --> [ 1, 2, 3, 4, 5, 0, 0, -1 ]

/*---------------------

o1 = new stzList("A":"E")
o1.AddItemAt(7,"X")
? o1.Content() # --> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

/*---------------------

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWhere( '{ @item >= 8 }' ) # --> [ 8, 11, 11, 10, 8, 8 ]

/*--------------------- TODO: Levels functions need a reflection, see code.

o1 = new stzList([
	1, [ "A", "B"], 2,
	[ 3, 4, [ "B", "C" ] ],
	[ 5, [ 6, [ "D", "E" ], 7 ], 8 ]
])

? o1.NumberOfLevels() # --> 4

? o1.ItemsThatAreLists_AtAnyLevel_XT()
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

/*---------------------
*
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence("2") 	# --> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence([ 2 ])	# --> 0
? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence( 2 )	# --> 2

? Q(2).IsOneOfThese([ 3, 2, 5 ]) 	# --> TRUE
? Q("2").IsOneOfThese([ 3, 2, 5 ]) 	# --> FALSE
? Q([2]).IsOneOfThese([ 3, 2, 5 ])	# --> FALSE

/*--------------------- TODO: Test it for items of type lists and objects

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

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsW('Q(@item).IsUppercase()')
# --> [ "A", "B", "A", "C", "B" ]

? o1.ItemsPositionsW('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...)
# --> [ 1, 4, 5, 7, 9 ]

? o1.ItemsAndTheirPositionsW('Q(@item).IsUppercase()')
# --> [ "A" = [1, 5], "B" = [4, 9], "C" = [7] ]

/*---------------------

# Finding positions where next item is double of precedent item
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) # --> [ 8, 11 ]

/*---------------------

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])
? o1.FindW( '{ @item = This[@i+1] }' ) # --> [ 3, 0, 17, 18 ]

/*---------------------

# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindWhere('{ This[@i] = This[@i+1] }') # --> [ 2, 5, 6 ]

/*---------------------

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') # --> 4

/*---------------------

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? o1.PreviousNthOccurrence(3, :Of = 0, :StartingAt = 5) # --> 1
? o1.PreviousNthOccurrence(2, :Of = 8, :StartingAt = :End) # --> 2

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

/*----------------------- TODO: fix some erronous outputs //////////////////////////////

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

? StzListQ([ 1, 2, 3 ]).RepeatNTimesQ(3).Content()

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

/*----------------------- TODO: fix error

# All these return TRUE

? StzListQ([ :DefaultLocale ]).IsLocaleList()
? StzListQ([ :SystemLocale ]).IsLocaleList()
? StzListQ([ :CLocale ]).IsLocaleList()

? StzListQ([ :Language = :Arabic, :Script = :Arabic, :Country = :Tunisia ]).IsLocaleList()

? StzListQ([ :Language = :Arabic, :Country = :Tunisia ]).IsLocaleList()
? StzListQ([ :Country = :Tunisia ]).IsLocaleList()

/*----------------------- TODO: fix error

# All these return TRUE

? _(1:5).Q.IsListOf(:Numbers)
? _("A":"E").Q.IsListOf(:Strings)
? _( [ 1:5, "A":"E" ]).Q.IsListOf(:Lists) 

? _( [ 1:5, 6:10, 11:15 ] ).Q.IsListOf(:ListOfNumbers)
? _( [ 1:5, 6:10, 11:15 ] ).Q.IsListOf(:ListsOfNumbers)

? _( [ "A":"E", "a":"e" ] ).Q.IsListOf(:ListOfStrings)
? _( [ "A":"E", "a":"e" ] ).Q.IsListOf(:ListsOfStrings)

/*----------------------- TODO: fix error

# All these return TRUE

oNumber1 = StzNumberQ(7)
oNumber2 = StzNumberQ(12)
oNumber3 = StzNumberQ(24)

? _([ oNumber1, oNumber2, oNumber3 ]).Q.IsListOf(:StzNumber) # error
? _([ [oNumber1, oNumber2], [oNumber2, oNumber3] ]).Q.IsListOf(:ListsOfStzNumbers)

oString1 = StzStringQ("Win")
oString2 = StzStringQ("Loose")
oString3 = StzStringQ("Don't care!")

? _([ oString1, oString2, oString3 ]).Q.IsListOf(:StzStrings)
? _([ [oString1, oString2], [oString2, oString3] ]).Q.IsListOf(:ListsOfStzStrings)

/*-----------------------

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemW(3, :Where = '{ isString(@item) and StringIsUppercase(@item) }')	# --> "CAMARADE"

/*-----------------------

# In Softanza, two lists are equal when they have same
# number of items and have same content
 
o1 = new stzList(1:3)
? o1.HasSameContentAs(3:1)		# --> TRUE
? o1.HasSameNumberOfItemsAs(3:1)	# --> TRUE
? o1.IsEqualTo(3:1)			# --> TRUE

/*-----------------------

# In Softanza, two lists are STRICTLY equal when # they have
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

/*-----------------------

o1 = new stzList([ 10, 1, 2, 3, 10 ])
o1.Remove(10)
? o1.Content() # --> [ 1, 2, 3 ]

/*----------------------- ////////////////////////////////// FINDING OBJECTS /////////////////

obj = new Person { name = "sun" }

o1 = new stzList([ 10, "A":"E", 12, obj, 10, "A":"E", "Ring" ])
? o1.FindAll(10)	# --> [ 1, 5 ]
? o1.FindAll("Ring")	# --> [ 7 ]
? o1.FindAll("A":"E")	# --> [ 2, 6 ]


? o1.FindAll(obj) # ERROR

//o1.Remove("A":"E") # Needs making IsStricltyEqual()
//? o1.Content()

class Person name

/*-----------------------

# Ring can find (and sort) items inside a list (respectively
# using find() and sort() functions), but only if these items
# are of type "NUMBER" or "STRING".

# Softanza makes it posible to find (and sort) all the four
# types: numbers, strings, lists, and objects (--> TODO: not yet for objects).

? o1.FindAll([ "L1", "L2" ]) # --> [ 3, 6 ]

# Not only list are findable, they are also sortable and comparable.

? o1.SortedInAscending() # --> [ 10, 12, "ten", "twelve", [ "L1", "L1" ], [ "L2", "L2" ] ]

# As you can see, the logic of sorting applied by Softanza is:
#	--> Putting numbers first and sorting them
#	--> Adding strings after that and sorting them
#	--> Adding lists as they occure in the main list

# Same thing should be possible for objects but not yet implemented (TODO)

/*----------------------- TODO: Object sortability //////////////////////////////////////

# Now we include a list and an object as new items (which
# are not findable by Ring)

obj = new Person { name = "moon" }

o2 = new stzList([ 10, [ "A", "B"], 12, obj ])
? ................

class Person name

/*-----------------------

# Softanza works consistently on lists and strings: What works
# for a string, would hopefully work for a list, when it makes
# sense, using the same semantics.

# For example, in strings, we can check if the string is bounded
# by two given substrings, or even by many of them. So, we say:

oStr = new stzString("|<- Scope of Life ->|")
? oStr.IsBoundedManyTimesBy([ ["|","|"], ["<",">"], ["-","-"] ]) # --> TRUE

# And then we can delete these bounds:
? oStr.ManyBoundsRemoved([ ["|","|"], ["<",">"], ["-","-"] ]) # --> " Scope of Life "

# The same semantics apply to lists, like this:
oList = new stzList([ "|", "<", "-", "Scope", "of", "Life", "-", ">", "|" ])
? oList.IsBoundedManyTimesBy([ ["|","|"], ["<",">"], ["-","-"] ]) # --> TRUE

# And we can remove all these boundes, exactly like we did for strings:
? oList.ManyBoundsRemoved([ ["|","|"], ["<",">"], ["-","-"] ]) # --> [ "Scope", "of", "Life" ]

/*-----------------------

o1 = new stzList([ "{", "A", "B", "C", "}" ])
? o1.IsBoundedBy("{","}") # --> TRUE

o1.RemoveBounds("{","}")
? o1.Content() # --> [ "A", "B", "C" ]

/*-----------------------

o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])
? o1.BoundsUpToNItems(1) # --> [ "{","}" ]
? o1.BoundsUpToNItems(2) # --> [ [ "{", "<" ], [ ">", "}" ] ]

/*-----------------------

o1 = new stzList([ "{", "A", "B", "C", "}" ])
? o1.BoundsRemoved("{","}")

/*-----------------------

o1 = new stzList([ "1", "2", "A", "B", "C", "3", "4" ])
? o1.ContainsEach([ "A", "B", "C" ])
? o1.ContainsEachOneOfThese([ "A", "B", "C" ])

/*-----------------------

o1 = new stzList([ "A", "B", "C" ])
? o1.EachItemExistsIn([ "1", "2", "A", "B", "C", "3", "4" ])

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
? o1.Show() # --> TRUE

/*-----------------------

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWQ('{
	isNumber(@item) and
	Q(@item).IsDividableBy(2)
}').NumberOfItems() # --> 3

/*----------------------

? StzListQ("A":"E").Reversed()
? StzListQ("A":"E").ItemsReversed()

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsW('isNumber(@item)') # --> 3
? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsW('isString(@item) and Q(@item).isLetter()') # --> 3
? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsW('Q(@item).IsDividableBy(2)') # --> 3

/*----------------------

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW(' isNumber(@item) ') # --> [1, 2, 3]
? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsW(' isString(@item) and _(@item).@.IsLetter() ') # --> ["A", "B", "C"]
? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsW('_(@item).@.IsDividableBy(2)') # --> [2, 4, 6]

# You can also use the abreviated for ItemsW() like this
? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsW('_(@item).@.IsDividableBy(2)') # --> [2, 4, 6]

/*----------------------

? StzListQ( [ "1","2", [ 1,["x"],2],  "3" ] ).ToCode()
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
o1.ReplaceItemAtPosition(2, :With@ = "_(@item).Q.Uppercased()")
? o1.Content()	# --> [ "A", "B", "C" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By = "A")
? o1.Content() # --> [ "A", "A", "A" ]

/*----------------------

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceItemAtPosition(2, :By@ = "Q(@item).Uppercased()")
? o1.Content()  # --> [ "A", "A", "A" ]

/*---------------------- FIX IT

# Conditional replacement of items can happen for all the items
# in the same time like this:

StzListQ( [1, "a", 2, "b", 3, "c" ] ) {
	ReplaceAllItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:by = "*"
	)

	? Content()
}

# If you want to evalute a dynamic code that sets the replace value then
# you should use :With@ like this:

StzListQ( [1, "a", 2, "b", 3, "c" ]) {
	ReplaceAllItemsW(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:by@ = '{ Q(@item).Uppercased() }'
	)

	? Content()
}

/*--------------------

o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3)

/*-------------------

// TODO: fix errors()

? StzListQ([]).IsTextBoxedParamList() # Returns TRUE but should return FALSE!

// The existant options are :

	aListOfBoxOptions = [
		:Line,
		:AllCorners,
		:Corners,
		:Width,
		:TextAdjustedTo,
		:EachChar,
		:EachWord,
		:Hilighted,
		:HilightedIf,
		:Numbered
	]

? StzStringQ("TEXT1").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr
	# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
	:Width = 17,
	:TextAdjustedTo = :Center, # or :Left or :Right or :Along,
			
	:EachChar = FALSE ,# TRUE,
	:Hilighted = [ 1, 3 ], # Hilight the 1st and 3rd chars,

	:Numbered = TRUE
])

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

? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).OnlyW('StzCharQ(@item).IsArabic()')

/*--------------

? StzListQ([ "a", 1, "b", 2, "c", 3 ]).Types()
? StzListQ([ "a", 1, "b", 2, "c", 3 ]).UniqueTypes()

/*--------------

StzListQ([ "one", "two", "three" ]) {
	ReplaceItemAtPosition(2, :With = "TWO")
	? Content()

	ReplaceAllItems( :With = "***")
	? Content()
}

/*--------------

StzListQ([ "a", 1, "b", 2, "c", 3 ]) {
	ReplaceAllW("*", :Where = '{ isNumber(@item) }')
	? Content()
}

/*--------------

o1 = new stzList([ "a", 1, "b", 2, "c", 3 ])
o1.RemoveAllWhere('NOT isNumber(@item)')
? o1.Content()

/*--------------

obj1 = new Person { name = "salem" age = 34 }
obj2 = new Person { name = "kaù" age = 24 }

o1 = new stzList([ "a", 1, 3, "b", ["A1", "A2"], obj1, "c", 3, ["B1", "B2"], obj2 ])
? o1.OnlyStrings()
? o1.OnlyNumbers()
? o1.OnlyLists()
? o1.OnlyObjects()

class Person name age

/*--------------

StzListQ([ "a", "b", [], "c", [] ]) {
	? Only('{ isString(@item) }')
}

/*--------------

StzListQ([ "a", "b", [], "c", [] ]) {
	ExcludeAllBut('{
		isString(@item)
	}')

	? Content()
}

/*--------------

StzListQ([ "a", "b", [], "c", [] ]) {
	Exclude('{
		isEmptyList(@item)
	}')

	? Content()
}

/*--------------

StzListQ([ 1, "a", "b", 2, 3, "c", 4, [ "..." ] ]) {

	Exclude('{
		isNumber(@item) or
		isString(@item)
	}')

	? Content()
}

/*-------------

person1 = new person { name = "obj1" }
person2 = new person { name = "obj2" }

o1 = new stzList([ "_", 3, "_" , person1, 6, "*", [ "L1", "L1" ], 12, person2, [ "L2", "L2" ], 25, "*" ])

? o1.FindAllWhere('{
	AreEqual([ Item(i+1), "*" ])
}') # --> Gives [ 5, 11]

? o1.FindAllWhere('{
	isNumber(@item) AND isNumber(i+3) AND
	AreEqual([ Item(i+3), DoubleOf(@item) ])
	
}') # --> Gives [ 2, 5 ]

? o1.FindAllWhere('{
	isNumber(@item) AND isNumber(i+3) AND
	(NOT AreEqual([ Item(i+3), DoubleOf(@item) ]))
	
}') # --> Gives [8]

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
? o1.ItemsWhere('{ Q(@item).IsLowercased() }') # --> [ "c", "c++" ]

? o1.FirstItemW('{ Q(@item).IsLowercased() }') # --< "c"
? o1.NthItemW(2, '{ Q(@item).IsLowercased() }') # --> "c++"
? o1.LastItemW('{ Q(@item).IsLowercased() }') # --> "c++"

/*-------------

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
? o1.CountWhere('{ isLower(@item) }')
? o1.NumberOfOcurrenceWhere('{  }')

/*-------------

# Use this piece of code to better visualize a plitted list
# Useful only for testing purposes
# TODO: think of a better show() method to visualize lists!

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
aSplitted = o1.SplitToPartsOfNItemsEach(3)

for i = 1 to len(aSplitted)
	? "-- " + i
	//? type(aSplitted[i])
	? aSplitted[i]
next

/*-------------

? o1.SplitToPartsOfNItemsEach(2)
# [ ["a","b"], ["c","d"] ]


? o1.SplitToPartsOfNItems(2)
# Returns [ ["a","b"], ["c", "d"], ["e"] ]


? o1.SplitAfterPositions([ 3, 5 ])

? o1.SplitBeforePositions([ 1, 5 ])
# Returns [ ["a","b"], ["c", "d"], ["e"] ]

/*-------------

o1 = new stzList("A":"J")

? o1.SplitBeforePositions([3,7])
# --> [ [ "A", "B" ], [ "C", "D", "E", "F" ], [ "G", "H", "I", "J" ] ]

/*---------------

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

o1.InsertAfterWhere( '{ StzStringQ(@item).IsLowercase() }', "*" )
? o1.Content()

# Returns [ "a", "*", "b", "*", "C", "D", "e" ]

/*----------------

o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeWhere( '{ StzStringQ(@item).IsLowercase() }', "*" )
? o1.Content()

# Returns [ "*", "a", "*", "b", "C", "D", "*", "e" ]

/*----------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertAfterAtManyPositions([ 2, 4, 5 ], "*")
? o1.Content()
# Returns [ "a", "b", "*", "c", "d", "*", "e" ]

/*---------------

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertBeforeAtManyPositions([ 2, 4, 5 ], "*")
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

o1 = new stzList([ :Direction = :Forward, :CS = TRUE ])
? o1.IsSplitParamList()

/*-----------------

//? ListReverse([ 1, 2, 3 ])

o1 = new stzList([ "tunis", 1:3, 1:3, "gafsa", "tunis", "tunis", 1:3, "gabes", "tunis", "regueb", "regueb" ])
//o1.ReverseItems() # Note: Softanza does not use Reverse() because it is reserved by Ring
//? o1.Content()
//? o1.NumberOfDuplicates("tunis")
? o1.Duplicates()

? o1.DuplicatedItems() # TODO: CaseSensitive! in stzListOfStrings + Objects are not covered!
? o1.DuplicatesOfItem(1:3)

//? o1.DuplicatedItemsAndTheirDuplicates()
//? o1.RemoveDuplicatesQ().Content()
//? o1.DuplicatesRemoved()

/*---------------------

o1 = new stzList([ "poetry", "music", "theater", "stranger" ])
o1 - [ "poetry", "music" ]
? o1.Content() # --> [ "theater", "stranger" ]

/*---------------------

o1 = new stzList([ "poetry", "music", "theater", "stranger" ])
o1 - [[ :LastItemIf, :EqualTo, "stranger" ]]
? o1.Content() # --> [ "poetry", "music", "theater" ]
                                              
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
? o1.WalkUntil("Item = :Milk")
? o1.WalkUntil("Item = ' '")

/*---------------------- TODO: refactored: reveiw it after completing stzWalker

StzListQ( "A":"J" ) {
	AddWalker( Named(:Walker1), StartingAt(1), EndingAt(10), NStep(1) )
	? WalkedItems( :By = :Walker1 )
	? WalkerPositions( :By = :Walker1 )
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
	? Yield( '{ type(item) }', WhileWalking(:Walker1) )
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

// Removing the first item if it is equal to :Water
o1 - [[ :FirstItemIf, :EqualTo, :Water ]]

// Remove the last item if it is equal to :Tea
// And showing the final content of the list
? (o1 - [[ :LastItemIf, :EqualTo, :Sugar ]]).Content()

? o1.IsStrictlyEqualTo([ :water, :coca, :milk, :spice, :cofee, :tea, :honey ])

/*---------------------

o1 = stzListQ([ :water, :coca, :milk, :spice, :cofee, :tea, :honey ])
? o1.DistributeOver([ :arem, :mohsen, :hamma ], :Using = [ 2, 3, 2 ] )
		# Gives [ :arem   = [ :water, :coca ],
		# 	  :mohsen = [ :milk, :spice, :cofee ],
		# 	  :hamma  = [ :tea, honey ]


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

? o1.IncludesOneOfThese(["red", "t", "cv"])

// Checking inclusion (all these return TRUE)
? o1.IsIncludedIn([ "green", "red", "blue", "magenta", "gray" ])

? o1.Includes([ "red", "blue" ])

? o1.IncludesOneOfThese([ "yelloW", "GREEN", "magenta" ])
? o1.IncludesNoOneOfThese([ "yellow", "magenta", "gray" ]) + NL

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

o1 = new stzList(1:3)
? o1.ExtendWithOtherListAt(4:6,2)

/*--------------------------

o1 = new stzList([ 1, 1, 1 ])
? o1.AllItemsAreEqualTo(1)

/*--------------------------

o1 = new stzList("a":"t")
? o1.Contains("x")
