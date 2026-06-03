# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #123.
#ERR Error (R14) : Calling Method without definition: cellq

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])

? o1.CellQ(:NAME, 2).Conttains("io") // #NOTE: A misspelled form of Contains()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17
