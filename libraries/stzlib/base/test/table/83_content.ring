# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #83.
#ERR Error (R14) : Calling Method without definition: addcol

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	[ 10,	"Imed" 	],
	[ 20,	"Hatem" ],
	[ 30,	"Karim" ]
])

o1.AddCol(:AGE = [ 55, 35, 28 ])
? @@NL( o1.Content() )
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	],
#	[ "age", 	[ 55, 35, 28 ] 			]
# ]

pf()
# Executed in 0.02 second(s)
