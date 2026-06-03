# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #128.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]
# Executed in 0.11 second(s)

? @@( o1.FindInCols( [ 1, 2 ], "Ali" ) )
#--> [ [ 1, 2 ] ]

pf()
# Executed in 0.04 second(s)
