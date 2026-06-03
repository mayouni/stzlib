# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #80.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cell(2, 2) )
#--> "Hatem"

? o1.Cell(:EMPLOYEE, 2)
#--> Error message:
#   Syntax error in (employee)! This column name is inexistant.

? o1.Cell(5, 7 )
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column. 

pf()
# Executed in 0.02 second(s)
