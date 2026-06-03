# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #79.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfColumns()
#--> 3

? o1.HasCol(:NAME) + NL
#--> TRUE

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.ColName(2)
#--> "name"

pf()
# Executed in 0.02 second(s)
