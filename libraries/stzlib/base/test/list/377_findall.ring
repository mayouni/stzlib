# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #377.

load "../../stzBase.ring"

pr()

o1 = new stzList([ [1,2], [3, [1], 4], [5,6], [ 2, 10 ], [3,4], [3, [1], 4] ])

? o1.FindAll( [3, [1], 4] )
#--> [2, 6]

? o1.FindFirst( [3, [1], 4] )
#--> 2

pf()
# Executed in 0.02 second(s).
