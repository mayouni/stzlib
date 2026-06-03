# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #176.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? o1.Count( :SubValue = "a" )
#--> 3

? o1.CountCS( :SubValue = "A", :CaseSensitive = FALSE )
#--> 4

pf()
# Executed in 0.04 second(s)
