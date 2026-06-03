# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #119.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@( o1.ColCellsAsPositions(:FIRSTNAME) )
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.ColCellsAsPositions(:ANY) )
#--> Error message:
#    Incorrect param value! "any" is not a valid column identifier.

pf()
# Executed in 0.02 second(s)
