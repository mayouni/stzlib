# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #159.
#ERR Error (R14) : Calling Method without definition: extendxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :ByItemsRepeated )
// ByItemsRepeated

o1.Show()
#--> [ "A", "B", "C", "A", "B" ])

pf()
# Executed in 0.04 second(s)
