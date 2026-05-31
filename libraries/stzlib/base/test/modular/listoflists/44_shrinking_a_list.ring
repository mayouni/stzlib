# Narrative
# --------
# SHRINKING A LIST
#
# Extracted from stzlistofliststest.ring, block #44.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.ShrinkTo(3)

? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.03 second(s)
