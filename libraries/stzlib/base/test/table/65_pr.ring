# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #65.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.AddCol( :AGE = [ 1, 2, 3 ] )
#--> Error message:
# 	Can't add the column! The name your provided already exists.

pf()
