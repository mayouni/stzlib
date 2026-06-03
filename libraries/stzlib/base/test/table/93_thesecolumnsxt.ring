# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #93.
#ERR Error (R14) : Calling Method without definition: thesecolumnsxt

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@NL( o1.TheseColumnsXT([ :ID, :NAME ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17
