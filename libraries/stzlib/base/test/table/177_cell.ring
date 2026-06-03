# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #177.

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

? o1.Cell(:EMPLOYEE, 3)
#--> "Han"

? @@( o1.CellZ(:EMPLOYEE, 3) ) + NL
#--> [ "Han", [2, 3] ]

? o1.Count( :Cells = "Ali" )
#--> 2
	# Same as NumberOfOccurrence( :OfCell = "Ali" )
	# Or you can say: ? o1.CountOfCell( "Ali" )
	# Or: HowMany( :Cells = "Ali" )

? @@( o1.FindCell("Ali") ) + NL
#--> [ [ 2, 1 ], [2, 4] ]
#--> One occurrence of "Ali" in the cell [2, 1], and
#    one in the cell [ 2, 4 ]

? @@NL( o1.FindSubValue("a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ]
#    ]
#--> There are 3 occurrences of of "a" in the table:
#	--> 2 occurrences in cell [2, 2] ("Dania"), in the 2nd and 5th chars.
#	--> 1 occurrence in cell [2, 3] ("Han"), in position 2.

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) ) + NL
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

? o1.CountCS( :SubValue = "a", :CS= FALSE )
#--> 5
	#--> five occurrences of "A" (or "a"):
	# 	- one occurrence in the cell [2, 1] ("Ali") at the 1st char
	# 	- two occurrences in the cell [2, 2] ("Dania") at the 2nd and 5th chars
	# 	- one occurrence in the cell [2, 3] ("Han") at the 2nd char
	# 	- one occurrence in the cell [2, 4] ("Ali") at the 1st char

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 1.54 second(s) in Ring 1.17
