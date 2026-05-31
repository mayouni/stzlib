# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #578.

load "../../../stzBase.ring"


o1 = new stzSplitter(3)
? @@( o1.SplitToNParts(0) )
#--> [ ]

o1 = new stzList([ "A", "B", "C" ])
? @@( o1.SplittedToNParts(0) )
#--> [ "A", "B", "C" ]

#~> The list is not splitted and returned as is.

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.17
