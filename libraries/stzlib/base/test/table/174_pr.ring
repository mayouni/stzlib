# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #174.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? @@( o1.FindNth(1, :Cell = "Ali") ) # Same as ? @@( o1.FindFirst( :Cell = "Ali" ) )
#--> [2, 1]

? @@( o1.FindNthCS(3, :SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 2 ]
#--> 3rd occurrence of "A" (or "a") found in the cell [2, 3] ("Hania") in position 2

? @@( o1.FindFirstCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 1 ], 1 ]

? @@( o1.FindLastCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 5 ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.65 second(s) in Ring 1.17
