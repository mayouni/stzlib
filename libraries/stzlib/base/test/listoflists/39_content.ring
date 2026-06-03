# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #39.
#ERR Error (R14) : Calling Method without definition: extendxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :Using = AHeart() )

? @@( o1.content() )
#--> [ "A", "B", "C", "♥", "♥" ]

pf()
# Executed in 0.04 second(s)
