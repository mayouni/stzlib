# Narrative
# --------
# StartProfiler()
#
# Extracted from stztabletest.ring, block #47.

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

	? o1.Show()
	#--> ID   EMPLOYEE   SALARY
	#    --- ---------- -------
	#    10        Ali    35000
	#    20      Dania    28900
	#    30        Han    25982
	#    40        Ali    12870

	? o1.NthColName(:LastCol) + NL
	#--> :SALARY

	? @@( o1.CellsInColsAsPositions([ :EMPLOYEE, :SALARY ]) ) + NL
	#--> [
	# 	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
	# 	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ]
	# ]

	? o1.CellsToHashList()["[ 3, 4 ]"] + NL
	#--> 12870

	? @@( o1.SectionAsPositions([2,2], [3, 4]) )
	#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ], [ 2, 4 ], [ 3, 4 ] ]

StopProfiler()

pf()
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 1.56 second(s) in Ring 1.17
