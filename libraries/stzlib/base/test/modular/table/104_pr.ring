# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #104.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, :LastRow)
#--> "Sonia"

? o1.Cell(:FirsCol, :LastRow)
#--> Error message:
#  Syntax error in (firscol)! Allowed values are
#  :First or :Last (or :FirstCol or :LastCol).

pf()
# Executed in 0.02 second(s)
