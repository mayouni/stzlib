load "stzlib.ring"

# Bounds() BoundingChars()

 
/*------

pron()

# Here, you cen get a section from a string
? Q("---ring---").Section(4, 7)
#--> ring

# And here you get the list of chars of that section
? Q("---ring---").CharsInSection(4, 7)
#--> [ "r", "i", "n", "g" ]

proff()

/*------
*/
pron()

o1 = new stzString("---Ring")

? o1.FirstChar()
? o1.LastChar()

/*
? o1.LeadingChars()
#--> [ "-", "-", "-" ]

? o1.LeadingCharsXT() # Or LeadingCharsAsString() or LeadingCharsAsSubString()
#--> "---"

o1 = new stzString("Ring---")
? o1.TrailingChars()
#--> [ "-", "-", "-" ]

? o1.TrailingCharsXT()
*/
proff()

/*------

pron()

o1 = new stzString("---Ring")

o1.RemoveThisLeadingChar("*")
? o1.Content()
#--> "---Ring"

o1.RemoveThisLeadingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.05 second(s)

/*------

pron()

o1 = new stzString("Ring---")

o1.RemoveTrailingChar()
? o1.Content()

o1.RemoveThisTrailingChar("*")
? o1.Content()
#--> "Ring---"

o1.RemoveThisTrailingChar("-")
? o1.Content()
#--> "Ring"

proff()
# Executed in 0.05 second(s)

/*------

pron()

# Remove the 7 dashes in front of the word ring

o1 = new stzString("-------Ring")

o1.RemoveFirstChar()
? o1.Content()
#--> ------ring

# Remove an other one
o1.RemoveFirstChar()
? o1.Content()
#--> -----ring

# And an other one
o1.RemoveFirstChar()
? o1.Content()
#--> ----ring

# Tired? Remove them all in one shot using the eXTend form
o1.RemoveFirstCharXT()
? o1.Content()
#--> ring

proff()

/*-----------
*/
pron()

o1 = new stzString("ring---")
? o1.RemoveThisLastCharXT("-")

proff()

/*-----------

pron()

o1 = new stzString("ring---")

? o1.RightCharRemoved()
#--> ring--

? o1.CharRemovedFromRight("-")
#--> ring--

? o1.TrailingCharsRemoved()
#--> ring

? o1.CharRemovedFromRightXT("-")
#--> ring

? o1.CharTrimmedFromRight("-")
#--> ring--

proff()

/*--------
*/
pron()

o1 = new stzString("---ring")

? o1.LeftCharRemoved()
#--> ring--

? o1.CharRemovedFromLeft("-")
#--> ring--

? o1.CharRemovedFromLeftXT("-")
#--> ring

? o1.CharTrimmedFromLeft("-")
#--> ring

proff()
# Executed in 0.04 second(s)

/*====

pron()

o1 = new stzString("12.58000")
o1.RemoveAnyOccurrenceOfCharFromRight("0")
? o1.Content()
#--> 12.58

proff()

/*===

pron()

o1 = new stzString("00012.58")
o1.RemoveCharFromLeft("0")
? o1.Content()
#--> 0012.58

pron()
# Executed in 0.02 second(s)

/*-----

pron()

o1 = new stzString("000012.58")
o1.RemoveCharFromLeftXT("0")
? o1.Content()
#--> 12.58

proff()
# Executed in 0.03 second(s)

/*========

pron()

? Q("---ring").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharRightSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharRightSide("-")
#--> 3

#--

? Q("---ring").NumberOfOccurrenceOfCharStartSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharEndSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharEndSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharStartSide("-")
# #--> 3

proff()
# Executed in 0.03 second(s)

/*-----

pron()

? StzChar(65021)
#--> ﷽

? StzCharQ(65021).Name()
#--> ARABIC LIGATURE BISMILLAH AR-RAHMAN AR-RAHEEM

? StzCharQ(65021).SizeInBytes()
#--> 3

? StzCharQ(65021).SizeInChars()
#--> 1

? Basmalah()
#--> #--> ﷽

proff()
# Executed in 0.15 second(s)

/*------

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
#    (it's a NAMED OBJECT then, made specifically to make objects findable!),
#    and the second beeing the value of the string:

	o3 = new stzString( :o3 = "hello" )
	? o3.Uppercased()
	#--> HELLO

# You want to see how NAMED OBJECTS can be findable? Ok.
# Let's consider the following list :

aMyList = [ "Hi", o1, "how", 1:3, o2, "are", o3, "you?", 1:3, o3, 99 ]

# In Ring, you can find the string "how" like this:

? find(aMyList, "how")
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

# In Softanza, you can find numbers adn strings as usual, but also you
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
# Executed in 0.08 second(s)

/*---------

pron()

? @@( Association([ "A":"C", 1:3, "a":"c" ]) )
#--> [ [ "A", 1, "a" ], [ "B", 2, "b" ], [ "C", 3, "c" ] ]

proff()
# Executed in 0.04 second(s)

/*---------

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

proff()
# Executed in  5.75 second(s) in Ring 1.19 (64 bits)
# Executed in  6.55 second(s) in Ring 1.19 (32 bits)
# Executed in 16.13 second(s) in Ring 1.18
# Executed in 34.33 second(s) in Ring 1.17

/*---------

pron()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Association() function directly
# is better than using it through a stzListOfLists object

Association([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 3.99 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Associated()
# Executed in 11.12 second(s)

proff()
# Executed in 14.72 second(s)

/*--------

pron()

# PERFORMANCE TIP - FOR LARGE LISTS: Using Merge() function directly
# is better than using it through a stzListOfLists object

Merge([ 1 : 1_000_000, 1_000_001 : 2_000_000 ])
# Executed in 1.23 second(s)

StzListOfListsQ([ 1 : 1_000_000, 1_000_001 : 2_000_000 ]).Merged()
# Executed in 1.75 second(s)

proff()
# Executed in 2.89 second(s)

/*--------

pron()



proff()

/*--------

pron()

o1 = new stzString("12345678")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList(1:8)

? o1.Section(3, 5)
#--> [ 3, 4, 5 ]

? o1.Section(5, 3)
#--> [ 3, 4, 5 ]

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList([ 120, "abc", 1:3 ])
? o1.QStringified()
#--> 	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]

proff()
