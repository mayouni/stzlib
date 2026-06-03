# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #126.
#ERR Error (R14) : Calling Method without definition: numberofoccurrenceincols

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], "Ali") + NL
#--> 1

? @@( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], :OfSubValue = "Ali") + NL
#--> 4

? @@NL( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17
