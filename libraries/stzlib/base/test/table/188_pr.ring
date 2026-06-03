# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #188.

load "../../stzBase.ring"


// Finding nth occurrence of a subvalue in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 4, 6 ] 	]
#    ]

? @@( o1.FindNthInCol(:Nth = 2, :InCol = 2, :OfSubValue = "a") ) + NL
#--> [ [ 2, 2 ], 4 ]

? @@( o1.FindFirstInCol(:LASTNAME, :SubValue = "a") )
#--> [ [ 2, 1 ], 2 ]

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17
