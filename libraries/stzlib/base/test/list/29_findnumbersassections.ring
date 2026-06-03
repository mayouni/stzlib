# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #29.
#ERR Error (R14) : Calling Method without definition: findnumbersassections

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", 7, 8, "C", "D", 11, 12, 13 ])
? @@( o1.FindNumbersAsSections() )
#--> [ [ 1, 4 ], [ 7, 8 ], [ 11, 13 ] ]

pf()
