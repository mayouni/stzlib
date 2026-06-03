# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #86.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.FirstColXT() ) + NL
#--> [ "id", 10, 20, 30 ]

? @@( o1.LastColXT() )
#-->[ "age", 52, 46, 48 ]

pf()
# Executed in 0.02 second(s)
