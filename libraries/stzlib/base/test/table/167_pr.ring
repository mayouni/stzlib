# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #167.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ NULL, NULL, NULL ])

? o1.LastColName()
#--> "tempo"

? @@(o1.LastCol())
#--> [ "", "", "" ]

pf()
# Executed in 0.02 second(s)
