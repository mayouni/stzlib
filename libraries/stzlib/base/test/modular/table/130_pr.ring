# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #130.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.RowAsPositions(2) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.RowsAsPositions([ 1 , 3 ]) ) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], "Ali") + NL
#--> 1

? @@( o1.FindInRows([ 2, 3 ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], :OfSubValue = "Ali") + NL
#--> 4

? @@( o1.FindInRows([ 2, 3 ], :SubValue = "Ali") ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.26 second(s) in Ring 1.17
