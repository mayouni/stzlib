# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #633.
#ERR Error (R14) : Calling Method without definition: intersectionwith

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])

? @@( o1.UnionWith([ 3, 4, 5 ]) )
#--> [ 1, 2, 3, 3, 4, 5 ]

? @@( o1.IntersectionWith([3, 4, 5 ]) )
#--> [ 3 ]

pf()
# Executed in 0.02 second(s).
