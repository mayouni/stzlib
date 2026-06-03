# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #178.
#ERR Error (R14) : Calling Method without definition: thesecells

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.TheseCells([ [1,2], [2,2], [2,3] ]) )
#--> [ 20, "Dania", "Ben" ]

? @@( o1.TheseCellsZ([ [1,2], [2,2], [2,3] ]) )
#--> [ [ 20, [ 1, 2 ] ], [ "Dania", [ 2, 2 ] ], [ "Han", [ 2, 3 ] ] ]

pf()
# Executed in 0.02 second(s)
