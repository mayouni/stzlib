# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #74.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],

	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? @@( o1.ColAsPositions(:NAME) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ] ]

? @@( o1.ColsAsPositions([ :NAME, :AGE ]) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.RowAsPositions(3) ) + NL
#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

? @@( o1.RowsAsPositions([2, 3]) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17
