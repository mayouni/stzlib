# Narrative
# --------
# #narration
#
# Extracted from stztabletest.ring, block #182.

load "../../../stzBase.ring"


pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

# Let's take this list of cells

aMyCells = [ [2,1], [2,3], [2,4] ]

# And get them along with their positions:

? @@NL( o1.TheseCellsZ( aMyCells ) ) + NL
#--> [
#	[ "Ali", [ 2, 1 ] ],
#	[ "Han", [ 2, 3 ] ],
#	[ "Ali", [ 2, 4 ] ]
# ]

# How many cell made of the value "Ali" does exist in those cells?

? o1.CountInCells( aMyCells, :Value = "Ali" )
#--> 2

# Where do they exist exactly?

? @@( o1.FindInCells( aMyCells, :Value = "Ali" ) )
#--> [ [ 2, 1 ], [ 2, 4 ] ]

# How many subvalue "A" exists in the same list of cells?

? o1.CountInCells( aMyCells, :SubValue = "A" )
#--> 2

# How many subvalue "A" whatever case it has?

? o1.CountInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE )
#--> 3

# And where do they exist exactly?

? @@NL( o1.FindInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.46 second(s) in Ring 1.17
