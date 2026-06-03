# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #285.

load "../../stzBase.ring"


o1 = new stzList(1:10)
? o1.AntiPositions([ 3, 4, 7, 9 ])
#--> [1, 2, 5, 6, 8, 10 ]

pf()
# Executed in almost 0 second(s).
