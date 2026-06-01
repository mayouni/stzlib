# Narrative
# --------
#
# Extracted from stzSsplittertest.ring, block #10.

load "../../../stzBase.ring"

pr()

# Used internally by Softanza, but could be useful...

o1 = new stzSplitter(10)
? @@( o1.GetPairsFromPositions([3, 6, 8]) )
#--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
