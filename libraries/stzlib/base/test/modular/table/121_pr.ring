# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #121.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 4 ] ]

? @@NL( o1.FindInCol( :FIRSTNAME, :SubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ],
#	[ [ 1, 4 ], [ 1 ] ]
# ]

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "A", :CS = FALSE ) )
#-->[
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 5 ] ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17
