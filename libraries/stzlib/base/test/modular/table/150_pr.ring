# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #150.

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

? o1.NumberOfOccurrenceInRow( 3, :OfSubValue = "Ali" )
#--> 3

? @@NL( o1.FindInRow( 3, :SubValue = "Ali" ) ) + NL
#-->[
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthInRow( 2, 3, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 1 ]

pf()
# Executed in 0.09 second(s)
