# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #127.
#ERR Error (R14) : Calling Method without definition: findincols

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

# Same as:
? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" ) ) + NL # Added the :Value named param
#--> [ [ 1, 2 ] ]

? @@NL( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17
