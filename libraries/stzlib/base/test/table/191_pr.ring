# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #191.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.Cell(:FIRSTNAME, 3)
#--> "Ali"

o1.ReplaceCell(:FIRSTNAME, 3, :With = "Saber")

? o1.Cell(:FIRSTNAME, 3)
#--> "Saber"

pf()
# Executed in 0.04 second(s)
