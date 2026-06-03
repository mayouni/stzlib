# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #347.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")

? @@( o1.FindAnyBoundedByAsSectionsIB([ "12", "67" ]) )
#--> [ [ 1, 7 ], [ 11, 17 ] ]

? @@( o1.FindAnyBoundedByAsSections([ "♥♥♥", "♥♥♥" ]) )
#--> [ [ 6, 7 ], [ 11, 12 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.09 second(s) in Ring 1.18
