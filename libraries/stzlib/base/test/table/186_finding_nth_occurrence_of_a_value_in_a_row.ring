# Narrative
# --------
# // Finding nth occurrence of a value in a row
#
# Extracted from stztabletest.ring, block #186.

load "../../stzBase.ring"


pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInRow(:Nth = 1, :InRow = 2, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:

? @@( o1.FindNthInRow(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInRow(:N = 2, :Row = 3, :Value = "Ali") )
#--> [2, 3]

? @@( o1.FindFirstInRow(3, :Value = "Ali") )
#--> [1, 3]

? @@( o1.FindLastInRow(3, :Value = "Ali") )
#--> [2, 3]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

#-----------

pr()

// Finding nth occurrence of a subvalue in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@( o1.FindNthInRow(:Nth = 2, :InRow = 2, :OfSubValue = "a") )
#--> [ [ 2, 2 ], 6 ]

pf()
# Executed in 0.05 second(s)

#-----------

pr()

// Counting the number of occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInRow(3, :Value = "Ali")
#--> 2

? o1.CountInRow(2, :SubValue = "A")
#--> 2

pf()
# Executed in 0.04 second(s)

#-----------

pr()

// Checking if a given value, or subvalue, exists in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])


? o1.ContainsInRow(2, "Abraham")
#--> TRUE

? o1.RowContains(2, "Abraham")
#--> TRUE

? o1.ContainsInRow(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInRowCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.04 second(s)

#================= COL: FindInCol(), CountInCol(), ContainsInCol()

pr()

// Finding all occurrences of a value, or subvalue, in a column

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol(:FIRSTNAME, "Ali") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol(2, :Value = "Ali") ) + NL
#--> [ [ 2, 3 ] ]

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a" ) ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@NL( o1.FindInColCS(:LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] 	]
#   ]

pf()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17
