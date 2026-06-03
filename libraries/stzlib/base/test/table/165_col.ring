# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #165.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ "any", "any" ])

? @@( o1.Col(:TEMPO) )
#--> [ "any", "any", "" ]

pf()
# Executed in 0.02 second(s)
