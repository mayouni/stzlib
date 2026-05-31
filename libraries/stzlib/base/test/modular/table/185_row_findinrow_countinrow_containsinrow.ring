# Narrative
# --------
# ROW: FindInRow(), CountInRow(), ContainsInRow()
#
# Extracted from stztabletest.ring, block #185.

load "../../../stzBase.ring"


pr()

// Finding all occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :Value = "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? @@( o1.FindInRow(3, :Value = "Ali" ) ) + NL
#--> [ [1, 3], [2, 3] ]

? @@( o1.FindInRow( 2, :SubValue = "a" ) ) + NL
#--> [ 
#	[ [2, 2], [4, 6] ]
#    ]

? @@( o1.FindInRowCS( 2, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [1, 2], [1]    ],
#	[ [2, 2], [1, 4, 6] ],
#   ]

pf()
# Executed in 0.16 second(s)
