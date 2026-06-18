# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #616.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 1:3, "B", "C", 1:3, 1:3 ])

? o1.CheckItemsAtWF([ 2, 5, 6 ], func x { return isList(x) and len(x) = 3 } )
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.22
