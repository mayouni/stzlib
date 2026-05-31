# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #90.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.RemoveCols([ :ID, :AGE ])

? @@( o1.Content() )
#--> [ [ "name", [ "Imed", "Hatem", "Karim" ] ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17
