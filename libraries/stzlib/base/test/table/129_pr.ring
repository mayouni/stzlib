# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #129.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.ColContains(2, "Ali")
#--> FALSE

? o1.ColContains(2, :SubValue = "Ali")
#--> TRUE

? o1.ColsContain([ :FIRSTNAME, :JOB ], "Ali")
#--> TRUE

? o1.ColsContain([ :LASTNAME, :JOB ], "Ali")
#--> FALSE

? o1.ColsContain([ :LASTNAME, :JOB ], :SubValue = "Ali")
#--> TRUE

? @@( o1.FindInCols([ :LASTNAME, :JOB ], :SubValue = "Ali") )
# [ [ [ 2, 3 ], [ 1, 4 ] ] ]

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.40 second(s) in Ring 1.17
