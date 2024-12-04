load "../max/stzmax.ring"

#TODO Add Check() Yield() Perform()

/*-------------------

pron()

o1 = new stzList([ "A1", "A2", "A3", "A4", "A5", "A6", "A7" ])
? o1.NextNthItem(3, :StartingAt = 4)
#--> "A6"

? o1.PreviousNthItem(4, :StartingAt = 7)
#--> "A4"

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-------------------

pron()

? Q(1:10).ManyRemoved([ 3, 7, 9 ])
#--> [ 1, 2, 4, 5, 6, 8, 10 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*====

pron()

o1 = new stzList([ "me", "you", "all", "the", "others" ])
? o1.ContainsEither("me", :or = "you")
#--> FALSE

o1 = new stzlist([ "me", "and", "all", "the", "others" ])
? o1.ContainsEither("me", :or = "you")
#--> TRUE

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

/*----

pron()

o1 = new stzList([ "me", "you", "all", "the", "others" ])
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE
	
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> FALSE

o1 = new stzlist([ "me", "and", "all", "the", "others" ])
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*======

pron()

o1 = new stzList([ "ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "zai" ])
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji", "zai" ], :By = [ "♥", "♥♥" ])

? @@( o1.Content() )
# ♥ qt ♥♥ pyhton ♥ csharp ♥♥
#--> [ "♥", "qt", "♥♥", "pyhton", "♥", "csharp", "♥♥" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-----

pron()

o1 = new stzList([
	"ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "ring", "kandaji" ])

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "qt", "♥♥", "pyhton", "♥♥♥", "csharp", "♥", "♥♥♥" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

#====

pron()

? SectionToRange(3, 7)
#--> [ 3, 5 ]

? RangeToSection(3, 5)
#--> [ 3, 7 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*========= Stringifying the items of a list

pron()

o1 = new stzList([ 120, "abc", 1:3 ])
o1.Stringify()
? o1.Content()
#--> [ "120", "abc", "[ 1, 2, 3 ]" ]

proff()

/*-------- QStringifying the items of a list

pron()

# QStringifying a list : All items are forced to become QString objects
o1 = new stzList([ 120, "abc", 1:3 ])
aQStrings = o1.QStringified()
#--> A list containing 3 QString objects
# 	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]

? aQStrings[1].mid(0, 3)
#--> "120"

? aQStrings[2].mid(0, 3)
#--> [ 1, 2, 3 ]

? aQStrings[3].mid(0, 11)
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.02 second(s)

/*====== @perf

pron()

# Constructing a large deep list of 1 million items
# Items are of all types : numbers, strings, lists and objects
# Some items are deep up to 3 levels (a list in list in list!)

aLarge = 1 : 300_000

aList = [ "A" : "Z", [ 10 : 12, [ "_", "_"] ], [ NullObject(), TrueObject() ] ]
for j = 1 to 20_000
	for i = 1 to len(aList)
		aLarge + aList[i]
	next
next

for i = 100_001 to 140_000
	aLarge + i
next

? len( Flatten(aLarge) )
#--> 1_000_000

# The code above is 9X times more performant in Ring 1.21 then Ring 1.17

? SpeedUpX(34.33, 3.81)
#--> 9.01

proff()
# Executed in 3.81 second(s) in Ring 1.21 (64 bits)
# Executed in  5.75 second(s) in Ring 1.19 (64 bits)
# Executed in  6.55 second(s) in Ring 1.19 (32 bits)
# Executed in 16.13 second(s) in Ring 1.18
# Executed in 34.33 second(s) in Ring 1.17

/*--------- @perf

pron()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Association() function directly
# is better (4X) than using it through a stzListOfLists object

Association([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 3.41 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Associated()
# Executed in 11.12 second(s)

proff()
# Executed in 11.80 second(s)

/*-------- @perf

pron()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Merge() function directly
# can be better than using it through a stzListOfLists object

Merge([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 1.19 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Merged()
# Executed in 1.93 second(s)

proff()
# Executed in 3.15 second(s)

/*=====

pron()

? @@( Association([ "A":"C", 1:3, "a":"c" ]) )
#--> [ [ "A", 1, "a" ], [ "B", 2, "b" ], [ "C", 3, "c" ] ]

proff()
# Executed in 0.03 second(s)

/*===== #narration: everything is findable

pron()

# A stzString object can be created in one of three ways

# 1. From a normal Ring string

	o1 = new stzString("hello")
	? o1.Uppercased()
	#--> HELLO

# 2. From a QString object

	o2 = new stzString( @ToQString("hello") )
	? o2.Uppercased()
	#--> HELLO

# 3. From a pair of strings, the first beeing the name of the object
#    (it's a NAMED OBJECT then, made specifically to making objects findable!),
#    and the second beeing the value of the string:

	o3 = new stzString( :o3 = "hello" )
	? o3.Uppercased()
	#--> HELLO

# You want to see how NAMED OBJECTS can be findable? Ok.
# Let's consider the following list :

aMyList = [ "Hi", o1, "how", 1:3, o2, "are", o3, "you?", 1:3, o3, 99 ]

# In Ring, you can find the string "how" like this:

? find(aMyList, "how") # or ring_find() if you want
#--> 3

# And find the number 99 like this:
? find(aMyList, 99)
#--> 11

# But you can't find a list:

	//? find(aMyList, 1:3)
	#--> ERROR: Bad parameter type!

# Nor an object:

	//? find(aMyList, o1)
	#--> ERROR: Bad parameter type!

# In Softanza, you can find numbers and strings as usual, but also you
# can find a list, any list, and an object if this object is created as
# a Softanza NAMED object (like o3 above)...

# Let's check, first, how a list can be found inside a list:

	? Q(aMyList).Find(1:3) # Reminder : Q() elevates aMyList to a stzList object
	#--> [ 4, 9 ]

# Now let's find the o3 named object:

	? o3.IsNamedObject()
	#--> TRUE

	? Q(aMyList).Find(o3)
	#--> [ 7, 10 ]

# Of course, Softanza can't find an object if it is not named!

	? o2.IsNamedObject()
	#--> FALSE
	
	//? Q(aMyList).Find(o2)
	#--> ERROR: Line 689 Can't find an unnamed object!

proff()
# Executed in 0.03 second(s)

/*====

pron()

? Q(1:7) - These(3:5) # Or AllThese() or EachIn()
#--> [ 1, 2, 6, 7 ]

? Q(1:7) - These(3:5)
#--> [ 1, 2, 6, 7 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*====

pron()

StzListQ([ "1":"3", "2":"7", "10":"12" ]) {
	Flatten()
	Sort()

	Show() + NL
	#--> [ "1", "10", "2", "2", "3", "3", "4", "5", "6", "7" ]

	? @@( FindItems() ) + NL # Or ItemsAndTheirPositions() or ItemsZ()
	#-->[
	# 	[ "1", [ 1 ] ], [ "10", [ 2 ] ], [ "2", [ 3, 4 ] ],
	# 	[ "3", [ 5, 6 ] ], [ "4", [ 7 ] ], [ "5", [ 8 ] ],
	# 	[ "6", [ 9 ] ], [ "7", [ 10 ] ]
	# ]

	? @@( NumberOfOccurrenceOfEachItem() ) # Or ItemsCount()
	#-->[
	# 	[ "1", 1 ], [ "10", 1 ], [ "2", 2 ],
	# 	[ "3", 2 ], [ "4", 1 ], [ "5", 1 ],
	# 	[ "6", 1 ], [ "7", 1 ]
	# ]
}

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*====

pron()

o1 = new stzList([ "1", "A", "B", "A", "A", "C", "B", 1 ])
? @@( o1.Withoutduplication() ) + NL
#--> [ "1", "A", "B", "C", 1 ]


? @@( o1.FindItems() ) + NL # Or ItemsZ()
#--> [
#	[ "1", [ 1 ] ],
#	[ "A", [ 2, 4, 5 ] ],
#	[ "B", [ 3, 7 ] ],
#	[ "C", [ 6 ] ],
#	[   1, [ 8 ] ]
# ]

? @@( o1.ItemsCount() )
#--> [ [ "1", 1 ], [ "A", 3 ], [ "B", 2 ], [ "C", 1 ], [ 1, 1 ] ]

proff()
# Executed in 0.04 second(s)

/*====

pron()

? Intersection([ 1:3, 2:7, 2:3 ])
#--> [ 2, 3 ]

proff()
# Executed in 0.05 second(s)

/*===

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 3 ] ],
#	[ "B", [ 2, 6 ] ],
#	[ "C", [ 4 ] ],
#	[ "D", [ 5 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*---

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? @@( o1.IndexCS(FALSE) )
#--> [
#	[ "a", [ 1, 3 ] ],
#	[ "b", [ 2, 6, 7 ] ],
#	[ "c", [ 4 ] ],
#	[ "d", [ 5 ] ]
# ]

#NOTE: When casesitivity is used, all items are turned to lowercase in the output

proff()
# Executed in 0.03 second(s)

/*----

pron()

o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 2, 3 ] ],
#	[ "B", [ 1, 2, 3 ] ],
#	[ "C", [ 1, 3 ] ]
# ]

proff()
#--> Executed in 0.10 second(s)

/*=====

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? o1.ItemsOccuringNTimesCS(3, FALSE) #NOTE this is a misspelled form (one r instead of 2)
#--> [ "b" ]

proff()

/*===

pron()

o1 = new stzList([ "A", "A", "B", "C", "A", "C" ])
? o1.ItemsOccurringNTimes(2)
#--> [ "A", "C" ]

? o1.ItemsOccurringExactlyNTimes(2)
#--> [ "C" ]

? o1.ItemsOccurringLessThanNTimes(3)
#--> [ "B", "C" ]

? o1.ItemsOccurringNTimesOrLess(3)
#--> [ "A", "B", "C" ]

? o1.ItemsOccurringNTimesOrMore(3)
#--> [ "A" ]

proff()

/*---

pron()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? o1.ItemsOccuringNTimesCS(3, FALSE) #NOTE this is a misspelled form (one r instead of 2)
#--> [ "b" ]

proff()

/*==

pron()

o1 = new stzList([ "_", "_", "3", "4", "5", "6", "7", "_", "_" ])

o1.ReplaceAtByManyXT(3:5, [ "-3", "-4", "-5" ])
? @@( o1.Content() )
#--> [ "_", "_", "-3", "-4", "-5", "6", "7", "_", "_" ]

proff()
# Executed in 0.07 second(s)

/*==

pron()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", 7, 8, "C", "D", 11, 12, 13 ])
? @@( o1.FindNumbersAsSections() )
#--> [ [ 1, 4 ], [ 7, 8 ], [ 11, 13 ] ]

proff()

/*---

pron()

o1 = new stzList([
	1, 2, 3,
	"A", "B", "C",
	7, 8,
	1:3, 4:8, 9:12,
	"D", "E",
	4:8,
	11, 12,
	NullObject(),
	TrueObject(),
	FalseObject()
])

? @@( o1.FindNumbersAsSections() ) # or FindNumbersZZ()
#--> [ [ 1, 3 ], [ 7, 8 ], [ 15, 16 ] ]

? @@( o1.FindStringsZZ() )
#--> [ [ 4, 6 ], [ 12, 13 ] ]

? @@( o1.FindListsZZ() )
#--> [ [ 9, 11 ], [ 14, 14 ] ]

? @@( o1.FindObjectsZZ() )
#--> [ [ 17, 19 ] ]

proff()
# Executed in 0.02 second(s)

/*---

pron()

o1 = new stzList([
	1, 2, 3,
	"A", "B", "C",
	7, 8,
	1:3, 4:8, 9:12,
	"D", "E",
	4:8,
	11, 12,
	NullObject(),
	TrueObject(),
	FalseObject()
])

? o1.TypesU()
#--> [ "NUMBER", "STRING", "LIST", "OBJECT" ]

? @@XT( o1.ItemsAndTheirTypes(), NL, ("#" + TAB) ) + NL
#--> [
#	[ 1, "NUMBER" ],
#	[ 2, "NUMBER" ],
#	[ 3, "NUMBER" ],
#	[ "A", "STRING" ],
#	[ "B", "STRING" ],
#	[ "C", "STRING" ],
#	[ 7, "NUMBER" ],
#	[ 8, "NUMBER" ],
#	[ [ 1, 2, 3 ], "LIST" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ [ 9, 10, 11, 12 ], "LIST" ],
#	[ "D", "STRING" ],
#	[ "E", "STRING" ],
#	[ [ 4, 5, 6, 7, 8 ], "LIST" ],
#	[ 11, "NUMBER" ],
#	[ 12, "NUMBER" ],
#	[ @nullobject, "OBJECT" ],
#	[ @trueobject, "OBJECT" ],
#	[ @falseobject, "OBJECT" ]
# ]

? @@NL( o1.TypesAndTheirSections() ) # same as TypesZZ()
#--> [
#	[ "NUMBER", [ [ 1, 3 ], [ 7, 8 ], [ 15, 16 ] ] ],
#	[ "STRING", [ [ 4, 6 ], [ 12, 13 ] ] ],
#	[ "LIST", [ [ 9, 11 ], [ 14, 14 ] ] ],
#	[ "NUMBER", [ [ 17, 19 ] ] ]
# ]

proff()
# Executed in 0.02 second(s)

/*===== #narration: activating and deactivating CheckParams()

pron()

# This narration shows how deactivating checking params could enhance
# performance. By default, the feature is on, and depending on the
# function you are using, more or less params semantics are checked.
	
# So, in the case:
	
	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , :By = "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]
	
	# The execution takes about 0.18 seconds (on my machine)

	? ElapsedTime()
	# Executed in 0.18 second(s)

# But if you disable params checking and restartd the same code:

	CheckParamsOff()

	# And repeat the same job

	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]

	# It would take half of the time!

proff()
# Executed in 0.09 second(s)

/*======= #narration

pron()

# The fellowing two code snippets illustrate the use of two similar functions.
# Try to read the code, see the output and identify the difference between them...

# First snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])
	
? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]
	
# Second snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 1, 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "♥", "php", "♥♥", "ruby", "♥", "python", "♥♥", "csharp", "♥" ]

# Read how Google Bard answered the question:
# Link: https://bard.google.com/share/fb5fb52af8de

proff()
# Executed in 0.03 second(s)

/*==== Find and AntiFind in stzList

pron()

o1 = new stzList([ "1", "2", "♥", "4", "5", "♥", "6", "7", "♥", "9" ])

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

proff()
# Executed in 0.03 second(s)

/*---- Find and AntiFind in stzString

pron()

o1 = new stzString("12♥45♥67♥9")

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

? @@( o1.AntiFindZZ("♥") )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

proff()

/*======

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

proff()
# Executed in 0.04 second(s)

/*------

pron()

o1 = new stzList([ "♥", 2, "♥", "♥", 5, "♥" ])
o1.ReplaceByMany("♥", [ 1, 3, 4, 6 ])
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.04 second(s)

/*=====

pron()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceAnyItemsAtPositions([ 1, 3, 4, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "♥♥♥", "softanza" ]

proff()
# Executed in 0.07 second(s)

/*===

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

proff()
#--> Executed in 0.03 second(s)

/*-------

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

proff()
#--> Executed in 0.02 second(s)

/*---

pron()

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByMany([ 3, 5, 7], "ring", [ "♥", "♥♥", "♥♥♥" ])
# Or you can say: o1.ReplaceItemAtPositions([ 3, 5, 7], "ring", :ByMany = [ "♥", "♥♥", "♥♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥", "csharp", "ring" ]

proff()
#--> Executed in 0.02 second(s)

/*------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥", "♥♥♥" ] )

? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥♥♥", "php", "softanza", "♥", "softanza" ]

proff()
# Executed in 0.03 second(s)

/*=======

pron()

o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
o1.ReplaceTheseItemsAtPositionsByMany([ 1, 3, 4, 6 ], [ "ring", "softanza" ] , [ "♥", "♥♥" ])
		
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥", "♥♥", "php", "♥♥" ]

proff()
# Executed in 0.06 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceItemAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	"ring" , [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#--> [ "♥", "ruby", "softanza", "♥♥", "♥", "php", "softanza", "♥♥", "softanza" ]
#	^                        ^    ^                        ^

proff()
# Executed in 0.04 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza",
	"ring", "ring", "php",
	"softanza", "ring", "softanza"
])

o1.ReplaceTheseItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8, 9 ],
	[ "ring", "softanza" ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#       1    2       3     4    5     6      7    8     9
#--> [ "♥", "ruby", "♥", "♥♥", "♥", "php", "♥♥", "♥♥", "♥" ]
#	^                  ^    ^                 ^
#                    ^                       ^          ^

proff()
# Executed in 0.06 second(s)

/*-------

pron()

o1 = new stzList([
	"ring", "ruby", "softanza", "ring", "softanza", "php", "softanza", "ring", "python"
])

o1.ReplaceAnyItemsAtPositionsByManyXT( [ 1, 3, 4, 5, 7, 8 ], [ "♥", "♥♥" ] )
				
? @@( o1.Content() )
#--> [ "♥", "ruby", "♥♥", "♥", "♥♥", "php", "♥", "♥♥", "python" ]

proff()
# Executed in 0.03 second(s)

/*=======

pron()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceAnyItemAtPositions([ 1, 5 ], :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

proff()
# Executed in 0.06 second(s)

/*---------

pron()

//CheckParamOff()

o1 = new stzList([ "ring", "ruby", "ring", "php", "ring" ])
o1.ReplaceThisItemAtPositions([ 1, 5 ], "ring", :By = "♥♥♥")

? o1.Content()
#--> [ "♥♥♥", "ruby", "ring", "php", "♥♥♥" ]

proff()
# Executed in 0.16 second(s)
#NOTE : turn CheckParamsOff() to get 0.03

/*========

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceAnyItemAt(3, :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*--------

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceThisItemAt(3, "♥", :With = "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replaced. Otherwise, nothing
# will happen. In fact:

o1.ReplaceThisItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*---

pron()

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])

o1.ReplaceThisItemAt(3, "♥", "★")
? @@( o1.Content() )
#--> [ 1, 2, "★", 4, "♥" ]

# Because there is the terme "item" in ReplaceItemAt(), the provided item
# ("♥" in our case) must be in position 3 to be replace. Otherwise, nothing
# will happen. In fact:

o1 = new stzList([ 1, 2, "♥", 4, "♥" ])
o1.ReplaceThisItemAt(2, "BLA", :With = "★" )
? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, "♥" ]

proff()
# Executed in 0.05 second(s)

/*===

pron()

o1 = new stzList([ "a", "+", "b", "-", "c", "/", "d", "=", "0" ])
o1.ReplaceMany( ["+", "-", "/" ], :by = "*" )
? o1.Content()	
#--> [ "a", "*", "b", "*", "c", "*", "d", "=", "0" ]

proff()
#--> Executed in 0.04 second(s)

/*---

pron()
o1 = new stzList([ "ring", "php", "ruby", "ring", "python", "ring" ])
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content()
#--> [ "♥", "php", "ruby", "♥♥", "python", "♥♥♥" ]

proff()
# Executed in 0.03 second(s)

/*---

pron()
o1 = new stzList([ "ring", "ring", "ruby", "ring", "python", "ring" ])
o1.ReplaceItemByManyXT("ring", [ "♥", "♥♥" ])
	
? @@( o1.Content() )
#--> [ "♥", "♥♥", "ruby", "♥", "python", "♥♥" ]

proff()
# Executed in 0.02 second(s)

/*====

pron()

o1 = new stzList([ 1, :♥, 3, 4, :♥, :♥ ])
anPos = o1.Find(:♥)
#--> [ 2, 5, 6 ]

o1.ReplaceByMany(:♥, [2, 5, 6])
? o1.Content()

#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.04 second(s)

/*===

pron()

o1 = new stzList([ "1", "♥", "♥", "4", "5", "6", "♥", "♥", "9" ])

anPos = o1.Find("♥")
#--> [ 2, 3, 7, 8 ]

o1.ReplaceAnyItemsAtPositions( o1.Find("♥"), :By = "★" )
? @@( o1.Content() )
#--> [ "1", "★", "★", "4", "5", "6", "★", "★", "9" ]

proff()
# Executed in 0.06 second(s)

/*===

pron()

o1 = new stzList( Q("1♥♥456♥♥901♥♥4").Chars() )

o1 {

	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 7, 8, 12, 13 ]

	# Doing someting with the positions

	ReplaceAnyItemsAtPositions(anPos, :With = "★")
		? Content()
		#--> [ "1","★","★","4","5","6","★","★","9","0","1","★","★","4" ]
	
}

proff()
# Executed in 0.06 second(s)

/*===

pron()

? L('8:5')
#--> [ 8, 7, 6, 5 ]

proff()
# Executed in 0.17 second(s)

/*----------------- #narration : Use of the L() small function

pron()

# As we all know, Ring provides us with this elegant syntax:

? "A" : "D"
#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# Hence, if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? aList
#o--> "ا"

# Fortunately, Softanza solves this by the L() small function:

? L( ' "ا" : "ج" ')
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? L(' "A" : "D" ')
#--> [ "A", "B", "C", "D" ]

# Interestingly, you can get any list of a numbered string:

? L(' "♥1" : "♥5" ')
#--> [ "♥1", "♥2", "♥3", "♥4", "♥5" ]

# Or maybe:

? L(' "Ring1" : "Ring3" ')
#--> [ "Ring1", "Ring2", "Ring3" ]

# This works also for any unicode string (here in arabic):

? L(' "كلمة1" : "كلمة3" ')
#o--> [ "كلمة3", "كلمة2", "كلمة1" ]

# On the other hand, as you kow, the _:_ syntax in Ring
# works also for numbers, like this:

? 1:5
#--> [ 1, 5 ]

# But it suports only integers and not real numbers (with decimals):

? 1.02 : 3.08
#--> [ 1, 2, 3 ]

# While in Softanza, using the magic of L() function, you can enumarate
# all the real numbers inbetween, what ever decimal part they have:

? L(' 1.02 : 1.05 ')
#--> [ 1.02, 1.03, 1.04, 1.05 ]
 
# Finally, if the string you feed to L() function contains a list written
# in Ring form, than the function will evaluate it and return it:

? L('[ 1, 2, 3 ]')
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.24 second(s) in Ring 1.20
# Executed in 0.60 second(s) in Ring 1.17

/*---

pron()

? Q("2.8").IsRealInString()
#--> TRUE

? Q("3.2").IsRealInString()
#--> TRUE

? BothAreRealsInStrings("2.8", "3.2")
#--> TRUE

proff()

/*----

pron()

? 1 : 3
#--> [ 1, 2, 3 ]

? 2.8 : 3.2
#--> [ 2, 3 ]

? L('2.8 : 3.2')
#--> [ 2.80, 2.90, 3, 3.10, 3.20 ]

? L('0.07 : 0.10')
#--> [ 0.07, 0.08, 0.09, 0.10 ]

? L(' -3.25 : -3.2 ')
#--> [ -3.25, -3.24, -3.23, -3.22, -3.21, -3.20 ]

? L(' "v1" : "v3" ')
#--> [ "v1", "v2", "v3" ]

? L(' "♥1" : "♥5" ')
#--> [ "♥1", "♥2", "♥3", "♥4", "♥5" ]

? L(' "A" : "E" ')
#--> [ "A", "B", "C", "D", "E" ]

ShowShort( L(' "ج" : "ه" ') )
#o--> [ "ج", "ح", "خ", "...", "م", "ن", "ه" ]

? L(' "كلمة1" : "كلمة3" ')
#o--> [ "كلمة3", "كلمة2", "كلمة1" ]

proff()
# Executed in 0.65 second(s)

/*=============

pron()

? Q(1:3).IsNeither(5:8, :Nor = 10:12)
#--> TRUE

? Q(1:3).IsNeither(2:4, :Nor = 1:3)
#--> FALSE

#--

? Q("Ring").IsNeither("Python", :Nor = "Ruby")
#--> TRUE

? Q("Ring").IsNeither("Python", :Nor = "Ring")
#--> FALSE

#--

? Q(5).IsNeither( 5 + 2, :Nor = 5 - 2 )
#--> TRUE

? Q(5).IsNeither( 5, :Nor = 15 )
#--> FALSE

#--

? Q("str").IsNeither( :ANumber, :Nor = :List )
#--> TRUE

? Q(12).IsNeither( :List, :Nor = :Object )

proff()
# Executed in 0.12 second(s)

/*=============

pron()

? Q([ "by", [ "2", "5", "6" ] ]).IsByNamedParam()
#--> TRUE

proff()
#--> Executed in 0.03 second(s)

/*=============

pron()

o1 = new stzList([ ["03", "04"], 3, ["01","02"], 1, "Two", 2, "One" ])
? @@( o1.Sorted() ) # Or o1.SortedInAscending()
#--> [ 1, 2, 3, "One", "Two", [ "01", "02" ], [ "03", "04" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "03", "04" ], [ "01", "02" ], "Two", "One", 3, 2, 1 ]

proff()
# Executed in 0.06 second(s)


/*===========

pron()

o1 = new stzList([ "🔻", "🔻", "1", "2", "3", "🔻", "🔻" ])
o1.RemoveAnyItemFromStart("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3", "🔻", "🔻" ]

o1.RemoveAnyItemFromEnd("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3" ]

proff()
# Executed in 0.01 second(s)

/*--------------- TODO: fix error

pron()

new stzChar("🔻")
#--> ERR: Can not create char object!

proff()

/*---------------

pron()

o1 = new stzString("♥♥♥123♥♥♥")

o1.RemoveAnyCharFromLeft("♥")
? o1.Content()
#--> 123♥♥♥

o1.RemoveAnyCharFromRight("♥")
? o1.Content()
#--> 123

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

o1 = new stzString(" ♥♥♥123♥♥♥   ")
o1.Trim()
? o1.Content()
#--> "♥♥♥123♥♥♥"

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzString("♥♥♥123♥♥♥")
o1.TrimChar("♥")
? o1.Content()
#--> "123"

proff()
# Executed in 0.03 second(s)

/*================= UNDERSTANDING THE ..ed() and ..Q() FUNCTION FORMS

pron()
# In softanza the ..ed() form returns the expected result
# from the function without altering the object content:

o1 = new stzList(L(' "♥1" : "♥3" '))
? @@( o1.ItemsReversed() )
#--> Returns [ "♥3", "♥2", "♥1" ]
# But the object content itself is left as-is:
? @@( o1.Content() )
#--> [ "♥1", "♥2", "♥3" ]

# Using the function directly (without ..ed()) will definetly alter
# the object content, without returning anything:
o1.Reverse() # The items are reversed but nothing is returned
# Let's see the object content:
? @@( o1.Content() )
#--> [ "♥3", "♥2", "♥1" ]

# If you want to alter the object and then return it to continue
# working on it, then use the ...Q() form like this:
o1 = new stzList(L(' "♥1" : "♥3" '))
? o1.ReverseQ().ToStzListOfStrings().ConcatenatedUsing("~")
# returns a string containing "♥3~♥2~♥1"

#--> Initially the object contained [ "♥1", "♥2", "♥3" ]. It's then
# reversed and became [ "♥1", "♥2", "♥3" ]. Finally, the stzList object
# is transformed to a stzListOfStrings object so it can be concatenated
# and returned as a string containing "♥3~♥2~♥1".

proff()
# Executed in 0.94 second(s)

/*-----------------------

pron()

o1 = new stzList(1:3)
? o1.Reversed()
#--> [ 3, 2, 1 ]

proff()
# Executed in 0.03 second(s)

/*============ REVRSING ITEMS IN PAIRS AND, MORE GENERALLY, IN LISTS

# The same code you write for reversing items inside a list of pairs:

o1 = new stzListOfPairs([ [ "A1", "A2" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInPairs()
? @@( o1.Content() )
#--> [ [ "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# will work for reversing items in any list of lists:

o1 = new stzListOfLists([ [ "A1", "A2", "A3" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInLists()
? @@( o1.Content() )
#--> [ [ "A3", "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# This is a not a casual, but general feature you will find anywhere
# in Softanza: you go from specific to more general, or from general to more
# specific using nearly the same code and the same semantics.

# PS: CONSISTENCY is one of the 7 design goals of SoftanzaLib.

/*==========

pron()

? Q(1:7) - 4:7
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

? Q(1:7) - These(4:7)
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.06 second(s) in Ring 1.19 (64 bits)
# Executed in 0.05 second(s) in Ring 1.19 (32 bits)
# Executed in 0.04 second(s) in Ring 1.17

/*==========

pron()

o1 = new stzList([ Q("one"), Q(1), Q("two"), Q(2), Q("three"), Q(3), Q(1:2), NullObject() ])

? @@( o1.FindStzNumbers() )
#--> [ 2, 4, 6 ]

? @@( o1.FindStzStrings() )
#--> [ 1, 3, 5 ]

? @@( o1.FindStzLists() )
#--> [ 7 ]

? @@( o1.FindStzObjects() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

proff()

/*==========

pron()

StzNamedListQ(:langs = [ :Ring, :Ruby, :Python ]) {

	? Name()
	#--> :myage

	? Content()
	#--> [ :Ring, :Ruby, :Pyhton ]

	? StzType()
	#--> :stzlist

}

proff()
# Executed in 0.03 second(s)

/*========== A Softanza narration about one of the many uses of @

pron()

# In softanza there some useful functions that you can use from
# every where, because they are defined at the global level (you
# will find them either in stzGlobal.Ring or in each class file).

# For example, if you want to check if a list contains two numbers,
# you can say :

? BothAreNumbers(5, -12)
#--> TRUE

# When it makes sense, those functions are also provided as
# methods in a given class. So, BothAreNumbers() can also be
# used inside a list to check that it contains two numbers,
# like this:

? Q([ 5, -12 ]).BothAreNumbers() # Q() elevates the list to a stzList object
#--> TRUE

#NOTE that the name of the function stays the same, but its signature
# is different. In fact, they are two different things: the first one
# (with the two numbers as parameters) is defined at the global scope,
# and the second one (the method with the same name but without any
# parameter) is defined at the object scope, a stzList in this case.

# So, when you call it inside the object, Ring will execute the one
# without parameters and ignores the one with parameters located
# at the global scope.

# Now, what happens, if you need to call the gloabl function inside
# the object, like this:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? BothAreNumbers(9, -9)	# This will raise an error!
	#--> ERROR: Calling function with extra number of parameters!
}

# You may solve this by creating an other stzList object
# for the [9, -9] list and call the function on it, like this:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? Q([ 9, -9 ]).BothAreNumbers()	# This will work! Creates an other stzList object
	#--> TRUE
}

# This is correct! But Softanza wants to avoid mental distruption (the
# fact of thinking of an other object that you need to create inside
# the object you are focusing on!), and provides you with a simple
# and quick solution by the use of the @ wildcard:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? @BothAreNumbers(9,-9)	# works, without beaking your train of thoughts!
				# by calling an alternative name of the global function
	#--> TRUE
}

# GENRAL RULE: Every time you have a global function in Softanza that is also
# available for a given object, and you need to call it from inside that
# object, prefix its name with a @, and it will work.

proff()
# Executed in 0.06 second(s)

/*==========

pron()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])

o1.ReplaceOccurrencesByMany([ 3, 5, 6 ], ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

proff()
# Executed in 0.06 second(s)

/*-------------

pron()

o1 = new stzList([ "A", "B", "*", "*", "*",  "*" ])

o1.ReplaceOccurrencesByManyXT([ 3, 4, 5, 6 ], [ "#1", "#2" ])

? @@( o1.Content() )
#--> [ "A", "B", "#1", "#2", "#1", "#2" ]

proff()
# Executed in 0.07 second(s)

/*-------------

pron()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])
o1.ReplaceManyByMany([ "*", "=" ], :With = ["C", "E", "F"])
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

o1 = new stzList([ "A", "B", "3", "D", "5",  "6" ])
o1.ReplaceManyByMany([ "3", "5", "6"], :With = ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

proff()
# Executed in 0.06 second(s)

/*----------

pron()

o1 = new stzList([ "A", "B", "*", "_", "-",  "/" ])
o1.ReplaceManyByManyXT([ "*", "_", "-",  "/" ], :With = ["A", "B"])

? @@( o1.Content() )
#--> [ "A", "B", "A", "B", "A", "B" ]

proff()
# Executed in 0.11 second(s)

/*---------

pron()

StzListQ([ "#1", "#2", "*", "*", "*" ]) {
	ReplaceManyByManyXT(["*"], [ "#1", "#2" ])
	? @@( Content() )

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

proff()
# Executed in 0.07 second(s)

/*---------

pron()

StzListQ([ "#1", "#2", "*", "_", "/" ]) {
	ReplaceManyByManyXT(["*", "_", "/"], [ "#1", "#2" ])
	? @@( Content() )

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

proff()
# Executed in 0.07 second(s)

/*---------

pron()

StzListQ([ "A", "A", "A", "A", "A" ]) {
	ReplaceManyByManyXT(["A"], [ "#1", "#2" ])
	? Content()

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

proff()

/*=========

pron()

o1 = new stzList([ "♥", 1, 2, 2, "♥", "♥", 3 ])
o1.RemoveAllExcept("♥") # Or RemoveItemsOtherThan()

? @@( o1.Content() )
#--> [ "♥", "♥", "♥" ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

o1 = new stzList([ "♥", 1, 2, 2, "★", 3, "🌞" ])
o1.RemoveAllExcept([ "♥", "★", "🌞" ]) # Or RemoveItemsOtherThan()

? @@( o1.Content() )
#--> [ "♥", "★", "🌞" ]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

? U([ "♥", 1, 2, 2, "♥", "♥", 3 ]) # Or Unique() or WithoutDuplicates()
#--> [ "♥", 1, 2, 3 ]

proff()
# Executed in 0.01 second(s)

/*----------

pron()

o1 = new stzList([ "♥", "A", "B", "C", "♥" ])
? o1.FindAllExcept([ "A", "B", "C" ]) # Or FindItemsOtherThan()
#--> [1, 5]

proff()
# Executed in 0.04 second(s)

/*----------

pron()

? Q([ [], [] ]).AllItemsAreEmptyLists()
#--> TRUE

? @@( Association([ [], [] ]) )
#--> Error: Can't associate empty lists!

proff()


/*===========

pron()

o1 = new stzList("A" : "E")
? o1.ItemsAtPositions([2, 3])
#--> [ "B", "C" ]

proff()
#--> Executed in 0.03 second(s)

/*===========

pron()

aLargeList = []
for i = 1 to 1_000
	aLargeList + "R_ING"
next

o1 = new stzList(aLargeList)
o1.StringifyLowercaseAndReplace("_", "♥")

? o1.FirstNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

? o1.LastNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

proff()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.10 second(s) in Ring 1.19 (64 bits)
# Executed in 0.09 second(s) in Ring 1.19 (32 bits)
# Executed in 0.12 second(s) in Ring 1.17

/*-------------

pron()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplaceXT("_", "♥") # Used by internal staff in Softanza
? @@( o1.Content() )
#--> [
#	[ "--♥--", "[ 12, "--♥--", 10 ]", "--♥--", "9" ],
#	[ 1, 3 ],
#	[ ]
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
# Executed in 0.04 second(s) in Ring 1.19 (32 bits)
# Executed in 0.04 second(s) in Ring 1.18
# Executed in 0.03 second(s) in Ring 1.17

/*-------------

pron()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplace("_", "♥")
? @@( o1.Content() )
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9" ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000_000 # test it with 1_000, 10_000, and 100_000 times
	aLargeList + "ring"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "*")
? @@( o1.Content()[2] )
#--> [1, 3]

proff()
# Executed in 20.31 second(s) in Ring 1.22
# Executed in 19.96 second(s) in Ring 1.21


#   SIZE    | Ring 1.17 | Ring 1.18 | Ring 1.19 | Ring 1.19 X64
#-----------+-----------+-----------+-----------+---------------
#     1_000 |   0.08 s  |   0.07 s  |   0.06 s  |   0.07 s
#    10_000 |   0.50 s  |   0.48 s  |   0.25 s  |   0.23 s
#   100_000 |   4.83 s  |   4.58 s  |   2.24 s  |   2.04 s
# 1_000_000 | 114.89 s  | 114.80 s  |  43.73 s  |  38.21 s
#-----------+-----------+-----------+-----------+---------------

/*---------------

pron()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplaceXT("_", :With = AHeart())
o1.Show()
#--> [ [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ], [ 2, 4, 6 ], [ ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.19

/*-------------

pron()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplace("_", :With = AHeart())
o1.Show()
#--> [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000
	aLargeList + "_--_"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplace("_", "♥")

? o1.FirstNItems(5)
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9", "♥--♥" ]

? o1.LastNItems(3)
#--> [ "♥--♥" ], "♥--♥" ], "♥--♥" ]

proff()
# Executed in 0.09 second(s)

/*-------------

pron()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 10_000
	aLargeList + "ring"
next
aLargeList + "--_--" + "--_--"

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "♥")
? o1.Content()[2]
#--> [1, 3, 1005, 1006]

proff()
# Executed in 0.21 second(s) in Ring 1.22
# Executed in 0.50 second(s) in Ring 1.20

/*===============
*/
pron()

