# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #76.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
#--> TRUE

? o1.ContainsCols([
	:NAME = [ "Imed", "Hatem", "Karim" ],
	:AGE  = [ 52, 46, 48 ]
])
#--> TRUE

? o1.ContainsRow([ 20, "Hatem", 46 ])
#--> TRUE

? o1.ContainsRows([
	[ 20, "Hatem", 46 ],
	[ 30, "Karim", 48 ]
])
#--> TRUE

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.33 second(s) in Ring 1.17
