# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #138.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@NL( o1.FindInSection( :From = [1, 2], :To = [2, 3], :CellPart = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.03 second(s)
