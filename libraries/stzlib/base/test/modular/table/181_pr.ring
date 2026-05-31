# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #181.

load "../../../stzBase.ring"

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali" ) )
#--> []	// In fact, there is no a 3rd occurrence of 'ali" (in lowercase) in the table!

? @@( o1.FindNthInCellsCS( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali", :CS = FALSE ) )
#--> [2, 4]

pf()
# Executed in 0.10 second(s)
