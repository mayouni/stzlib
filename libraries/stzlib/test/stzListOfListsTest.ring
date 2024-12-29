load "../max/stzmax.ring"

/*--------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, "hi", "ring" ],
	[ "karim", 	20 , "hi" ],
	[ "salem", 	67 ]
])

? o1.HowManyMissing()
#--> 3

? @@( o1.Sizes() )
#--> [ 4, 2, 2 ]

? o1.MinSize()
#--> 2

? o1.Maxsize()
#--> 4

? @@( o1.FindMissing() ) + NL
#--> [ [ 2, 4 ], [ 3, 3 ], [ 3, 4 ] ]

o1.Extend()

? @@SP( o1.Content() )
#--> [
#	[ "mohannad", 100, "hi", "ring" ],
#	[ "karim",     20, "hi", ""     ],
#	[ "salem",      67,  "", ""     ]
# ]

? o1.HowManyMissing()
#--> 0

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------

profon()

? @IsListofLists([
	[ "mohannad", 	100, "hi", "ring" ],
	[ "karim", 	20 , "hi" ],
	[ "salem", 	67 ]
])
#--> _TRUE_

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*--------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, "him", "ring" ],
	[ "karim", 	20 , "hi" ],
	[ "salem", 	67 ]
])

? @@( o1.NthList(3) ) + NL
#--> [ "salem", 67 ]

? @@( o1.NthCol(3) )
#--> [ "him", "hi" ]

? @@( o1.NthCol(4) )
#--> [ "ring"]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*========

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, "him", "ring" ],
	[ "karim", 	20 , ["hi"] ],
	[ "salem", 	67 ]
])

o1.Sort()

? @@SP( o1.Content() )
#--> [
#	[ "karim", 20, [ "hi" ] ],
#	[ "mohannad", 100, "him", "ring" ],
#	[ "salem", 67 ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-------- #ring #qt

profon()

# In Ring and Qt and other programming languages, sort is made
# based on asscii (or unicode) values of the chars. And hance,
# "X" comes before "x" because UPPER chars come before
# lower chars in ascci range

# Let's check it in Ring

? sort([ "x", "X" ])
# [ "X" ,"x" ]

? ascii("X") #--> 88
? ascii("a") #--> 97

# And in Qt via a stzListOfStrings object (base on QStringList)

oQList = new stzListOfStrings([ "X", "x" ])
oQList.sort()
? oQList.Content()
#--> [ "X" ,"x" ]

# The same thing applies the the multi-dimensional sort:

aLists = [
	[ "mazen", 300, "X", 1 ],
	[ "amer", 300, "a", 1 ]
]

? @@SP( sort(aLists, 3) )
#--> [
#	[ "mazen", 300, "X", 1 ],
#	[ "amer", 300, "a", 1 ]
# ]

proff()
# Executed in 0.02 second(s).

/*--------

profon()

aList = [
	[ "salem", 67, "" ],
	[ "mourad", 18, "" ],
	[ "amer", 34, "" ],
	[ "abir", "", "" ],
	[ "amer", 20, "" ]
]

? @@SP( ring_sort2(alist, 1) )
#--> [
#	[ "abir", "", "" ],
#	[ "amer", 20, "" ],
#	[ "amer", 34, "" ],
#	[ "mourad", 18, "" ],
#	[ "salem", 67, "" ]
# ]

proff()
# Executed in almost 0 second(s).

/*--------

profon()

aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	18 ],
	[ "mazen", 	300, 	"X", 	1 ],
	[ "amer", 	300, 	"a", 	1 ],
	[ "mourad", 	18 ],
	[ "abir" ],
	[ "amer", 	34, 	'[]' ],
	[ "amer", 	20, 	"" ],
	[ "mahran", 	87,	FalseObject() ]
]

SortListsOn(aLists, 3)
#--> ERROR: Can't proceed! Nth column must not contain objects.

proff()

/*-------- #narration

profon()

# Softanza can gracefully sort a list of lists on a given column,
# even when these inner lists exhibit varying lengths

aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	18 ],
	[ "mazen", 	300, 	"X", 	1 ],
	[ "amer", 	300, 	"a", 	1 ],
	[ "mourad", 	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[] ],
	[ "amer", 	20, 	"" ]
]

? @@SP( SortListsOn(aLists, 3) )
#--> [
#	[ "abir", 	"", 	"", 	"" 	],
#	[ "mourad", 	18, 	"", 	"" 	],
#	[ "salem", 	18, 	"", 	"" 	],
#	[ "amer", 	20, 	"", 	"" 	],
#	[ "mazen", 	300, 	"X", 	1 	],
#	[ "amer", 	34, 	"[]", 	"" 	],
#	[ "amer", 	300, 	"a", 	1 	],
#	[ "karim", 	20, 	"hi", 	"" 	],
#	[ "mohannad", 	100, 	"him", 	"ring" 	]
# ]

# As you can see, the list is sorted with two notable modifications:
# all the lists are adjusted to the lengh of the largest list
# using _NULL_s, and if the nth column contains lists then those
# lists are stringified.

# These modifications are made to make it possible the use of
# the Ring standard function sort(aListOfLists, nCol).

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------

profon()

aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20, 	"hi", 	"" ],
	[ "salem", 	67, 	"", 	"" ],
	[ "mazen", 	0, 	"X", 	1 ],
	[ "mourad", 	18, 	"", 	"" ],
	[ "abir", 	0, 	"", 	"" ],
	[ "amer", 	34, 	"[ ]", 	"" ]
]

? @@SP( ring_sort2(aLists, 2) )
#--> [
#	[ "mazen", 0, "X", 1 ],
#	[ "abir", 0, "", "" ],
#	[ "mourad", 18, "", "" ],
#	[ "karim", 20, "hi", "" ],
#	[ "amer", 34, "[ ]", "" ],
#	[ "salem", 67, "", "" ],
#	[ "mohannad", 100, "him", "ring" ]
# ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*-------- #TODO #narration Difference between SortOn() and SortBy()

SortOn(pcColName)

SortBy(pcExpr)

/*-------- Col() and ColXT() in a list of lists

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	67 ],
	[ "mazen", 	90, 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[] ]
])

? @@SP( o1.Col(3) ) + NL
#--> [
#	"him",
#	"hi",
#	"X",
#	[ ]
# ]

# ColXT adds _NULL_s to lines corresponding to inner lists
# with smaller size then n

? @@SP( o1.ColXT(3) )
#--> [
#	"him",
#	"hi",
#	"",
#	"X",
#	"",
#	"",
#	[ ]
# ]

proff()
# Executed in 0.02 second(s).

/*-------------- #narration MEASURING SPEEDUP AND PERFPRMANCE GAIN
# Inspired by a discussion with Mahmoud on the Ring group

profon()

# Suppose you profiled a function you wrote and got 12.08 seconds.
# After refactoring and optimizing the code, you get 3.2 seconds.
# What's the performance gain in percentage?
# And how can you express this in terms of speedup factor?

# Softanza saves your time since it has the exact functions
# to do the required job:

? PerfGain(12.08, 3.20)   # Or PerfGain100 ~> Output in %
#--> 73.51

# Read it: There is a 73.51% performance gain with the second solution.

? SpeedUp(12.08, 3.20) + NL   # Or SpeedUpX() or PerfGainX() ~> Output in factor
#--> 3.78

# Read it: The second solution is 3.78 times more performant.

# These functions can be generally applied to any list of numbers.
# This allows you to calculate multiple speedups and performance
# gains in one shot:

oTimes = new stzListOfNumbers([ 12.08, 3.20, 1.18, 0.08 ])

? oTimes.PerfGains() # Or PerfGains100()
#--> [73.51, 63.13, 93.22]

? oTimes.SpeedUps() # Or PerfGainsX()
#--> [3.77, 2.71, 14.75]

# NOTE: With the more general-purpose names we have for these
# functions, Gain100() and GainX(), we can use them in contexts
# beyond time performance:

oSales = new stzListOfNumbers([ 34500.89, 42180.98, 56100.65 ])

? oSales.Gain100()  # Or simply Gain() instead of PerfGain()
#--> [ 18.21, 24.81 ]

? oSales.GainX()    # Or GainFactor() instead of SpeedUp()
#--> [ 1.22, 1.33 ]

proff()
# Executed in 0.04 second(s).

/*-------

profon()

o1 = new stzListOfLists([ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ])
? o1.AreContiguous()
#--> _TRUE_

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-------

profon()

o1 = new stzList([ 1, 2, 3, 4, "|", 2, 3, 4, 5, "|", 2, 3, 4, 5 ])

? @@( AreContiguous( o1.FindManyQ([ 2, 3, 4 ]) / 3 ) ) + NL
#--> _TRUE_

? @@( o1.FindMany([ 2, 3, 4 ]) ) + NL
#--> [ 2, 3, 4, 6, 7, 8, 11, 12, 13 ]

? @@( o1.FindManyQ([ 2, 3, 4 ]) / 3 ) + NL
#--> [ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ]

? AreContiguous( [ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ] )
#--> _TRUE_

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*-------

profon()

o1 = new stzList([ 1, 2, 3, 4, "|", 2, 3, 4, 5, "|", 2, 3, 4, 5 ])
#		      \_____/       \_____/          \_____/
#			 2             6                11

? o1.FindSubList([ 2, 3, 4 ])
#--> [ 2, 6, 11 ]

proff()
# Executed in 0.04 second(s).

/*-------

profon()

? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsMany([ "amer", 34 ])
#--> _FALSE_

? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsCS("amer", _TRUE_)
#--> _FALSE_

? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsSubList([ "loves", "ring" ])
#--> _TRUE_

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*--------------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "abir",	234 ],
	[ "salem", 	67 ],
	[ "mazen", 	[90], 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[1, 2, 3 ] ],
	[ "sahloul",	108, 	"amer",	34 ],
	[ "abir" ]
])


? @@SP( o1.ListsWXT(' Q(@list).Contains("abir") ') ) + NL
#--> [
#	[ "abir", 234 ],
#	[ "abir" ],
#	[ "abir" ]
# ]

? o1.FindListsWXT(' Q(@list).Contains("abir") ')
#--> [ 3, 7, 9 ]

? @@SP( o1.ListsWXTZ(' Q(@list).Contains("abir") ') ) + NL
#--> [
#	[ [ "abir", 234 ], 3 ],
#	[ [ "abir" ], 	   7 ],
#	[ [ "abir" ], 	   9 ]
# ]

? @@SP( o1.ListsWXTZ(' Q(@list).ContainsMany([ "amer", 34 ]) ') ) + NL
#--> [
#	[ [ "amer", 34, [ 1, 2, 3 ] ], 8 ],
#	[ [ "sahloul", 108, "amer", 34 ], 9 ]
# ]

proff()
# Executed in 0.20 second(s) in Ring 1.21

/*------------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"amer", 34 ],
	[ "abir",	234 ],
	[ "salem", 	67 ],
	[ "mazen", 	[90], 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[1, 2, 3 ] ],
	[ "sahloul",	108, 	"amer",	34 ],
	[ "abir" ]
])

? Q([ "sahloul", 108, "amer", 34 ]).FindSubList([ "amer", 34 ])
#--> [ 3, 4 ]

? @@NL( o1.FindSubList([ "amer", 34 ]) ) + NL
#--> [
#	[ 2, [ 3, 4 ] ],
#	[ 8, [ 1, 2 ] ],
#	[ 9, [ 3, 4 ] ]
# ]

? o1.ContainsSubList([ "amer", 34 ])
#--> _TRUE_

proff()
# Executed in 0.11 second(s) in Ring 1.21

/*-------------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"amer", 34 ],
	[ "abir",	234 ],
	[ "salem", 	67 ],
	[ "mazen", 	[90], 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[1, 2, 3 ] ],
	[ "sahloul",	108, 	"amer",	34 ],
	[ "abir" ]
])

# Now, let’s sort this complex structure based on the 3rd column of each list (index 3).

? @@SP( o1.SortedOn(3) )

#--> [
#	[ "salem", 67, "", "" ],
#	[ "mourad", 18, "", "" ],
#	[ "abir", 234, "", "" ],
#	[ "abir", "", "", "" ],
#	[ "abir", "", "", "" ],
#	[ "mazen", [ 90 ], "X", 1 ],
#	[ "amer", 34, "[ 1, 2, 3 ]", "" ],
#	[ "sahloul", 108, "amer", 34 ],
#	[ "karim", 20, "amer", 34 ],
#	[ "mohannad", 100, "him", "ring" ]
# ]

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*--------

profon()

? @@( StzListQ([ "him", [ "him" ], "" ]).Sorted() ) + NL
#--> [ "", "him", [ "him" ] ]

o1 = new stzList([ "him", [ "him" ], "" ])
o1.Stringify()
? @@( o1.Content() )
o1.Sort()
#--> [ "him", '[ "him" ]', "" ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*--------

profon()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", 		"ring" 	],
	[ "karim", 	20 , 	[ 89, 14, 10 ] 		],
	[ "salem", 	67 , 	"h" 			],
	[ "hatem",	1200, 	[ "xyz", "www" ] 	],
	[ "selim",	199, 	1500			]
])


? @@SP( o1.SortedOn(3) )
#--> [
#	[ "selim", 199,    1500 			],
#	[ "hatem", 1200,   [ "xyz", "www" ] 		],
#	[ "karim", 20,     [ 89, 14, 10 ] 		],
#	[ "salem", 67,     "h" 				],
#	[ "mohannad", 100, "him", 		"ring" 	]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*--------

profon()

o1 = new stzListOfLists([
	[ :is, :will, :can, :some, :can ],
	[ :can, :will ],
	[ :will ]
])

? @@NL( o1.Index() ) + NL
#--> [
#	[ "is", [ 1 ] ],
#	[ "will", [ 1, 2, 3 ] ],
#	[ "can", [ 1, 1, 2 ] ], [ "some", [ 1 ] ]
# ]

? @@NL( o1.IndexXT() )
#--> [
#	[ "is", 	[ [ 1, 1 ] ] ],
#	[ "will", 	[ [ 1, 2 ], [ 2, 2 ], [ 3, 1 ] ] ],
#	[ "can", 	[ [ 1, 3 ], [ 1, 5 ], [ 2, 1 ] ] ],
#	[ "some", 	[ [ 1, 4 ] ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*===

profon()

? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*-----

profon()

? Intersection([ "A":"C", "A":"C", "A":"C" ])
#--> [ "A", "B", "C" ]

? Intersection([ "A":"C", "A":"B", "A":"C" ])
#--> [ "A", "B" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*=====

profon()

o1 = new stzListOfLists([ 1:3, 1:3, 1:3 ])
? o1.IsMadeOfSameList()
#--> _TRUE_

? StzListOfListsQ([ 1:3, 1:2, 1:3 ]).AllListsAreEqual()
#--> _FALSE_

#TODO : Add to stzList
#	AllNumbersAreEqual()
#	AllStringsAreEqual()
#	AllListsAreEqual()
#	AllObjectsAreEqual()

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*=========

profon()

o1 = new stzListOfLists([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() )
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*=========

profon()

? @@( Association([ [ :one, :two, :three ], s[1, 2, 3] ]) )
#--> [ [ "one", 1 ], [ "two", 2 ], [ "three", 3 ] ]

proff()
# Executed in 0.05 second(s)

/*-------------

profon()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "I", "♥" ],
	[ "G", "H", "R" ],
	[ "J", "K", "I", "N", "G" ]
])

? @@(o1.FindExtraItems()) + NL
#--> [
#	[ 1, [ ] ],
#	[ 2, [ 3, 4 ] ],
#	[ 3, [ 3 ] ],
#	[ 4, [ 3, 4, 5, 6 ] ]
# ]

? @@( o1.ExtraItems() )
#--> [ [ ], [ "I", "♥" ], [ "R" ], [ "I", "N", "G" ] ]

proff()

/*=============

profon()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Flatten()
#--> Error message:
# Can't flatten the list of lists!
# Instead you can return a flattend copy of it using Flattened()

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.04 second(s)

/*---------------

profon()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Merge()
#--> Error message:
# Can't merge the list of lists!
# Instead you can return a merged copy of it using Merged()

? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.03 second(s)

#NOTE: You will understand the difference between Flatten() and Merge()
# by reading the fellowing two ewxamples...

/*---------------

profon()

o1 = new stzList([
	[1, 2],
	[3, [4, 5:7 ] ],
	8,
	[ [ 9, [10] ] ]
])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.03 second(s)

/*---------------

profon()

o1 = new stzList([ [1, 2], [3, [4]], 5 ])

? @@( o1.Merged() )
#--> [ 1, 2, 3, [ 4 ], 5 ]

proff()
# Executed in 0.03 second(s)

/*---------------

profon()

? @@( ListsMerge([ [3, 5], [7, [8]] ]) )
#--> [ 3, 5, 7, [ 8 ] ]

proff()
# Executed in 0.03 second(s)

/*-------------

profon()

aMyLists = [
	[ "a", "ab", "b", "b" ],
	[ "a", "a", "ab", "abc", "b", "bc", "c" ],
	[ "ab", "xt", "b", "xt" ]
]

? @@( Intersection(aMyLists) ) # Same as CommonItems()
#--> [ "ab", "b" ]

proff()
# Executed in 0.07 second(s)

/*===============

profon()

o1 = new stzListOfLists([
	[ "Ring", "Ruby", "Python" ],
	[ "Julia", "Ring", "Go", "Python" ],
	[ "C#", "PHP", "Python", "Ring" ]
])

? o1.CommonItems() # Same as Intersection()
#--> [ "Ring", "Pyhton" ]

proff()
# Executed in 0.11 second(s)

/*-------------

profon()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3, "c" ])
? @@( o1.ToSet() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ], "abc", "bc", "c" ]

proff()
# Executed in 0.17 second(s)

/*-------------

profon()

? Q([ "a", "ab", "b", [ 1, 2, 3 ] ]).ToSet()
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

proff()
#--> Executed in 0.06 second(s)

/*=============== EXTENDING A LIST

profon()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)

? @@( o1.content() )
#--> [ "A", "B", "C", "", "" ]

proff()
# Executed in 0.03 second(s)

/*-------------

profon()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :Using = AHeart() )

? @@( o1.content() )
#--> [ "A", "B", "C", "♥", "♥" ]

proff()
# Executed in 0.04 second(s)

/*=============== EXTENDING THE LISTS OF A LIST OF LISTS

profon()

o1 = new stzListOfLists([ # or stzLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])
 
? o1.IsHomolog() # or o1.IsHomologuous() or o1.ListsHaveSameSize()
#--> _FALSE_

? o1.SizeOfLargestList()
#--> 4

o1.Extend()

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> _TRUE_

proff()
# Executed in 0.07 second(s)

/*---------------

profon()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendXT(:Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

proff()
# Executed in 0.08 second(s)

/*---------------

profon()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :ByRepeatingItems ) # or :Using = :RepeatedItems

? @@( o1.Content() )
#--> [
#	[ "A", "B", "A", "B", "A", "B" ],
#	[ "C", "D", "E", "F", "C", "D" ],
#	[ "I", "I", "I", "I", "I", "I" ]
# ]

proff()
#--> Executed in 0.07 second(s)

/*---------------

profon()

o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥", "♥", "♥" ],
#	[ "C", "D", "E", "F", "♥", "♥" ],
#	[ "I", "♥", "♥", "♥", "♥", "♥" ]
# ]

proff()
# Executed in 0.10 second(s)

/*================= SHRINKING A LIST

profon()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.ShrinkTo(3)

? o1.Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.03 second(s)

/*================= SHRINKING A LIST OF LISTS

profon()

o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.Shrink()

? @@( o1.Content() )
#--> [ [ "A", "B" ], [ "D", "E" ], [ "H", "I" ] ]

proff()
# Executed in 0.09 second(s)

/*-----------------

profon()

o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.ShrinkTo(1)

? @@( o1.Content() )
#--> [ [ "A" ], [ "D" ], [ "H" ] ]

proff()
# Executed in 0.12 second(s)

/*-----------------

profon()

o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.AdjustXT(:To = 3, :Using = AHeart())

o1.Show()
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E" ],
#	[ "I", "♥", "♥" ]
# 

proff()
# Executed in 0.03 second(s) in Ring 1.21

/*=================

profon()

o1 = new stz2DList([	# Or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? @@( o1.Shrinked() ) + NL
#--> [ [ "A" ], [ "C" ], [ "I" ] ]

? @@( o1.Extended() )
#--> [
#	[ "A", "B", "", "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "", "", "" ]
# ]

proff()
# Executed in 0.07 second(s)

/*=================

profon()

# You can extend a list of lists to any number of items like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> _FALSE_

o1.ExtendTo(4)
# By default, the items are extended using the _NULL_ char
# Use ExtendToXT(n, char) to specify your own (next example)

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> _TRUE_

proff()
#--> Executed in 0.05 second(s)

/*---------------

profon()

# You can even extend to n items and specify
# the value of the item to extend them with, like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT(4, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*---------------

profon()

# If the lists are to be extended to a number
# smaller then the largest size in the list,
# then only the smaller lists extended:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> _FALSE_

o1.ExtendToXT(3, :Using = AHeart())
# Only the 1st and 3d lists are extended

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> _FALSE_

proff()
# Executed in 0.06 second(s)

/*---------------

profon()

# If the lists are to be extended to a number
# larger then the largest size in the list,
# then all the lists are extended:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> _FALSE_

o1.ExtendToXT(5, :Using = AHeart())
# Only the 1st and 3d lists are extended

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥", "♥" ],
#	[ "C", "D", "E", "F", "♥" ],
#	[ "I", "♥", "♥", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> _TRUE_

proff()
# Executed in 0.06 second(s)

/*==================

profon()

o1 = new stzLists([ 1:3, 1:5, 1:2 ])

? o1.Smallest()
#--> [1, 2]

? o1.SmallestSize()
#--> 2

? o1.FindSmallest()
#--> 3

? "--"

? o1.Largest()
#--> [1,2, 3, 4, 5]

? o1.LargestSize()
#--> 5

? o1.FindLargest()
#--> 2

proff()
#--> Executed in 0.03 second(s)

/*-------------------

profon()

o1 = new stzLists([ 1:2, 1:5, 1:3, 1:5 ])

? @@( o1.FindLargestLists() ) + NL
#--> [2, 4]

? @@( o1.LargestLists() ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ] ]

? @@( o1.LargestListsZ() )
# [ [ [ 1, 2, 3, 4, 5 ], 2 ], [ [ 1, 2, 3, 4, 5 ], 4 ] ]

proff()
# Executed in 0.07 second(s)

/*-------------------

profon()

o1 = new stzLists([ 1:2, 1:5, 1:3, 1:2 ])

? @@( o1.FindSmallestLists() ) + NL
#--> [1, 4]

? @@( o1.SmallestLists() ) + NL
#--> [ [1, 2], [1, 2] ]

? @@( o1.SmallestListsZ() )
#--> [ [ [ 1, 2 ], 1 ], [ [ 1, 2 ], 4 ] ]

proff()
# Executed in 0.07 second(s)

/*==================

profon()

o1 = new stzLists([ "A":"C", 1:3 ])
? @@( o1.Associated() )
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

proff()
# Executed in 0.03 second(s)

/*------------------

profon()

? @@( Association([ ["A", "B", "C"], [1, 2, 3] ]) )
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

proff()
# Executed in 0.03 second(s)

/*==================

profon()

o1 = new stzList([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? o1.EachItemIsA(:ListOfNumbers)
#--> _TRUE_

o1 = new stzList([ "A":"C", "E":"D", "G": "Y" ])
? o1.EachItemIs(:ListOfStrings)
#--> _TRUE_

? o1.EachItemIs(:ListOfChars)
#--> _TRUE_

proff()
# Executed in 0.37 second(s)

/*==================

profon()

o1 = new stzList([ "A", 1:3, "B", 4:7, 8:10 ])
? @@( o1.MergeQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, 8, 9, 10 ]

o1 = new stzList([ "A", 1:3, "B", 4:7, [ "C", 99:100, "D" ], 8:10 ])
? @@( o1.MergeQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, "C", [ 99, 100 ], "D", 8, 9, 10 ]

o1 = new stzList([ "A", 1:3, "B", 4:7, [ "C", 99:100, "D" ], 8:10 ])
? @@( o1.FlattenQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, "C", 99, 100, "D", 8, 9, 10 ]

proff()
# Executed in 0.04 second(s)

/*-----------------

profon()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//? @@( o1.MergeQ().Content() )
#--> Error: Can't merge the list of lists! Instead
# you can return a merged copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", [ 0, 1 ], "B" ]

//? @@( o1.FlattenQ().Content() )
#--> Error: Can't flatten the list of lists! Instead
# you can return a flattened copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", 0, 1, "B" ]

proff()
# Executed in 0.06 second(s)

/*==================

profon()

o1 = new stzListOfLists([
	1:2, 1:3, [9,9,9], 1:4, 1:5, [9,9,9], 1:7, 1:8, [9,9,9]
])


? o1.FindAll([9,9,9])
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = [9,9,9]) 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = [9,9,9])
#--> [6, 9]

? o1.NLastOccurrencesXT(2, [9,9,9], :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 6)
#--> [6, 9]

? @@(o1.LastNOccurrencesXT(1, :Of = [9,9,9], :StartingAt = 9))
#--> [9]

proff()
# Executed in 0.15 second(s)

/*-----------

profon()

o1 = new stzString("[4, 5, 6, 7, 8]")

? @@(o1.RepeatedLeadingChars())
#--> []

? o1.ContainsLeadingAndTrailingChars()
#--> _FALSE_

? o1.FirstAndLastChars()
#--> [ "[", "]" ]

? o1.Bounds()
#--> [ "[", "]" ]


? @@( o1.FindTheseBoundsAsSections("[[", "]") )
#--> [ ]

? o1.FindTheseBoundsAsSections("[", "]")
#--> [ [ 1, 1 ], [ 15, 15 ] ]

o1.RemoveTheseBounds("[","]")
? o1.Content()
#--> "4, 5, 6, 7, 8"

proff()
# Executed in 0.06 second(s) in Ring 1.21

/*-----------

profon()

? @@( StzListQ( 4:8 ).ToListInAString() )
#--> "[ 4, 5, 6, 7, 8 ]"

? @@( StzListQ( 4:8 ).ToListInAStringInShortForm() )
#--> "4:8"

proff()
# Executed in 0.50 second(s)

/*----------- #TODO Retest after including CheckW()

profon()

o1 = new stzListOfLists([ 1:3, 4:5, 6:7 ])
? @@( o1.ToListInString() )
#--> "[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7 ] ]"

? @@( o1.ToListInStringInShortForm() )
#--> [ "1:3", "4:5", "6:7" ]

proff()

/*----------

profon()

o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])


? o1.NthList(4)
#--> [3, 5]

? @@( o1.ItemsAtPositionN(2) )
#--> [ 2, 5, 0, 5, 6 ]

? @@( o1.ListsOfSize(2) )
#--> [ [9, 0], [3, 5] ]

? o1.PositionsOfListsOfSize(2)
#--> [ 3, 4 ]

? @@( o1.Sizes() )
#--> [ 3, 5, 2, 2, 3 ]

? o1.SmallestSize()
#--> 2

? o1.BiggestSize()
#--> 5

? @@( o1.SmallestLists() )
#--> [ [ 9, 0 ], [ 3, 5 ] ]

? o1.PositionsOfSmallestLists()
#--> [ 3, 4 ]

? @@( o1.ListsWXT('Q(@list).Size() <= 3') )
#--> [ [ 1, 2, 3 ], [ 9, 0 ], [ 3, 5 ], [ 5, 6, 7 ] ]

# Test this line after adding Yield() #TODO

//? @@( o1.Yield('{ len(@list) }') ) 	#--> [ 3, 5, 2, 2, 3 ]

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*----------

profon()

// Merging many lists in one list
o1 = new stzListOfLists([ 1:3, 4:7, 8:9, [10, 11:13] ])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*================

profon()

o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? @@( o1.ListsOfSizeN(2) )
#--> [ [ 9, 0 ], [ 3, 5 ] ]

? proff()
# Executed in 0.01 second(s) in Ring 1.21

/*=============== #TODO Make a narration about indexing lists of lists

profon()

# In this example, we are going to index those three lists:

a1 = [ "A", "B", "A" ]
a2 = [ "A", "B", "C" ]
a3 = [ "C", "D", "A" ]

o1 = new stzListOfLists([ a1, a2, a3 ])

# First, we index them on the positions occuppied by each item
# in each list

? @@NL( o1.Index() ) + NL
#--> [
#	[ "A", [ 1, 1, 2, 3 ] ],
#	[ "B", [ 1, 2 ] ],
#	[ "C", [ 2, 3 ] ],
#	[ "D", [ 3 ] ]
# ]

? @@NL( o1.IndexXT() )
#--> [
#	[ "A", [ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 3, 3 ] ] ],
#	[ "B", [ [ 1, 2 ], [ 2, 2 ] ] ],
#	[ "C", [ [ 2, 3 ], [ 3, 1 ] ] ],
#	[ "D", [ [ 3, 2 ] ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*==============

profon()

? 3Cards()
#--> [ "🂭", "🂡", "🂡" ]

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ 1, 2, 3 , 4, 5 ],
	3Cards()
])

? @@SP( o1.Adjusted() ) + NL
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]

? @@SP( o1.AdjustedWith( AHeart() ) ) # Or AdjustedWith("♥")
#--> [
#	[ "A", "B",  "♥",  "♥", "♥" ],
#	[   1,   2,    3,   4,    5 ],
#	[ "🂡", "🂨",  "🂨", "♥", "♥" ]
# ]


? @@SP( o1.Stretched() ) + NL # Or Extended or Expanded
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]


? @@SP( o1.Shrinked() )
#--> [
#	[ "A", "B" ],
#	[ 1, 2 ],
#	[ "🂡", "🂥" ]
# ]

proff()
# Executed in 0.03 second(s) in Ring 1.22
