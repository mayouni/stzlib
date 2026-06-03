# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #98.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.TheseColNames([1, 2]) #--> [ "id", "employee" ]
#--> [ "id", "name" ]

pf()
# Executed in 0.02 second(s)
