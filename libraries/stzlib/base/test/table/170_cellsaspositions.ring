# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #170.
#ERR Error (R14) : Calling Method without definition: cellsaspositions

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

? @@( o1.CellsAsPositions() )
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

pf()
# Executed in 0.02 second(s)
