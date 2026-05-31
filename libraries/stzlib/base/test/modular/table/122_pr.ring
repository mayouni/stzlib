# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #122.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@NL( o1.FindInRow(3, :CellPart = "Ali") )
#--> [
# 	[ [ 1, 3 ], [ 1 ] ],
# 	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.03 second(s)
