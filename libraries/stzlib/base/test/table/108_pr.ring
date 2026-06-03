# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #108.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "*****", 10000.10 ],
	[ "003", "Sonia", 12740.30 ],
	[ "002", "*****", 10000.10 ]
])

? @@( o1.FindCol(:SALARY) )
#--> 3

? @@( o1.FindRow([ "002", "*****", 10000.10 ]) )
#--> [ 2, 4 ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17
