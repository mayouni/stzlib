# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #422.

load "../../stzBase.ring"


o1 = new stzSplitter(8)
? @@( o1.SplitAt([3, 5]) )
#--> [ [ 1, 2 ], [ 4, 4 ], [ 6, 8 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20
