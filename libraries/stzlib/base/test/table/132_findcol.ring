# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #132.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.FindCol(:JOB)
#--> 3

? @@( o1.FindCell("Abraham") )
#--> [ [ 2, 2 ] ]

? @@( o1.FindCell("Programmer") )
#--> [ [ 3, 1 ] ]

? @@( o1.FindCell("Ali") )
#--> [ [ 1, 2 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17
