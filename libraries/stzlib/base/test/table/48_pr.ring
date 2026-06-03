# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #48.

load "../../stzBase.ring"


o1 = new stzTable([
	[ "NAME", "AGE", "RANGE" ],
	[ "Sam",    42,      2   ],
	[ "Dan",    24,    "_"   ],
	[ "Alex",   34,      3   ]
])

? o1.Cell(3, 2) + NL
#--> "_"

o1.ReplaceCell(3, 2, 1)

o1.Show()
#--> NAME   AGE   RANGE
#    ----- ----- ------
#     Sam    42       2
#     Dan    24       1
#    Alex    34       3

pf()
# Executed in 0.09 second(s)
