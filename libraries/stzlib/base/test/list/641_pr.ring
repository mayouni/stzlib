# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #641.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, 6 ])
? o1.IsReverseOf([ 6, 3, 2, 1 ])
#--> TRUE

pf()
# Executed in almost 0 second(s).
