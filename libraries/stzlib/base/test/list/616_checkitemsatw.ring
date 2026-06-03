# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #616.
#ERR Error (R14) : Calling Method without definition: checkitemsatw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 1:3, "B", "C", 1:3, 1:3 ])

? o1.CheckItemsAtW([ 2, 5, 6 ], 'isList(this[@i]) and len(this[@i]) = 3')
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.22
