# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #116.
#ERR Error (R14) : Calling Method without definition: cellsinrow

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.CellsInRow(2) ) + NL // same as Row(2)
#--> [ 20, "Hatem", 46 ]

? @@( o1.CellsInRowAsPositions(2) ) + NL // same as RowAsPositions(2)
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@NL( o1.CellsInRowZ(2) )
#--> [
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ]
#    ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17
