# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #96.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.AllCols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.TheseCols([ 1, 3 ]) ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.ColsXT() ) + NL
#--> [
#	[ "id",   [ 10, 20, 30 ] ],
#	[ "name", [ "Imed", "Hatem", "Karim" ] ],
#	[ "age",  [ 52, 46, 48 ] ]
# ]


? @@NL( o1.TheseColsXT([ 1, 3 ]) ) + NL
#--> [
#	[ "id", [ 10, 20, 30 ] ],
#	[ "age", [ 52, 46, 48 ] ]
# ]

? @@( o1.CellsInCols([ :name, :age ]) )
#--> [ "Imed", "Hatem", "Karim", 52, 46, 48 ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.31 second(s) in Ring 1.17
