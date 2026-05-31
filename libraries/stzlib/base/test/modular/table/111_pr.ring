# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #111.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.RowSection(2, :FromCell = 2, :To = :LastCol) ) + NL
#--> [ "Henri", 10890.10 ]

? @@( o1.FindCellsInRowSection(2, 2, :LastCol) ) + NL # Or RowSectionAsPositions()
#--> [ [ 2, 2 ], [ 3, 2 ] ]

? @@NL( o1.CellsInRowSectionZ(2, 2, 3) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ 10890.10, [ 3, 2 ] ]
# ]

pf()
# Executed in 0.03 second(s)