o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.Trim()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*--------

pron()

o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.TrimLeft()
o1.TrimRight()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*------------- PERFORMANCE TIP
*/
pron()

#TODO // General note on performance
# For all loops on large data (tens of thousands of times and more)
# don't rely on stzString services, but use Qt directly instead!

oQStr = new QString2()
oQStr.append("I talk in Ring language!")

? oQStr.contains("ring", FALSE)
#--> TRUE

oQStr.replace_2("ring", "RING", FALSE)
? oQStr.mid(0, oQStr.count())
#--> I talk in RING language!

#UPDATE #WARNING
# I discovered some critival issues in Qt replace and contains
# ~> The library has been updated to avoid them and use a
# Ring-based solutuion via @Replace() and @Contains() functions
# To get an idea of the issue, read this discussion on the group:
# link: https://groups.google.com/g/ring-lang/c/BbdsAsylurA

proff()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.20

/*------------- PERFORMANCE TIP

pron()

# ComputableForm() function, abreviated with @@(), is not intended to
# be used inside large loops like this:

aList = ["_", "_", "♥"]

for i = 1 to 100_000
	@@(aList)
next
#--> Takes more then 20 seconds! (in Ring 1.17)
#--> Takes more then 10 seconds! (in Ring 1.19)

# Instead, you shoud do this:

cList = @@(aList)
for i = 1 to 100_000
	cList
next
# Takes only 0.05 seconds!
#--> 400 times more performant.

proff()
# Executed in 21.3657 second(s)

/*-------------

pron()

# In this example, the large list contains +160K items...

	aLargeList = ["_", "_", "♥"]
	for i = 1 to 100_000
		aLargeList + "_"
	next
	
	aLargeList + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeList + "_"
	next i
	
	aLargeList + "♥" + "_" + "_" + "♥"
	

	# ElapseTime: 0.08s

	o1 = new stzList(aLargeList)

	# ElapsedTime: 0.11

	o1.StringifyAndReplace("♥", :With = "*")

	# ElapsedTime: 12.83s

	o1.LastNItems(40_000)
	#--> [ "*", "_", "_", "*" ]

proff()
# Executed in  4.09 second(s) in Ring 1.19 (64 bits)
# Executed in  4.53 second(s) in Ring 1.19 (32 bits)
# Executed in  7.40 second(s) in Ring 1.18
# Executed in 16.62 second(s) in Ring 1.17

/*============== #TODO check it

pron()

? IsChar("🌞")
#!--> FALSE
#~> Should return TRUE!

? StzCharQ("🌞").Content()
#!--> Can not create char object!
#~> Should be able to create it...

proff()

/*=============

pron()

? isNumber([ "'" ])
#--> FALSE

? @@( "🌞" )
#--> "🌞"

? @@([ 1, 2 ])
#--> [ 1, 2 ]

? @@([ '"' ])
#--> [ '"' ]

? @@([ "'" ])
#-->[ "'" ]

? @@([ "1", "🌞", "ring" ])
#--> [ "1", "🌞", "ring" ]

proff()
# Executed in 0.02 second(s)

/*-----

pron()

aList = [ "1", "🌞", "1", [ "2", "♥", "2", "🌞"], "1", [ "2", ["3", "🌞"] ] ]

? Q(aList).ToCode() + NL
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

? @@(aList)
#--> [ "1", "🌞", "1", [ "2", "♥", "2", "🌞" ], "1", [ "2", [ "3", "🌞" ] ] ]

proff()
# Executed in 0.02 second(s)

/*-----

StartProfiler()

o1 = new stzList([ "1", "🌞", "1", [ "2", "♥", "2", "🌞"], "1", [ "2", ["3", "🌞"] ] ])

? o1.DeepContains("🌞")
#--> TRUE

? @@( o1.DeepFind("🌞") )
#--> [ [ 1, 2 ], [ 2, 4 ], [ 3, 2 ] ]
# 🌞 exists in level 1 at position 2, in level 2 at position 4, and in level 3 at position 2.

StopProfiler()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzlist(1:120_000)

? o1.FindNext(3, :StartingAt = 10)
#--> 0

? o1.FindNext(10, :StartingAt = 10)
#--> 0

? o1.FindNext(11, :StartingAt = 10)
#--> 11

? o1.FindNext(100_000, :StartingAt = 70_000)
#--> 100_000

#--

? o1.FindPrevious(10, :StartingAt = 5)
#--> 0

? o1.FindPrevious(10, :StartingAt = 10)
#--> 0

? o1.FindPrevious(7, :StartingAt = 10)
#--> 7

? o1.FindPrevious(110_000, :StartingAt = 112_000)
#--> 110000

proff()
# Executed in 0.61 second(s) in Ring 1.19 (64 bits)
# Executed in 0.67 second(s) in Ring 1.19 (32 bits)
# Executed in 2.06 second(s) in Ring 1.18
# Executed in 2.19 second(s) in Ring 1.17

/*-------------

pron()

o1 = new stzlist(1:120_000)
ShowShort( o1.Stringified() )
#--> [ "1", "2", "3", "...", "119998", "119999", "120000" ]

proff()
# Executed in 0.66 second(s) in Ring 1.19 (64 bits)
# Executed in 1.14 second(s) in Ring 1.17

/*==========

pron()

o1 = new stzList([ 1, 1:5, "hi!", StzNullObjectQ(), [ "a", "b" ] ])

? @@( o1.NListified(3) )
#--> [
#	[ 1, NULL, NULL ],
#	[ 1, 2, 3 ],
#	[ "hi!", NULL, NULL ],
#	[ @noname, NULL, NULL ],
#	[ "a", "b", NULL ]
# ]

proff()
# Executed in 0.05 second(s)

/*------------- SINGLES AND SINGLIFIED

pron()

? Q(['alone']).IsSingle()
#--> TRUE

o1 = new stzList([ 1, ['alone1'], 3, ['alone2'], 5, ['alone2'], 7:9 ])

? o1.ContainsSingles()
#--> TRUE

? @@( o1.FindSingles() )
#--> [ 2, 4, 6 ]

? @@( o1.Singles() )
#--> [ [ "alone1" ], [ "alone2" ], [ "alone2" ] ]

? @@( o1.SinglesU() )
#--> [ [ "alone1" ], [ "alone2" ] ]

? @@( o1.SinglesZ() ) + NL
#--> [
#	[ [ "alone1" ], [ 2 ] ],
#	[ [ "alone2" ], [ 4, 6 ] ]
# ]

? @@( o1.Singlified() )
#--> [ [ 1 ], [ "alone1" ], [ 3 ], [ "alone2" ], [ 5 ], [ "alone2" ], [ 7 ] ]

proff()
# Executed in 0.05 second(s)

/*-------------

pron()

o1 = new stzList([ 1, 2, [ "a", "b" ], 4, [ "c", "d"], [ "a", "b" ] ])
? o1.ContainsPairs()
#--> TRUE

? @@( o1.FindPairs() )
#--> [ 3, 5, 6 ]

? @@( o1.Pairs() )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "a", "b" ] ]

? @@( o1.PairsU() )
#--> [ [ "a", "b" ], [ "c", "d" ] ]

? @@( o1.PairsZ() ) + NL
#--> [
#	[ [ "a", "b" ], [ 3, 6 ] ],
#	[ [ "c", "d" ], [ 5 ] ]
# ]

? @@( o1.Pairified() )
#--> [
#	[ 1, NULL ], [ 2, NULL ], [ "a", "b" ],
#	[ 4, NULL ], [ "c", "d" ], [ "a", "b" ]
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

pron()

? Q([ "a", "♥", "*" ]).ContainsThese([ "♥", "*"])
#--> TRUE

o1 = new stzList([ [ "a", "♥", "*" ], [ "♥", "*"], [ "a", "b", "♥", "*" ] ])
? o1.EachContainsThese([ "♥", "*" ])
#--> TRUE

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-----

pron()

o1 = new stzList([ "ee♥ee", "b♥bbb", "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ ["ee","♥","ee"], ["♥", "bb"], "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ "a♥a" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ 0, "a♥a" ])
? o1.EachContains("♥")
#--> FALSE

proff()
# Executed in 0.04 second(s)

/*-----

pron()

? Unicode("Hi")
#--> [ 72, 105 ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=====

pron()

? IsChar(12.5)
#--> FALSE

? IsChar(-7)
#--> FALSE

? IsChar(14)
#--> FALSE

? IsChar(6)
#--> TRUE

? IsChar("A")
#--> TRUE

? IsChar("م")
#--> TRUE

? IsChar("♥")
#--> TRUE

? IsChar("Hi")
#--> FALSE

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-----

pron()

? Q([ "a", "b", "c" ]).IsListOfChars()
#--> TRUE

? Q([ 1, 2, 3 ]).IsListOfChars()
#--> TRUE

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=====

pron()

? Q(1:3).Unicodes()
#--> [1, 2, 3]

? Unicodes([2, 3])
#--> [2, 3]

? Unicodes([ "a", "b", "c" ])
#--> [97, 98, 99]

? @@( Unicodes([ "How", "are", "you?" ]) )
#--> [ [ 72, 111, 119 ], [ 97, 114, 101 ], [ 121, 111, 117, 63 ] ]

? @@( Unicodes([ "A", "HI", [ 1, 2 ] ]) )
#--> [ 65, [ 72, 73 ], [ 1, 2 ] ]

? @@( Unicodes([ "a", [ 1, ["b","c"], 2], "d" ]) )
#--> [ 97, [ 1, [ 98, 99 ], 2 ], 100 ]

? @@( Unicodes([ "a", [ 1, ["b", [ "ring" ] ], 2 ], "d" ]) )
#--> [ 97, [ 1, [ 98, [ [ 114, 105, 110, 103 ] ] ], 2 ], 100 ]

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*========= Replace and DeepReplace

pron()

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

proff()
# Executed in 0.07 second(s)

/*------------

pron()

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

proff()

/*==============

pron()

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])

o1.SortBy('len(@item)')
? o1.Content()
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

proff()
# Executed in 0.11 second(s)

/*==============

pron()

o1 = new stzList(1:1_500_000)

o1.ShowShort()
#--> [ 1, 2, 3, " ... ", 1499998, 1499999, 1500000 ]

proff()
# Executed in 1.71 second(s)

/*----------------

pron()

o1 = new stzList(1:18)

o1.Show()
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 ]

o1.ShowShort()
#--> [ 1, 2, 3, " ... ", 16, 17, 18 ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

o1 = new stzList(1:180_000)

o1.ShowShortUsing("***")
#--> [ 1, 2, 3, "***", 179998, 179999, 180000 ]

o1.ShowShortN(2)
#--> [ 1, 2, "...", 179999, 180000 ]

o1.ShowShortNUsing(2, "***")
#--> [ 1, 2, "***", 179999, 180000 ]

? @@( o1.Shortened() )
#--> [ 1, 2, 3, "...", 179998, 179999, 180000 ]

? @@( o1.ShortenedN(2) )
#--> [ 1, 2, "...", 179999, 180000 ]

? @@( o1.ShortenedXT(0, 2, "{...}") )
#--> [ 1, 2, "{...}", 179999, 180000 ]

proff()
# Executed in 0.46 second(s) in Ring 1.19 (64 bits)
# Executed in 0.76 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzList(1:180_000)

o1.Shorten()
? @@( o1.Content() )
#--> [ 1, 2, 3, "...", 179998, 179999, 180000 ]

proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzList(1:180_000)

o1.ShortenN(2)
? @@( o1.Content() )
#--> [ 1, 2, "...", 179999, 180000 ]

proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzList(1:180_000)

o1.ShortenNUsing(2, "{}")
? @@( o1.Content() )
#--> [ 1, 2, "{}", 179999, 180000 ]

proff()
# Executed in 0.09 second(s)

/*=======

pron()

# REMINDER: Duplication is performed in a reasonable performance
# when the size of the list does not exceed 30K items!

aBigList = 1 : 30_000 +
	   "A" + "B" + "." + "A" + "A" + "B" + 2 + 2

o1 = new stzList(aBigList)

? o1.ContainsDuplicates()
#--> TRUE

proff()
# Executed in 3.15 second(s) in Ring 1.21
# Executed in 4.27 second(s) in Ring 1.19

/*-------

pron()

	alist = []
	for i = 1 to 30000
		alist + 'A' + 'B'
	next
	alist + "A" + "A" + 2 + "B" + "B" + 2 + "B"

	o1 = new stzList(alist)
	
	? o1.AllItemsAreDuplicated()
	#--> TRUE

proff()
# Executed in 1.82 second(s) in Ring 1.21
# Executed in 4.75 second(s) in Ring 1.19

/*-------

pron()

	o1 = new stzList([ "A", "B", "2", 1:3, "C", 2 ])
	? o1.NoItemsAreDuplicated()
	#--> TRUE

	o1 = new stzList("A":"E")
	? o1.NoItemsAreDuplicated()
	#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.8

/*-------

pron()

o1 = new stzList([ "2", 2 ])
? o1.ContainsDuplicates()
#--> FALSE

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19

/*------- #narration

pron()
	#NOTE // Let's precise the concepts of Duplicates/Duplications,
	# and DuplicateItems, as implemented semantically in Softanza

	o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])

	? o1.ContainsDuplicates() # Or ContainsDuplications() or ContainsduplicatedItems()
	#--> TRUE

	? o1.NumberOfDuplicates() # Or o1.NumberOfDuplicatedItems()
	#--> 4

	? @@( o1.DuplicatesZ() ) # Or DuplicateItemsZ() or DuplicationsZ()
	#--> [ [ "A", [ 4, 5 ] ], [ "B", [ 6 ] ], [ 2, [ 8 ] ] ]

	# ~> "A" is duplicated in positions 4 and 5, "B" is duplicated in position 5,
	# and 2 is duplicated in position 8

	# To get the list of duplicates (or duplicated items):

	? @@( o1.Duplicates() ) # Or o1.DuplicatedItems()
	#--> [ "A", "B", 2 ]

	# To find the positions where these items are duplicated, we say:

	? @@( o1.FindDuplicates() ) # of FindDuplications()
	#--> [ 4, 5, 6, 8 ]

	# --> Note that the first occurrences of "A", "B" and 2 are not counted
	# --> To get them with the positions of duplicates you can use: 
	? @@( o1.FindDuplicatesXT() )
	#--> [ 1, 2, 4, 5, 6, 7, 8 ]

	# To get only the first occurrences of each duplicated item, use:

	? @@( o1.FindDuplicatesOrigins() )

	#NOTE // There is an other alternative long name intended for near-natural
	# lanaguage support in Softanza, not for using in normal programming:

	? @@( o1.FindFirstOccurrenceOfEachDuplicatedItem() )
	#--> [ 1, 2, 7 ]

	# What about items that are not duplicated:

	? o1.ContainsItemsNonDuplicated()
	#--> TRUE

	? o1.ContainsAtLeastOneNonDuplicatedItem()
	#--> TRUE

	? o1. ContainsNoDuplications()
	#--> FALSE

	? o1.ContainsNonDuplicatedItems()
	#--> TRUE

	? o1.NumberOfNonDuplicatedItems()
	#--> 2

	? @@( o1.FindNonDuplicatedItems() )
	#--> [ 3, 9 ]

	? @@( o1.NonDuplicatedItems() )
	#--> [ "2", "." ]

	? @@( o1.NonDuplicatedItemsZ() )
	#--> [ [ "2", 3 ], [ ".", 9 ] ]


proff()
# Executed in 0.03 second(s) in Ring 1.21.
# Executed in 0.08 second(s) in Ring 1.19

/*------------

pron()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "2", 2, "." ]

proff()
# Executed in almost 0 second(s).

/*------------

pron()

aBigList = 1:30_000
aMore = [ "A", "B", "2", "A", "A", "B", 2, 2, "." ]
nLen = len(aMore)
for i = 1 to nLen
	aBigList + ("" + aMore[i] + i)
next

o1 = new stzList(aBigList)

@@( o1.Withoutduplication() ) # Or ToSet()
#--> [ "A", "B", "2", 2, "." ]

proff()
# Executed in 3.28 second(s) in Ring 1.21
# Executed in 4.29 second(s) in Ring 1.19

/*------------

pron()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
? @@( o1.Withoutduplication() ) # Or ToSet()
#--> [ "A", "B", "2", 2, "." ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

/*------------

pron()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveNonDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "A", "A", "B", 2, 2 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

# Enhancing Your Mental Model with Softanza: A Case Study of List Sorting
# Let's explore how Softanza improves the programming experience by examining
# the sort() function implementation

/*======== #narration

pron()

# A Common Programming Dilemma:
# When working with Ring sort() function, there's often a moment of uncertainty:
# Does it modify the list in place, or does it return a new sorted list?
# This uncertainty typically leads to writing test cases for verification...

alist = [ 4, 3, 1 , 2, 5 ]
alist = ring_sort(alist)

? @@(alist)
#--> [ 1, 2, 3, 4, 5 ]

# Softanza's Solution: Crystal-Clear Mental Models
# When you want to modify the list in place, the syntax is explicit:

o1 = new stzList([ 4, 3, 1 , 2, 5 ])
o1.Sort()
# The list is now sorted in place, and you can verify it:
o1.Show()
#--> [ 1, 2, 3, 4, 5 ]

# Need a sorted copy instead? The passive voice syntax makes it intuitive:

aSorted = Q([ 4, 3, 1 , 2, 5 ]).Sorted()
? @@(aSorted)
#--> [ 1, 2, 3, 4, 5 ]

# Bridging Ring and Softanza:
# Softanza provides an elegant solution by wrapping Ring's native functions
# with enhanced versions that offer consistent behavior. Take ring_sort()
# for example:

# Using the wrapped function:
aList = [ 4, 3, 5, 2, 1 ]
ring_sort(aList)

# The list is modified in place:
? @@( aList )
#--> [ 1, 2, 3, 4, 5 ]

# And simultaneously returns the sorted list:
? @@( ring_sort([ 4, 3, 5, 2, 1 ]) )
#--> [ 1, 2, 3, 4, 5 ]

# This unified behavior eliminates cognitive overhead, allowing you to use
# Ring functions seamlessly within your workflow.

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19

/*------------

pron()

o1 = new stzList([ "A", "B", "C" ])
? o1.ContainsDupSecutiveItems()
#--> FALSE

proff()
# Executed in 0.01 second(s).

/*------------

pron()

# DupSecutive = Duplicate + Consecutive

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])
#                             ^    ^    ^                   ^    ^
? o1.ContainsDupSecutiveItems()
#--> TRUE

? o1.FindDupSecutiveItems()
#--> [ 3, 4, 9 ]

? o1.FindDupSecutiveItemsCS(FALSE)
#--> [ 3, 4, 5, 9, 10 ]

? o1.Duplicates()
#--> [ "A", "B", "C" ]

? o1.DupSecutiveItems()
#--> [ "B", "C" ]

? @@( o1.DupSecutiveItemsZ() ) + NL
#--> [ [ "B", [ 3, 4 ] ], [ "C", [ 9 ] ] ]

? @@( o1.DupSecutiveItemsCSZ(FALSE) ) + NL
#--> [ [ "B", [ 3, 4, 5 ] ], [ "C", [ 9, 10 ] ] ]

o1.RemoveDupSecutiveItemsCS(FALSE)
? @@( o1.Content() ) + nl
#--> [ "A", "B", "C", "B", "C", "A" ]

o1.RemoveDuplicates()
? @@( o1.Content() )
# [ "A", "B", "C" ]

proff()
# Executed in 0.02 second(s).

/*------------

pron()

# DupOrigins = DuplicatesOrigins

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])
? o1.FindDupSecutiveItems()
#--> [ 3, 4, 9 ]

? @@( o1.DupSecutiveItemsZ() )
#--> [ [ "B", [ 3, 4 ] ], [ "C", [ 9 ] ] ]

? @@( o1.FindThisDupSecutiveItem("B") )
#--> [ 3, 4 ]

? @@( o1.FindThisDupSecutiveItemCS("B", :CS = FALSE) )
#--> [ 3, 4, 5 ]

? @@( o1.DupSecutiveItemCSZ("B", FALSE) )
#--> [ "B", [ 3, 4, 5 ] ]

o1.RemoveDupSecutiveItemCS("B", FALSE)
? @@( o1.Content() )
#--> [ "A", "B", "C", "B", "C", "C", "c", "A" ]

proff()
# Executed in 0.01 second(s).

/*------------

pron()

# DupOrigins = DuplicatesOrigins

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])

? o1.DupOrigins() # Same As Duplicates()
#--> [ "A", "B", "C" ]

? o1.FindDupOrigins()
#--> [ 1, 2, 6 ]

o1.RemoveDupOrigins()
? @@( o1.Content() )
#--> [ "B", "B", "b", "B", "C", "C", "c", "A" ]

proff()
# Executed in almost 0 second(s).

/*-----

pron()

# Simulated CSV data with duplicate rows

aImportedData = [
    	["id", "name", "email"],
    	["1", "John", "john@email.com"],
    	["1", "John", "john@email.com"],	# Duplicate
    	["2", "Jane", "jane@email.com"],
    	["2", "Jane", "jane@email.com"],    	# Duplicate
	["2", "Jane", "jane@email.com"],	# Duplicate
   	["3", "Bob", "bob@email.com"]
]

oDataRecords = new stzList(aImportedData)

? @@NL(oDataRecords.DuplicatesZ()) + NL
#--> [
#	[ [ "1", "John", "john@email.com" ], [ 3 ] ],
#	[ [ "2", "Jane", "jane@email.com" ], [ 5, 6 ] ]
# ]

oDataRecords.RemoveDuplicates()
? @@NL(oDataRecords.Content())
#--> [
#	[ "id", "name", "email" ],
#	[ "1", "John", "john@email.com" ],
#	[ "2", "Jane", "jane@email.com" ],
#	[ "3", "Bob", "bob@email.com" ]
# ]

proff()
# Executed in 0.01 second(s).

/*----

# Sensor readings with duplicate values

aSensorReadings = [
    ["timestamp", "temperature"],
    ["10:00:00", 22.5],
    ["10:00:00", 22.5],    # Duplicate reading
    ["10:00:00", 22.5],    # Duplicate reading
    ["10:00:01", 22.6],
    ["10:00:01", 22.6],    # Duplicate reading
    ["10:00:02", 22.7]
]

oSensorData = new stzList(aSensorReadings)

? @@( oSensorData.FindDuplicates() ) + NL

# Get unique readings while preserving order

oSensorData.RemoveDuplicates()
? @@NL( oSensorData.Content() )
#--> [
#	[ "timestamp", "temperature" ],
#	[ "10:00:00", 22.50 ],
#	[ "10:00:01", 22.60 ],
#	[ "10:00:02", 22.70 ]
# ]

proff()

/*---- #NLP

pron()

# Word frequency analysis
aWords = [
    "the", "cat", "sat", "on", "the", "mat",
    "the", "cat", "sat", "there"
]

oWords = new stzList(aWords)

# Find all duplicate words

? @@(oWords.Duplicates()) + NL
#--> ["the", "cat", "sat"]

# Get word positions with context

? @@(oWords.DuplicatesZ())
#--> [ [ "the", [ 5, 7 ] ], [ "cat", [ 8 ] ], [ "sat", [ 9 ] ] ]

proff()
# Executed in almost 0 second(s).

/*============

pron()

? Q([0]) * 3
#--> [0, 0, 0]

proff()

/*------------

o1 = Q([0])
o1 * 3
o1.Show()
#--> [ 0, 0, 0 ]

proff()

/*------------

pron()

# Changes the object and returns its content IN THE SAME TIME:

o1 = new stzList([0])
? o1 * 3
#--> [0, 0, 0]

o1.Show()
#--> [ 0, 0, 0 ]

proff()

/*------------

pron()

o1 = new stzList([0, 1, 2])
o1 * 3
o1.Show()
#--> [ 0, 1, 2, 0, 1, 2, 0, 1, 2 ]

proff()
# Executed in 0.03 second(s)


/*============

pron()

o1 = new stzList(1:7)
o1 - 3:5
o1.Show()
#--> [ 1, 2, 6, 7 ]

proff()
# Executed in 0.03 second(s)

/*============

pron()

o1 = new stzList(1:100_000)
? o1.NLastItems(10)

proff()
# Executed in 0.05 second(s)

/*============

pron()

o1 = new stzList(1:299_000)
o1.Stringified()

proff()
# Executed in 3.35 second(s)

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

//? @@( o1.LettersZ() ) #TODO

#--

? o1.NumberOfNumbers()
#--> 1

? @@( o1.Numbers() )
#--> [ 5 ]

# ? @@( o1.NumbersZ() ) #TODO

#--

? o1.NumberOfStrings()
#--> 5

? @@( o1.Strings() )
#--> [ "a", "bcd", "♥", "b", "♥♥♥" ]

# ? @@( o1.StringsZ() ) #TODO

#--

? o1.NumberOfLists()
#--> 1

? @@( o1.Lists() )
#--> [ [ 1, 2 ] ]

# ? @@( o1.ListsZ() ) #TODO

#--

? o1.NumberOfPairs()
#--> 1

? @@( o1.Pairs() )
#--> [ [ 1, 2 ] ]
# ? @@( o1.PairsZ() ) #TODO

#--

? o1.NumberOfObjects()
#--> 0

? @@( o1.Objects() )
#--> []

# ? @@( o1.ObjectsZ() ) #TODO

proff()
# Executed in 0.12 second(s)

/*========= #narration Ring List2Code() VS Softanza ListToCode()

pron()

? List2Code([ [ 6, 8 ], [ 16, 18 ] ]) + NL # Ring standard function
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

? ListToCode([ [ 6, 8 ], [ 16, 18 ] ]) + NL # Softanza function
#--> "[ [ 6, 8 ], [ 16, 18 ] ]"

? "---" + NL

? List2Code([ "A", '"B"', "'C'" ]) + NL # Ring standard function
#--> [
#	"A",
#	""+char(34)+"B"+char(34)+"",
#	"'C'"
# ]

? ListToCode([ "A", '"B"', "'C'" ]) # Softanza function
#--> [ "A", '"B"', "'C'" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

#NOTE: Also, Softanza version is more performant (testit for a large list)

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
# Executed in 0.21 second(s).
# Executed in 0.99 second(s) in Ring 1.19

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
# Executed in 2.35 second(s) in Ring 1.19 (64 bits)
# Executed in 3.72 second(s) in Ring 1.17

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

o1 = new stzString("123456789")

? o1.SectionXT(5, 3) # Same as Section(3, 5)
#--> 534

? o1.SectionXT(5, -3)
#--> 567

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*============

pron()

o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7" ])

? o1.Section(3, 5)
#--> [ "3", "4", "5" ]

? o1.Section(5, 3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(3, -3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(-3, 3)
#--> [ "3", "4", "5" ]

? o1.Range(3, 3)
#--> [ "3", "4", "5" ]

? o1.RangeXT(3, 3)
#--> [ "1", "2", "3" ]

? o1.RangeXT(-5, 3)
#--> [ "1", "2", "3" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*===========

pron()

? Association([ [ 1, 2, 3 ], [ "One", "Two", "Three" ] ])
#--> [ [ 1, "One" ], [ 2, "Two" ], [ 3, "Three" ] ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*===========

pron()

o1 = new stzList([ :StartingAt, 5 ])
? o1.IsAPairQ().Where('{ isString(@pair[1]) and isNumber(@pair[2]) }')

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*============

pron()
   
o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ])

# FIRST HALF

	? @@( o1.FirstHalf() )
	#--> [ "1", "2", "3", "4" ]
	? @@( o1.FirstHalfXT() ) + NL
	#--> [ "1", "2", "3", "4", "5" ]
	
	? @@( o1.FirstHalfAndItsPosition() )
	#--> [ [ "1", "2", "3", "4" ], 1 ]
	? @@( o1.FirstHalfAndItsSection() ) + NL
	#--> [ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	
	? @@( o1.FirstHalfAndItsPositionXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], 1 ]
	? @@( o1.FirstHalfAndItsSectionXT() ) + NL + NL + "---" + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ]

# SECOND HALF

	? @@( o1.SecondHalf() )
	#--> [ "5", "6", "7", "8", "9" ]
	? @@( o1.SecondHalfXT() ) + NL
	#--> [ "6", "7", "8", "9" ]
	
	? @@( o1.SecondHalfAndItsPosition() )
	#--> [ [ "5", "6", "7", "8", "9" ], 5 ]
	? @@( o1.SecondHalfAndItsSection() ) + NL
	#--> [ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ]
	
	? @@( o1.SecondHalfAndItsPositionXT() )
	#--> [ [ "6", "7", "8", "9" ], 6 ]
	? @@( o1.SecondHalfAndItsSectionXT() ) + NL + NL + "---" + NL
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
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.32 second(s) in Ring 1.17

/*============

pron()

o1 = new stzList([ "programming", "is" ])
? o1.SortedBy('Q(@item).NumberOfChars()')
#--> [ "is", "programming" ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*------------

pron()

? StzCCodeQ('Q(@NextItem).IsNotANumber()').Transpiled()
#--> Q( This[@i + 1] ).IsNotANumber(  )

proff()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.30 second(s) in Ring 1.17

/*------------

pron()

? StzCCodeQ('NOT isNumber( This[@i + 1] )').ExecutableSection()
#--> [1, -1]

proff()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18

/*-----------

pron()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 7 ])

? @@( o1.ToString() ) + NL
#-->
# "1
#  2
#  3
#  *
#  5
#  6
#  *
#  7"

? @@( o1.Stringified() ) + NL
#--> [ "1", "2", "3", "*", "5", "6", "*", "7" ]

? o1.ToCode()
#--> [ 1, 2, 3, "*", 5, 6, "*", 7 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.7

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

/*-----------

pron()

o1 = new stzList([ 1, 2, "ring", 4, 5, "RING", 7, "Ring" ])

? o1.FindW('{
	isString(This[@i]) and This[@i] = "ring"
}')
#--> [ 3 ]

? o1.FindWCS('{
	isString(This[@i]) and This[@i] = "ring"
}', :CS = FALSE)
#--> [ 3, 6, 8 ]

proff()
# Executed in 0.13 second(s) in Ring 1.21

/*-----------

pron()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? o1.FindW(' NOT isNumber(This[@i + 1]) ')
#--> [2, 6]
# Executed in 0.13 second(s)

? o1.FindWXT(' Q(@NextItem).IsNotANumber() ')
#--> [2, 6]

proff()
# Executed in 0.15 second(s) in Ring 1.21
# Executed in 0.59 second(s) in Ring 1.20
# Executed in 0.70 second(s) in Ring 1.17

/*===========

StartProfiler()

? Q(5).Repeated(3)
#--> [ 5, 5, 5 ]

? Q(5).Repeated([ 3, :Times ])
#--> [ 5, 5, 5 ]

#--

? Q(1:2).Repeated(3)
#--> [ 1:2, 1:2, 1:2 ]

? Q(1:2).Repeated([ 3, :Times ])
#--> [ 1:2, 1:2, 1:2 ]

#--

? Q("A").Repeated(3)
#--> AAA

? Q("A").Repeated([ :NTimes, 3 ])
#--> AAA

? Q("A").Repeated([ 3, :Times ])
#--> AAA

StopProfiler()
# Executed in 0.07 second(s) in Ring 1.21

/*---

StartProfiler()

? Q("A").RepeatedXT(:InAString, :OfSize = 3)
#--> "AAA"

? Q("A").RepeatedXT(:InAList, :OfSize = 3)
#--> ["A", "A", "A"]

? Q("A").RepeatedXT( :NTimes = 3, :InAList )
? Q("A").RepeatedXT([ 3, :Times ], :InAList )

? Q("A").RepeatedXT( :NTimes = 3, :InAString )
? Q("A").RepeatedXT([ 3, :Times ], :InString ) + NL

StopProfiler()
# Executed in 0.11 second(s) in Ring 1.21

/*---

StartProfiler()

? Q(5).RepeatedXT(:InAString, :OfSize = 3)
#--> "555"

? Q(5).RepeatedXT(:InAList, :OfSize = 3)
#--> [5, 5, 5]

? Q(5).RepeatedXT( :NTimes = 3, :InAList )
#--> [5, 5, 5]

? Q(5).RepeatedXT([ 3, :Times ], :InAList )
#--> [5, 5, 5]

? Q(5).RepeatedXT( :NTimes = 3, :InAString )
#--> "555"

? Q(5).RepeatedXT([ 3, :Times ], :InString ) + NL
#--> [5, 5, 5]

StopProfiler()
# Executed in 0.10 second(s) in Ring 1.21

/*===========

StartProfiler()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? @@NL( o1.BoundsOf("*", :UpToNItems = 2) ) + NL
#--> [
#	[ [ 1, 2 ], [ 4, 5 ] ],
#	[ [ 5, 6 ], [ 8, 9 ] ]
# ]

? @@NL( o1.BoundsOf("*", :UpToNItems = 3) )
#--> [
#	[ [ ], [ 4, 5, 6 ] ],
#	[ [ 4, 5, 6 ], [ ] ]
# ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*===========

StartProfiler()

 # Extract(item) removes the item from the list and returns it

o1 = new stzList([ "A", "B", "_", "C" ])

? o1.Extract("_")
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*-----------

StartProfiler()

	o1 = new stzList([ "A", "B", "_", "C", "*" ])
	? o1.ExtractMany(["_", "*"]) # Or ExtractThese()
	#--> ["_", "*"]
	
	? o1.Content()
	#--> #--> [ "A", "B", "C" ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*-----------

StartProfiler()

o1 = new stzList([ "A", "B", "C" ])

? o1.ExtractAll()
#--> [ "A", "B", "C" ]

? @@( o1.Content() )
#--> []

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.01 second(s) in Ring 1.20

/*-----------

StartProfiler()

o1 = new stzList([ "A", "_", "B", "C" ])
? o1.ExtractAt(2) + NL
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

/*-----------

pron()

? @FindNth([ "_", "A", "_", "B", "C" ], 2, "_")
#--> 3

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-----------

StartProfiler()

o1 = new stzList([ "_", "A", "_", "B", "C" ])
? o1.FindNthOccurrence(2, "_")
#--> 3

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21

/*-----------

StartProfiler()

o1 = new stzList([ "_", "A", "B", "C" ])

? o1.ExtractFirst("_") + NL

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

/*-----------

StartProfiler()

o1 = new stzList([ "A", "B", "C", "_" ])

? o1.ExtractLast("_") + NL
#--> "_"

? o1.Content()
#--> ["A", "B", "C"]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 3, "*", 4, "_" ])

? o1.ExtractWXT('{ NOT isNumber(@item) }')
#--> [ "♥", "*", "_" ]

? o1.Content()
#--> [ 1, 2, 3, 4 ]

StopProfiler()
# Executed in 0.13 second(s) in Ring 1.21
# Executed in 0.44 second(s) in Ring 1.20

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
# Executed in almost 0 second(s) in Ring 1.21

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractNext("♥", :StartingAt = 4)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 6, "♥" ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21

/*-----------

StartProfiler()

o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractPrevious("♥", :StartingAt = 6)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, 4, "♥", 6, "♥" ]

StopProfiler()
# Executed in almost 0 second(s).

/*===========

StartProfiler()

? Q([ "ONE", "ONE", "ONE" ]).ItemsHaveXT('{ len(@item) = 3 }')
#--> TRUE

? Q([ "One", "Two", "Three" ]).Are(:Strings)
#--> TRUE

? Q(1:5).ItemsAre(:Numbers)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:Lists)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:ListsOfStrings)
#--> TRUE

StopProfiler()
# Executed in 0.24 second(s) in Ring 1.19
# Executed in 0.47 second(s) in Ring 1.19

/*----------

pron()

o1 = new stzList([
	[ "A", "B", "C" ],
	[ 1, 2, 3 ],
	[ NULL, NULL, [] ]
])

? o1.IsMadeOfUniformLists() # Or more precisely: IsMadeOfUnisizeLists()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*----------

StartProfiler()

	? Q([ "♥", "♥", "♥" ]).IsMadeOfItem("♥")
	#--> TRUE

	? Q([ 12, 12, 12 ]).AllItemsAre(12)
	#--> TRUE

	? Q([ 1:3, 1:3, 1:3 ]).ContainsOnly(1:3)
	#--> TRUE

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.41 second(s) in Ring 1.17

/*==========

pron()

o1 = new stzList([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])

? o1.ContainsDuplicates()
#--> TRUE

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6, 9 ]

? @@( o1.Duplicates() )
#--> [ "_", "*" ]

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ "_", [ 3, 4, 6 ] ], [ "*", [ 9 ] ] ]

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ "_", "ONE", "TWO", "THREE", "*" ]

proff()
# Executed in 0.01 second(s) in ring 1.21
# Executed in 0.55 second(s) in Ring 1.17

/*--------------- 

pron()

o1 = new stzList([ "A", "b", "C", "B", '"B",', "D", "E" ])
? o1.ToCode()
#-->  [ "A", "b", "C", "B", '"B",', "D", "E" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17

/*---------------

pron()

o1 = new stzList([ 10, '"[ :Tunis, :Paris ]"', "ONE," ])
? o1.ToCode()
#-- [ 10, '"[ :Tunis, :Paris ]"', "ONE," ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17

/*--------------- #internal

pron()

o1 = new stzList([ 10, [ :Tunis, :Paris ], "ONE," ])
? o1.StringifyAndReplaceQ(",", "*").Content()
#--> [ "10", '[ "tunis"* "paris" ]', "ONE*" ]

proff()
# Executed in 0.01 second(s)

/*--------------- #internal

pron()

aList = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]
	for i = 1 to 10
		aList + ("*"+i)
	next
	aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aList)

? @@( o1.StringifyAndReplaceQ(",", "*").Content() )
#--> [
#	"10", "20", "One", "ONE",
#	'[ "tunis"* "paris" ]',
#	"30", "two",
#
#	"__*1__",
#	"__*2__",
#	"__*3__",
#	"__*4__",
#	"__*5__",
#	"__*6__",
#	"__*7__",
#	"__*8__",
#	"__*9__",
#	"__*10__",
#
#	"in", "out", "IN", "OUT" ]
# ]

? o1.ContainsDuplicates()
#--> FALSE

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17

/*--------------- #perf

pron()

#                                         v                              v
aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two", [ :Tunis, :Paris ] ]
#                                         ^                              ^

for i = 1 to 100_000
	aLarge + ("*"+i)
next

aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicates()
#--> TRUE

proff()
# Executed in 5.11 second(s) in Ring 1.21
# Executed in 8.32 second(s) in Ring 1.17

/*--------------- #perf

pron()

aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]

	for i = 1 to 30_000
		aLarge + ("*"+i)
	next

aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicates()
#--> FALSE

proff()
# Executed in 4.89 second(s).

/*--------------- #perf

pron()

# Constructing a large list of 30K items

aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]

	for i = 1 to 30_000
		aLarge + ("*"+i)
	next
	
	aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicatesCS(FALSE)
#--> TRUE

? o1.NumberOfDuplicationsCS(FALSE)
#--> 3

proff()
# Executed in 6.68 second(s) in Ring 1.21
# Executed in 12.05 second(s) in Ring 1.17

/*--------------- #ringqt draft

pron()

aList = [ "5", "7", "5", "5", "4", "7" ]

o1 = new QStringList()
for i = 1 to len(aList)
	o1.append(aList[i])
next

o1.sort()
? QStringListContent(o1)
#--> [ "4", "5", "5", "5", "7", "7" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.17

/*---------------

pron()

o1 = new stzList([ 5, 7, 5, 5, 4, 7 ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates()
#--> 3
# Executed in 0.03 second(s)

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6 ]
# Executed in 0.03 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ 5, [ 3, 4 ] ], [ 7, [ 6 ] ] ]

#~> the number 5 is duplicated at positions 3 and 4
#~> the number 7 is duplicated at position 6.

# Executed in 0.25 second(s)

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ 5, 7, 4 ]

# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

proff()
# Executed in 0.54 second(s)

/*---------- #ringqt draft

pron()

aList = [ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ]
o1 = new QStringList()
for str in aList
	o1.append(str)
next

? o1.indexof("Ab", 2)
#--> 2

proff()
# Executed in almost 0 second(s).

/*----------

pron()

o1 = new stzList([ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ])
? @@( o1.ItemsZ() ) # Or ItemsAndTheirPositions()
#--> [
#	[ "Ab", [ 1, 3, 6 ] ],
#	[ "Im", [ 2 ] ],
#	[ "Cf", [ 4, 7 ] ],
#	[ "Fd", [ 5 ] ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.8

/*---------- #perf

pron()

# ItemsAndTheirPositions(), also called ItemsZ(), can do
# the job in a reasonable performance when the number of
# items in the list is around 1000 items

o1 = new stzList(1:1_000 + 3 + 5 + 7 + 10 + 100 + 1000)
ShowShort( o1.ItemsZ() )
#--> [
#	[ 1, [ 1 ] ],
#	[ 2, [ 2 ] ],
#	[ 3, [ 3, 10001 ] ],
#	"...",
#	[ 998, [ 998 ] ],
#	[ 999, [ 999 ] ],
#	[ 1000, [ 1000, 1006 ]
# ]

proff()
# Executed in 1.09 second(s) in Ring 1.21

/*----------

pron()

o1 = new stzList(
	[] +
	"EMM, ahh," +		#--> "emm* ahh*"	<<< [1]
	"emm, ahh*" +		#--> "emm* ahh*"	<<< [2]

	"emm* AHH*" +		#--> "__emm* ahh*__"	!!!! [3]

	1:3 +			#--> "[1* 2* 3*]"
	10 +
	100 +
	1:3 +			#--> "[1* 2* 3*]"
	1000 +

	"oh, bah,," +		#--> "oh* bah**"	<<< [9]

	"[ 1* 2* 3 ]"		#--> "__[ 1* 2* 3 ]__"	!!!! [10]
)

o1.StringifyLowercaseAndReplaceXT(",", "*")
o1.Show()

#--> [
#	[
#		"emm* ahh*",
#		"emm* ahh*",
#		"__emm* ahh*__",
#		"[ 1* 2* 3 ]",
#		"10", "100",
#		"[ 1* 2* 3 ]",
#		"1000",
#		"oh* bah**",
#		"__[ 1* 2* 3 ]__"
#	],
#
#	[ 1, 2, 9 ], #--> Items where "," is replaced by "*" 
#	[ 3, 10 ]    #--> Items containing "*" but no "," 
# ]

proff()
# Executed in 0.01 second(s)

/*----------

pron()

? @@( "" )
#--> ""

? @@( '' )
#--> ""

? @@( '""' )
#--> '""'

? @@( "''" )
#--> "''"

? @@( "[1, 2, 3 ]" )
#--> "[1, 2, 3 ]"

? @@( '[1, 2, 3 ]' )
#--> "[1, 2, 3 ]"

? @@( '"[1, 2, 3]"' )
#--> '"[1, 2, 3]"'

? @@( "'[1, 2, 3]'" )
#--> "'[1, 2, 3]'"

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*----------

pron()

o1 = new stzString("123456789")
? o1.FindNext("1", :startingAt = 10)

proff()

/*---------- #ring

pron()

? ring_version()
#--> "1.17"

? StzVersion()
#--> "1.0"

proff()
# Executed in almost 0 second(s).

/*---------- #ringqt code draft

pron()

aList = [ "A", "*", "B", "C", "D", "*", "E" ]

o1 = new QStringList()

for i = 1 to 7
    o1.append(aList[i])
next

? o1.indexof("*", 0) + 1 # To get and Ring-index.
#--> 2

? o1.indexof("*", 3) + 1
#!--> 6

proff()

/*----------

pron()

o1 = new stzList([ 1, "*", 10:12, "B", 2, 1, "*", "A", 3, "*", "B", 10:12, "B" ])
? @@( o1.DuplicatesZ() )
#--> [
#	[ 1, 	 [ 6 ] ],	# 1 is duplicated once at position 5
#	[ "*", 	 [ 7, 10 ] ],	# "*" is duplicated twice at positions 6 and 9
#	[ 10:12, [ 12 ] ],	# 10:12 is duplicated once at position 12
#	[ "B", 	 [ 11, 13 ] ]	# "B" is duplicated twice at positions 10 and 11
# ]
proff()
# Executed in almost 0 second(s).

/*----------

pron()

aList = [ "A", "B", 1, "A", "A", 1, "C", 1:2, "D", "B", "E", '"1"', 1:2 ]
o1 = new stzList(aList)

? @@( o1.DuplicatesZ() )
#--> [
#	[ "A", 		[ 4, 5 ] ],
#	[ "B", 		[ 10 ]   ],
#	[ 1, 		[ 6 ]    ],
#	[ [ 1, 2 ], 	[ 13 ]   ]
# ]
? ""
? @@( o1.DuplicatesXTZ() )
#--> [
#	[ "A", 		[ 1, 4, 5 ] ],
#	[ "B", 		[ 2, 10 ]   ],
#	[ 1, 		[ 3, 6 ]    ],
#	[ "C",		[ 7 ]	    ],
#	[ [ 1, 2 ], 	[ 8, 13 ]   ],
#	[ "D", 		[ 9 ] 	    ],
#	[ "E", 		[ 11 ]      ],
#	[ '"1"', 	[ 12 ] 	    ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*---------- Profiling the Duplicates() function --> Reasonable perf up to 30K items!

pron()

aList = 1:100_000
aList + 1 + "*" + 10:12 + "B" + 2 + 1 + "*" + "A," + 3 + "*" + "B" + 10:12 + "B"

o1 = new stzList(aList)
o1.DuplicatesZ()


proff()
#-->        10 items 	:   0.02 second(s)
#-->       100 items 	:   0.02 second(s)
#-->	   500 items	:   0.03 second(s)
#-->     1_000 items 	:   0.05 second(s)
#-->    10_000 items 	:   1.04 second(s)
#-->    30_000 items	:  10.52 second(s)
#-->    50_000 items	:  60.99 second(s)
#-->   100_000 items	: 220.19 second(s)

/*----------

pron()

aList = 1 : 30_000
aList + 1 + "*" + 10:12 + "B" + 2 + 1 + "*" + "A," + 3 + "*" + "B" + 10:12 + "B" + "A,"

o1 = new stzList(aList)
? @@(o1.DuplicatesZ())
#--> [
#	[ 1, [ 30001, 30006 ] ],
#	[ 2, [ 30005 ] ],
#	[ 3, [ 30009 ] ],
#	[ "*", [ 30007, 30010 ] ],
#	[ [ 10, 11, 12 ], [ 30012 ] ],
#	[ "B", [ 30011, 30013 ],
#	[ "A,", [ 30014 ] ]
# ]

proff()
# Executed in 10.70 second(s)

/*----------

pron()

o1 = new stzList([ "A", "B", "A", "A", "C", "D", "B", "E", "a" , "b"])
? @@( o1.DuplicatesCSZ(:CaseSensitive = FALSE) )
#--> [ [ "A", [ 3, 4, 9 ] ], [ "B", [ 7, 10 ] ] ]

proff()
# Executed in 0.03 second(s)

/*----------

o1 = new stzList(
	1:10 + //0_000 +
	10 +
	"10" +
	[1, 2, 3] +
	'[1, 2, 3]' +
	
	[1, 2, 3] +
	10 +
	'[ 1* 2* 3 ]'
)

//? o1.ContainsDuplicates()
#--> TRUE

? @@( o1.FindDuplicates() )
#--> [
#	[ "10", [ 10, 10001 ] ],
#	[ "100", [ 100, 10002 ] ],
#	[ "1000", [ 1000, 10003 ] ]
# ]

proff()
# Executed in 2.19 second(s)

/*======= MANAGING DUPLICATED ITEMS: Check errros

pron()

o1 = new stzList([ 5, 7, 5, 5, 4, 7, 1 ])

? o1.Duplicates()
#--> [5, 7]

? o1.FindDuplicates()
#--> [3, 4, 6]

proff()
# Executed in 0.05 second(s)

/*-------------

pron()

o1 = new stzList([ 5, 7, 5, 5, 4, 7, 1 ])

#NOTE: the same code shown here can work as-is for stzListOfStrings!
# to test it just replace the line above with the following:
//o1 = new stzListOfStrings([ "5", "7", "5", "5", "4", "7", "1" ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates() + NL
#--> 3
# Executed in 0.03 second(s)

? o1.FindDuplicates()
#--> [ 3, 4, 6 ]
# Executed in 0.03 second(s)

? o1.Duplicates() # Or DuplicatesItems()
#--> [5, 7]
# Executed in 0.03 second(s)

? o1.HowManyDuplicatedItems() + NL # Not the same as HowManyDuplicates()
#--> 2
# Executed in 0.04 second(s)

? o1.DuplicatedItems()
#--> [5, 7]
# Executed in 0.04 second(s)

? @@( o1.DuplicatedItemsZ() ) # Same as DuplicatesZ()
#--> [ [ 5, [ 3, 4 ] ], [ 7, [ 6 ] ] ]
#--> the item 5 is duplicated twice at position 3 and 4, and,
#    the item 7 is duplicated once at position 6.

# Executed in 0.06 second(s)

o1.RemoveDuplicates() # Same as RemoveDuplicatedItems()
# Executed in 0.03 second(s)

? @@( o1.Content() )
#--> [ 5, 7, 4, 1 ]

proff()
# Executed in 0.13 second(s)

/*-----------

pron()

o1 = new stzList([ "*", "4", "*", "3", "4" ])

? o1.NumberOfDuplicates() + NL
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.08 second(s)

/*==========

pron()

o1 = new stzList(1:7)
o1 - 4:6

? @@( o1.Content() )
#--> [ 1, 2, 3, 7 ]

proff()
# Executed in 0.03 second(s)

/*==========

pron()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3, 5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.AntiSections(:Of = [ [3, 5], [7, 8] ] ) )
#--> [ ["A", "B"], ["F"], ["I", "J"] ]

proff()
# Executed in 0.07 second(s)

/*-------------

pron()

o1 = new stzList([ "Ring", "Ruby", "Python" ])

? o1.CommonItems(:With = [ "Julia", "Ring", "Go", "Python" ])
#--> [ "Ring", "Python" ]

proff()
#--> Executed in 0.03 second(s)

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
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.17

/*==========

pron()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3,"c" ])

? o1.FindDuplicates()
#--> [ 5, 6, 8, 10 ]

? @@( o1.ItemsAtPositions( o1.FindDuplicates() ) )
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

? @@( o1.Duplicates() ) + NL
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

? @@( o1.DuplicatesZ() )
#--> [ [ "a", 5 ], [ "ab", 6 ], [ "b", 8 ], [ [ 1, 2, 3 ], 10 ] ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19 (64 bits)
# Executed in 0.03 second(s) in Ring 1.17

/*-------------

pron()

o1 = new stzList([ "a", "ab", "b" ])
? @@( o1.Intersection(:with = [ "a", "ab", "abc", "b", "bc", "c" ]) ) # Or CommonItems()
#--> [ "a", "ab", "b" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19 (64 bits)
# Executed in 0.03 second(s) in Ring 1.17

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
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.19 (64 bits)
# Executed in 0.04 second(s) in Ring 1.17

/*===============

pron()

aLarge = 1:1_000_000

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]

for i = 1 to 8
	aLarge + aList[i]
next

o1 = new stzList(aLarge)
? o1.FindNth(2, "♥")
#--> 1_000_007

proff()
# Executed in  3.42 second(s) in Ring 1.21
# Executed in  5.74 second(s) in Ring 1.19 (64 bits)
# Executed in  6.11 second(s) in Ring 1.19 (32 bits)
# Executed in 13.13 second(s) in Ring 1.18
# Executed in 14.88 second(s) in Ring 1.17

/*-----------------

pron()

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
aLarge = aList

for i = 1 to 1_000_000
	aLarge + i
next

o1 = new stzList(aList)
? o1.FindNth(2, "♥")
#--> 7

proff()
# Executed in 0.15 second(s) in Ring 1.21 (64 bits)
# Executed in 0.17 second(s) in Ring 1.19 (64 bits)
# Executed in 0.20 second(s) in Ring 1.19 (32 bits)
# Executed in 0.26 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17

/*----------------- #narration #perf #ring

pron()

# Constructing the large list

	aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
	aLarge = aList
	
	for i = 1 to 1_000_000
		aLarge + "..."
	next

	for i = 1 to 8
		aLarge + aList[i]
	next


# Doing the job

	CheckParamsOff()

	? @FindNth(aLarge, 4, "♥")
	#--> 1000015

# Here we use an enhance Ring-find()-based global function.
# It's far more perforant then using a stzLits object like in:

#	o1 = new stzList(aLarge)
#	? o1.FindNth(4, "♥")

# In this case, execution time exceeds 42 seconds!

#NOTE
# You should always prefer this option when the items you are
# goinf to find are findable by Ring (numbers or strings).

proff()
# Executed in 0.79 second(s).

/*-----------------

pron()

# Constructing the large list (+1M items, the to-be-found item is a list (1:3),
# and it exists in the beginning and the end of the large list)

	aList = [ "A", 10, "A", 1:3, 20, 1:3, 1:3, "B" ]
	aLarge = aList
	
	for i = 1 to 1_000_000
		aLarge + "..."
	next
	for i = 1 to 8
		aLarge + aList[i]
	next
	# ElapsedTime : 0.48 seconds

# Turning param chek off (better performance)

	CheckParamsOff()

# Doing the job

	o1 = new stzList(aLarge)
	? o1.FindNth(4, 1:3)
	#--> 1_000_012

proff()
# Executed in 45.05 second(s)

/*----------------

pron()

aLarge = 1:1_000_000

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]

for i = 1 to 8
	aLarge + aList[i]
next

o1 = new stzList(aLarge)
? o1.FindLast("♥")
#--> 1000007

proff()
# Executed in  5.00 second(s) in Ring 1.21
# Executed in  6.51 second(s) in Ring 1.19
# Executed in 14.32 second(s) in Ring 1.17

/*--------------

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

# Finding next "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindNext("♥", :StartingAt = 100_000)
	#--> 100004

	? o1.FindNth(3, "♥")
	#--> 100007

	? o1.FindNthNext(2, "♥", :StartingAt = 2)
	#--> 100004
	
	? o1.FindNthNext(3, "♥", :StartingAt = 12_000)
	#--> 150008

StopProfiler()
# Executed in 2.70 second(s) in Ring 1.21
# Executed in 3.51 second(s) in Ring 1.19
# Executed in 7.55 second(s) in Ring 1.17

/*------------

pron()

o1 = new stzString("12♥4♥67")

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 3

proff()
# Executed in 0.01 second(s)

/*------------

pron()

o1 = new stzList([ "1", "2", "♥", "4", "♥", "6", "7" ])

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 5

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------ #perf

StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_", "♥" ]
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
# 

# Finding previous "♥"

	o1 = new stzList(aLargeListOfStr)

	? o1.FindPrevious("♥", :StartingAt = 5)
	#--> 3

	? o1.FindNthPrevious(2, "♥", :StartingAt = 120_000)
	#--> 100004

	? o1.FindNthPrevious(3, "♥", :StartingAt = 150_000)
	#--> 3

	? o1.FindPrevious("♥", :StartingAt = 150_000)
	#--> 100007

StopProfiler()
# Executed in 2.15 second(s) in Ring 1.21
# Executed in 7.51 second(s) in Ring 1.20

/*------------ #ring

pron()

? find([ "A", "B", [ 1, 2, 3 ], "C" ], "C")
#--> 4

? find([ "A", "B", [ 1, 2, 3 ], "C" ], [ 1, 2, 3 ])
#--> ERROR: Bad parameter type!

proff()

/*------------

StartProfiler()

aList = [ "_", "_", "♥", "_", "_", "♥", "_" ]

? @FindFirst(aList, "♥")
#--> 3

? @FindLast(aList, "♥")
#--> 6

? @FindNext(aList, "♥", :StartingAt = 3)
#--> 6

? @FindPrevious(aList, "♥", :StartingAt = 6)
#--> 3

? @FindNthNext(aList, 1, "♥", :StartingAt = 3)
#--> 6

? @FindNthPrevious(aList, 2, "♥", :StartingAt = 7)
#--> 3

StopProfiler()
# Executed in almost 0 second(s).

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
# Executed in 0.01 second(s)

/*===== #ring #perf #narration

StartProfiler()

# When searching for elements in a list, always start by
# checking if you can use the global @Find...() functions
# provided by Softanza, before using an stzList object.

# These functions can be used when the items you’re looking for
# are either numbers or lists. Otherwise, the use of stzList is necessary.

# As you’ll see in this example and the one that follows,
# choosing the right approach can lead to significant performance gains.

# In this example, we use the @Find... global functions
# (execution time: 0.78 second(s))

# In the following example, we perform the same task
# using an stzList object (execution time: 12.14 seconds)


# Fabricating a large list of strings (more then 150K items)

	aLargeListOfStr = [ "_", "_" ]
	for i = 1 to 100_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeListOfStr + "_"
	next i

# Finding the first occurrence of "♥" in the list

	? @FindFirst(aLargeListOfStr, "♥")
	#--> 100003

# Finding the last occurrence of "♥" in the list

	? @FindLast(aLargeListOfStr, "♥")
	#--> 100006

# Finding the 2nd occurrence of "♥" in the list

	? @FindNthST(aLargeListOfStr, 2, "♥", :StartingAt = 1)
	#--> 100006

# Finding the next occurrence of "♥" in the list starting at position 3

	? @FindNext(aLargeListOfStr, "♥", :StartingAt = 3)
	# 100003

# Finding the next 2nd occurrence of "♥" in the list starting at position 3

	? @FindNthNext(aLargeListOfStr, 2, "♥", :StartingAt = 3)
	#--> 100006

# Finding previous occurrence of "♥" in the list starting at position 120_000

	? @FindPrevious(aLargeListOfStr, "♥", :StartingAt = 120_000)
	#--> 100006

# Finding 2nd oprevious occurrence of "♥" in the list starting at position 120_000

	? @FindNthPrevious(aLargeListOfStr, 2, "♥", :StartingAt = 120_000)
	#--> 1003

proff()
# Executed in 0.78 second(s).

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

	? o1.FindFirst("♥")
	#--> 100003
	
	? o1.FindLast("♥")
	#--> 100006

	? o1.FindNth(2, "♥")
	#--> 100006

	? o1.FindNext("♥", :StartingAt = 3)
	#--> 999999

	? o1.FindNthNext(2, "♥", :StartingAt = 3)
	#--> 100006
	
	? o1.FindPrevious("♥", :StartingAt = 120_000)
	#--> 100006

	? o1.FindNthPrevious(2, "♥", :StartingAt = 120_000)
	#--> 1003

StopProfiler()
# Executed in 11.90 second(s) in Ring 1.21
# Executed in 31.56 second(s) in Ring 1.17

/*------------

pron()

o1 = new stzList(1:10)
? o1.AntiPositions([ 3, 4, 7, 9 ])
#--> [1, 2, 5, 6, 8, 10 ]

proff()
# Executed in almost 0 second(s).

/*------------

StartProfiler()

# Fabricating a list of strings (more then 10K items)

	aLargeListOfStr = []
	for i = 1 to 5_000
		aLargeListOfStr + "_"
	next
	
	aLargeListOfStr + "HI" + "ME"
	
	for i = 1 to 5_000
		aLargeListOfStr + "_"
	next i
	
	aLargeListOfStr + "HI" + "YOU"
	
	for i = 1 to 10
		aLargeListOfStr + "_"
	next i

# Removing dupicates

	o1 = new stzList(aLargeListOfStr)

	? ShowShort( o1.FindDuplicates() )
	#--> [ 2, 3, 4, "...", 150012, 150013, 150014 ]
	# Executed in 0.26 seconds

	o1.RemoveDuplicates()
	? ShowShort( o1.Content() )

StopProfiler()
# Executed in 15.85 second(s) in Ring 1.21

/*============

StartProfiler()
#                   1    2    3    4    5    6    7    8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "♥", "_", "_", "♥", "_", "_" ])
? o1.FindNth(3, "♥")
#--> 8

StopProfiler()
# Executed in 0.01 second(s)

/*------------

StartProfiler()
#                   1    2      3      4      5     6     7      8     9    10
o1 = new stzList([ "_", "_", "A":"C", "_", "A":"C", "_", "_", "A":"C", "_", "_" ])
? o1.FindNth(3, "A":"C")
#--> 8

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.20

/*------------

StartProfiler()
o1 = new stzList([ 1, 2, 3, "A":"C", 5, 7, 8, 9, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 0

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.22 second(s) in Ring 1.20

/*------------

StartProfiler()

o1 = new stzList([ 1, 2, 3, "A":"C", "A":"C", 6, 7, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 4

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.25 second(s) in Rin 1.20

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

	? o1.FindNext("A":"C", :StartingAt = 89_000)
	#--> 100001

	? o1.FindNthPrevious(3, "A":"C", :StartingAt = 100_010)
	#--> 100002

StopProfiler()
# Executed in 1.04 second(s) in Ring 1.21
# Executed in 8.38 second(s) in Ring 1.19

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
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.38 second(s) in Ring 1.19

/*----------

StartProfiler()

# Fabricating a large list

	aLargeList = 1 : 100_000

	aMyList = [ 1, 2,
		    [ "A", "B", "C", "عربي", "كلام", "D" ],
		    3, 4, 5,
		    [ "A", "B", "C", "عربي", "كلام", "D" ],
		    6, 7,
		    [ "A", "B", "C", "عربي", "كلام", "D" ]
	]

	for i = 1 to len(aMyList)
		aLargeList + aMyList[i]
	next

# Finding the first occurrence
	o1 = new stzList(aLargeList)

	? o1.FindFirst([ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100003

# Finding the last occurrence

	? o1.FindLast([ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100010

# Finding the 2nd occurrence

	? o1.FindNth(2, [ "A", "B", "C", "عربي", "كلام", "D" ])
	#--> 100007

StopProfiler()
# Executed in 1.32 second(s) in Ring 1.21
# Executed in 8.50 second(s) in Ring 1.18

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
#--> Executed in 0.01 second(s)

/*----

StartProfiler()

o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.NumberOfOccurrence("♥") #NOTE that this is a misspelled form (lacks an "r")
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
# Executed in 3.36 second(s)

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
# Executed in 0.67 second(s) in Ring 1.21
# Executed in 9.01 second(s) in Ring 1.18

/*----

StartProfiler()

o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.FindAll("♥")
#--> [2, 5, 6, 8 ]

o1 = new stzList(["__", 1:3, "_", "__", 1:3, 1:3, "__", 1:3 ])
? o1.FindAll(1:3)
#--> [2, 5, 6, 8 ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.60 second(s) in Ring 1.17

/*==========

#NOTE: This is a draft note I made while refactoring the naming startegy
# of some functions involving bounds and things inbetween.
# I left it here as a memory of the hard work made on this front...

# NAMING REFORM

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
# Executed in almost 0 second(s).

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
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20

/*----------- #internal

pron()

# This function is used internally by Softanza

? @FindAll(
	[ "_", "_", ["•"], "_", ["•"], "_", "_" ],
	["•"]
)
#--> -1

proff()

/*--------- #internal

pron()

# This function is used internally by Softanza

? @FindNext([ "_", "_", "•", "_", "•", "_", "_" ], "•", 3)
#--> 5

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], "•", 3)
#--> 0

? @FindNext([ "_", "_", ["•"], "_", ["•"], "_", "_" ], ["•"], 3)
#--> -1

proff()
# Executed in almost 0 second(s).

/*-----------

StartProfiler()
#                   1    2    3    4    5    6    7
o1 = new stzList([ "_", "_", "•", "_", "•", "_", "_" ])


? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 2)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 0

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 7)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 0

StopProfiler()
# Executed in 0.01 second(s)

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
# Executed in 0.01 second(s)

/*==============

StartProfiler()

o1 = new stzString("---456---")

? o1.DistanceTo("6", :StartingAt = 4)
#--> 1

? o1.DistanceToXT("6", :StartingAt = 4)
#--> 3

StopProfiler()
# Executed in 0.01 second(s)

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

#~> XT form : bounds are counted in the distance

? NL + "--" + NL

? o1.DistanceToSTXT("[", :StartingAt = 1)
#--> 4

? o1.DistanceToSTXT( :Next = "[", :StartingAt = 1 )
#--> 4

? o1.DistanceToSTXT( :NextNth = [2, "["], :StartingAt = 1 )
#--> 4

? NL + "--" + NL

? o1.DistanceToSTXT( :Previous = "[", :StartingAt = 9 )
#--> 4

? o1.DistanceToSTXT( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 6

? o1.DistanceTo( :Previous = "[", :StartingAt = 9 )
#--> 2

? o1.DistanceTo( :PreviousNth = [2, "["], :StartingAt = 9 )
#--> 4

StopProfiler()
# Executed in 0.03 second(s)

/*-----------

StartProfiler()
#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? @@( o1.FindBoundedByZZ([ "[","]" ]) ) + NL
#--> [ [ 7, 8 ], [ 12, 12 ], [ 18, 19 ] ]

? @@( o1.DeepFindBoundedByZZ([ "[","]" ]) )
#--> [ [ 7, 8 ], [ 12, 12 ], [ 18, 19 ], [ 5, 13 ], [ 2, 20 ] ]

StopProfiler()
# Executed in 0.01 second(s).

/*============ #ring A draft for a code using inside Softanza

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
# [ [ 1, 21 ], [ 6, 9 ], [ 11, 13 ], [ 17, 20 ] ]

StopProfiler()
# Executed in almost 0 second(s).

/*-----------

StartProfiler()

o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? o1.NeighborsOf(1)
#--> [ 4 ]

? o1.NeighborsOf(5)
#--> [ 4, 6 ]

? o1.NeighborsOf(6)
#--> [4, 11]

? o1.NeighborsOf(18)
#--> [ 11 ]

? o1.NeighborsOf(-2)
#--> [ 1]

? o1.NeighborsOf(22)
#--> [ 18 ]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

pron()

o1 = new stzList([1,2,3,4,5])
? o1 - These([3,5])
#--> [ 1, 2, 4 ]

proff()
# Executed in almost 0 second(s).

/*----------- #ring A draft for a code using inside Softanza

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
# [ [ 6, 9 ], [ 11, 14 ], [ 18, 21 ], [ 4, 15 ], [ 1, 22 ] ]

StopProfiler()
# Executed in 0.01 second(s).

/*============

StartProfiler()

 #                  ...4.6...v...4.v.v..1.v..
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                   ...^.^...0...^.6.8..^.3..

? @@( o1.FindBoundedByZZ([ "[", "]" ]) )
#--> [ [ 5, 9 ], [ 15, 15 ], [ 22, 22 ] ]

? @@( o1.BoundedBy([ "[", "]" ]) ) + NL
#--> [ " [===", "=", "=" ]

#--

? @@( o1.DeepFindBoundedByZZ([ "[", "]" ]) )
#--> [ [ 7, 9 ], [ 15, 15 ], [ 22, 22 ], [ 5, 17 ] ]

? @@( o1.DeepBoundedBy([ "[", "]" ]) )
#--> [ "===", "=", "=", " [===]---[=] " ]

StopProfiler()
# Executed in 0.02 second(s).

/*-----------

StartProfiler()

#                   1..4.6..v.1..vv..8..vv
o1 = new stzString("[••[•[••]•[••]]••[••]]")
#                   ^..^.^..9.^..45..^..21

? @@( o1.DeepFindSubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 7, 8 ], [ 12, 13 ], [ 19, 20 ], [ 5, 14 ], [ 2, 21 ] ]

? @@NL( o1.DeepSubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [
#	[ "••", [ 7, 8 ] ],
#	[ "••", [ 12, 13 ] ],
#	[ "••", [ 19, 20 ] ],
#	[ "•[••]•[••]", [ 5, 14 ] ],
#	[ "••[•[••]•[••]]••[••]", [ 2, 21 ] ]
# ]

#--

? @@( o1.DeepFindSubStringsBoundedByIBZZ([ "[", "]" ]) ) + NL
#--> [ [ 6, 9 ], [ 11, 14 ], [ 18, 21 ], [ 4, 15 ], [ 1, 22 ] ]

? @@NL( o1.DeepSubStringsBoundedByIBZZ([ "[", "]" ]) ) + NL
#--> [
#	[ "[••]", [ 6, 9 ] ],
#	[ "[••]", [ 11, 14 ] ],
#	[ "[••]", [ 18, 21 ] ],
#	[ "[•[••]•[••]]", [ 4, 15 ] ],
#	[ "[••[•[••]•[••]]••[••]]", [ 1, 22 ] ]
# ]

StopProfiler()
# Executed in 0.03 second(s).

/*-----------

StartProfiler()

#  BOUNDED-BY             v-------v
#                       v---v     v-v    v           
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                       | | |     ‖ |    ‖
#   DEEP-FIND >>        | \_/    15 |   22
#                       | 7 9       |
#                       \___________/
#                       5           17

? @@( o1.FindAnyBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 5, 9 ], [ 15, 15 ], [ 22, 22 ] ]

? @@NL( o1.SubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [
#	[ " [===", [ 5, 9 ] ],
#	[ "=", [ 15, 15 ] ],
#	[ "=", [ 22, 22 ] ]
# ]

#---

? @@( o1.DeepFindSubStringsZZ(:BoundedBy = [ "[", "]" ]) ) + NL
#--> [ [ 7, 9 ], [ 15, 15 ], [ 22, 22 ], [ 5, 17 ] ]

? @@NL( o1.DeepSubStringsZZ(:BoundedBy = [ "[", "]" ]) )
#--> [
#	[ "===", [ 7, 9 ] ],
#	[ "=", [ 15, 15 ] ],
#	[ "=", [ 22, 22 ] ],
#	[ " [===]---[=] ", [ 5, 17 ] ]
# ]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

StartProfiler()

o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
? o1.SubstringsBoundedBy([ "<<", ">>" ])
#--> [ "word1", "word2" ]

StopProfiler()
# Executed in 0.02 second(s)

/*-----------

pron()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.FindAntiSectionsIB( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 3 ], [ 5, 7 ], [ 8, 10 ] ]

proff()
# Executed in 0.03 second(s).

/*-----------

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


? @@NL( o1.SimplifyQ().NestedSubStringsIB(:BoundedBy = [ "[", "]" ]) )
#--> [
#	'[ "1", "1", [',
#	'["2", "♥", "2"]',
#	'], "1", [',
#	'["2", [',
#	'["3", "♥", [',
#	'["4", [',
#	'["5", "♥"]',
#	'], "4", [',
#	'["5","♥"]',
#	'], "♥"]',
#	'], "3"]',
#	"] ]",
#	"] ]"
# ]

StopProfiler()
#--> Executed in 0.06 second(s)

/*-----------

StartProfiler()

o1 = new stzString('[[[
	"1", "1",
		[[[ "2", "♥", "2" ]]],
	"1",
		[[[ "2",
			[[[ "3", "♥",
				[[[ "4",
					[[[ "5", "♥" ]]],
				"4",
					[[[ "5", "♥" ]]],
				"♥" ]]],
			"3" ]]]
		]]]

]]]')

o1.Simplify() # To remove NLs, TABs and overspaces from the string

? @@NL( o1.NestedSubStrings(:BoundedBy = [ "[[[", "]]]" ]) ) 		# Or DeepSubStrings() or SubStringsBoundedBy()
#--> [
#	' "1", "1", ',
#	' "2", "♥", "2" ',
#	', "1", ',
#	' "2", ',
#	' "3", "♥", ',
#	' "4", ',
#	' "5", "♥" ',
#	', "4", ',
#	' "5", "♥" ',
#	', "♥" ',
#	', "3" ',
#	" ",
#	" "
# ]

? SpeedUpX(12.72, 0.06) # Ring 1.21 is 200X more performant!
#--> 212.00

StopProfiler()
# Executed in  0.06 second(s) in Ring 1.21
# Executed in 12.72 second(s) in Ring 1.17

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

? @@( o1.FindSubStringsBoundedByIBZZ([ "[[[", "]]]" ]) ) + NL
#--> [ [ 1, 36 ], [ 47, 101 ], [ 118, 130 ] ]

? @@NL( o1.SubStringsBoundedByIB([ "[[[", "]]]" ]) )

#--> [
#	'[[[
#		"1", "1",
#			[[["2", "♥", "2"]]]',
#
#	#--
#
#	'[[["2",
#				[[["3", "♥",
#					[[["4",
#						[[["5", "♥"]]]',
#
#	#--
#
#	'[[["5","♥"]]]'
#
# ]
# Executed in 0.64 second(s)

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

o1.ReplaceAnyBoundedBy([ "[", "]" ], "***")
? o1.Content()
#-->
# [***]]],
#	"1",
#		[***]]],
#				"4",
#					[***]]],
#				"♥"]]],
#			"3"]]]
#		]]]
#
# ]]]

StopProfiler()
# Executed in 0.04 second(s)

/*-----------

StartProfiler()

o1 = new stzString('Hello ]---[Ring!]---[')

o1.RemoveSubStringsBoundedByIB([ "]","[" ])
? o1.Content()
#--> Hello Ring!

StopProfiler()
# Executed in 0.04 second(s)

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
#--> Executed in 0.07 second(s)

/*==============

StartProfiler()

o1 = new stzList([ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "🌞"] ] ])

? o1.DeepContains("🌞")
#--> TRUE

? o1.DeepContainsMany([ "1", "♥", "3", "🌞" ]) # Or DeepContainsThese()
#--> TRUE

? o1.DeepContainsBoth("♥", :And = "🌞")
#--> TRUE

? o1.DeepContainsOneOfThese(["_", "🌞", "0" ])
#--> TRUE

? o1.DeepContainsNOfThese(2, ["_", "🌞", "0", "♥" ])
#--> TRUE

StopProfiler()
# Executed in 0.02 second(s).

/*==============

pron()

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortBy('len(@item)')
? o1.Content()
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

proff()
# Executed in 0.04 second(s).

/*==============

pron()

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

o1.RemoveFirst("_")
? @@( o1.Content() )
#--> [ "B", "C", "D", "E" ]

o1.RemoveThisFirstItemCS("b", :CS = FALSE)
? @@( o1.Content() )
#--> [ "C", "D", "E" ]

o1.RemoveNthItem(:Last) # CheckParams() should be TRUE, otherwise :Last raises an error
			# You can use o1.RemoveNthItem(o1.NumberOfItems()) or
			# o1.RemoveLastItem() instead
? @@( o1.Content() )
#--> [ "C", "D" ]

proff()
# Executed in 0.02 second(s)

/*-----------------

StartProfiler()

	o1 = new stzList([ "A", "B", "A", "C", "C", "D", "A", "E" ])
	
	? @@NL( o1.Index() ) # Or FindItems() or ItemsZ() or ItemsAndTheirPositions()
	#--> [
	# 	[ "A", [ 1, 3, 7 ] ],
	# 	[ "B", [ 2 ] ],
	# 	[ "C", [ 4, 5 ] ],
	# 	[ "D", [ 6 ] ],
	# 	[ "E", [ 8 ] ]
	# ]

StopProfiler()
#--> Executed in almost 0 second(s).

/*-----------------

pron()

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

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList([ ".",".",".",4 ,5 ,6 ,".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 3)
#--> [ 4, 5, 6 ]

? o1.PreviousNItems(3, :StartingAtPosition = 7)
#--> [ 4, 5, 6 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*=================

pron()

o1 = new stzList([ 7, 3, 3, 10, 8, 8 ])

? o1.Smallest()
#--> 3

? o1.Largest()
#--> 10

? @@( o1.FindSmallest() )
#--> [2, 3]

? o1.NumberOfOccurrencesOfSmallestItem()
#--> 2

# or more simply

? o1.NumberOfSmallest()
#--> 2

? @@( o1.FindLargest() )
#--> [ 4 ]

? o1.NthSmallest(3)
#--> 8

? @@( o1.FindNthSmallest(3) )
#--> [ 5, 6 ]

proff()
# Executed in 0.01 second(s).

/*================= #TODO

pron()

o1 = new stzList([ ".", ".", "3", "4", ".", ".", "7", "8", "9", ".", "." ])

? o1.YieldXT( '@item', :FromPosition = 4, :To = -3)
#--> [ ".", ".", "7", "8", "9" ]

? o1.YieldXT( '@char', :StartingAt = 3, :Until = ' @item = "." ' )
#--> [ "3", "4" ]

? o1.YieldXT( '@char', :StartingAt = 3, :UntilXT = ' @item = "." ' )
#--> [ "3", "4", "." ]

proff()

/*=================

pron()

? @@( Q([ "AB", 12, ["A", "B"] ]).TypesXT() )
#--> [ [ "AB", "STRING" ], [ 12, "NUMBER" ], [ [ "A", "B" ], "LIST" ] ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList(["1","2","3","4","5"])

? o1.Section(2, 4)
#--> [ "2","3","4" ]

? o1.SectionXT(2, -2)
#--> [ "2","3","4" ]

? o1.Section(:First, :Last)
#--> ["1","2","3","4","5"]

? o1.Section(3, :@)
#--> [ "3" ]

? o1.Section(:@, 3)
#--> [ "3" ]

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

o1 = new stzList([ "T", "A", "Y", "O", "U", "B", "T", "A" ])
? @@NL( o1.SectionsBetween( "T", "A" ) )
#--> [
#	["T", "A"],
#	[ "T", "A", "Y", "O", "U", "B", "T", "A" ],
#	["T", "A"]
# ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList([ "1", "2", "abc", "4", "5", "abc", "7", "8", "abc" ])

? o1.FindAll("abc")
#--> [ 3, 6, 9 ]

#NOTE: the following functions work the same for stzString and
# stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "abc") 
#--> [ 3, 6 ]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 1)
#--> [ 3, 6 ]

? o1.NLastOccurrences(2, :Of = "abc")
#--> [ 6, 9 ]

? o1.NLastOccurrencesST(2, "abc", :StartingAt = 1)
#--> [ 6, 9 ]

? o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 6)
#--> [ 6, 9 ]

? o1.LastNOccurrencesST(1, :Of = "abc", :StartingAt = 9)
#--> [ 9 ]

proff()
# Executed in 0.06 second(s).

/*------------------

pron()

# The W() small function take a string (containing a condition)
# and returns a list of the form :Where = ...

? W(' isString(@item) and isLower(@item) ')
#--> [ "where", " isString(@item) and isLower(@item) " ]

proff()
# Executed in almost 0 second(s).

/*------------------ #TODO

pron()

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('len(@item)')
#--> [10, 10, 10]

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('StzLen(@item)')
#--> [5, 5, 5]

proff()

/*------------------

pron()

? StzTextQ("你好").Script()
#--> :Han

proff()
# Executed in 0.04 second(s).

/*------------------

pron()

? Stz(:Text, :Attributes)
#--> [
#	"@oobject",
#	"@cVarName",
#	"@oqstring",
#	"@@aconstraints",
#	"@clanguage"
# ]

proff()
# Executed in 0.03 second(s).

/*================

pron()


? InfereType("string")
#--> string

? InfereType("strings")
#--> strings

proff()
# Executed in 0.01 second(s).

/*-------------------

pron()

? Q([ "ring", "php", "python" ]).Are([ :Lowercase, :Strings ])
#--> TRUE

? Q([ "ABC", "DEF", "GHI" ]).Are([ :Uppercase, :Strings ])
#--> TRUE

proff()
# Executed in 0.11 second(s).

/*------------------

pron()

? TQ("واحد").IsArabic()
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*------------------

pron()

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are(:Strings)
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :Arabic, :Strings ])
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :ArabicScript, :RightToLeft, :Texts ])
#--> TRUE

proff()
# Executed in 0.26 second(s).

/*------------------ #TODO

pron()

? Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ])
#--> TRUE

proff()

/*------------------

pron()

? W('len(@item)=3')
#--> ( "where", "len(@item)=3" ]

proff()
# Executed in almost 0 second(s).

/*------------------

pron()

? Q([ "ONE", "TWO", "THREE" ]).Are(:Strings)
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Latin, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Strings ])

proff()
# Executed in 0.28 second(s) in Ring 1.21

/*------------------

pron()

? InfereType(:Numbers)
#--> number

proff()

/*------------------

pron()

? Q([ 1, 2, 3 ]).Are(:Numbers)
#--> TRUE

? Q([ -2, -4, -8 ]).Are([ :Even, :Negative, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Positive, :Numbers ])
#--> TRUE

? Q([ "(",";", ")" ]).Are([ :Punctuation, :Chars ])
#--> TRUE

proff()
# Executed in 0.28 second(s).

/*============= #TODO check error
*
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

pron()

o1 = new stzList([ "A", 0, 0, "B", "C", 0, "D", 0, 0 ])
? o1.ZerosRemoved()
#--> [ "A", "B", "C", "D" ]

proff()
# Executed in almost 0 second(s).

/*============= #narration COMPARING LISTS FOR EQUALITY

pron()

# In Ring, you can't check two equal listq for equality,
# and if you do, you get FALSE as result:

? [ 1, 2 ] = [ 1, 2 ]
#--> FALSE

# That's because Ring compares lists by reference not
# by value. When you create two separate lists [ 1, 2 ],
# even though they contain the same values, they are
# distinct objects in memory.

# We can do it differently in Ring by casting the
# lists to strings using lis2str like this:

? list2str([ 1, 2 ]) = list2str([ 1, 2 ])
#--> TRUE

# Softanza provides a more direct and elegant solution by
# simply using the Q() small function with the first list:

? Q([ 1, 2 ]) = [ 1, 2 ]
#--> TRUE

# Hence, the first [ 1, 2 ] is elevated to a stzList, and
# the = operator is used to call internally the IsEqual()
# method to compare the object content with the second list.

# It seems to be a minor feature, but in practice it can
# save us some tricky situations like this:

aMyList = [ 1, 2 ]

if aMyList = [ 1, 2 ]
	? "I'm done :)"
else
	? "Ooops!"
ok
#--> Oppps!

# Here is the same code enabled with Softanza Q() magic:

aMyList = [ 1, 2 ]

if Q(aMyList) = [ 1, 2 ]
	? "I'm really done! Thanks Softanza :)"
else
	? "Ooops!"
ok
#--> "I'm really done! Thanks Softanza :)"

proff()
# Executed in 0.01 second(s).

/*---------

pron()

o1 = new stzList([ 0, 2, 0, 3, [1,2] ])
? o1.IsListOfNumbersAndPairsOfNumbers()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*========= Deep finding items at any level

pron()

o1 = new stzList([
	"you",
	"other",
	[ "other", "you", [ "you" ], "other" ],
	"other",
	"you"
])

? o1.NumberOfLevels()
#--> 3

? @@( o1.DeepFind("you") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 1 ], [ 1, 4 ] ]

#~> the item "you" is found at:
#	- posisitons 1 and 4 in level 1
#	- position 2 in level 2
#	- position 1 in level 4

proff()
# Executed in 0.03 second(s).

/*========= Replace and DeepReplace

pron()

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.Replace("me", :By = "you")
? @@NL( o1.Content() ) + NL

#--> [
#	"you",
#	"other",
#	[ "other", "me", [ "me" ], "other" ],
#	"other",
#	"you"
#    ]

proff()
# Executed in almost 0 second(s).

/*---

pron()

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.DeepReplace("me", :By = "you")
? @@NL( o1.Content() )

#--> [
#	"you",
#	"other",
#	[ "other", "you", [ "you" ], "other" ],
#	"other"
#    ]

proff()
# Executed in 0.01 second(s).

/*================

pron()

# to get the background of this sample, read this:
# https://groups.google.com/g/ring-lang/c/_33L7miE3QM

# First way: Substring first

o1 = new stzString("ACD")
o1.Insert("B", :AtPosition = 2)
? o1.Content()
#--> "ABCD"

# Second way: Position first

o1 = new stzString("ACD")
o1.InsertAt( :Position = 2, :SubString = "B")
? o1.Content()
#--> "ABCD"

# Short forms:

o1.Insert("B", 2)
o1.InsertAt(2, "B")
? o1.Content()
#--> ABBBCD

#TODO // add ( :Position = ... and :SubString = ... ) everywhere!
#UPDATE: done!

proff()
# Executed in 0.02 second(s).

/*--------------

pron()

# Same example above in stzList

o1 = new stzList([ "A", "C", "D" ])
o1.InsertAt(2, "B")

? o1.Content()
#--> [ "A", "B", "C", "D" ]

proff()
# Executed in almost 0 second(s).

/*--------------

pron()

# Same example above in stzListOfStrings

o1 = new stzListOfStrings([ "A", "C", "D" ])
o1.Insert("B", :AtPosition = 2)			# or you can say: o1.InsertAt(2, "B")
? o1.Content()
#--> [ "A", "B", "C", "D" ]

proff()
# Executed in 0.04 second(s).

/*--------------

pron()

o1 = new stzList([ "A1", "A2", "A3" ])
o1.InsertAfter( :ItemAtPosition = 3, "A4" )
? o1.Content()
#--> [ "A1", "A2", "A3" ]

proff()
# Executed in 0.01 second(s).

/*================ MOVING AND SWAPPING

pron()

o1 = new stzList([ "C", "B", "A" ])
o1.Move( :From = 3, :To = 1 )
? o1.Content() #--> [ "A", "C", "B" ]

o1.Swap( :Items = 2, :AndItem = 3 )
? o1.Content() #--> [ "A", "B", "C" ]

proff()
# Executed in 0.06 second(s).

/*--------------- #narration Writablilty VS Readablility VS Both of them!

pron()

# Softanza coding style is designed with a double promise in mind:
#  - Your code is WRITABLE: Easy to you while your are crafting it
#  - As well as READBALE: Easy easy to your reader to understand it.

# I'll explain this by code.

# Let's have a list, and then take two items inorder to swap them:

o1 = new stzList([ "C", "B", "A" ])

# You can quickly write:

o1.Swap(1, 3)
? o1.Content()
#--> ["A", "B", "C"]

# And you are done! Which means litterally: "swap items at positions 1 and 3".

# The point is that Softanza talks in near natural language tongue,
# and the sentence above can be written as-is in plain Ring code:

o1.SwapItems( :AtPositions = 1, :And = 3)

# It's: What You Think Is What You Get.

? o1.Content()
#--> [ "C", "B", "A" ]

# Let's recapitulate:

# WRITABILITY: you quickly write a function, always in a short form,
# without complications, because you need to focus on the thinking
# behind the solution not the underling syntax.

# READBILITY : Others, or yourself in the future, can read the function
# and understand the intent of its writer without referring
# to any external documentation).

# And in Softanza, you have them both...

proff()
# Executed in 0.02 second(s).

/*---------------

pron()

o1 = new stzList([ "ONE", "TWO", "THREE" ])
? o1 - "TWO"
#--> [ "ONE", "THREE" ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

? Q([ "I", "B", "M" ]).HasSameContent( :As = [ "B", "M", "I" ] )
? Q([ "I", "B", "M" ]).HasSameContentCS( :As = [ "b", "m", "i" ], :CS = FALSE )

proff()
# Executed in almost 0 second(s).

/*--------------- #narration SEMANTIC PRECISION

pron()

? Q("SFTANZA").IsLargerThan("RING")
#--> TRUE

# or if you want to be precise:
? Q("SFTANZA").HasMoreChars(:Than = "RING")
#--> TRUE

#--

? Q("RING").IsSmaller(:Than = "SFTANZA")
#--> TRUE

# or if you want to precise:

? Q("RING").HasLessChars(:Than = "SFTANZA")
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*---------------

pron()

? Q([1, 2, 3, 4, 5]).IsLarger(:Than = [8, 9])
#--> TRUE

# or if you want to precise:

? Q([1, 2, 3, 4, 5]).HasMoreItems(:Than = [8, 9])
#--> TRUE

#--

? Q([8, 9]).IsSmaller(:Than = [1, 2, 3, 4, 5])
#--> TRUE

# or if you want to precise:
? Q([8, 9]).HasLessItems(:Than = [1, 2, 3, 4, 5])
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ "arem", "mohsen", "AREM" ])

? o1.FindAll("arem")
#--> [ 1 ]

? o1.FindAllCS("arem", :CS = FALSE)
#--> [1, 3]

? o1.FindNth(2, "arem")
#--> 0

? o1.FindNthCS(2, "arem", :CS = FALSE)
#--> 3

proff()
# Executed in 0.02 second(s).

/*---------------

pron()

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])
? o1.NthToLast(2)
#--> "N"

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])

? o1.Section(1, 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(4, 1)
#--> [ "S", "O", "F", "T" ]

? o1.Section(:From = 1, :To = 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(:From = (:NthToLastItem = 3), :To = :LastItem)
#--> [ "A", "N", "Z", "A" ]

? o1.Section(:From = "F", :To = "A")
#--> [ "F", "T", "A", "N", "Z", "A" ]

? o1.Section( :From = "A", :To = :EndOfList )
#--> [ "A", "N", "Z", "A" ]

? o1.Section(4, :@)
#--> "T"

? o1.Section(:NthToLast = 3, :@)
#--> "A"

? o1.Section(:@, :@)
#--> [ "S", "O", "F", "T", "A", "N", "Z", "A" ]

//? @@( o1.Section(-99, 99) ) + NL
#--> ERROR: Line 2453 Indexes out of range! n1 and n2 must be inside the list.

proff()
# Executed in 0.13 second(s).

/*=======================

pron()

# In Softanza, you can find lists inside lists:

o1 = new stzList([ "A", "B", [1, 2], "C", "D", [1, 2], "E" ])

? o1.FindAll([1, 2])
#--> [3, 6]

? o1.FindFirst([1, 2]) + NL
#--> 3

# And you can go deep and find even more complicated lists:

o1 = new stzList([
		"A", "B",
		[ 1, ["v", ["u"] ], 2 ],
		"C", "D",
		[ 1, ["v", ["u"] ], 2 ],
		"E"
])

? o1.FindAll( [ 1, ["v", ["u"] ], 2 ] )
#--> [ 3, 6]

? o1.FindFirst([ 1, ["v", ["u"] ], 2 ])
#--> 3

proff()
# Executed in 0.02 second(s).

/*-----------------------

pron()

o1 = new stzList([ 1, 2 ])

? o1.IsEqualTo([ 1, 2 ])
#--> TRUE

? o1.IsEqualTo([ 2, 1 ])
#--> TRUE

? o1.IsStrictlyEqualTo([ 2, 1 ])
#--> FALSE

? o1.IsStrictlyEqualTo([ 1, 2 ])
#--> TRUE

proff()
# Executed in 0.04 second(s).

/*-----------------------

pron()

o1 = new stzList([ [1,2], [3, [1], 4], [5,6], [ 2, 10 ], [3,4], [3, [1], 4] ])

? o1.FindAll( [3, [1], 4] )
#--> [2, 6]

? o1.FindFirst( [3, [1], 4] )
#--> 2

proff()
# Executed in 0.02 second(s).

/*===============

pron()

? StzListQ( 4:8 ).ToListInString()
#--> "[ 4, 5, 6, 7, 8 ]"

? StzListQ( 4:8 ).ToListInStringInShortForm()
#--> "4:8"

proff()
# Executed in 0.06 second(s).

/*---------------

pron()

o1 = new stzList([ 4, 1, 2, 1, 1, 2, 3, 3, 3 ])
? o1.DuplicatesRemoved()
#--> [ 4, 1, 2, 3 ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

? o1.FindAll(1:3)
#--> [1, 3, 4]

? o1.Contains(7:10)
#--> TRUE	

proff()
# Executed in 0.02 second(s).

/*---------------

pron()

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

o1.Removeduplicates()
? @@( o1.Content() )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9, 10 ] ]

proff()
# Executed in almost 0 second(s).

/*================

pron()

? Q(' [ "A", "B", 3 ] ').IsListInString()
#--> TRUE

? Q(' 1 : 3 ').IsListInString()
#--> TRUE

? Q(' "A" : "C" ').IsListInString()
#--> TRUE

? Q(' "ا" : "ج" ').IsListInString()
#--> TRUE

proff()
# Executed in 0.07 second(s).

/*-----------------

pron()

? Q(' "A" : "C" ').ToList()
#--> [ "A", "B", "C" ]

? Q(' "ا" : "ج" ').ToList()
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

proff()
# Executed in 0.09 second(s).

/*=============== #narration Generalisation of the Ring "A":"B" syntax 

pron()

# In Ring, you can declare a "contiguous" list of chars
# from "A" to "F" like this:

StzListQ("A":"F") {
	? Content()
	#--> [ "A", "B", "C", "D", "E", "F" ]

	? ItemAtPosition(4) + NL #--> "D"
}

# This beeing working only for ASCII chars, Softanza comes
# with a general solution for any "contiguous" UNIOCDE char:

StzListQ( L(' "ا" : "ج" ') ) {
	? Content()
#	#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

	? ItemAtPosition(4)
#	#o--> "ت"
}

proff()
# Executed in 0.07 second(s) in Ring 1.21

/*----------------- #narration : Use of the L() small function

pron()

# As we all know, Ring provides us with this elegant syntax:

aList = "A" : "D"
? @@( aList )
#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# And if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? @@( aList )
#o--> "ا"

# Fortunately, Softanza solves this by the L() small function:

? @@( L( ' "ا" : "ج" ') )
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? @@( L(' "A" : "D" ') )
#--> [ "A", "B", "C", "D" ]

# Interestingly, you can get an other form of a numbered list of strings:

? @@( L(' "Ring1" : "Ring2" ') )
#--> [ "Ring1", "Ring2", "Ring3", "Ring4", "Ring5" ]

# This works also for any unicode string:

? L(' "كلمة1" : "كلمة3" ')
#o--> [ "كلمة3", "كلمة2", "كلمة1" ]

# On the other hand, as you kow, the _:_ syntax in Ring
# works also for numbers, like this:

? 1:5
#--> [ 1, 5 ]

# But it suports only integers and not real numbers (with decimals):

? 1.02 : 3.08
#--> [ 1, 2, 3 ]

# While in Softanza, using the magic of L() function, you can enumarate
# all the real numbers inbetween, what ever decimal part they have:

? L(' 1.02 : 1.05 ')
#--> [ 1.02, 1.03, 1.04, 1.05 ]
 
# Finally, if the string you feed to L() function contains a list written
# in Ring form, than the function will evaluate it and return it:

? L('[ 1, 2, 3 ]')
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.23 second(s).

/*================

pron()

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

 	? @@SP( Classify() ) + NL
	#--> [
	# 	:Arabic  = [ 1, 2, 8 ],
	# 	:French  = [ 3 ],
	# 	:Enslish = [ 4, 7 ],
	#    	:Spanish = [ 5, 6 ]
	#    ]

	? Classes()
	#--> [ :Arabic, :French, :English, :Spanish ]

	? NumberOfClasses()
	#--> 4
}

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzList([
	1982, 1964, 1992, 1982, 1964, 2001, 1982, 1992, 2000
])

? @@SP( o1.Classify() )
#--> [
# 	:1982 = [ 1, 4, 7 ],
# 	:1964 = [ 2, 5 ],
# 	:1992 = [ 3, 8 ],
# 	:2001 = [ 6 ],
# 	:2000 = [ 9 ]
#    ]

#NOTE that list items are stringified.

proff()
# Executed in 0.01 second(s).

/*----------------- #narration LIST CLASSIFICATION

pron()

o1 = new stzList([
	1:5, 3:9, 1:5, 10:15, 3:9, 12:20, 10:15, 1:5, 12:20
])

? @@SP( o1.Classify() )	+ NL # Same as Categorize()
#--> [
#	[ "[ 1, 2, 3, 4, 5 ]",   [1, 3, 8 ] ],	
#	[ "[ 3, 4, 5, 6, 7, 8, 9 ]",   [2, 5 ] ],
#	[ "[ 10, 11, 12, 13, 14, 15 ]", [4, 7 ] ],
#	[ "[ 12, 13, 14, 15, 16, 17, 18, 19, 20 ]", [6, 9 ]
#    ]

#NOTE that lists are transformed to strings so we can use them
# as keys for idenfifying their positions in the hash string.

# Hence we can say:

? @@( o1.Klass("[ 1, 2, 3, 4, 5 ]") ) + NL
#--> [1, 3, 8 ]

# Here, I used "K" because "Class" is a reserved name by Ring.
# If you don't like that, use Category() instead.

# If you prefer getting the classes in "short form" (i.e. "1:5"
# instead of normal form "[1, 2, 3, 4, 5 ]", then use this:

? @@SP( o1.ClassifySF() ) + NL #--> "@C" for "Contiguous" or "Continuous"
#--> [
#	[ "1:5",   [1, 3, 8 ] ],	
#	[ "3:9",   [2, 5 ] ],
#	[ "10:15", [4, 7 ] ],
#	[ "12:20", [6, 9 ]
#    ]

? @@( o1.ClassesSF() ) + NL
#--> [ "1:5", "3:9", "10:15", "12:20" ]
	
? @@( o1.KlassSF("1:5") )
#--> [1, 3, 8]

proff()
# Executed in 0.42 second(s).

/*=================

pron()

? StzStringQ(:stzList).IsStzClassName()
#--> TRUE

? StzListQ( :ReturnedAs = :stzList ).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? StzListQ([]).IsListOfStrings()
#--> FALSE

? StzListQ([]).IsListOfNumbers()
#--> FALSE

proff()

/*----------------- #narration HASHLIST SYNTAX :key = value

pron()

# In Ring, this is how we can declare a hashlist using the :key = value syntax

? StzListQ([ :name = "Mansour", :age = 45 ]).IsHashList()
#--> TRUE

# Which is equivalent to the fellowing normal list declaration:

? StzListQ([ [ "name", "Mansour"], [ "age", 45] ]).IsHashList()
#--> TRUE

# But, becareful when using a normal string with =, it won't lead to a hashlist

? StzListQ([ "name" = "Mansour", "age" = 45 ]).IsHashList() + NL
#--> FALSE

# In fact, what we wrote are two FALSE expressions, since "name" is different
# from "Mansour" and "age" is different from 45:

? @@( [ "name" = "Mansour", "age" = 45 ] )
#--> [ 0, 0 ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? Numbers() #--> [ 1, 2, 3, 4, 5 ]
	# You can also say ? OnlyNumbers()

	? NonNumbers() # [ "A", "B", "C", "D" ]
	# You can also say OnlyNonNumbers()

	? Content()
	#--> [ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]

	# NOTE that the list is not altered by Numbers() and
	# NonNumbers() functions.

	# Now we alter it by removing numbers

	RemoveNumbers() #--> You can also say RemoveOnlyNumbers()
	? Content()
	#--> [ "A", "B", "C", "D" ] 
}

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? NonNumbers()	# You can also say ? OnlyNonNumbers()
	#--> [ "A", "B", "C", "D" ]
	
	RemoveNonNumbers() # Or RemoveOnlyNonNumbers() or RemoveAllExceptNumbers()
	? Content()
	#--> [ 1, 2, 3, 4, 5 ]

}

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These( o1.NonNumbers() )
#-->  [ 1, 2, 3, 4, 5 ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzListOfStrings([ "A", "B", "1", "C", "2", "3", "D", "4", "5" ])

? o1.FindFirstCS("b", TRUE)
#--> 0

? o1.FindFirstCS("b", :CS = FALSE)
#--> 2

proff()
# Executed in 0.13 second(s).

/*-----------------

pron()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1.Contains("a")
#--> FALSE

? o1.Contains("A")
#--> TRUE

? o1.ContainsNo("C")
#--> FALSE

? o1.ContainsNo("X")
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1.ItemsWXT('Q(@item).IsNotANumber()')
#--> [ "A", "B", "C", "D" ]

proff()
# Executed in 0.13 second(s).

/*-----------------

pron()

o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

? o1 - "A":"B"
#--> [ 1, 2, 3, "X", "Y", "Z" ]

? @@( o1 - These([ "X", "Y", "Z" ]) )
#--> [ 1, [ "A", "B" ], 2, 3 ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemoved(1:3)
#--> [ "A", "B", "C" ]

? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemovedW('isList(This[@i])')
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.04 second(s).

/*==================

pron()

? Q(1:5) - 3
#--> [ 1, 2, 4, 5 ]

? ( Q(1:5) - Q(3) ).Content()
#--> [ 1, 2, 4, 5 ]

? Q([ "A", "B", 1:3, "C" ]) - 1:3
#--> [ "A", "B", "C" ]

? ( Q([ "A", "B", 1:3, "C" ]) - Q(1:3) ).Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.02 second(s).

/*---------------

pron()

o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

? o1 - "A":"B"
# \____ ____/
#      V
#  A normal Ring list

#--> [ 1, 2, 3, "X", "Y", "Z" ]

? o1 - Q("A":"B") - These([ "X", "Y", "Z" ])
# \______ _____/
#        V
#  A stzList object due to the use of Q("A":"B")

#--> [ 1, 2, 3 ]


? o1 - Q("A":"B") - These([ "X", "Y", "Z" ]) + 4
# \___________________ ___________________/
#                     V
#             A normal Ring list
#         due to the use of These()

#--> [ 1, 2, 3, 4 ]

? o1 - Q("A":"B") - TheseQ([ "X", "Y", "Z" ]) + These([ 4, 5 ])
# \___________________ ____________________/
#                     V
#             A stzList object
#        due to the use of TheseQ()

#--> [ 1, 2, 3, 4, 5 ]

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3 ])

? @@( o1 * 3 )	#--> Leads to a normal Ring list
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]

? @@( o1 * Q(3) / 3 ) + NL
#     \___ ___/   \__ Leads to an output as a normal Ring list
#         V
#   A stzList object due to the use of the Q() small function

#--> [ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ] ]

#---

? Q([ "file1", "file2", "file3" ]) * ".ring"
#--> [ "file1.ring", "file2.ring", "file3.ring" ]

? ( Q([ "file1", "file2", "file3" ]) * Q(".ring") ) .Uppercased()
#   \______________________ ______________________/ \_____ _____/
#                          V                              V
#               StzList object (via Q())           Applied to the stzList object

#--> [ "FILE1.RING", "FILE2.RING", "FILE3.RING" ]


? Q([ "file1", "file2", "file3" ]) * Q(".ring").Uppercased()
#   \_____________ _____________/    \__________ _________/
#                 V                             V
#      StzList object (via Q())    An uppercasded ".RING" string
#
#   \__________________________ _________________________/
#                              V
# ~> Equivalent to: ? Q[ "file1", "file2", "file3" ]) * ".RING"

#--> [ "file1.RING", "file2.RING", "file3.RING" ]

proff()
# Executed in 0.05 second(s).

/*-----------------

pron()

o1 = new stzList([ "VALUE1", "VALUE2", "VALUE3" ])
o1.MultiplyBy([ 1001, 1002, 1003 ])
? @@SP( o1.Content() )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

? @@SP( Q([ "VALUE1", "VALUE2", "VALUE3" ]) * [ 1001, 1002, 1003 ] )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

? @@NL( Q([ 15, 25, 70]) * [ 2, 4, 6 ] )
#--> [
#	[ 15, [ 2, 4, 6 ] ],
#	[ 25, [ 2, 4, 6 ] ],
#	[ 70, [ 2, 4, 6 ] ]
# ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

#WARNING
# At a given point I decided to support = as an overloaded operator
# on Softanza objects so we can make equality check on them like
# in the code below:

	? Q("str") = "str"
	#--> TRUE
	
	? Q("str") = Q("str") = "str"
	#--> TRUE
	
	? Q(2+5) = 7
	#--> TRUE
	
	? Q(2+5) = Q(3+4) = 7
	#--> TRUE
	
	? Q(2+5) = Q(3+4) = Q(9-2) = 7
	#--> TRUE
	
	? Q(1:3) = Q(3:1) = [3, 1, 2]

# But after that, I was faced with several complications when I needed
# to write an = after an object just to assign a value to it, like:
#
# oTempObj = anyValue
#
# The problem happens when aTempObj is a Softanza object. In this case
# the = operator is no longer considered an assignment operator but
# fires the meaning we gave to it in the related Softanza class, which
# is not what I want.
#
# So, I decided to disqualify this feature and keep only the arithmetic
# opearors +, -, * and / as overloaded operators on Softanza objects.

proff()

/*-----------------

pron()

? ( Q([ "ONE", "TWO", "THREE" ]) * TrueObject() ).Content()
#                                  \_____ ____/
#					 V
#        A stzTrueObject holding the value TRUE ~> 1
#  \__________________________ __________________________/
#                             V
#       It's like if we wrote the fellowing expression:
#      ( Q([ "ONE", "TWO", "THREE" ]) * Q(1) ).Content()

#--> [ "ONE", "TWO", "THREE" ]

? @@( ( Q([ "ONE", "TWO", "THREE" ]) * Q(2) ).Content() )
#--> [ "ONE", "TWO", "THREE", "ONE", "TWO", "THREE" ]

proff()
# Executed in 0.03 second(s).

/*-----------------

pron()

? @stztype( Q( "X":"Z" ) )
#-- stzlist

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3 ])
? @@( o1 + Q(4) + 5 )
#--> [ 1, 2, 3, 4, 5 ]

? @@( (o1 + Q("X" : "Z")).content() )
#--> [ 1, 2, 3, [ "X", "Y", "Z" ] ]

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3 ])

? @IsStzObject(o1)
#--> TRUE

? @IsStzList(o1)
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

? @@( ( Q([1, 2, 3]) + Q([ 4, 5 ]) ).Content() )
#--> [ 1, 2, 3, [ 4, 5 ] ]

? Q([1, 2, 3]) + Obj(Q([ 4, 5 ]))
#--> [ 1, 2, 3, Q([ 4, 5 ] ]

? Q([1, 2, 3]) + ObjQ(Q([ 4, 5 ])) + 6
#--> [ 1, 2, 3, Q([ 4, 5 ], 6 ]

proff()
# Executed in 0.02 second(s).

/*----------------- #narration Use of AsObject() with + operator

pron()

# When you add a normal list to a stzList object,
# you get a normal list:

? @@( Q([1,2]) + [3, 4] ) + NL
#--> [ 1, 2, [ 3, 4 ] ]

# To return the result in a stzList object (to make
# other actions on it), you elevate the added list
# with a Q() elevator like this:

? @@( ( Q([1, 2]) + Q([3, 4]) ).Content() ) + NL
#      \__________ __________/
#                 V
#          A stzList object

#--> [ 1, 2, [ 3, 4 ] ]

# Now: what if you need to add a stzList and not
# a normal list? You use AsObject() like this:

? @@( Q([1, 2]) + AsObject( Q([3, 4]) ) ) + NL # Or Obj() or simply O()
#--> [ 1, 2, Q([3,4]) ]

# ~> Q([3, 4]) which is is a stzList object is then added
# to the Q([1, 3]) list as an object.

# To add an object and return a stzList, use AsObjectQ():

? @@( ( Q([1, 2]) + AsObjectQ( Q([3, 4]) ) ).Content() ) # Or ObjQ() or simply OQ()
#      \________________ ________________/
#                       V
# 		 A stzList object

#--> [ 1, 2, Q([3,4]) ]

# REMINDER: You can add many items at once using These:

? @@( Q([1, 2]) + These([3, 4]) ) + NL
#--> [ 1, 2, 3, 4 ]

? @@( ( Q([1, 2]) + TheseQ([3, 4]) ).Content() )
#      \_____________ _____________/
#                    V
#            A stzList object
#     due to the use of Q in TheseQ()

#--> [1, 2, 3, 4 ]

proff()
# Executed in 0.03 second(s).

/*----------------- #narration HOW TO RETRIVE A NAMED OBJECT USING v()

pron()

o1 = StzNamedStringQ(:mystr = "Hello!")

? v(:mystr).Content()
#--> "Hello!"

o2 = StzNamedListQ(:mylst = 1:3 )
? v(:mylst).Content()
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzNumber(12500)

? o1 / 500
#--> 25

# Note that the / operator does not change the o1 content:

? o1.Content()
#--> 12500

proff()
# Executed in 0.08 second(s).

/*-----------------

pron()

? Q(12500) / 500
#--> 25

? ( Q(12500) / Q(500) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 50

proff()
# Executed in 0.14 second(s).

/*-----------------

pron()

? Q(12500) + 500
#--> 13000

? ( Q(12500) + Q(500) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 26000

proff()
# Executed in 0.14 second(s).

/*-----------------

pron()

? Q(15) * 7
#--> 105

? ( Q(15) * Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 210

proff()
# Executed in 0.11 second(s).

/*-----------------

pron()

? Q(15) - 7
#--> 8

? ( Q(15) - Q(7) ) * 2
#  \_________ _______/
#            V
#    A stzNumber object due to the use of Q() in Q(500)

#--> 16

proff()
# Executed in 0.09 second(s).

/*-----------------

pron()

? Q("ABCDEFGHI") / 3
#--> [ "ABC", "DEF", "GHI" ]

? ( Q("ABCDEFGHI") / Q(3) ).StzType() + NL
#--> stzlist

? ( Q("ABCDEFGHI") / Q(3) ).Lowercased()
#--> [ "abc", "def", "ghi" ]

? Q("ABC") + "D"
#--> "ABCD"

? ( Q("ABC") + Q("D") ).Lowercased()
#--> "abcd"

proff()
# Executed in 0.05 second(s).

/*-----------------

pron()

? Q("ABC") * 3
#--> "ABCABCABC"

? ( Q("ABC") * Q(3) ).StzType() + NL
#--> stzstring

? ( Q("ABC") * Q(3) ).Lowercased()
#--> "abcabcabc"

? Q("ABC") * " -> "
#--> "A -> B -> C -> "

? ( Q("ABC") * Q(" -> ") ).Lowercased()
#--> "a -> b -> c -> "

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

o1 = new stzString("A**BC***DE***")
? o1 - "*"
#--> ABCDE

# Note that o1 content did not change:

? o1.Content()
#--> A**BC***DE***

proff()
# Executed in 0.01 second(s).

/*-----------------

pron()

? Q("A**BC***DE***") - 3	# Remove the last 3 chars
#--> "A**BC***DE"

? Q("A**BC***DE***") - "*"
#--> ABCDE

? ( Q("A**BC***DE***") - Q("*") ).StzType() + NL
#--> stzstring

? ( Q("A**BC***DE***") - Q("*")  ).Lowercased()
#--> abcde

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

? Q("ABCABCABC") / 3	# Remove the last 3 chars
#--> [ "ABC", "ABC", "ABC" ]

? Q("ABC-ABC-ABC") / "-"
#--> [ "ABC", "ABC", "ABC" ]

? ( Q("ABC-ABC-ABC") / Q("-") ).StzType() + NL
#--> stzlist

? ( Q("ABC-ABC-ABC") / Q("-")  ).Lowercased()
#--> [ "abc", "abc", "abc" ]

proff()
# Executed in 0.04 second(s).

/*-----------------

pron()

? Basmalah() + NL
#o--> ﷽

oNamedList = StzNamedListQ(:MyList = [ "A", "B", "C" ])

o1 = new stzList([ 1, 2, 3, [ "X", "Y", "Z" ], 4, oNamedList, 5 ])

? @@( o1 - [ "X", "Y", "Z" ] ) + NL
#--> [ 1, 2, 3, 4, mylist, 5 ]
#		      |
#	The name list called mylist
# You can check it using the small function		
	 ? v(:MyList).Content()
#	 #--> [ "A", "B", "C" ]

# NOTE: o1 initial content stays as is.

# Let's try to remove the oNamedList

? @@( ( o1 - oNamedList ).Content() ) + NL
#      \_______ _______/
#              V
#       A stzList object

#--> [ 1, 2, 3, [ "X", "Y", "Z" ], 4, mylist, 5 ]

# If you need to return the output in a normal list,
# use the Obj() small function like this:

? @@( o1 - O(oNamedList) ) # Or Obj() of AsObject()
#--> [ 1, 2, 3, [ "X", "Y", "Z" ], 4, 5 ]

proff()
# Executed in 0.05 second(s).

/*-----------------

pron()

o1 = new stzList([ 1, 2, 3 ])

? @@( o1 + [ "X", "Y", "Z" ] )
#          \_______ _______/
#                  V
#      Like in Ring, this is added
#     as an item to end of the list

#--> [ 1, 2, 3, [ "X", "Y", "Z" ] ]

# BE CAREFUL: Object content did not change!

? o1.Content()
#--> [ 1, 2, 3 ]

? o1 + Q( "X" : "Z" ) - These([ 1, 2, 3 ]) 
# \________ ________/   \________ _______/
#          V                     V
#  A stzList object      Items are removed
# due to the use of       one by one from
#   Q() eleveator      the list due to These()

#--> [ "X", "Y", "Z" ]


? o1 - Q("X":"Z") + These([ 4, 5 ]) + 6
# \_______________ _______________/
#                 V
#      A normal Ring list due
#        the use of These()

#--> [ 1, 2, 3, 4, 5, 6 ]

? o1 - Q(1) - Q(2) - TheseQ([ 3, 6 ]) + These([ "X", "Y", "Z" ])
# \________________ ________________/
#                  V
#           A stzList object
#      due to the use of TheseQ()

#--> [ "X", "Y", "Z" ]

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*=================

pron()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These([ "A", "B", "C", "D" ])
#--> [ 1, 2, 3, 4, 5 ]

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1 - These( o1.ItemsW('NOT isNumber(This[@i])') )
#             \_______________ ________________/
#                             V
#                   [ "A", "B", "C", "D" ]

#--> [ 1, 2, 3, 4, 5 ]

proff()
# Executed in 0.05 second(s).

/*================

pron()

StzListQ([ "by", "except"]) { 

	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ])
	#--> TRUE

	# Same as:

	? IsMadeOfSome([ :by, :except, :stopwords ])
	#--> TRUE
}

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

? IsBoolean(FALSE)
#--> TRUE

? Q(TRUE).IsBoolean()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

o1 = new stzList([ "by", "except", "stopwords" ])
? o1.IsMadeOfThese([ :by, :except, :stopwords ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*================

pron()

? StzListQ([ "q", "r", [ 2, 1 ] ]).ToCode()
#--> [ "q", "r", [ 2, 1 ] ]

# Or you can use this alternative short form:

? @@( [ "q", "r", [ 2, 1 ] ] ) + NL # same as ComputableForm()
#--> [ "q", "r", [ 2, 1 ] ]

proff()
# Executed in almost 0 second(s).

/*===============

pron()

? StzListQ([ "q", "r", [ 2, 1 ] ]).Contains([ 2, 1 ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameContentAs([ "r", [ 2, 1], "q" ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameSortingOrderAs([ "r", [ 2, 1], "q" ])
#--> FALSE

? StzListQ([ "q", "r", [ 2, 1] ]).IsEqualTo([ "q", "r", [2, 1] ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------

pron()

? StzListQ([]).Contains(NULL)
#--> FALSE

? StzListQ([NULL]).Contains(NULL)
#--> TRUE

? StzListQ([]).IsListOfStrings()
#--> FALSE

? StzListQ([ NULL, NULL, NULL]).IsListOfStrings()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*==================

pron()

o1 = new stzList([ "fa", "bo" , "wy" , "wo" ])
? @@( o1 - These([ "bo", "wo" ]) )
#--> [ "fa", "wy" ]

proff()
# Executed in almost 0 second(s).

/*==================

pron()

? IsListOfStrings([ "baba", "ommi", "jeddy" ])
#--> TRUE

? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}
#-->
#	 [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#	  --^--------------^---------^-------------------^------------

# WARNING: works only for list of chars
#TODO : Generalize it for list of strings and other types

proff()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.20

/*------------------ TODO: Add this function (future)

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindXT("A")
}

#--> Returns a string like this:

#	     1    2    3    4    5    6    7    8    9    0    1    2
#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^--------------^---------^-------------------^------------ (4)

proff()

/*------------------ #TODO (future)

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindMany([ "A", "B", "C", "D" ])
}

# !--> Returns a string like this:

#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^----.----.----^----.----^---------.----.----^---------.--
#   "B" :  -------^----.---------.--------------^----.--------------.--
#   "C" :  ------------.---------^-------------------.--------------^--
#   "D" :  ------------^-----------------------------.-----------------

proff()

/*------------------ #TODO (future)

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

pron()

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrenceST(2, :Of = "A", :With = "*", :StartingAt = 2 )
	? Content()
	#--> [ "A" , "B", "C", "A", "D", "*" ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*------------------

pron()

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of = "A", :By = "*", :StartingAt = 5)
	? Content() #--> [ "*" , "B", "C", "A", "D", "A" ]
}

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

StzListQ([ -1 , 2, 3, 4 ]) {

	? NumberOfItemsWXT("Q(@item).IsBetween(1, 4)")
	#--> 2

	? NumberOfItemsWXT("Q(@item).IsBetweenIB(1, 4)")
	#--> 3
}

proff()
# Executed in 0.13 second(s) in Ring 1.21

/*------------------

pron()

o1 = new stzList([ "1", "2", "*", "4", "5" ])

o1.ReplaceAt(3, :By = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrenceST( 2, :Of = "_", :With = "5", :StartingAt = 3)
? @@( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

proff()
# Executed in 0.03 second(s)  in Ring 1.21

/*------------------

pron()

o1 = new stzList([ "A" , "B", "A", "C", "A", "D", "A" ])

? o1.FindNextOccurrencesST("A", 3)
#--> [ 5, 7 ]

? o1.FindNextNthOccurrencesST([1, 2], "A", 3)
#--> [ 5, 7 ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplaceNextNthOccurrences([1, 2], :of = "A", :with = "*",  :StartingAt = 3)
	? @@( Content() )
	#--> [ "A" , "B", "A", "C", "*", "D", "*" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? @@( NextNthOccurrencesReplaced([1, 2], :Of = "A", :With = "*",  :StartingAt = 3 ) )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrencesST([1, 2 ], :of = "A", :with = "*",  :StartingAt = 5)
	? @@( Content() )
	#--> [ "*" , "B", "*", "C", "*", "D", "A" ]
}

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrencesST([3, 1], "A", :With = [ "#3", "#1" ], :StartingAt = 6)
	? @@( Content() )
	#--> [ [ "#3", "#1" ], "B", "A", "C", [ "#3", "#1" ], "D", "A" ]
}

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content()
	#--> [ "A", "-", "-", "A", "-", "-", "A" ]
}

proff()
# Executed in almost 0 second(s).

/*------------------

pron()

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6)
	? Content() #--> [ "A", "-", "-", "-", "A", "-", "A" ]
}

proff()
# Executed in 0.01 second(s).

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 2)
	? Content() #--> [ "A" , "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 2)
	#--> [ "A" , "B", "A", "C", "D" ]
}

proff()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*-----------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindNextOccurrences(:Of = "A", :StartingAt = 3) #--> [ 5, 7 ]

	? FindPreviousOccurrences(:Of = "A", :StartingAt = 5) #--> [ 1, 3 ]

}

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*------------------

pron()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindPreviousNthOccurrences([2, 3], "A", 6)
	#--> [ 3, 5 ]

	RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 6)
	? Content()
	#--> [ "A" , "B", "C", "D", "A" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? PreviousNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 6)
	#--> [ "A" , "B", "C", "D", "A" ]
}

proff()
# Executed in 0.01 second(s).

/*=================

pron()

# In Softanza, you can replace all occurrences of an item
# in the list by a provided value, by saying:

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	Replace("A", :With = "#")
	# Or ReplaceAll("A", :With = "#") or ReplaceAllOccurrences(:Of = "A", :With = "#')

	? Content()
	#--> [ "#", "B", "C", "#", "D", "B", "#" ]

}

# In case you need to make many replacements at once, then you are covered:
# just provide the list of items to replace and the value of replacement...

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceMany([ "A", "B" ], :With = "#")
	? Content()
	#--> [ "#", "#", "C", "#", "D", "#", "#" ]

}

# You can even replace exitant items by many other new values, one by one,
# like this (useful in many scenarios of text interpolation and processing):

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceManyByMany([ "A", "B" ], :With = [ "#1", "#2" ])
	? Content()
	#--> [ "#1", "#2", "C", "#1", "D", "#2", "#1" ]

}

# And if you want to replace the occurrences of a given item by alternating
# between several other items you provide, then this is possible:

StzListQ([ "A", "A", "A" , "A", "A" ]) {
	
	ReplaceItemByManyXT("A", :With = [ "#1", "#2" ])

	? Content()
	#--> [ "#1", "#2", "#1", "#2", "#1" ]

}

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ "A", "B", "C", "A", "D", "B", "A" ])
? o1.FindNthOccurrence(3, :Of = "A")
#--> 7

? @@( o1.Content() )
# [ "A", "B", "C", "A", "D", "B", "A" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---------------------

pron()

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	? FindNthOccurrence(3, :Of = "A") + NL
	#--> 7

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content()
	#--> [ "A", "B", "C", "A", "D", "B", "#" ]

}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*====================

pron()

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending()
#--> [ 2, 5, 7, 9 ]

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])

? o1.DuplicatesRemoved()
#--> [ "teeba", "hussein", "haneen" ])

? o1.NumberOfItems()
#--> 4

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	#--> TRUE

# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		#--> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	#--> TRUE

proff()
# Executed in 0.04 second(s).

/*=====================

pron()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a" ]))
#--> [ "c" ]

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a", "c" , "q" ]) )
#--> []

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])

? o1.FindMany([ "a", "e" ])
#--> [ 1, 3, 4, 7 ]

? @@( o1.TheseItemsZ([ "a", "e" ]) )
#--> [ "a" = [ 1, 4 ], "e" = [ 3, 7 ] ]

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "a", "E", "a", "c", "V", "E" ])
? o1.FindMany([ "a", "c" ]) #--> [1, 3, 5]

? o1 - These([ "a", "c" ]) # Same as: o1.RemoveItemsAtPositions([ 1, 3, 5 ])
#--> [ "E", "V", "E" ]

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

o1 = new stzList([ "a", "b", "c" ])

? o1.IsEqualTo([ "c", "b", "a" ])		#--> TRUE

? o1.IsStrictlyEqualTo([ "c", "b", "a" ])	#--> FALSE
# Because
? o1.HasSameTypeAs([ "c", "b", "a" ])		#--> TRUE
? o1.HasSameContentAs([ "c", "b", "a" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "c", "b", "a" ])	#--> FALSE

proff()
# Executed in 0.05 second(s).

/*---------------------

pron()

o1 = new stzList([ "a", "b", "c" ])
? o1.IsStrictlyEqualTo([ "a", "b" ])	#--> FALSE

# Because
? o1.HasSameTypeAs([ "a", "b" ])	#--> TRUE
? o1.IsEqualTo([ "a", "b" ])		#--> FALSE
? o1.HasSameSortingOrderAs([ "a", "b" ])#--> TRUE

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

? @@( StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened() )
#--> [ "a","b","c","d","e","f" ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

? StzStringQ("ab []    cd").Simplified()
#--> ab [] cd

? Q(list2code([ "a", [ [] ], "b" ])).Simplified()
#--> [ "a",[ [ ] ],"b" ]

proff()
# Executed in 0.01 second(s).

/*---------------------

pron()

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {

	Flatten()

	? @@( Content() )
	#--> [ "a", "c", 1, 2, "b" ]

	? NumberOfItems()
	#--> 5

	? ItemAtPosition(3)
	#--> 1

	? ItemAtPosition(5)
	#--> b
	
}

proff()
# Executed in 0.01 second(s).

/*=====================

pron()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
#--> [ 1, 2, 3, 5 ]

? @@(o1.TheseItemsZ([ :one, :five ]))
#--> [ :one = [ 1, 3, 5 ], :five = [] ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
#--> [ 1, 2, 3, 5, 6 ]

? o1.TheseItemsZ([ :one, :two, :four ])
#--> [ :one = [ 1, 3, 5 ], :two = [ 2 ], :four = [ 6 ] ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

o1 = new stzList([ 1, 2, 3])

o1.ExtendToPosition(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

o1.ExtendToPositionXT( 8, :With = 5 )
? @@(o1.Content())
#--> [ 1, 2, 3, 0, 0, 5, 5, 5 ]

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

oList = new stzList([ [1],[1],[1],[1] ])
? oList.ItemsHaveSameType()
#--> TRUE

? oList.ItemsAreEmptyLists()
#--> FALSE

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

o1 = new stzList(1:5)
o1.AddItemAt(8, 9)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5, NULL, NULL, 9 ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

o1 = new stzList("A":"E")
o1.AddItemAt(8, "X")
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

proff()
# Executed in almost 0 second(s).

/*=====================

pron()

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWXT( '{ @item >= 8 }' )
#--> [ 8, 11, 11, 10, 8, 8 ]

proff()
# Executed in 0.15 second(s).

/*---------------------

pron()

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence("2")
#--> 0

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence([ 2 ])
#--> 0

? StzListQ([ 3, 2, 5 ]).FindFirstOccurrence( 2 )
#--> 2

? Q(2).IsOneOfThese([ 3, 2, 5 ])
#--> TRUE

? Q("2").IsOneOfThese([ 3, 2, 5 ])
#--> FALSE

? Q([2]).IsOneOfThese([ 3, 2, 5 ])
#--> FALSE

proff()
# Executed in 0.03 second(s).

/*======================

pron()

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 8 ])

? o1.FindWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 1, 3, 5, 8, 9, 12 ]

? o1.ItemsWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 2, 2, 4, 2, 2 ]

? o1.UniqueItemsWXT( :Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )
#--> [ 2, 4 ]

? @@NL( o1.ItemsAndTheirPositionsWXT(:Where = '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }') )
#--> [
#	[ 2, [ 1, 3, 5, 9, 12 ] ], 
#	[ 4, [ 8 ] ]
#    ]

proff()
# Executed in 0.56 second(s) in Ring 1.21
# Executed in 0.69 second(s) in Ring 1.19

/*---------------------

pron()

o1 = new stzList([ "_", "_", 1:3, "_", 5:9, "_" ])
? o1.FindWXT( :Where = '{ Q(@item).IsOneOfThese([ 1:3, 5:9 ]) }' )
#--> [ 3, 5 ]

proff()
# Executed in 0.13 second(s).

/*---------------------

StartProfiler()

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsWXT( :Where = 'Q(@item).IsAnUppercase()')
#--> [ "A", "B", "A", "C", "B" ]

? ElapsedTime() + NL
#--> 0.18 second(s)

# The other extended form (provides more features, like code transpilation
# and executable section identification) takes more time ( about 0.92 second).
? o1.ItemsWXT( :Where = 'Q(@item).IsAnUppercase()')
#--> #--> [ "A", "B", "A", "C", "B" ]

proff()
# Executed in 0.29 second(s).

/*---------------------

StartProfiler()

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsPositionsWXT('Q(@item).IsUppercase()') # Say also o1.FindItemsW(...) or .FindW(...)
#--> [ 1, 4, 5, 7, 9 ]

? @@( o1.ItemsAndTheirPositionsWXT('Q(@item).IsUppercase()') )
#--> [ [ "A", [ 1, 5 ] ], [ "B", [ 4, 9 ] ], [ "C", [ 7 ] ] ]

StopProfiler()
# Executed in 0.40 second(s).

/*=========================

StartProfiler()

o1 = new stzList([ "A", "B", "_", "C", "D", "E", "F" ])
? @@( o1.AllItemsExcept("_") )
#--> [ "A", "B", "C", "D", "E", "F" ]

StopProfiler()
# Executed in almost 0 second(s).

/*========================= #TODO

StartProfiler()

o1 = new stzList([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])
? o1.CheckOnWXT([1, 3, 5], :That = 'Q(@item).IsLeftToRight()' )
#--> TRUE

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
# Executed in 0.25 second(s).

/*========================= #TODO Chek result correctness

pron()

? StzCCodeQ('{ This[ @i - 3 ] = This[ @i + 3 ] }').ExecutableSection()
#--> [4, -3]

proff()

/*============== #narration: ...W() and ..WXT() forms in Conditional Code

# In conditional code, there are always to forms:
#	- the ...W(pcCondition) form, which is more performant, but less expressive
#	- the ...WXT(pcCondition) form, which is less performant, but more expressive

# In the first form, you can only use the @item, @string, ... and the @i keywords.
# While in the second, you can use keywords sutch as @NextItem, @PreviousItem, and others.

# You can always express these additional keywords, while option for the more performant
# form, by transalating them to This[@i-1] for @PreviousItem, for example, and to
# This[@i+1] for @NextItem, etc.

StartProfiler()

# Finding positions where next number is double of previous number
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? @@( o1.FindWXT( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' ) ) #--> [ 8, 11 ]
#--> [ 8, 11 ]

? ElapsedTime() + NL
#--> 0.19 second(s)

? @@( o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) )  #--> [ 8, 11 ]
#--> [ 8, 11 ]

StopProfiler()
# Executed in 0.28 second(s).

/*-----------

pron()

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

# The function above you can also write like this:
? o1.FindWXT( :Where = '{ Q( @NextItem ).IsDoubleOf( @PreviousItem ) }' )
#--> [ 8, 11 ]

# or like this:
? o1.FindWhere( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' )
#--> [ 8, 11 ]

proff()
# Executed in 0.28 second(s).

/*-----------

StartProfiler()

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])

? o1.FindWXT( '{ @Number = @NextNumber }' )
#--> [ 3, 8, 17, 18 ]

? ElapsedTime()
#--> Takes 0.20s

? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 3, 8, 17, 18 ]

#--> Takes as little as 0.05s!

StopProfiler()
# Executed in 0.29 second(s).

/*-----------

StartProfiler()

# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 2, 5, 6 ]

StopProfiler()
#--> Executed in 0.10 second(s)

/*-----------

StartProfiler()

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? @@( o1.FindWXT('{ This[ @i - 3 ] = This[ @i + 3 ] }') )
#--> [ 4 ]

? ElapsedTime()
#--> 0.15 second(s)

? @@( o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') )
#--> [ 4 ]

StopProfiler()
#--> Executed in 0.23 second(s) in Ring 1.21
#--> Executed in 0.74 second(s) in Ring 1.18

/*========================

pron()

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )

? o1.PreviousNthOccurrence(2, :Of = 0, :StartingAt = 5)
#--> 3

? o1.PreviousNthOccurrence(2, :Of = 8, :StartingAt = :LastItem)
#--> 2

proff()
# Executed in 0.11 second(s).

/*----------------------

pron()

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindAll(120)
#--> [ 3, 6 ]

? o1.NumberOfOccurrence(120)
#--> 2

proff()
# Executed in 0.01 second(s).

/*-----------------------

pron()

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindNthNextOccurrence( 2, :Of = 120, :StartingAt = 1 ) #--> 6
#--> 6

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "mio", "mia", "mio", "mix", "miz", "mix" ])

? o1.FindNthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

# Other alternatives are:
? o1.FindNextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

? o1.NthNextOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

? o1.NextNthOccurrence( 2, :Of = "mix", :StartingAt = 3 )
#--> 6

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "mio", "mix", "mia", "mio", "mix", "miz", "mix" ])

? o1.FindPreviousNthOccurrence( 2, :Of = "mix", :StartingAt = 6)
#--> 2

proff()
# Executed in 0.05 second(s).

/*-----------------------

pron()

o1 = new stzList([ :Char, :String, :Number, :List, :Object, :CObject, :QObject, :Byte ])
? o1.RemoveItemsAtThesePositionsQ( 6:8 ).Content()
#--> [ :Char, :String, :Number, :List, :Object ]

proff()
# Executed in almost 0 second(s).

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
#--> Executed in 0.20 second(s)

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
#--> Executed in 0.17 second(s)

/*--------- OTHER WALKING TECHNIQUES

StartProfiler()

StzListQ([ "A", "B", "C", "D", "E", "F", "G" ]) {

	// Walking the list from the position where a condition is verified

		? @@( WalkWhen( ' @item = "D" ' ) )
		#--> [ 4, 5, 6, 7 ]

		? @@( WalkWhenXT( ' @item = "D" ', :Forward, :WalkedItems ) )
		#--> [ "D", "E", "F", "G" ]

		? @@( WalkWhenXT( ' @item = "D" ', :Backward, :WalkedItems ) )
		#--> [ "D", "C", "B", "A" ]

	// Walking the list from the position where a condition is verified

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
		#--> [ 2 ]

		? @@( WalkForwardBackwardXT(1, 2, :Return = :WalkedItems) )
		#--> [ "B" ]

		#--

		? @@( WalkForwardBackward(3, 1) )
		#--> [ 1, 4, 3, 6, 5 ]

		? @@( WalkForwardBackwardXT(3, 1, :Return = :WalkedItems) )
		#--> [ "A", "D", "C", "F", "E" ]

	// Walking n steps backward n steps forward

		? @@( WalkBackwardForward(1, 2) )
		#--> [ 6 ]

		? @@( WalkBackwardForwardXT(1, 2, :WalkedItems) )
		#--> [ "F" ]

		#--

		? @@( WalkBackwardForward(3, 2) )
		#--> [ 7, 4, 6, 3, 5, 2, 4 ]

		? @@( WalkBackwardForwardXT(3, 2, :WalkedItems) )
		#--> [ "G", "D", "F", "C", "E", "B", "D" ]

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
# Executed in 0.28 second(s) in Ring 1.21

/*========================

pron()

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSection(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", [ "*", "*", "*", "*" ], "D", "E" ]

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSectionByMany(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", "*", "*", "*", "*", "D", "E" ]

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

? @@NL( StzListQ([ 1, 2, 3 ]).RepeatNTimes(3) )
#--> [
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ]
# ]

proff()
# Executed in 0.02 second(s).

/*-----------------------
*/
pron()

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems()
	#--> TRUE
	? NumberOfLeadingItems() + NL
	#--> 3

	? LeadingItems()
	#--> [ "*", "*", "*" ]
	
	? HasTrailingItems()
	#--> TRUE

	? NumberOfTrailingItems() + NL
	#--> 2

	? TrailingItems()
	#--> [ "+", "+" ]

	ReplaceRepeatedLeadingItem(:with = "+")
	? Content()
	#--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]
	
	ReplaceLeadingAndTrailingItems("*","*")
	? Content() #--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

