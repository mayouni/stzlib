# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #85.

load "../../stzBase.ring"


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
