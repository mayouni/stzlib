# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #117.
#ERR Error (R14) : Calling Method without definition: findincol

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol( :FIRSTNAME, :SubValue = "a" ) ) + NL
#--> [ ]

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ]      ],
#	[ [ 2, 2 ], [ 1, 4, 6] ],
#	[ [ 2, 3 ], [ 1 ]      ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 4.48 second(s) in Ring 1.17
