# Narrative
# --------
# EXTENDING A LIST
#
# Extracted from stzlistofliststest.ring, block #38.

load "../../stzBase.ring"


pr()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)

? @@( o1.content() )
#--> [ "A", "B", "C", "", "" ]

pf()
# Executed in 0.03 second(s)
