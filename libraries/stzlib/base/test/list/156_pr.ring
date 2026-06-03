# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #156.
#ERR Error (R14) : Calling Method without definition: extendtowithitemsin

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsIn( 8, "A":"C" )
o1.Show()
#--> [ 1, 2, 3, "A", "B", "C", "A", "B" ]

pf()
# Executed in 0.03 second(s)
