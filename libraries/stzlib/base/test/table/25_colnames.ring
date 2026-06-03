# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #25.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])
		
? o1.ColNames()
#--> [ "col1", "col2", "col3" ]

? o1.Row(2)
#--> [ 20, "Hatem", 46 ]

pf()
# Executed in 0.02 second(s)
