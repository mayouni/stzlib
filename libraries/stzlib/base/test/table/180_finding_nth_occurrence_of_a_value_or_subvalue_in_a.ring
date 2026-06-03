# Narrative
# --------
# // Finding nth occurrence of a value, or subvalue, in a given list of cells
#
# Extracted from stztabletest.ring, block #180.
#ERR Error (R14) : Calling Method without definition: findnthincells

load "../../stzBase.ring"


pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [2, 2]

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "blabla" ) )
#--> [ ]

? @@( o1.FindNthInCells( 2, [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) ) 
#--> [ [ 2, 2 ], 5 ]
// Same as:  @@( o1.FindNthSubValueInCells( 2, [ [1,2], [2,2], [2,3] ], "a" ) )

? @@( o1.FindFirstInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

? @@( o1.FindLastInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.52 second(s) in Ring 1.17
