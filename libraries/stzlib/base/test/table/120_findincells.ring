# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #120.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ]
])

? @@( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :SubValue = "Ali" ) ) + NL
#NOTE: In place of :SubValue = ... you can say :CellPart or :SubPart = ...

#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.45 second(s) in Ring 1.17
