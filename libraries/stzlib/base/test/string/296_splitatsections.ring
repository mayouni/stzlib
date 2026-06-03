# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #296.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(12)

? @@( o1.SplitAtSections([ [3, 5], [8, 9] ]) ) + NL
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 12 ] ]

? @@( o1.SplitAtSections([ [1, 12 ] ]) ) + NL
#--> [ ]

? @@( o1.SplitAtSections([ [1, 5], [ 8, 9 ] ]) ) + NL
#--> [ [ 6, 7 ], [ 10, 12 ] ]

? @@( o1.SplitAtSections([ [3, 5], [8, 9], [12, 12] ]) )
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 11 ] ]

pf()
# Executed in 0.09 second(s).