proff()
# Executed in 0.01 second(s).

/*===================

pron()

# All these return TRUE

? StzListQ([ :DefaultLocale ]).IsLocaleList()
#--> TRUE

? StzListQ([ :SystemLocale ]).IsLocaleList()
#--> TRUE

? StzListQ([ :CLocale ]).IsLocaleList()
#--> TRUE

? StzListQ([ :Language = :Arabic, :Script = :Arabic, :Country = :Tunisia ]).IsLocaleList()
#--> TRUE

? StzListQ([ :Language = :Arabic, :Country = :Tunisia ]).IsLocaleList()
#--> TRUE

? StzListQ([ :Country = :Tunisia ]).IsLocaleList()
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------------

pron()

# All these return TRUE

? Q( 1:5 ).IsListOf(:Numbers)
#--> TRUE

? Q( "A":"E" ).IsListOf(:Strings)
#--> TRUE

? Q([ 1:5, "A":"E" ]).IsListOf(:Lists)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListOfNumbers)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListsOfNumbers) // #NOTE the support of plural form
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListOfStrings)
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListsOfStrings) //#NOTE the support of plural form
#--> TRUE

proff()
# Executed in 0.09 second(s).

/*-----------------------

pron()

# All these return TRUE

oNumber1 = StzNumberQ(7)
oNumber2 = StzNumberQ(12)
oNumber3 = StzNumberQ(24)

? Q([ oNumber1, oNumber2, oNumber3 ]).IsListOf(:StzNumbers)
#--> TRUE

? Q([ [oNumber1, oNumber2], [oNumber2, oNumber3] ]).IsListOf(:ListsOfStzNumbers)
#--> TRUE

oString1 = StzStringQ("Win")
oString2 = StzStringQ("Loose")
oString3 = StzStringQ("Don't care!")

? Q([ oString1, oString2, oString3 ]).IsListOf(:StzStrings)
#--> TRUE

? Q([ [oString1, oString2], [oString2, oString3] ]).IsListOf(:ListsOfStzStrings)
#--> TRUE

proff()
# Executed in 0.06 second(s).

/*==================

pron()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemW(3, :Where = '{ isString(This[@i]) and Q(This[@i]).IsLowercase() }')
#--> "compagon"

proff()
# Executed in 0.13 second(s).

/*------------------

pron()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemWXT(3, :Where = '{ isString(@item) and Q(@item).IsLowercase() }')
#--> "compagon"

proff()
# Executed in 0.15 second(s).

/*================== #narration List Equality and Strict Equality in Softanza

pron()

# In Softanza, two lists are equal when they have same
# number of items and have same content
 
o1 = new stzList(1:3)

? o1.HasSameContentAs(3:1)
#--> TRUE

? o1.HasSameNumberOfItemsAs(3:1)
#--> TRUE

? o1.IsEqualTo(3:1) + NL
#--> TRUE

# While two lists are STRICTLY equal when they have
# same number of items, have same content, and same sorting order

# In other terms: when they are Equal (in the sense of
# IsEqualTo()) and have same sorting order
 
# Hence, 1:3 is equal to its reversed list 3:1
# but it is not STRICTLY equal to it

? Q(1:3).IsEqualTo(3:1)
#--> TRUE

? Q(1:3).IsStrictlyEqualTo(3:1)
#--> FALSE

# In fact, the two lists don't have the same sorting order!

? Q(1:3).SortingOrder()
#--> :Ascending

? Q(3:1).SortingOrder()
#--> :Descending

# Hence, 1:3 is STRICTLY equal only to itself

? Q(1:3).IsStrictlyEqualTo(1:3)
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*-------------- #narration List approximate comparison in Softanza

pron()

# Softanza can compare lists (and strings also), in an approximative way.
# The degree of approximation can be tuned to fit with your need.

o1 = new stzList([ "f","a","y","e","d" ])

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> FALSE

# By default, the approximation facor is 0.09

? QuietEqualityRatio()
#--> 0.09

# And you can change it:

SetQuietEqualityRatio(0.41)

# Now the equality becomes TRUE

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*----------------------- #narration

pron()

# Softanza can sort a list, whatever data types it contains (not only
# numbers and strings), in ascending and descending orders (see
# comments in corresponding methods in stzList class).

# Also, it can retrieve the sorting of a list using SortingOrder()
# method (returns :Ascending, :Descending, or :Unsorted).

# And it can compare the sorting orders of two lists using
# HasSameSortingOrderAs() method.

? Q(3:1).SortInAscendingQ().Content() 	# Or SortUp()
#--> [ 1, 2, 3 ]

? Q(1:3).SortInDescendingQ().Content()	# Or SortDown()
#--> [ 3, 2, 1 ]

? Q(1:3).SortingOrder()
#--> :Ascending

? Q(1:3).HasSameSortingOrderAs(3:1)
#--> FALSE

? Q(1:3).HasSameSortingOrderAs(1:3)
#--> TRUE

? Q(1:3).HasSameSortingOrderAs(1:5) + NL
#--> TRUE

# For conciseness, you can call these functions directly,
# without objects instanciation:

? HaveSameSortingOrder(1:3, 1:7)
#--> TRUE

? SortingOrders([ 1:3, 1:7 ])
#--> [ "ascending", "ascending" ]

proff()
# Executed in 0.01 second(s).

/*======================

pron()

# Operators on stzString

o1 = new stzList([ "S","O","F","T","A","N","Z","A" ])

# Getting a char by position

? o1[5] + NL
#--> "A"

# Finding the occurrences of a substring in the string

? o1["A"]
#--> [ 5, 8 ]

# Getting occurrences of chars verifying a given condition

? o1[ '{ Q(@item).IsOneOfThese(["A", "T", "Z"]) }' ]
#--> [ 4, 5, 7, 8 ]

proff()
# Executed in 0.07 second(s).

/*===============

pron()

o1 = new stzList([ 10, 1, 2, 3, 10 ])

o1.Remove(10)
? o1.Content()
#--> [ 1, 2, 3 ]

proff()
# Executed in almost 0 second(s).

/*==============

pron()

obj = NullObject()

o1 = new stzList([ 10, "A":"E", 12, obj, 10, "A":"E", obj, "Ring" ])

? @@( o1.FindAll(10) )
#--> [ 1, 5 ]

? o1.FindAll("Ring")
#--> [ 8 ]

? o1.FindAll("A":"E")
#--> [ 2, 6 ]

? o1.FindAll(obj)
#--> [ 4, 7 ]

#TODO // this won't work corretcly if we add other objects different from
# obj in the list. We should think of an other algorithm other then relying
# on the empty spaces generated, for objects, by list2code() function of Ring!

	#UPDATE It's done, and object findability is now managed using named object.
	#~> If an object is named (created using new stzString(:mystr = "Ring") for
	# example, then it becomes findable!

o1.RemoveMany([ "A":"E", obj ])
? @@( o1.Content() )
#--> [ 10, 12, 10, "Ring" ]

proff()
# Executed in 0.08 second(s).

/*-------

pron()

oTrue  = TrueObject()
oFalse = FalseObject()
oNull  = NullObject()

o1 = new stzList([ "Ring", "PHP", oTrue, oTrue, "Python", oNull, oFalse, "Julia", oNull ])

? @@( o1.FindAll(oTrue) )
#--> [ 3, 4 ]

? @@( o1.FindAll(oFalse) )
#--> [ 7 ]

? @@( o1.FindAll(oNull) ) + NL
#--> [ 6, 9 ]

? @@( o1.FindObjects() )
#--> [ 3, 4, 6, 7, 9 ]

? @@( o1.FindMany([ oTrue, oFalse, oNull ]) ) + NL
#--> [ 3, 4, 6, 7, 9 ]

o1.Remove(oNull)
? @@( o1.Content() ) + NL
#--> [ "Ring", "PHP", @trueobject, @trueobject, "Python", @falseobject, "Julia" ]

o1.Replace(oFalse, 0)
? @@( o1.Content() ) + NL
#--> [ "Ring", "PHP", @trueobject, @trueobject, "Python", 0, "Julia" ]

o1.RemoveMany([ oTrue, 0 ])
? @@( o1.Content() )
#--> [ "Ring", "PHP", "Python", "Julia" ]

proff()
# Executed in 0.34 second(s).

/*----------------------- #narration

pron()

# Ring can find (and sort) items inside a list (respectively
# using find() and sort() functions), but only if these items
# are of type "NUMBER" or "STRING".

# Softanza makes it posible to find (and sort) all the three
# types: numbers, strings, lists (--> TODO: not yet for objects).

o1 = new stzList([ "twelve", 12, [ "L2", "L2" ], "ten", 10, [ "L1", "L1" ] ])

? @@( o1.FindAll([ "L1", "L1" ]) ) + NL
#--> [ 6 ]

# Not only list are findable, they are also sortable and comparable.

? @@( o1.SortedInAscending() )
#--> [ 10, 12, "ten", "twelve", [ "L1", "L1" ], [ "L2", "L2" ] ]

# As you can see, the logic of sorting applied by Softanza is:
#	--> Putting numbers first and sorting them
#	--> Adding strings after that and sorting them
#	--> Adding lists after that and sorting them

# Same thing should be possible for objects but not yet implemented (#TODO)
# ~> For the mean time, objects are added at the end in the order of
# their appearance. But we could sort them also, based on their attributes
# values. Which makes Softanza sort totally pervasive for all Ring types!

proff()
#--> Executed in 0.02 second(s).

/*--------- #narration Same semantics for all softanza objects

pron()

# Softanza works consistently on lists and strings: What works
# for a string, would generally work for a list, when it makes
# sense, using the same semantics.

# For example, in strings, we can check if the string is bounded
# by two given substrings, or even by many of them. So, we say:

oStr = new stzString("|<--Scope of Life-->|")
? oStr.IsBoundedBy([ "|<--", "-->|" ])
#--> TRUE

# And then we can delete these bounds:
? oStr.TheseBoundsRemoved( "|<--", "-->|" )
#--> "Scope of Life"

# The same semantics apply to lists, like this:

oList = new stzList([ "|<--", "Scope", "of", "Life", "-->|" ])
? oList.IsBoundedBy([ "|<--", "-->|" ])
#--> TRUE

# And we can remove all these bounds, exactly like we did for strings:
? oList.TheseBoundsRemoved( "|<--", "-->|" )
#--> [ "Scope", "of", "Life" ]

proff()
# Executed in 0.05 second(s).

/*-----------------------

pron()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.IsBoundedBy([ "{", "}" ]) + NL
#--> TRUE

o1.RemoveTheseBounds("{", "}")
? o1.Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.01 second(s).

/*-----------------------

pron()

o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])

? @@( o1.BoundsUpToNItems(1) ) + NL
#--> [ "{","}" ]

? @@( o1.BoundsUpToNItems(2) )
#--> [ [ "{", "<" ], [ ">", "}" ] ]

proff()
# Executed in almost 0 second(s).

/*-----------------------

pron()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.TheseBoundsRemoved("{", "}")
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.01 second(s).

/*-----------------------

pron()

o1 = new stzList([ "1", "2", "A", "B", "C", "3", "4" ])

? o1.ContainsEach([ "A", "B", "C" ])
#--> TRUE

? o1.ContainsEachOneOfThese([ "A", "B", "C" ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------------

pron()

o1 = new stzList([ "A", "B", "C" ])

? o1.EachItemExistsIn([ "1", "2", "A", "B", "C", "3", "4" ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*-----------------------

pron()

? @IsListOfHashLists([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
]) + NL
#--> TRUE

o1 = new stzListOfHashLists([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
])

o1.Show()

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

proff()
# Executed in 0.02 second(s).

/*===============

pron()

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWXTQ('{

	isNumber(@item) and
	Q(@item).IsDividableBy(2)

}').NumberOfItems()
#--> 3

proff()
# Executed in 0.14 second(s).

/*----------------------

pron()

? @@( StzListQ("A":"E").Reversed() )
#--> [ "E", "D", "C", "B", "A" ]

? @@( StzListQ("A":"E").ItemsReversed() )
#--> [ "E", "D", "C", "B", "A" ]

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

? StzListQ([ "A", 1, "B", 2, "C", 3]).NumberOfItemsWXT('isNumber(@item)')
#--> 3

? StzListQ([ "A", 1, "B", 2, "C", 8 ]).NumberOfItemsWXT('
	isString(@item) and Q(@item).isLetter()
')
#--> 3

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).NumberOfItemsWXT('Q(@item).IsDividableBy(2)')
#--> 3

proff()
# Executed in 0.21s second(s).

/*----------------------

pron()

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT(' isNumber(@item) ')
#--> [1, 2, 3]

? StzListQ([ "A", 1, "B", 2, "C", 3]).ItemsWXT('
	isString(@item) and Q(@item).IsLetter()
') #--> [ "A", "B", "C" ]

? StzListQ([ 1, 2, 3, 4, 5, 6 ]).ItemsWXT('Q(@item).IsDividableBy(2)')
#--> [2, 4, 6]

proff()
# Executed in 0.22 second(s).

/*----------------------

pron()

o1 = new stzList( [ "1", "2", [ 1, [ "x" ], 2 ],  "3" ] )

? o1.ToCode()
#--> '[ "1", "2", [ 1, [ "x" ], 2 ],  "3" ]'

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

# You can replace the nth item of a list
# by a given value by writing:

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceAt(2, "B")
? o1.Content()
#--> [ "A", "B", "C" ]

# Or you can be a bit more expressive by using :With

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceAt(2, :With = "B")
? o1.Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceAt(2, :By = "A")
? o1.Content()
#--> [ "A", "A", "A" ]

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

o1 = new stzList([ "1", "2", "_", "_", "_", "4", "5" ])
o1.ReplaceSection(3, 5, :With = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

proff()
# Executed in almost 0 second(s).

/*=======================

StartProfiler()

o1 = new stzList([ 1, "a", 2, "b", 3, "c" ])
? o1.FindWXT('{ isString(@item) and Q(@item).isLowercase() }')
#--> [2, 4, 6]

StopProfiler()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.26 second(s) in Ring 1.17

/*========================

pron()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt(2, "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", 5 ]

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt([2, 5], "♥")	# Or ReplaceAnyAt()
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

o1.ReplaceThisAt(3, "♥", 3)
? @@( o1.Content() )
#--> [ "♥", "♥", 3, "♥", "♥" ]

proff()
# Executed in almost 0 second(s).

/*----------------------

pron()

? Intersection([ [ 1, 3, 4 ], [ 1, 3, 4 ] ])
#--> [ 1, 3, 4 ]

proff()
# Executed in 0.02 second(s).

/*----------------------

pron()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceItemAtPositionsByMany([1, 3, 4 ], "♥", [ 1, 3, 4 ])
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5 ]

proff()
# Executed in 0.02 second(s).

/*----------------------

StartProfiler()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])
o1.ReplaceItemsAtPositions([2, 5], :With = "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

StopProfiler()
#--> Executed in almost 0 second(s).

/*----------------------

StartProfiler()

# Conditional replacement of items can happen for all the items defined by a
# given condition, and by replacing themn with the same given value like this:

StzListQ( [ 1, "a", 2, "b", 3, "c" ] ) {
	ReplaceItemsWXT(
		:Where = '{ isString(@item) and Q(@item).isLowercase() }',
		:By = "*"
	)

	? Content()
	#--> [ 1, "*", 2, "*", 3, "*" ]
}

StopProfiler()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.19

/*=================

pron()

o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3)
#--> [ "a", "b", "c" ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

? @@( Merge([ [ 1, 2 ], [ 3 ] ]) )
#--> [ 1, 2, 3 ]

? @@( Merge([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
]) )
#--> [ [ 1, 2], [3, 4] ]

? @@( Flatten([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
]) )
#--> [ 1, 2, 3, 4 ]

proff()
# Executed in almost 0 second(s).

/*--------------

pron()

? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).
	ItemsWXT('StzCharQ(@item).IsArabic()')

#o--> [ "ض", "س", "ط" ]

proff()
# Executed in 0.13 second(s).

/*--------------

pron()

? @@( StzListQ([ "a", 1, "b", 2, "c", 3 ]).Types() ) + NL
#--> [ "STRING", "NUMBER", "STRING", "NUMBER", "STRING", "NUMBER" ]

? StzListQ([ "a", 1, "b", 2, "c", 3 ]).UniqueTypes()
#--> [ "STRING", "NUMBER" ]

proff()
# Executed in almost 0 second(s).

/*--------------

pron()

StzListQ([ "one", "two", "three" ]) {

	ReplaceItemAtPosition(2, :With = "TWO") # or ReplaceAt
	? Content()
	#--> [ "one", "TWO", "three" ]

	ReplaceAllItems( :With = "***")
	? Content()
	#--> [ "***", "***", "***" ]
}

proff()
# Executed in almost 0 second(s).

/*--------------

pron()

StzListQ([ "a", 1, "b", 2, "c", 3 ]) {

	ReplaceWXT( :Where = '{ isNumber(@item) }', :By = "*" )
	? @@( Content() )
	#--> [ "a", "*", "b", "*", "c", "*" ]
}

proff()
# Executed in 0.13 second(s).

/*--------------

pron()

o1 = new stzList([ "a", 1, "b", 2, "c", 3 ])
o1.RemoveWXT('Not isNumber(@item)')
? o1.Content()
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.12 second(s).

/*--------------

pron()


obj1 = TrueObject()
obj2 = FalseObject()

o1 = new stzList([ "a", 1, 3, "b", ["A1", "A2"], obj1, "c", 3, [ "B1", "B2" ], obj2 ])

? o1.OnlyStrings()
#--> [ "a", "b", "c" ]

? o1.OnlyNumbers()
#--> [ 1, 3, 3 ]

? o1.OnlyLists()
#--> [ "A1", "A2", "B1", "B2" ]

? o1.OnlyObjects()
#--> The two objects o1 and o2 printed in the console:
#
# @oobject: NULL
# @cvarname: @trueobject
#
# @oobject: NULL
# @cvarname: @falseobject

proff()
# Executed in almost 0 second(s).

/*--------------

pron()

StzListQ([ "a", "b", [], "c", [] ]) {
	? OnlyWhereXT('{ isString(@item) }')
	#--> [ "a", "b", "c" ]
}

proff()
# Executed in 0.12 second(s).

/*--------------

pron()

StzListQ([ "a", "b", [], "c", [] ]) {
	RemoveWXT('{
		isList(@item) and Q(@item).IsEmpty()
	}')

	? Content()
	#--> [ "a", "b", "c" ]
}

proff()
# Executed in 0.13 second(s).

/*--------------

pron()

StzListQ([ 1, "a", "b", 2, 3, "c", 4, [ "..." ], "d" ]) {

	RemoveWXT('{
		isNumber(@item) or
		isString(@item)
	}')

	? @@(Content())
	#--> [ [ "..." ] ]
}

proff()
# Executed in 0.14 second(s).

/*-------------

pron()

o1 = new stzList(["_", "A", "*", "_", "B", "*", "_", "C", "*" ])

? o1.FindWXT( :Where = ' @NextItem = "*" ' )
#--> [ 2, 5, 8 ]

? o1.ItemsWXT( :Where = ' @NextItem = "*" ' )
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.20 second(s).

/*-------------

pron()

oTrueObj = TrueObject()
oFalseObj = FalseObject()

o1 = new stzList([
	"_", 3, "_" , oTrueObj, 6, "*",
	[ "L1", "L1" ], 12, oFalseObj,
	[ "L2", "L2" ], 25, "*"
])

? o1.FindWhereXT('{
	( NOT isObject(@item) ) and
	( isString(@NextItem) and @NextItem = "*" )
}')
#--> [ 5, 11]

? o1.FindWhereXT('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] = DoubleOf(@item)	
}')
#--> [ 2, 5 ]

? o1.FindWhereXT('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] != DoubleOf(@item)	
}')
	#--> [ 8 ]

proff()
# Executed in 0.35 second(s).

/*-------------

pron()

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])

? o1.FindAllWXT('{ Q(@item).IsUppercase() }')
 #--> [3, 4, 6]

? o1.ItemsWXT('{ Q(@item).IsUppercase() }')
  #--> ["C#", "RING", "RUBY"]

proff()
# Executed in 0.25 second(s).

/*-------------

pron()

o1 = new stzList(["c", "c++", "C#", "RING", "Python", "RUBY"])
o1.InsertAfterWXT( :Where = '{ Q(@item).IsLowercase() }' , "*")
? o1.Content()
#--> ["c", "*", "c++", "*", "C#", "RING", "Python", "RUBY"]

proff()
# Executed in 0.16 second(s).

/*-------------

pron()

o1 = new stzList( [ "c", "c++", "C#", "RING", "Python", "RUBY" ] )
? o1.ItemsWXT('{ Q(@item).IsLowercased() }')
#--> [ "c", "c++" ]

? o1.FirstItemWXT('{ Q(@item).IsLowercased() }') + NL
#--> "c"

? o1.NthItemWXT(2, '{ Q(@item).IsLowercased() }') + NL
#--> "c++"

? o1.LastItemWXT('{ Q(@item).IsLowercased() }')
#--> "c++"

proff()
# Executed in 0.55 second(s).

/*-------------

pron()

o1 = new stzList(["c", "c++", "C#", "RING", "python", "ruby"])

//? o1.FindW("   ")
#--> ERROR: Can't proceed.

? o1.CountWXT('{ @isLowercase(@item) }')
#--> 4

? o1.NumberOfOccurrenceWXT('{ @isLowercase(@item) }') #--> 6
#--> 4

proff()
# Executed in 0.25 second(s).

/*==============

pron()

o1 = new stzSplitter(5)

? @@(o1.SplitToPartsOfNItemsXT(2))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@(o1.SplitBeforePositions( [ 3, 5 ] ))
#--> [ [ 1, 2 ], [ 3, 5 ] ]

? @@(o1.SplitAfterPositions( [ 3, 5 ] ))
#--> [ [ 1, 3 ], [ 4, 5 ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-------------

pron()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

? @@( o1.SplittedToPartsOfNItemsXT(2) ) + NL
#--> [ [ "a", "b" ], [ "c", "d" ], [ "e" ] ]

? @@( o1.SplittedAfterPositions([ 3, 5 ]) ) + NL
#--> [ [ "a", "b", "c" ], [ "d", "e" ] ]

? @@( o1.SplittedBeforePositions([ 3, 5 ]) )
#--> [ [ "a", "b" ], [ "c", "d", "e" ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*============

pron()

o1 = new stzSplitter(5)

? @@( o1.GetPairsFromPositions([ 3, 5 ]) )
#--> [ [ 1, 3 ], [ 3, 5 ] ]

? @@( o1.GetPairsFromPositions([ 1, 4 ]) ) + NL
#--> [ [ 1, 4 ], [ 4, 5 ] ]

proff()
# Executed in 0.02 second(s).

/*-----------

pron()

o1 = new stzSplitter(5)

? @@( o1.SplitAt(1) )
#--> [ [ 2, 5 ] ]

? @@( o1.SplitAt(5) ) + NL
#--> [ [ 1, 4 ] ]

? @@( o1.SplitAtPositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 2 ], [ 4, 4 ] ]

? @@( o1.SplitAtPositions([ 1, 5 ]) ) + NL
#--> [ [ 2, 4 ] ]

? @@( o1.SplitAtPositions([ 1, 3, 5 ]) )
#--> [ [ 2, 2 ], [ 4, 4 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*-----------

pron()

o1 = new stzSplitter(5)

? @@( o1.SplitBeforePositions([ 1, 6 ]) )
#--> ERROR: Incorrect param value!
# panPos must contain unique numbers between 1 and 5.

proff()

/*-----------

pron()

o1 = new stzSplitter(5)

? @@( o1.SplitBefore(1) )
#--> [ [ 1, 5 ] ]

? @@( o1.SplitBefore(5) ) + NL
#--> [ [ 1, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 1, 5 ]) ) + NL
#--> [ [ 1, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 5 ]) )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*-----------

pron()

o1 = new stzSplitter(5)

? @@( o1.SplitAfter(3) )
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitAfter(1) )
#--> [ [ 1, 1 ], [ 2, 5 ] ]

? @@( o1.SplitAfter(5) ) + NL
#--> [ [ 1, 5 ] ]

? @@( o1.SplitAfterPositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitAfterPositions([ 1, 5 ]) ) + NL
#--> [ [ 1, 1 ], [ 2, 5 ] ]

? @@( o1.SplitAfterPositions([ 1, 3, 5 ]) )
#--> [ [ 1, 1 ], [ 2, 3 ], [ 4, 5 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*-------------

pron()

o1 = new stzString("abcde")

? o1.SplitToPartsOfNChars(2)
#--> [ "ab", "cd" ]

? o1.SplitToPartsOfNCharsXT(2)
#--> [ "ab", "cd", "e" ]

? o1.SplitAfterPositions([ 3, 4 ])
#--> [ "abc", "d", "e" ]

? o1.SplitAfterPositions([ 3, 5 ])
#--> [ "abc", "de" ]

? o1.SplitBeforePositions([ 3, 5 ])
#---> [ "ab", "cd", "e" ]

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*================

pron()

o1 = new stzList([ "*", "a", "*", "b", "C", "D", "*", "e" ])

? o1.Find("*")
#--> [1, 3, 7]

? o1.FindItem("*")
#--> [1, 3, 7]

? o1.Find(:Item = "*")
#--> [1, 3, 7]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*--------------

pron()

o1 = new stzList([ "a", "b", "a", "a", "c", "d", "a" ])
o1.RemoveOccurrences([ 4, 1, 3 ], "a")
? o1.Content()
#--> [ "b", "a", "c", "d" ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

? o1.FindAllW('{ Q(This[@i]).IsLowercase() }')
#--> [ 1, 2, 5 ]
# Executed in 0.08 second(s).

? o1.FindAllWXT('{ Q(@item).IsLowercase() }')
#--> [ 1, 2, 5 ]
# Executed in 0.14 second(s).

proff()
# Executed in 0.18 second(s).

/*=========

pron()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

o1.InsertAfterW( '{ Q(This[@i]).IsLowercase() }', "*" )
? @@( o1.Content() )
#--> [ "a", "*", "b", "*", "C", "D", "e", "*" ]

proff()
# Executed in 0.07 second(s).

/*---------------

pron()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

o1.InsertAfterWXT( '{ Q(@item).IsLowercase() }', "*" )
? @@( o1.Content() )

#--> [ "a", "*", "b", "*", "C", "D", "e", "*" ]

proff()
# Executed in 0.14 second(s).

/*----------------

pron()

o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeW( '{ Q(This[@i]).IsLowercase() }', "*" )
? o1.Content()
#--> [ "*", "a", "*", "b", "C", "D", "*", "e" ]

proff()
# Executed in 0.07 second(s).

/*----------------

pron()

o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeWXT( '{ Q(@item).IsLowercase() }', "*" )
? o1.Content()
#--> [ "*", "a", "*", "b", "C", "D", "*", "e" ]

proff()
# Executed in 0.13 second(s).

/*----------------

pron()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertAfterManyPositions([ 2, 4, 5 ], "*")
? @@( o1.Content() )
#--> [ "a", "b", "*", "c", "d", "*", "e", "*" ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertBeforeManyPositions([ 2, 4, 5 ], "*")
? @@( o1.Content() )
#--> [ "a", "*", "b",  "c", "*", "d", "*", "e" ]

proff()
# Executed in almost 0 second(s).

/*===========

pron()

o1 = new stzList([ 5, 4, 3, 7 ])
o1.SortUp() # Or SortInAscending()
? o1.Content()
#--| [ 3, 4, 5, 7 ]

proff()
# Executed in almost 0 second(s).

/*---------------

pron()

o1 = new stzList([ 5, 4, "tunis", 3, 7, "cairo" ])
o1.SortInAscending()
? o1.Content()
#--> [ 3, 4, 5, 7, "cairo", "tunis" ]

proff()

/*---------------

pron()

o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", 3, 7, [ :them, :others ], "cairo"  ])
o1.SortInAscending()
? ListToCode( o1.Content() )
# Returns [ 3, 4, 5, 7, "cairo", "tunis", [ "me", "you" ], [ "them", "others" ] ]

proff()
#--> Executed in 0.02 second(s).

/*--------------

pron()

obj1 = TrueObject()
obj2 = FalseObject()

o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", obj2, 3, 7, [ :them, :others ], "cairo", obj1  ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ 3, 4, 5, 7, "cairo", "tunis", [ "me", "you" ], [ "them", "others" ], @falseobject,  @trueobject ]

proff()
# Executed in 0.03 second(s).

/*--------------

pron()

o1 = new stzList([ 3, 6, 9, 12, "a", "b", [ "List0" ], [ "List1" ] ])
? o1.IsSortedInAscending()
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*------------

pron()

obj1 = TrueObject()
obj2 = FalseObject()

o1 = new stzList([ "_", 3, "_" , obj1, "*", 6, [ "L1", "L1" ], 12, obj2, [ "L2", "L2" ], 24, "*" ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ 3, 6, 12, 24, "*", "*", "_", "_", [ "L1", "L1" ], [ "L2", "L2" ], @trueobject, @falseobject ]

proff()
# Executed in 0.03 second(s).

/*---------------

pron()

o1 = new stzList(1:5)

o1.RemoveW('{
	isNumber(This[@i]) and This[@i] > 3
}')

? o1.Content()
#--> [ 1, 2, 3 ]

proff()
# Executed in 0.05 second(s).

/*=================

pron()

o1 = new stzSplitter(3)
? @@( o1.SplitToNParts(0) )
#--> [ ]

o1 = new stzList([ "A", "B", "C" ])
? @@( o1.SplittedToNParts(0) )
#--> [ "A", "B", "C" ]

#~> The list is not splitted and returned as is.

proff()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.17

/*===========

pron()

# Look at this list:

o1 = new stzlist([ "a" , "b", "c", [ "a", "b", "c" ], "c" ])
#				   --------^--------
#				           |
#				       (this one)
#				           |
# If we need to remove the item at position 4 containing [ "a", "b", "c" ], we say:

? @@( o1 - [ "a", "b", "c" ] )
#--> [ "a", "b", "c", "c" ]

# But if we need to remove all the items equal to "a", "b", "c", and leave only the
# list at position 4 containing [ "a", "b", "c" ], we use These() like this:

? @@( o1 - These([ "a", "b", "c" ]) )
#--> [ [ "a", "b", "c" ] ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18

/*--------------- #narration : - operator never changes the object

pron()

# When you write this:

o1 = new stzList([ "a", "b", "c", "d", "e" ])
o1 - These([ "b", "c" ])
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

# And you get the hole list as a result, it's correct. Why?

# Because using (-) operator on o1 object does not modify the
# object itself. It just calculates the opeartion and returns
# the result in a normal new list.

# Check it by yourself by using ? command before the operation:

? @@( o1 - These([ "b", "c" ]) )
#--> [ "a", "d", "e" ]

# Again, the object itself has not been changed:

? @@( o1.Content() ) + NL
#--> [ "a", "b", "c", "d", "e" ]

# Now, what if you need to make the opeation and get a stzList
# object instead of a normal Ring list? Easy!

# Just use the Q() elevator to tell softanza that you want
# the output to be elevated to a stzList object, like this:

? ( o1 - TheseQ(["b", "c"]) ).Stztype()
#--> stzlist

# Of course, you can chain any other method supported by stzList:

? ( o1 - TheseQ([ "b", "c" ]) ).UppercaseQ().ToStzListOfStrings().Joined()
#--> "ADE"

# But the main object content again is not affected:
? @@( o1.Content() )
#--> [ "a", "b", "c", "d", "e" ]

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzList(["file1", "file2", "file3" ])

# The operators (*, +, /) when used with basic Ring types
# (strings, numbers) return a new value without altering
# the object itself (o1 in our case).

# Hence, if we say:

? o1 * ".ring"
#--> [ "file1.ring", "file2.ring", "file3.ring" ]

? o1.Content()
#--> ["file1", "file2", "file3" ]

? o1 + "file4"
#--> [ "file1", "file2", "file3", "file4" ]

proff()
# Executed in almost 0 second(s).

/*--------

pron()

o1 = new stzList(["file1", "file2", "file3" ])

? @@( o1 / 3 ) + NL
#--> [ [ "file1" ], [ "file2" ], [ "file3" ] ]

# o1 content remains the same:

? @@( o1.Content() )
#--> [ "file1", "file2", "file3" ]

proff()
# Executed in 0.02 second(s).

/*-----------

pron()

o1 = new stzString("File")

# Returning a new string and leaving o1 as is

? o1 * 3
#--> FileFileFile

? o1 + "File"
#--> FileFile

# Returning a list and leaving o1 as is

? @@( o1 / 4 )
#--> [ "F", "i", "l", "e" ]

? o1.Content() 	
#--> File

proff()
# Executed in 0.04 second(s).

/*-----------

pron()

o1 = new stzNumber(12500)

? o1 - 500	# You can even say o1 - "500" because stzNumber accepts
#--> 12000	# values of numbers that are hosted in strings!

proff()
# Executed in 0.07 second(s).

/*-----------

pron()

? @@( Q([ 3, 6, 9 ]) / 3 )
#     \_____ _____/
#           V
#    A stzList object

#--> [ [ 3 ], [ 6 ], [ 9 ] ]

? @@( QQ([ 3, 6, 9 ]) / 3 ) + NL
#     \______ _____/
#            V
#     A stzListOfNumber object

#--> [ 1, 2, 3 ]

# In both examples above, You can return
# stzList object instead of a normal list:

? ( Q([ 3, 6, 9 ]) / Q(3) ).StzType()
#--> stzlist

? ( QQ([ 3, 6, 9 ]) / Q(3) ).StzType()
#--> stzlistofnumbers

proff()
# Executed in 0.04 second(s).

/*===========

pron()

o1 = new stzList([
	"medianet", "st2i", "webgenetix", "equinoxes", "groupe-lsi",
	"prestige-concept", "sonibank", "keyrus", "whitecape",
	"lyria-systems", "noon-consulting", "ifes", "mourakiboun",
	"isie", "hnec", "haica", "kalidia", "triciti", "avionav",
	"maxeam", "nextav", "ring"
])

? o1.ContainsMany([ "medianet", "st2i" ])
#--> TRUE

? o1.ContainsEach([ "ifes", "haica"])
 #--> TRUE

? o1.ContainsBoth("ifes", "haica")
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*-----------------

pron()

? ListReverse([ 1, 2, 3 ])
#--> Executed in almost 0 second(s).

proff()
# Executed in almost 0 second(s).

/*---------

pron()

o1 = new stzList([ "tunis", 1:3, 1:3, "gafsa", "tunis", "tunis", 1:3, "gabes", "tunis", "regueb", "regueb" ])

o1.Reverse()
? @@( o1.Content() ) + NL
#--> [ "regueb", "regueb", "tunis", "gabes", [ 1, 2, 3 ], "tunis", "tunis", "gafsa", [ 1, 2, 3 ], [ 1, 2, 3 ], "tunis" ]

? o1.NumberOfDuplicates()
#--> 6

? o1.NumberOfDuplicatesOf("tunis") + NL	# Or NumberOfOccurrence("tunis")
#--> 4

? @@( o1.DuplicatedItems() ) + NL
#--> [ "regueb", "tunis", [ 1, 2, 3 ] ]


? @@( o1.DuplicatesRemoved() )
#--> [ "regueb", "tunis", "gabes", [ 1, 2, 3 ], "gafsa" ]

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ "poetry", "music", "theater", "stranger" ])
? o1 - These([ "poetry", "music" ])
#--> [ "theater", "stranger" ]
         
proff()
# Executed in almost 0 second(s).
                              
/*---------------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT(:ToPosition = 5, :With = "0") # Or ExtendToWith()
? o1.Content()
#--> [ "A", "B", "C", "0", "0" ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

o1 = new stzList([ "A", "B", "C" ])

? o1.ContainsNo("v")
#--> TRUE

? o1.ContainsNoObjects()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*---------

pron()

o1 = new stzList( [ "A", "B", [ 1, "v", 2 ], "X" ] )

? o1.ContainsNo("v")
#--> TRUE

? o1.ContainsNoObjects()
#--> TRUE

? @@( o1.Flattened() ) # can also be written: o1.FlattenQ().Content()
#--> [ "A", "B", 1, "v", 2, "X" ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

o1 = new stzList([ "A", 1:3, NullObject(), "B", [ "C", 4:5, [ "V", 6:8, ["T", 9:12 ,"K"] ] ], "D" ])
? @@( o1.DeepLists() ) # Or ListsAtAnyLevel()
#--> [ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ], [ 9, 10, 11, 12 ] ]

proff()
# Executed in 0.08 second(s).

/*---------------------

pron()

? @@( Q([ 0, 1:3, 4:7, 8:10 ]).Merged() )
#--> [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.17

/*---------------------- #todo review the semantics of UntilXT()

pron()

o1 = new stzList([ :Water, :Milk, :Cofee, :Tea, :Sugar, " ",:Honey ])
? o1.WalkUntil('@Item = :Milk')
#--> [ 1, 2 ]

? o1.WalkUntil('@Item = " "')
#--> [ 1, 2, 3, 4, 5, 6 ]

proff()
# Executed in 0.16 second(s).

/*--------

pron()

? Q(5).IsBetween(2, 7)
#--> TRUE

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*========= TODO: refactor it to use stzWalker

pron()

? Q(5).IsBetween(2, 7)

StzListQ( "A":"J" ) {
	AddWalker( :Named = :Walker1, :StartingAt = 1, :EndingAt = 10, :NStep = 1 )
	? WalkedItems( :By = :Walker1 )
	? WalkedPositions( :By = :Walker1 )
	? WalkedLastItem( :By = :Walker1 )
	? WalkedLastPosition( :By = :Walker1 )
	? NumberOfWalkedItems( :By = :Walker1 )

	? Yield( 'type(@item)', :WhileWalkingListBy = :Walker1 )
}

proff()

/*---------------------- TODO: refactor it to use stzWalker

pron()

oPerson = new Person
//myList = "A":"J"
myList = [ "A", 1, "BB", 2, [ "W", 12, "V" ], "C", 10, oPerson, "D", oPerson ]

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

proff()

class Person

#====================== DISTRIBUTING ITEMS OVER THE ITEMS OF AN OTHER LIST

pron()

# Softanza can distribute the items of a list over the items of an other,
# called metaphorically 'Beneficiary Items'  as they benfit from that
# distribution.
		
# The distribution is defined by the share of each item.
		
# The share of each item determines how many items should be given to
# the each beneficiary item.
		
# Let's see:	

o1 = new stzList([ "water", "coca", "milk", "spice", "cofee", "tea", "honey" ] )
? @@SP( o1.DistributeOver([ "arem", "mohsen", "hamma" ]) ) + NL
#--> [
#	[ "arem",   [ "water", "coca", "milk" ] ],
#	[ "mohsen", [ "spice", "cofee" ],
#	[ "hamma",  [ "tea", "honey" ]
# ]

# Same can be made using the extended form of the function, that allows
# us to specify how the items are explicitly shared:

? @@SP( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 3, 2, 2 ] ) ) + NL
#--> [
#	[ "arem",   [ "water", "coca", "milk" ] ],
#	[ "mohsen", [ "spice", "cofee" ],
#	[ "hamma",  [ "tea", "honey" ]
# ]

# And so you can change the share at your will:
? @@SP( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 1, 2, 4 ] ) ) + NL
#--> [
#	[ "arem",   [ "water" ] ] ],
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

proff()
# Executed in 0.01 second(s)

/*-----------------

pron()

# The distribution of the items of a list can be made directly using
# the "/" operator on the list object:

o1 = new stzList( L(' "♥1" : "♥6" ' ) ) # or simply o1 = LQ(' "♥1" : "♥6" ')
? @@( o1 / 6 )
#-->[ [ "♥1" ], [ "♥2" ], [ "♥3" ], [ "♥4" ], [ "♥5" ], [ "♥6" ] ]

? o1 / 8
#--> Error message:
#--> Incorrect value! n must be between 0 and 6 (the size of the list)

#NOTE
#--> The beneficiary items can be of any type. In practice, they are
# strings and hence the returned result is a hashlist.

proff()
# Executed in 0.08 second(s)

/*-----------------

pron()

o1 = new stzList(1:12)
? @@NL( o1.DistributeOver([ "Mansour", "Teeba", "Haneen", "Hussein", "Sherihen" ]) )
#-->
# [
#	[ "Mansour",  [ 1, 2, 3 ] ],
#	[ "Teeba",    [ 4, 5, 6 ] ],
#	[ "Haneen",   [ 7, 8    ] ],
#	[ "Hussein",  [ 9, 10   ] ],
#	[ "Sherihen", [ 11, 12  ] ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.17

/*-----------------

pron()

o1 = new stzList( L(' "♥1" : "♥9" ') )
? @@SP( o1 / [ "Mansoor", "Teeba", "Haneen" ] )
#-->
# [
#	[ "Mansoor", 	[ "♥1", "♥2", "♥3" ] ],
#	[ "Teeba", 	[ "♥4", "♥5", "♥6" ] ],
#	[ "Haneen", 	[ "♥7", "♥8", "♥9" ] ]
# ]

proff()
# Executed in 0.05 second(s).

/*------------
*/
pron()

