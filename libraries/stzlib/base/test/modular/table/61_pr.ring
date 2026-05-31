# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #61.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColNumber(:AGE) 
#--> 3

? o1.ColNumber(2)
#--> 2

? o1.ColNumber(:NONE)
#--> Error message:
# 	Incorrect param value! p must be a number or string.
# 	Allowed strings are :First, :FirstCol, :Last,
# 	:LastCol and any valid column name.

? o1.ColNumber(22)
#--> Error message:
# 	Incorrect value! n must be a number between 1 and 3.

pf()
# Executed in 0.02 second(s)
