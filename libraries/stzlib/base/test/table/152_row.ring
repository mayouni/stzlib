# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #152.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	:ID 	  = [ 10,	20,		30	],
	:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
	:SALARY	  = [ 14500,	17630,		20345	]
])

o1.AddRow([ 40, "Peter", 12500 ])
? o1.Row(4)
#--> [ 40, "Peter", 12500 ]

pf()
# Executed in 0.02 second(s)
