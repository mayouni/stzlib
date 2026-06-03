# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #148.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:7)
o1 - 3:5
o1.Show()
#--> [ 1, 2, 6, 7 ]

pf()
# Executed in 0.03 second(s)
