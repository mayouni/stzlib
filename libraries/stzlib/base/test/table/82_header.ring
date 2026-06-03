# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #82.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Header() ) + NL
#--> [ "id", "name", "age" ]

pf()
# Executed in 0.02 second(s)
