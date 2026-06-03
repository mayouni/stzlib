# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #32.

load "../../stzBase.ring"

pr()

o1 = new stzList([ [1, 2], [3, [4]], 5 ])

? @@( o1.Merged() )
#--> [ 1, 2, 3, [ 4 ], 5 ]

pf()
# Executed in 0.03 second(s)
