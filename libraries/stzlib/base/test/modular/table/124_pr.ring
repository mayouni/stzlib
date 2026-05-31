# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #124.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])


? o1.CellContainsSubValue(:NAME, 2, "io")
#--> TRUE

? o1.CellXT(:NAME, 2, :ContainsSubValue, "io")
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17
