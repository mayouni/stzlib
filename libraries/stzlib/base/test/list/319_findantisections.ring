# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #319.

load "../../stzBase.ring"

pr()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.FindAntiSectionsIB( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 3 ], [ 5, 7 ], [ 8, 10 ] ]

pf()
# Executed in 0.03 second(s).
