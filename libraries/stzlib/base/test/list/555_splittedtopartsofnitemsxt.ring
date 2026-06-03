# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #555.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

? @@( o1.SplittedToPartsOfNItemsXT(2) ) + NL
#--> [ [ "a", "b" ], [ "c", "d" ], [ "e" ] ]

? @@( o1.SplittedAfterPositions([ 3, 5 ]) ) + NL
#--> [ [ "a", "b", "c" ], [ "d", "e" ] ]

? @@( o1.SplittedBeforePositions([ 3, 5 ]) )
#--> [ [ "a", "b" ], [ "c", "d", "e" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
