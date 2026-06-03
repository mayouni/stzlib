# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #152.

load "../../stzBase.ring"


o1 = new stzList("A" : "C")
o1.ExtendTo(5)
o1.Show()
#--> [ "A", "B", "C", "", "" ]

pf()
# Executed in 0.03 second(s)
