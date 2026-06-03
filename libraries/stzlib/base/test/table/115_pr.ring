# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #115.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.RowZ(2) ) // Same as o1.CellsAndPositionsInRow(2)
#--> [
#	[ 20, 	   [ 1, 2 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ 46, 	   [ 3, 2 ] ]
#    ]

pf()
# Executed in 0.02 second(s)
