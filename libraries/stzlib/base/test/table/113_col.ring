# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #113.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.Col(:EMPLOYEE) )
#--> [ "Salem", "Henri", "Sonia" ]

? @@NL( o1.ColZ(:EMPLOYEE) ) // Same as o1.CellsAndPositionsInCol(:EMPLOYEE)
			     // and o1.CellsInColZ(:EMPLOYEE)
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17
