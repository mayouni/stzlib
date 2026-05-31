# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #149.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? o1.NumberOfOccurrenceInCol( :LASTNAME, :OfSubValue = "Ali" )
#--> 2

? @@( o1.FindInCol( :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ [ 2, 3 ], [ 1, 4 ] ] ]

? @@( o1.FindNthInCol( 2, :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

pf()
# Executed in 0.12 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17
