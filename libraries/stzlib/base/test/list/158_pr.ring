# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #158.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :List, :ToPosition = 5 )
o1.Show()
#--> [ "A", "B", "C", "", "" ]

pf()
# Executed in 0.05 second(s)
