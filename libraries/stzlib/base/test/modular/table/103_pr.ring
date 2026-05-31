# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #103.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, 3)
#--> "Sonia"

o1.EraseCell(2, 3)

? @@( o1.Cell(2, 3) )
#-->NULL

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17
