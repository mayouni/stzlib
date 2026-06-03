# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #173.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? o1.Contains( :Cell = "Ali" ) # same as ? o1.ContainsCell("Ali")
#--> TRUE

? o1.Contains( :SubValue = "a" ) # same as ? o1.ContainsSubValue("a")
#--> TRUE

? @@( o1.FindCellCS("Ali", FALSE) ) + NL
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 4 ], [ 1 ] ],
#	[ [ 3, 4 ], [ 1 ] ]
# ]
#--> 5 occurrences of "a" (or "A"):
#	- 1 occurrence in cell [2, 1] ("Ali"), in position 1,
#	- 2 occurrences in cell [2, 2] ("Dania"), in positions 2 and 5
#	- 1 occurrence in cell [2, 4] ("ali"), in position 1, and finally
#	- 1 occurrence in cell [3, 4], ("Ali"), also in position 1

pf()
# Executed in 0.06 second(s)
