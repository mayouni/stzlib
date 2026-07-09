# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #554.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(5)

? @@(o1.SplitToPartsOfNItemsXT(2))
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@(o1.SplitBeforePositions( [ 3, 5 ] ))
#--> [ [ 1, 2 ], [ 3, 5 ] ]

? @@(o1.SplitAfterPositions( [ 3, 5 ] ))
#--> [ [ 1, 3 ], [ 4, 5 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
