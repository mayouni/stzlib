# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #59.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceRow(3, :With = [ 50, "NONE", 99 ])
? o1.Row(3)
#--> [ 50, "NONE", 99 ]

o1.ReplaceCol(:AGE, :With = [ "_", "_", "_" ])
? o1.Col(:AGE)
#--> [ "_", "_", "_" ]

pf()
# Executed in 0.04 second(s) in Ring 1.19
# Executed in 0.15 second(s) in Ring 1.17
