# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #92.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@( o1.Col(3) ) # Same as  o1.ColData(3), o1.Col(:AGE), and o1.ColData(:AGE)
#--> [ 52, 46, 48 ]

? o1.ColName(3)
#--> age

pf()
# Executed in 0.02 second(s)
