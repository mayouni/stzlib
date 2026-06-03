# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #91.
#ERR Error (R14) : Calling Method without definition: cols

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.ColNames() ) + NL
#--> [ "id", "name", "age" ]

? @@NL( o1.Cols() ) # Or ColsData()
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]
 
pf()
# Executed in 0.02 second(s)
