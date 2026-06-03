# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #94.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.ColZ(2) )
#--> [
#	[ "Imed", [ 2, 1 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ "Karim", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.02 second(s)
