# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #289.

load "../../../stzBase.ring"


aSections = [ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ]

o1 = new stzListOfSections(aSections)
o1.MergeOverlapping()
? @@( o1.Content() )
#--> [ [ 8, 15 ], [ 26, 29 ] ]

pf()
# Executed in 0.04 second(s).
