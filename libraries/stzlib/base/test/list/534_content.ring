# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #534.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceItemAtPositionsByMany([1, 3, 4 ], "♥", [ 1, 3, 4 ])
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in 0.02 second(s).
