# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #107.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Row(:First)
#--> [ "001", "Salem", 12499.20 ]

? o1.Row(:Last) # Works when CheckParams() = TRUE, otherwise use LAstRow()
#--> [ "003", "Sonia", 12740.30 ]

pf()
# Executed in 0.02 second(s)
