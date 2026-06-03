# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #106.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])


? o1.Col(:First)
#--> [ "001", "002", "003" ]

? o1.Col(:Last) # Works when CheckParams() = TRUE, otherwise use LastCol()
#--> [ 12499.20, 10890.10, 12740.30 ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.06 second(s) in Ring 1.17
