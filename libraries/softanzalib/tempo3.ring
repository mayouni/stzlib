load "stzlib.ring"

/*-----------------------
*/
o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

? @@( o1.FindNFirstOccurrencesOfSubString(4, "ring") )
#--> [ [ 1, 5 ], [ 1, 14 ], [ 2, 1], [ 2, 10 ] ]

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
#	[ [ 3, 1 ], , [ 4, 1 ] ], 				#<<< Occurrences of "ruby"
#	[  ] 					#<<< No occurrences at all for "pyhthon"
#   ]

/*--------------

o1 = new stzListOfStrings([ "ring php", "php", "ring php ring" ])

# How many occurrence are there of the substring "ring" in the list?
? o1.NumberOfOccurrenceOfSubString("ring") #--> 3

# Show these 3 in detail, string by string:
? @@( o1.NumberOfOccurrenceOfSubStringXT("ring") )
#--> [ [ 1, 1 ], [ 3, 2 ] ]

#====================== DISTRIBUTING ITEMS OVER THE ITEMS OF AN OTHER LIST

/*
Softanza can distribute the items of a list over the items of an other,
called metaphorically 'Beneficiary Items'  as they benfit from that
distribution.
		
The distribution is defined by the share of each item.
		
The share of each item determines how many items should be given to
the each beneficiary item.
		
Let's see:	

o1 = new stzList([ :water, :coca, :milk, :spice, :cofee, :tea, :honey ] )
? @@( o1.DistributeOver([ :arem, :mohsen, :hamma ]) ) + NL
# Gives:
# [
#	:arem   = [ :water, :coca ],
#	:mohsen = [ :milk, :spice, :cofee ],
#	:hamma  = [ :tea, honey ]
# ]

# Same can be made using the extended form of the function, that allows
# us to specify how the items are explicitely shared:

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

#   What : Can't distribute the items of the main list over the items of the provided list!
#   Why  : Sum of items to be distributed (in anShareOfEachItem) must be equal to number of items of the main list.
#   Todo : Provide a share list where the sum of its items is equal to the number of items of the list.


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

/*-----------------

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

		o1.ReplaceInStringN(2, "ring", :With = "♥")
		? o1.Content()
		#--> [ "php", "♥ php ♥ python ♥", "python" ]


/*
o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
o1.ReplaceInStringNSubstringAtPositionN(2, 5, "ring", "♥" )
? o1.Content()
#--> [ "php", "php ♥ python", "python" ]

		o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
		o1.ReplaceInStringNTheNthOccurrence(2, 1, "ring", "♥" )
		? o1.Content()
		#--> [ "php", "ring php ring python ♥", "python" ]

		o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
		o1.ReplaceInStringNTheFirstOccurrence(2, "ring", "♥" )
		? o1.Content()
		#--> [ "php", "♥ php ring python ring", "python" ]

		o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
		o1.ReplaceInStringNTheLastOccurrence(2, "ring", "♥" )
		? o1.Content()
		#--> [ "php", "ring php ring python ♥", "python" ]


