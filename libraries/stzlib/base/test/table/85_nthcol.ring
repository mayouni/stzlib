# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #85.
#ERR Error (R14) : Calling Method without definition: nthcol

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.NthCol(3) )
#--> [ 52, 46, 48 ]

pf()
# Executed in 0.02 second(s)
