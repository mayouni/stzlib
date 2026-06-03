# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #153.

load "../../stzBase.ring"


o1 = new stzList(1 : 3)
o1.ExtendTo(5)
o1.Show()
#--> [ 1, 2, 3, 0, 0 ]

pf()
# Executed in 0.03 second(s)
