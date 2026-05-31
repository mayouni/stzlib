# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #148.

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

? @@NL( o1.FindAllOccurrences( :OfSubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthOccurrence( 2, :OfSubValue = "Ali" ) ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindNth(2, :SubValue = "Ali") ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindFirst(:SubValue = "Ali") ) + NL
#--> [ [ 1, 2 ], 1 ]

? @@( o1.FindLast(:SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

pf()
# Executed in 0.15 second(s) in Ring 1.20
# Executed in 0.69 second(s) in Ring 1.17
