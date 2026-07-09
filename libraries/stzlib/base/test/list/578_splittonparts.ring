# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #578.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(3)
? @@( o1.SplitToNParts(0) )
#--> [ ]

o1 = new stzList([ "A", "B", "C" ])
? @@( o1.SplittedToNParts(3) )
#--> [ [ "A" ], [ "B" ], [ "C" ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.17
