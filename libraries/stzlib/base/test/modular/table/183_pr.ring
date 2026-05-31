# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #183.

load "../../../stzBase.ring"


// Checking if a given value, or subvalue, exists in a given list of cells

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" ) 
#--> TRUE

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :SubValue = "a" ) // Same as ? o1.CellsContainSubValue("a")
#--> TRUE

? o1.CountInCells( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" )
#--> 2

? o1.CountInCellsCS( [ [2,1], [2,3], [2,4] ], :SubValue = "a", :CS = FALSE )
#--> 3

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17
