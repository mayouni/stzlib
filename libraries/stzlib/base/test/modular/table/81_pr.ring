# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #81.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfRows()
#--> 3

? o1.NumberOfCols()
#--> 3

? o1.NumberOfCells()
#--> 12

pf()
# Executed in 0.02 second(s)
