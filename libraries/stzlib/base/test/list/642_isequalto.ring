# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #642.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])

? o1.IsEqualTo([ 3, 1, 2 ])
#--> TRUE

? o1.IsStrictlyEqualTo([ 3, 1, 2 ])
#--> FALSE

? o1.IsStrictlyEqualTo([ 1, 2, 3 ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
