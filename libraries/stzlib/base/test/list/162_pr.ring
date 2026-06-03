# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #162.
#ERR Error (R14) : Calling Method without definition: shrink

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.05 second(s)
