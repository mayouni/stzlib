# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #160.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :With = "*" )
o1.Show()
#--> [ "A", "B", "C", "*", "*" ]

pf()
# Executed in 0.04 second(s)
