# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #190.

load "../../../stzBase.ring"


// Checking if a given value, or subvalue, exists in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.ContainsInCol(2, "Abraham")
#--> TRUE

? o1.ColContains(2, "Abraham")
#--> TRUE

? o1.ContainsInCol(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInColCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.04 second(s)
