# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #166.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ ])

? @@( o1.Col(:TEMPO) )
#--> [ "", "", "" ]

pf()
# Executed in 0.02 second(s)
