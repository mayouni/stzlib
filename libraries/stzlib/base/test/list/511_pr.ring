# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #511.

load "../../stzBase.ring"


o1 = new stzList([ 10, 1, 2, 3, 10 ])

o1.Remove(10)
? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s).
