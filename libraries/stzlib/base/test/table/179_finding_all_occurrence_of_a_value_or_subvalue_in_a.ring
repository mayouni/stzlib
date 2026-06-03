# Narrative
# --------
# // Finding all occurrence of a value, or subvalue, in a given list of cells
#
# Extracted from stztabletest.ring, block #179.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) ) + NL
#--> [ [2, 2] ]

? @@NL( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> There are 3 occurrences of "a" in the specified cells:
#	- 2 occurrences in the cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2.

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17
