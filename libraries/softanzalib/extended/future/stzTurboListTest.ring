load "stzlib.ring"

/*-------

pron()

? @@( Q([ [ 1 ], [ 2 ], [ 3, 5, 8 ], [ 4 ], [ 6 ], [ 7 ], [ 9 ]  ]).flattened() )

proff()
#--> Executed in 0.03 second(s)

/*-------

pron()

? Q(1:9).IsContiguous()

proff()
# Executed in 0.07 second(s)

/*-------

pron()

o1 = new stzTurbolist([
	[  "1",   "2",      "*",      "4",   "6",   "7",   "9"   ],
	[ [ 1 ], [ 2 ], [ 3, 5, 8 ], [ 4 ], [ 6 ], [ 7 ], [ 9 ]  ]
])
# Executed in 0.09 second(s)

? @@( o1.@Items() )
? @@( o1.@Positions() ) + NL
#-->
# [   1,     2,       "*",       4,     6,     7,     9   ]
# [ [ 1 ], [ 2 ], [ 3, 5, 8 ], [ 4 ], [ 6 ], [ 7 ], [ 9 ] ]


? @@( o1.Content()) + NL
#--> [ "1", "2", "*", "4", "*", "6", "7", "*", "9" ]


? o1.NumberOfItems() + NL
#--> 9

? o1.FindNext("*", :StartingAt = 1) + NL
#--> 3

? o1.FindNext("*", :StartingAt = 5) + NL
#--> 8

? o1.FindNext("*", :StartingAt = 3) + NL
#--> 6

? o1.FindNextNth(2, "*", :StartingAt = 3) + NL
#--> 8

? o1.FindAll("*")
#--> [3, 5, 8]

? o1.FindNth(2, "*") + NL
#--> 5

? o1.FindFirst("*") + NL
#--> 3

? o1.FindLast("*")
#--> 9

proff()
# Executed in 0.15 seconds

/*------------
*/
StartProfiler()

# Fabricating a large list of strings (more then 150K items)

	aItems = [ "_", "♥", "_", "♥", "_"]

	anPos = []
	anPos + 1:10_000 + [10_001] + 10_002:50_000 + [50_001] + 50_002:60_000



# Find "♥" in several ways
	o1 = new stzTurboList([ aItems, anPos ])

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
	
//	? o1.FindPrevious("♥", :StartingAt = 120_000)
	#--> 100006
	# Executed in 3.27 second(s)

//	? o1.FindNthPrevious(2, "♥", :StartingAt = 33)
	#--> 3
	# Executed in 2.90 second(s)

StopProfiler()
# Executed in 31.56 second(s)
