# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #189.
#ERR Error (R14) : Calling Method without definition: countincol

load "../../stzBase.ring"

pr()

// Counting the number of occurrences of a value, or subvalue, in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInCol(:FIRSTNAME, :Value = "Ali")
#--> 2

? o1.CountInCol(:LASTNAME, :SubValue = "A")
#--> 2

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17
