load "stzlib.ring"

/*-----

pron()

? Q( :CS = FALSE ).IsCaseSensitiveNamedParam()
#--> TRUE

proff()
#--> Executed in 0.02 second(s)

/*------ #ring

pron()

# Ring can sort  columns made of only numbers or only strings
? @@NL( ring_sort2([
	[ "mahmoud", 	34000 	],
	[ "ahmed", 	:None	],
	[ "samir", 	10	],
	[ "mohammed", 	:New	],
	[ "ibrahim", 	10700	],
	[ "hamed",	12	]
], 2) )
#--> Ring error message: Bad parameter type! In sort() In function ring_sort2() in

proff()


/*------

pron()

# Softanza can sort lists of pairs containing columns with
# heteregenious data (not only strings or only numbers like
# it is the case for native Sort(aList, nCol) in Ring)

o1 = new stzListOfpairs([
	[ "mahmoud", 	34000 	],
	[ "ahmed", 	:None	],
	[ "samir", 	1:3	],
	[ "mohammed", 	:New	],
	[ "ibrahim", 	1:2	],
	[ "hamed",	12	]
])

? @@( o1.SortedOn(2) )
#--> [
#	[ "mahmoud", 	34000 	],
#	[ "ahmed", 	"none" 	],
#	[ "samir", 	[1, 2] 	],
#	[ "mohammed", 	"new" 	],
#	[ "ibrahim", 	10700 	]
# ]

proff()
# Executed in 0.03 second(s)

/*=====::::::::::::::::::::::::::::

Alpha, Baker, Charlie, Dog, Easy, Fox, George, Harry, Igloo, Jack, King, Larry

/*------

pron()

aLists = [
	[ "Dog", 	370 ],
	[ "Fox", 	120 ],
	[ "Charlie", 	 89 ],
	[ "Baker",	493 ],
	[ "Easy", 	100 ],
	[ "Alpha",	 45 ]
]

? @@NL( SortOn(aLists, 1) ) + NL
#--> [
#	[ "Alpha", 45 ],
#	[ "Baker", 493 ],
#	[ "Charlie", 89 ],
#	[ "Dog", 370 ],
#	[ "Easy", 100 ],
#	[ "Fox", 120 ]
# ]

? @@NL( SortOn(aLists, 2) ) + NL
#--> [
#	[ "Alpha", 45 ],
#	[ "Charlie", 89 ],
#	[ "Easy", 100 ],
#	[ "Fox", 120 ],
#	[ "Dog", 370 ],
#	[ "Baker", 493 ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

aLists = [
	"A":"C", 1:3, [ 5, "E", 7 ], [1]
]

? @@NL( @SortLists(aLists) ) + NL
#--> [

#	# First come pure lists (made of items of the same type)

#	[ 1 ],
#	[ 1, 2, 3 ],
#	[ "A", "B", "C" ],

#	# Then come hybrid lists

#	[ 5, "E", 7 ]
# ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

aLists = [
	[ "Dog", 	370,	"white",	TRUE	],
	[ 1:3, 		120,	"blue",		FALSE	],
	[ "Charlie", 	1:3,	"white" 		],
	[ 630,		493 				],
	[ "Easy", 	5:8 				],
	[ 1001,	 	45,	"green" 		],
	[ "King"					],
	[ 1:2,		"nine"				]
]

? @@NL( @SortLists(aLists) )
#-- [
#	# First comes pure lists (all items are of the same type)

#	[ 630, 493 ],
#	[ "King" ],

#	# Then hyrid lists are sorted based on their size

#	[ "Easy", [ 5, 6, 7, 8 ] ],
#	[ [ 1, 2 ], "nine" ],

#	[ 1001, 45, "green" ],
#	[ "Charlie", [ 1, 2, 3 ], "white" ],

#	[ "Dog", 370, "white", 1 ],
#	[ [ 1, 2, 3 ], 120, "blue", 0 ]
# ]

proff()
# Executed in 0.02 second(s)

/*---------------

pron()

aLists = [
	[ 5, 6, 7, 8 ], [ 1, 2, 3 ], [ 4 ]
]

? @@( SortLists(aLists) )
#--> [ [ 4 ], [ 1, 2, 3 ], [ 5, 6, 7, 8 ] ]

proff()
# Executed in 0.01 second(s)

/*---------------

pron()

? @@( SortListsBySize([ [ 1, 2, 3 ], [ 5, 6, 7, 8 ], [ 1 ] ]) )
# [ [ 1 ], [ 1, 2, 3 ], [ 5, 6, 7, 8 ] ]

proff()
# Executed in 0.02 second(s)

/*---------------

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

? @@NL( SortOn(aLists, 1) )
#--> [
#	[ "Alpha", 45, "green" ],
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ], "white" ],
#	[ "Dog", 370, "white", 1 ],
#	[ "Easy", [ 5, 6, 7, 8 ] ],
#	[ "Fox", 120, "blue", 0 ],
#	[ "King" ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzListOfStrings([ "130", "12500", "17" ])

? o1.AdjustedToRightUsing(".")
#-->
# ..130
# 12500
# ...17

#TODO
# Add this feature to stzListOfNumbers #UPDATE done!

proff()
# Executed in 0.09 second(s)

#TODO: Rethink stzListOfStrings main container
# Problem: QStringList() takes time in constructing the object

/*---------------

pron()

# SortOn(list, nthCol) stringifies the nth column and then
# sorts the lists based on it

aLists = [
	[ "Dog", 	   370,		"white",	TRUE	   ],
	[ "Fox", 	4120.34,	"blue",		FALSE	   ],
	[ "Charlie", 	   1:3,		"white" 		   ],
	[ "Baker",	493.12				   	   ],
	[ "Easy", 	   5:8 				  	   ],
	[ "Alpha",	    45,		"green" 		   ],
	[ "King", 	   [1]				   	   ],
	[ 1250,		  "ON"				   	   ],
	[ "Dog", 	  370, 		"white", 	1, 	10 ],
	[ "175",	  12.1 ],
	[ "han",	   7 ]
]

? @@NL( SortOn(aLists, 2) )
#--> [
#	[ "han", 		    7 				],
#	[ "175", 		   12.10 			],
#	[ "Alpha", 	   	   45, 		"green" 	],
#	[ "Dog", 		  370, 		"white", 1 	],
#	[ "Dog", 		  370, 		"white", 1, 10 	],
#	[ "Baker", 	          493.12 			],
#	[ "Fox", 		 4120.34, 	"blue", 0 	],

#	[ 1250, 		"ON" 				],
#	[ "King", 		[ 1 ] 				],
#	[ "Charlie", 		[ 1, 2, 3 ], 	"white"		],
#	[ "Easy", 		[ 5, 6, 7, 8 ] 			]
# ]

proff()

# Executed in 0.04 second(s)

/*---------------

pron()

aLists = [
	[ "Dog", 	370,	"white",	TRUE	],
	[ "Fox", 	120,	"blue",		FALSE	],
	[ "Charlie", 	1:3,	"white" 		],
	[ "Baker",	493 				],
	[ "Easy", 	5:8 				],
	[ "Alpha",	 45,	"green" 		],
	[ "King", 	[1]				]
]

? @@SP( SortLists(aLists) ) + NL
#--> [
#	[ "Alpha", 45, "green" ],
#	[ "Baker", 493 ],
#	[ "Charlie", [ 1, 2, 3 ], "white" ],
#	[ "Dog", 370, "white", 1 ],
#	[ "Easy", [ 5, 6, 7, 8 ] ],
#	[ "Fox", 120, "blue", 0 ],
#	[ "King", [ 1 ] ]	  ]
# ]

proff()
# Executed in 0.03 second(s)

/*======= SortLists()

pron()

# If the list is made of lists of numbers or lists of strings,
# then the lists are sorted by size

? @@( SortLists([ [ 1, 2, 3 ], [ 5, 6, 7, 8 ], [ 1 ] ]) )
#--> [
#	[ 1 ],
#	[ 1, 2, 3 ],
#	[ 5, 6, 7, 8 ]
# ]

? @@( SortLists([ [ "K", "L", "M" ], [ "G" ], [ "W", "N" ] ]) )
#--> [
#	[ "G" ],
#	[ "W", "N" ],
#	[ "K", "L", "M" ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

# If the list is made of lists of numbers and strings, then the
# lists of numbers are sorted first, and then the lists of strings
# are sorted after them

? @@NL( SortLists([
	[ 1, 2, 3 ], [ "K", "L", "M" ], [ 5, 6, 7, 8 ],
	[ "G" ], [ 1 ], [ "W", "N" ] ]
) )
#--> [
#	[ 1 ],
#	[ 1, 2, 3 ],
#	[ 5, 6, 7, 8 ],
#	[ "G" ],
#	[ "K", "L", "M" ],
#	[ "W", "N" ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

# If the list is made of lists of lists

aLists = [
	[ 10:12, 3:5, "A":"C", [5] ],

	[ "B":"D", [12] ],

	[ 7, 2, [ "B":"D", 10, 8 ] ]
]


? @@NL( SortListsBySize( aLists ) ) + NL
#--> [
#	[ [ "B", "C", "D" ], [ 12 ] ],
#	[ 7, 2, [ [ "B", "C", "D" ], 10, 8 ] ],
#	[ [ 10, 11, 12 ], [ 3, 4, 5 ], [ "A", "B", "C" ], [ 5 ] ]
# ]

proff()
# Executed in 0.04 second(s)

/*-------------------

pron()

? IsHybridList([ 10, [ "B", "C", "D" ], [ 12 ] ])
#--> TRUE

? IsHybridList([ "A", [ 10, 11, 12 ], [ 3, 4, 5 ], [ "A", "B", "C" ], [ 5 ] ])
#--> TRUE

? IsHybridList([ "B":"D", [12] ])
#--> FALSE

? IsListOfHybridLists([
	[ 10, [ "B", "C", "D" ], [ 12 ] ],
	[ "B":"D", [12] ],
	[ "A", [ 10, 11, 12 ], [ 3, 4, 5 ], [ "A", "B", "C" ], [ 5 ] ]
])
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*-------------------

pron()

aLists = [
	[ 10:12, 3:5, "A":"C", [5] ],

	[ "B":"D", [12] ],

	[ 7, 2, [ "B":"D", 10, 8 ] ]
]

? IsListOfHybridLists(aLists)
#--> FALSE

? @@( Types(aLists) )
#--> [ "LIST", "LIST", "LIST" ]

proff()
# Executed in 0.03 second(s)

/*-------------------

pron()

aList = [ 10:12, 3:5, "A":"C", [5] ]

? IsHybridList(aList)
#--> FALSE

? IsPureList(aList)
#--> TRUE

? @@( Types(alist) )
#--> [ "LIST", "LIST", "LIST", "LIST" ]

proff()
# Executed in 0.02 second(s)

/*-------------------

pron()

? IsHybridList([ 7, 2, [ "B":"D", 10, 8 ] ])
#--> TRUE

? Types([ 7, 2, [ "B":"D", 10, 8 ] ])
#--> [ "NUMBER", "NUMBER", "LIST" ])

proff()
# Executed in 0.02 second(s)

/*-------------------

pron()

aLists = [
	[ 10:12, 	3:5, 		"A":"C", 		[5] 		], 	
	[ "A":"B", 	"C":"D" 						],
	[ 3:5,		10:12,	 	14:15, 			[20] 		],
	[ "B":"D", 	[12] ],		
	[ 7, 		2,		[ "B":"D", 10, 8 ] 			]
]

? @@NL( SortLists(aLists) ) + NL # Or SortOn(aList, 1)
#--> [
#	[ 7, 			2, [ [ "B", "C", "D" ], 10, 8 ] 	],
#	[ [ "A", "B" ], 	[ "C", "D" ] ],
#	[ [ "B", "C", "D" ], 	[ 12 ] ],
#	[ [ 10, 11, 12 ], 	[ 3, 4, 5 ], [ "A", "B", "C" ], [ 5 ] ],
#	[ [ 3, 4, 5 ], 		[ 10, 11, 12 ], [ 14, 15 ], [ 20 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*-------

pron()

o1 = new stzListOfpairs([
	[ "mahmoud", 	15000 ],
	[ "ahmed", 	14000 ],
	[ "samir", 	16000 ],
	[ "mohammed", 	12000 ],
	[ "ibrahim", 	11000 ]
])

? @@NL( o1.SortedOn(1) ) + NL # Or just Sorted()
#--> [
#	[ "ahmed", 	14000 ],
#	[ "ibrahim", 	11000 ],
#	[ "mahmoud", 	15000 ],
#	[ "mohammed", 	12000 ],
#	[ "samir", 	16000 ]
# ]

? @@NL( o1.SortedOn(2) )
#--> [
#	[ "ibrahim", 	11000 ],
#	[ "mohammed", 	12000 ],
#	[ "ahmed", 	14000 ],
#	[ "mahmoud", 	15000 ],
#	[ "samir", 	16000 ]
# ]

proff()
# Executed in 0.04 second(s)

/*-------

pron()

o1 = new stzListOfPairs([
	[ 4, 4 ], [ 4, 5 ], [ 4, 6 ], [ 5, 5 ], [ 5, 6 ], [ 6, 6 ],
	[ 10, 10 ], [ 10, 11 ], [ 11, 11 ],
	[15, 20], [12, 22]
])

o1.MergeInclusive()
? @@( o1.Content() )
#--> [ [ 4, 6 ], [ 10, 11 ], [ 12, 22 ] ]

proff()
# Executed in 0.04 second(s)

#NOTE
# The code of the function has been generated (mostly) by Gemini AI
# using the fellowing prompts : https://g.co/gemini/share/2ecc1b47c465*

/*-------
 */
