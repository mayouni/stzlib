# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #379.

load "../../stzBase.ring"


o1 = new stzList([ 4, 1, 2, 1, 1, 2, 3, 3, 3 ])
? o1.DuplicatesRemoved()
#--> [ 4, 1, 2, 3 ]

pf()
# Executed in almost 0 second(s).
