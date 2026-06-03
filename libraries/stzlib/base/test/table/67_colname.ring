# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #67.
#ERR Error (R14) : Calling Method without definition: replacecolname

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceColName( :NAME, :FRIEND )
? o1.ColName(2)
#--> :FRIEND

pf()
# Executed in 0.02 second(s)
