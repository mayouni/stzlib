# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #87.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Row(2) ) + NL
#--> [ 20, "Hatem", 46 ]

? @@NL( o1.Rows() )
#-->
# [
#	[ 10, "Imed",	52 ],
#	[ 20, "Hatem", 	46 ],
#	[ 30, "Karim",	48 ]
# ]

pf()
# Executed in 0.02 second(s)