# A Softanza NullObject is a named object

? NullObject().IsNamedObject()
? NullObject().VarName()
#--> @nullobject

# It can't equal anything, even itself!

? NullObject().IsEqualTo(NullObject())
#--> FALSE

proff()
# Executed in almost 0 second(s).

/*------------ #narration NAMED OBJECTS EQuALiTY

# Softanza can check objects equality only if objects are
# created as named objects (a special form of a Softanza
# object that you cread along with its name)

pron()

obj1 = new stzString(:first  = "Ring")
obj2 = new stzString(:second = "Python")
obj3 = new stzString(:first  = "basic")

? AreNamedObjects([ obj1, obj2, obj3 ])
#--> TRUE

? ObjectsNames([ obj1, obj2, obj3 ])
#--> [ :first, :second, :first ]

? AreEqual([ obj1, obj2 ]) # Or AreEqualObjects()
#--> FALSE

? AreEqual([ obj1, obj3 ])
#--> TRUE

proff()
# Executed in 0.03 second(s).

/*---------------------

pron()

? AreEqual([ 1:3, 1:3, 1:3, 1:3 ])
#--> TRUE

? AreEqual([ ["A", 1:5], 1:3, 1:3, 1:3 ])
#--> FALSE

? AreEqual([ NullObject(), NullObject(), NullObject() ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])
o1.RemoveAll("a")
? o1.Content()
#--> [ "b", "c", "b", "c" ]

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

? AreEqualCS([ "a", "a", "A", "A", "a", "A" ], FALSE)
#--> TRUE

proff()
# Executed in almost 0 second(s).


/*---------------------

pron()

# All these return TRUE

o1 = new stzList([ "a", "a", "A", "A", "a", "A" ])

? o1.ItemsAreEqualTo("a")
#--> FALSE

? o1.ItemsAreEqualToCS("a", FALSE)
#--> TRUE

# You can also say:

? o1.ContainsOnly("a")
#--> FALSE

? o1.ContainsOnlyCS("A", FALSE)
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*--------------------- #TODO

pron()

o1 = new stzList([ "A", "B", "C" ])
? o1.CheckWXT("isString(@item) and @IsUppercase(@item)")

proff()

/*--------------------- #TODO

pron()

# All items are lists with 3 items

o1 = new stzList([ 1:3, 1:3, 1:3 ])
? o1.CheckWXT('isList(@item) and len(@item) = 3')

proff()

/*--------------------- #TODO

pron()

# All items are lLists having same number of items

o1 = new stzList([ 1:3, 1:3, 1:3 ])
? o1.CheckWXT('isList(@item) and len(@item) = len(o1[1])')

proff()

/*--------------------- #narration

pron()

# In the following example, we check if the entire list ["a", "b", "c"] exists
# as a single item within the list ["a", "b", "c", "x", "z"].

# Although you might expect this to return TRUE, it actually returns FALSE.
? Q(["a", "b", "c"]).ExistsIn(["a", "b", "c", "x", "z"])
#--> FALSE

# The result is FALSE because there are no occurrences of ["a", "b", "c"] as a 
# single list element within the larger list.
? @@(Q(["a", "b", "c", "x", "z"]).FindAll(["a", "b", "c"]))
#--> []

# However, if we modify the list to include ["a", "b", "c"] as an item:
? Q(["a", "b", "c"]).ExistsIn(["a", "b", "c", "x", "z", ["a", "b", "c"]])
#--> TRUE

# This returns TRUE because the last element of the second list is now an item of
# type list that matches ["a", "b", "c"], satisfying the ExistsIn() condition.

# Now, let's restart from the beginning with a different method: ExistIn(),
# which omits the "s" at the end. This method uses a different semantic approach.

? Q(["a", "b", "c"]).ExistIn(["a", "b", "c", "x", "z"])
#--> TRUE

# Here, the result is TRUE because ExistIn() implies checking if the sequence
# ["a", "b", "c"] exists within the list as a sub-sequence, rather than as a 
# single item. This method accounts for multiple consecutive items rather than 
# a single item, as with ExistsIn().

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])

? o1.IsMadeOf([ "a", "b", "c" ])
#--> TRUE

? o1.IsMadeOfSome([ "a", "b", "c", "x", "z" ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ :monday, :monday, :monday ])
? o1.IsMadeOfOneOfThese([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*---------------------

pron()

? IsHashList([ :Language = "arabic", :Country = "tn", :Script = "arabic" ])
#--> TRUE

? StzListQ([ :Language = "arabic", :Country = "tn", :Script = "arabic" ]).IsHashList()
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*---------------------

pron()

? Q([ :ar, :en, :fr ]).AreLanguageAbbreviations()
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*---------------------

pron()

o1 = new stzList([ :Language = "arabic", :Country = "tn", :Script = "arabic" ])

? o1.IsLocaleList() + NL
#--> TRUE

o1 = new stzList([ :Language = "ar", :Country = "TN", :script = "arabic" ])
? o1.IsLocaleList() + NL
#--> TRUE

? StringIsScriptName("latin")
#--> TRUE

proff()
# Executed in 0.03 second(s).

/*---------------------

pron()

o1 = new stzList([ :english = "house", :french = "maison", :arabic = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

o1 = new stzList([ :en = "house", :fr = "maison", :ar = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*---------------------

pron()

o1 = new stzList([ "green", "red", "blue" ])

? o1.ContainsOneOfThese(["red", "t", "cv"]) + NL
#--> TRUE

#---

? o1.IsContainedIn([ "green", "red", "blue", "magenta", "gray" ]) # Same as ExistsIn()
#--> FALSE

? o1.AreContainedIn([ "green", "red", "blue", "magenta", "gray" ]) + NL # Same as ExistIn() (without "s")
#--> TRUE

#---

? o1.Contains([ "red", "blue" ])
#--> FALSE

? o1.ContainsThese([ "red", "blue" ]) + NL
#--> TRUE

#---

? o1.ContainsOneOfThese([ "yelloW", "GREEN", "magenta" ])
#--> FALSE

? o1.ContainsOneOfTheseCS([ "yelloW", "GREEN", "magenta" ], FALSE)
#--> TRUE

? o1.ContainsNoOneOfThese([ "yellow", "magenta", "gray" ]) + NL
#--> TRUE

proff()
# Executed in 0.05 second(s).

#---------

pron()

o1 = new stzList([ "green", "red", "blue" ])

? o1.CommonItemsWith([ "yellow", "red", "blue", "gray" ]) 
#--> [ "red", "blue" ]

? o1.DifferentItemsWith([ "yellow", "red", "blue", "gray" ]) # Or DifferenceWith()
#--> [ "green", "yellow", "gray" ]

? @@NL( o1.DifferenceWithXT([ "yellow", "red", "blue", "gray" ]) ) # Or DifferentItemsWithXT()
#--> [
#	[ "surplus", [ "green" ] ],
#	[ "lacking", [ "yellow", "gray" ] ]
# ]

proff()
# Executed in 0.04 second(s).
                                       
/*--------------------------

pron()

o1 = new stzList([ "green", "red" ])

? o1.IsIncludedIn([ "green", "red", "blue" ])
#--> FALSE

? o1.AreIncludedIn([ "green", "red", "blue" ])
#--> TRUE

proff()
# Executed in 0.02 second(s).

/*--------------------------

pron()

o1 = new stzList([ "green", "red" ])

? o1.DifferenceWith([ "b","x", "a", "f"]) # Or DifferentItemsWith()
#--> [ "green", "red", "b","x", "a", "f"])

? @@( o1.CommonItemsWith([ "b","x", "a", "f"]) ) # or Intersection()
# []

? o1.ContainsSameItemsAs([ "red", "green" ])
#--> TRUE

? o1.ContainsSameItemsAs([ "a", "b", "c", "f" ])
#--> FALSE

proff()
#--> Executed in 0.02 second(s).

/*--------------------------

pron()

o1 = new stzList([ 1, 2, 3 ])

? @@( o1.UnionWith([ 3, 4, 5 ]) )
#--> [ 1, 2, 3, 3, 4, 5 ]

? @@( o1.IntersectionWith([3, 4, 5 ]) )
#--> [ 3 ]

proff()
# Executed in 0.02 second(s).

/*--------------------------

pron()

o1 = new stzList([ "a", "b", "b", "b", "c" ])
? o1 - "b"
#--> [ "a", "c" ]

? o1 - These([ "b", "c", "b" ])
#--> [ "a" ]

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ "a", "b", "b", "b", "c" ])
o1.RemoveItemsAtPositions([2,3,4])
? o1.Content()
#--> [ "a", "c" ]

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ "a", "b", "b", "b", "c" ])
? o1 - these([ "b", "b" ])
#--> [ "a", "c" ]

? o1.DifferenceWith([ "a", "c" ])
#--> [ "b", "b", "b" ]

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

aList = [ :name = "mansour", :job = "programmer", :name = "xe" ]
o1 = new stzList(aList)

? o1.IsHashList()
#--> FALSE

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ "a", "c", 12 ])
? o1.HasSameContentAs([ "a", 12, "c" ])
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ :ring, 5, :php, :ruby, :python, :ring, 5 ])
? o1.NumberOfOccurrence(5)
#--> 2

? o1.NumberOfOccurrence(:ring)
#--> 2

proff()
# Executed in 0.01 second(s).

/*--------------------------

pron()

o1 = new stzList([ "a", "c" ])
? o1.ItemsHaveSameOrderAs([ "a", "c", "f" ])

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ 1, 2, 3, 6 ])
? o1.IsReverseOf([ 6, 3, 2, 1 ])
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()
o1 = new stzList([ 1, 2, 3 ])

? o1.IsEqualTo([ 3, 1, 2 ])
#--> TRUE

? o1.IsStrictlyEqualTo([ 3, 1, 2 ])
#--> FALSE

? o1.IsStrictlyEqualTo([ 1, 2, 3 ])
#--> TRUE

proff()
# Executed in 0.01 second(s).

/*--------------------------

pron()

o1 = new stzList([ 2, 1, 3 ])
? o1.ItemsHaveSameOrderAs([ 2, 1, 3, 6 ])
#-- TRUE

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

aList = [ 12,
	[ "A", [ 1, 2, 3] ], 		# 1st sublist
	[ "B", [ 3, 5, 3 ] ], 		# 2nd sublist
	[ "C", [ 1, 4, [1,2,3], 4] ] 	# 3rd sublist
]

? StzListQ(aList).ContainsOneOrMoreLists()

proff()

/*--------------------------

pron()

o1 = new stzList([ "A", "B", 1:3, "C", "D", 4:5 ])
? o1.FirstList()
#--> [ 1, 2, 3 ]

? o1.FindFirstList()
#--> 3

proff()
# Executed in almost 0 second(s).

/*-------------------------- #TODO

pron()

aList = [ 12,
	[ "A", [ 1, 2, 3] ], # 1st sublist
	[ "B", [ 3, 5, 3 ] ], # 2nd sublist
	[ "C", [ 1, 4, [1,2,3], 4] ] # 3d sublist
]

o1 = new stzList(aList)
? o1.WalkUntilItem(7)
? aList

proff()

/*--------------------------

pron()

o1 = new stzList([
	"A",
	[ 1, 2, 3 ],
	"B",
	[ 4, [ 5, 6 ], 7 ],
	"C",
	[ 8 ]
])

? @@( o1.DeepLists() )
#--> [ [ 1, 2, 3 ], [ 5, 6 ], [ 8 ] ]

proff()
# Executed in 0.04 second(s).

/*--------------------------

pron()

o1 = new stzList(  [	:name, :age, 	:job		])
? o1.AssociateWith([ 	"Ali", 	24, 	"Programmer" 	])
? @@NL( o1.Content() )
#--> [
#	[ "name", "Ali" ],
#	[ "age", 24 ],
#	[ "job", "Programmer" ]
# ]

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList([ 1, 1, 1 ])
? o1.AllItemsAreEqualTo(1)

proff()
# Executed in almost 0 second(s).

/*--------------------------

pron()

o1 = new stzList("a":"t")
? o1.Contains("x")
#--> FALSE

proff()
# Executed in 0.03 second(s).

/*============ TODO: Levels functions need a reflection, see code.
# To be replaced with DeepFind

pron()

o1 = new stzList([
	1, [ "A", "B"], 2,
	[ 3, 4, [ "B", "C" ] ],
	[ 5, [ 6, [ "D", "E" ], 7 ], 8 ]
])

? @@NL( o1.DeepFindLists() ) + NL
#--> [
#	[ 2 ],
#	[ 4 ],
#	[ 4, 3 ],
#	[ 3 ],
#	[ 3, 2 ],
#	[ 3, 2, 2 ]
# ]

? o1.NumberOfLevels() + NL
#--> 4

? @@( o1.DeepLists() ) + NL
#--> [ [ "A", "B" ], [ "B", "C" ], [ "D", "E" ] ]


? @@NL( o1.DeepListsXT() )
#--> [
#	[ [ "path", [ 2 ] ], [ "level", 1 ], [ "position", 2 ] ],
#	[ [ "path", [ 4 ] ], [ "level", 1 ], [ "position", 4 ] ],
#	[ [ "path", [ 4, 3 ] ], [ "level", 2 ], [ "position", 3 ] ],
#	[ [ "path", [ 3 ] ], [ "level", 1 ], [ "position", 3 ] ],
#	[ [ "path", [ 3, 2 ] ], [ "level", 2 ], [ "position", 2 ] ],
#	[ [ "path", [ 3, 2, 2 ] ], [ "level", 3 ], [ "position", 2 ] ]
# ]

proff()
# Executed in 0.15 second(s).