pron()

o1 = new stzListOfPairs([
	[ "name", "foued" ],
	[ "lastname", "kamel" ],
	[ "job", "manufacturer" ],
	[ "age", 120 ]
])

o1.ToStzHashList().Show()
#-->
#	 NAME   LASTNAME            JOB   AGE
#	-----   --------   ------------   ---
#	foued      kamel   manufacturer   120

proff()
# Executed in 0.14 second(s)

/*-------

pron()

o1 = new stzListOfPairs([ [1.0, 2.0], [16.0, 17.34], [23.0, 25], [8.20, 10.0] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ 1, 2 ], [ 8.20, 10 ], [ 16, 17.34 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17.34 ], [ 8.20, 10 ], [ 1, 2 ] ]

proff()

/*-----

pron()

o1 = new stzListOfPairs([ [1,2], [8, 10], [16, 17], [23, 25] ])

? @@( o1.SortedInAscending() )
#--> [ [ 1, 2 ], [ 8, 10 ], [ 16, 17 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17 ], [ 8, 10 ], [ 1, 2 ] ]

proff()
# Executed in 0.20 second(s)

/*------------ TODO: check it!

pron()

o1 = new stzListOfPairs([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()
# Executed in 0.03 second(s)

/*-----------

pron()

o1 = new stzList([
	'[ 6, 1 ]', '[ 6, 3 ]', '[ 6, 9 ]', '[ 5, 3 ]'
])

? o1.Sorted()

proff()

/*-----------

pron()

o1 = new stzListOfPairs([
	[ 6, 1 ], [ 6, 3 ], [ 6, 9 ], [ 5, 3 ]
])

? @@( o1.Sorted() )
#--> [ [ 5, 3 ], [ 6, 1 ], [ 6, 3 ], [ 6, 9 ] ]

proff()
# Executed in 0.04 second(s)

/*-----------

pron()

o1 = new stzListOfPairs([
	[ 6, 1 ], [ 3, 7 ], [ 2, 5 ], [ 4, 1 ]
])

? @@( o1.Sorted() )
#--> [ [ 2, 5 ], [ 3, 7 ], [ 4, 1 ], [ 6, 1 ] ]

proff()
# Executed in 0.05 second(s)

/*----------- #TODO: check it!

pron()

o1 = new stzListOfPairs([
	[ 2, 1 ], [ 2, 3 ], [ 2, 5 ], [ 4, 1 ], [ 2, 4 ]
])

? @@( o1.SortedInDescending() )
#--> [ [ 4, 1 ], [ 2, 5 ], [ 2, 4 ], [ 2, 3 ], [ 2, 1 ] ]

proff()
# Executed in 0.05 second(s)

/*===========

pron()

? Q("--♥-♥--").ContainsXT( 2, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :Exactly = 2, "♥") # Or ContainsExactly(2, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :MoreThen = 1, "♥") # Or ContainsMoreThen(1, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :LessThen = 3, "♥") # ContainsLessThen(3, "♥")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.Sort() # Or SortInAscending()
? @@(o1.Content())
#--> [ [ 3, 1 ], [ 4, 7 ], [ 8, 9 ] ]

proff()
#--> Executed in 0.05 second(s)

proff()

/*------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@(o1.Content())
#--> [ [ 8, 9 ], [ 4, 7 ], [ 3, 1 ] ]

proff()
#--> Executed in 0.05 second(s)

/*======

pron()

o1 = new stzList([ "ring", "php", "ring", "ring", "_" ])
? o1.Find("ring")
#--> [1, 3, 4]

proff()
# Executed in 0.06 second(s)

/*------------

pron()

o1 = new stzListOfPairs([
	[ "♥", "_"],
	[ "_", " "],
	[ "♥", "_"],
	[ "♥", " "],
	[ "_", "_"]
])

? o1.FindInFirstItems("♥")
#--> [1, 3, 4]

? o1.FindInSecondItems("_")
#--> [1, 3, 5]

proff()
# Executed in 0.10 second(s)

/*===================

pron()

? StzCCodeQ('[ @CurrentItem, @NextItem]').Transpiled()
#--> [  @CurrentItem, This[@i + 1] ]

proff()
# Executed in 0.96 second(s)

/*----------------- ERR

pron()

#                  1  2 3  4 5 6  7
o1 = new stzList([ 1, 3,4, 7,8,9, 12 ])
? StzCCodeQ('This[@i+2]').ExecutableSection()
#--> [1, -3]

? @@( o1.Section(1, -3) )
#--> [ 1, 3, 4, 7, 8 ]

? @@(o1.YieldXT('[ @CurrentItem, @NextItem ]'))
#--> [ [ 1, 4 ], [ 3, 7 ], [ 4, 8 ], [ 7, 9 ], [ 8, 12 ] ]

//? @@( o1.FindW('@CurrentItem = @NextItem') )

? @@( o1.YieldW('[ This[@i], This[@i+1] ]', :Where = 'This[@i] = This[@i+1]+1') )

proff()
/*-----------------

StartProfiler()

o1 = new stzListOfPairs([
	[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15]
])

? @@( o1.Yield('[ This[@i][2], This[@i+1][1] ]') )
#--> [ [ 4, 6 ], [ 8, 9 ], [ 10, 12 ], [ 13, 13 ] ]

? @@( o1.YieldW('[ This[@i][2], This[@i+1][1] ]', :Where = 'Q(@i).IsEven()') )
#--> [ [ 8, 9 ], [ 13, 13 ] ]

? @@( o1.YieldW('[ This[@i][2], This[@i+1][1] ]',
		:Where = 'This[@i][2] = This[@i+1][1]-1') )

StopProfiler()

/*----

pron()

o1 = new stzListOfPairs([
	[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15]
])

o1.MergeContiguous() # Or MergeAdjuscent()
? @@( o1.Content() )
#--> [ [1, 4], [6, 10], [12, 15] ]

proff()
# Executed in 0.03 second(s)

/*-----------------

pron()

o1 = new stzListOfPairs([ [ 9, 10 ], [ 1, 2 ], [ 6, 6 ] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

proff()

/*-----------------

StartProfiler()

? Q([ [ 18, 22 ], [ 8, 12], [ 3, 5] ]).IsListOfPairs()
#-->  tRUE

StopProfiler()
# Executed in 0.01 second(s)

/*-----------------

StartProfiler()

o1 = new stzListOfPairs([ [ 18, 22 ], [ 8, 12], [ 3, 5] ])
? @@( o1.Sorted() )
#--> [ [ 3, 5 ], [ 8, 12 ], [ 18, 22 ] ]

StopProfiler()

/*-----------------

pron()

o1 = new stzListOfPairs([
	1:2, 1:2, [9,9], 1:2, 1:2, [9,9], 1:2, 1:2, [9,9]
])


? o1.FindAll([9,9])
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = [9,9]) 
#--> [3, 6]

? o1.NFirstOccurrencesS(2, :Of = [9,9], :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = [9,9])
#--> [6, 9]

? o1.NLastOccurrencesS(2, [9,9], :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesS(2, :Of = [9,9], :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesS(2, :Of = [9,9], :StartingAt = 4)
#--> [6, 9]

proff()
# Executed in 0.08 second(s)

/*------

pron()

o1 = new stzListOfPairs([ ["A", "B"], ["C", "♥"], ["E", "F"] ])
? o1.ContainsInAllPairs("♥") # Or ContainsInside()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*------

pron()

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])

? @@( o1.Swapped() )
#--> [ [ 22, 18 ], [ 12, 8 ], [ 5, 3 ] ]

proff()
# Executed in 0.03 second(s)

/*------ #todo check perf

pron()

o1 = new stzListOfPairs([
	[ 3, 5], [ 8, 12], [ 18, 22 ]
])

? o1.IsListOfSections()
#--> TRUE

? o1.IsSortedListOfSections()
#--> TRUE

? o1.IsListOfSectionsSortedInAscending()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*------  #todo check perf

pron()

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])

? o1.IsListOfSections()
 #--> TRUE

? o1.IsSortedListOfSections() 
#--> TRUE

? o1.IsListOfSectionsSortedInDescending()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*------------

pron()

o1 = new stzListOfPairs([
	[ 3, 5], [8, 12], [20, 23]
])

? @@( o1.ExpandedIfPairsOfNumbers() ) + NL
#--> [ [ 3, 4, 5 ], [ 8, 9, 10, 11, 12 ], [ 20, 21, 22, 23 ] ]

anPos = o1.ExpandedIfPairsOfNumbersQ().MergeQ().RemoveDuplicatesQ().SortedInAscending()
? @@( anPos )
#--> [ 3, 4, 5, 8, 9, 10, 11, 12, 20, 21, 22, 23 ]

proff()
# Executed in 0.04 second(s)
