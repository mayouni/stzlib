# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #376.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2 ])

? o1.IsEqualTo([ 1, 2 ])
#--> TRUE

? o1.IsEqualTo([ 2, 1 ])
#--> TRUE

? o1.IsStrictlyEqualTo([ 2, 1 ])
#--> FALSE

? o1.IsStrictlyEqualTo([ 1, 2 ])
#--> TRUE

pf()
# Executed in 0.04 second(s).
