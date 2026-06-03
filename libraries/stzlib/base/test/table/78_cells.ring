# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #78.
#ERR Error (R14) : Calling Method without definition: cells

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cells() ) + NL
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

? @@NL( o1.CellsAndPositions() ) + NL # Same as CellsZ()
#--> [
#	[ 10, 		[ 1, 1 ] ],
#	[ "Imed", 	[ 2, 1 ] ],
#	[ 52, 		[ 3, 1 ] ],
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ],
#	[ 30, 		[ 1, 3 ] ],
#	[ "Karim", 	[ 2, 3 ] ],
#	[ 48, 		[ 3, 3 ] ]
# ]

? @@NL( o1.PositionsAndCells() ) + NL
#--> [
#	[ [ 1, 1 ],	10	 ],
#	[ [ 2, 1 ],	"Imed"	 ],
#	[ [ 3, 1 ],	52	 ],
#	[ [ 1, 2 ],	20	 ],
#	[ [ 2, 2 ],	"Hatem"	 ],
#	[ [ 3, 2 ],	46	 ],
#	[ [ 1, 3 ],	30	 ],
#	[ [ 2, 3 ],	"Karim"	 ],
#	[ [ 3, 3 ],	48	 ]
# ]

? @@( o1.CellsToHashList() ) + NL # (used internally by Softanza)
#--> [
#	"[ 1, 1 ]" = 10,
#	"[ 2, 1 ]" = "Imed",
#	"[ 3, 1 ]" = 52,
#	"[ 1, 2 ]" = 20,
#	"[ 2, 2 ]" = "Hatem",
#	"[ 3, 2 ]" = 46,
#	"[ 1, 3 ]" = 30,
#	"[ 2, 3 ]" = "Karim",
#	"[ 3, 3 ]" = 48
# ]

? @@( o1.SectionToHashList([2, 2], [3, 3]) ) # (idem)
#--> [
#	[ "[ 2, 2 ]", "Hatem" ],
#	[ "[ 3, 2 ]", 46 ],
#	[ "[ 2, 3 ]", "Karim" ],
#	[ "[ 3, 3 ]", 48 ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.36 second(s) in Ring 1.17
