# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #168.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCols([
	:ONES = [ 1, 1, 1 ],
	:TWOS = [ 2, 2, 2 ]
])

? @@NL( o1.Cols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Ali", "Dan", "Ben" ],
#	[ 35000, 28900, 25982 ],
#	[ 1, 1, 1 ],
#	[ 2, 2, 2 ]
# ]

? @@( o1.TheseColumns([ :ONES, :TWOS ]) ) + NL
#--> [ [ 1, 1, 1 ], [ 2, 2, 2 ] ]

? @@NL( o1.TheseColumnsXT([ :ONES, :TWOS ]) )
#--> [
#	[ "ones", [ 1, 1, 1 ] ],
#	[ "twos", [ 2, 2, 2 ] ]
# ]

pf()
# Executed in 0.05 second(s) in Ring 1.17
# Executed in 0.30 second(s) in Ring 1.20
