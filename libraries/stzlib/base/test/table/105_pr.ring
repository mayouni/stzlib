# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #105.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.FirstColName()
#--> "id"

? o1.LastColName()
#--> "salary"

pf()
# Executed in 0.02 second(s)
