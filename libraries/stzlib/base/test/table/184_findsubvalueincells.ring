# Narrative
# --------
# #narration
#
# Extracted from stztabletest.ring, block #184.
#ERR Error (R14) : Calling Method without definition: findsubvalueincells

load "../../stzBase.ring"


pr()

# Softanza can find the values of a cell in a stzTable object,
# but also it can find parts of those values.

# In other terms, it can dig inside the cells and tell you if
# the cells contain a sub-value you provide

# It's like your are performing a full-text search of the table!

# Let's see this feature in action...

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Alia Dania",	"12870"	]
])

? @@NL( o1.FindSubValueInCells( [ [2,1], [2,2], [2, 4] ], "ia" ) ) + NL
#--> [
#	[ [ 2, 2 ], [ 4 ] ],	// "ia" exists in cell "Dania" starting at position 4
#	[ [ 2, 4 ], [ 3, 9 ] ]  // "ia" exists in cell "Alia Dania" at positions 3 and 8
# ]

# When the subvalue is a number and the cell is a number-in-string or viceversa,
# Softanza perfprmas the finding operation as if both where numbers-in-strings

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], "0" ) ) + NL
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], 0 ) )
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

pf()
# Executed in 0.03 second(s)
