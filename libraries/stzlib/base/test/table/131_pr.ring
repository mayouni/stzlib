# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #131.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.RowContains(3, "Ali")
#--> FALSE

? o1.RowContains(3, :SubValue = "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], "Ali")
#--> FALSE

? o1.RowsContain([ 1, 2 ], "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], :SubValue = "Ali") + NL
#--> TRUE

? @@NL( o1.FindInRows([ 1, 3 ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.12 second(s)
