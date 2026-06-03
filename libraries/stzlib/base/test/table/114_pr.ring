# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #114.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.CellsInCol(:EMPLOYEE) ) + NL // same as Col(:EMPLOYEE)
#--> [ "Salem", "Henri", "Sonia" ]

? @@( o1.CellsInColAsPositions(:EMPLOYEE) ) + NL // same as ColAsPositions(:EMPLOYEE)
#--> [ [2, 1], [2, 2], [2, 3] ]

? @@NL( o1.CellsInColZ(:EMPLOYEE) )
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17
