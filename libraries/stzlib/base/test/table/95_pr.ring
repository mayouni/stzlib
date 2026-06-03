# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #95.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.IsColName(:name)
#--> TRUE

? o1.IsColNumber(3)
#--> TRUE

? o1.IsColNameOrNumber(:age)
#--> TRUE

? o1.AreColNamesOrNumbers([ :name, :age ])
#--> TRUE

? o1.AreColID([ :name, :age ])
#--> TRUE

pf()
# Executed in 0.03 second(s)
