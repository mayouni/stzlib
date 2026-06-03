# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #110.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.ColSection(:EMPLOYEE, :FromCellAt = 2, :To = :LastRow) ) + NL
#--> [ "Henri", "Sonia" ]

? @@( o1.FindCellsInColSection(:EMPLOYEE, 2, :LastRow) ) + NL # Or ColSectionAsPositions()
#--> [ [ 2, 2 ], [ 2, 3 ] ]

? @@NL( o1.CellsInColSectionZ(:EMPLOYEE, 2, :LastRow) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17
