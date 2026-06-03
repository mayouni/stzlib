# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #157.
#ERR Error (R14) : Calling Method without definition: extendxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :List, :With = ["D", "E"])
o1.Show()
#--> [ "A", "B", "C", "D", "E" ])

pf()
# Executed in 0.04 second(s)
