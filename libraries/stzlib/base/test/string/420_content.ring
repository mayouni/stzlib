# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #420.

load "../../stzBase.ring"

pr()

o1 = new stzString("...12..1212..121212..12.")

aSections = o1.FindZZ("12")
#--> [ [ 4, 5 ], [ 8, 9 ], [ 10, 11 ], [ 14, 15 ], [ 16, 17 ], [ 18, 19 ], [ 22, 23 ] ]

o1 = new stzListOfSections(aSections)
o1.MergeContiguous()

? @@( o1.Content() )
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
