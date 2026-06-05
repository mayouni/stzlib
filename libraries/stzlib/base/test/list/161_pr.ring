# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #161.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :WithItemsIn = [ "D", "E" ])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.05 second(s)
