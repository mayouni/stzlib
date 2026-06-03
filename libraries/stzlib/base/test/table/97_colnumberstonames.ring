# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #97.
#ERR Error (R14) : Calling Method without definition: colnumberstonames

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.ColNumbersToNames([3, 1])
#--> [ "age", "id" ]

? @@( o1.ColNamesToNumbers([ :AGE, :ID ]) )
#--> [ 3, 1 ]


pf()
# Executed in 0.03 second(s)
