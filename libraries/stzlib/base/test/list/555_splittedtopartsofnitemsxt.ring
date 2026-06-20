# Narrative
# --------
# Three ways to CUT a list into parts.
#
# SplittedToPartsOfNItemsXT(n) chops into runs of n items, the final part
# keeping the leftover ("XT" = keep the short tail rather than dropping or
# padding it). SplittedAfterPositions / SplittedBeforePositions cut at
# explicit boundaries -- after, or before, the given positions. All three
# are the non-mutating "Splitted..." forms (they return a fresh list of
# parts and leave the original intact; the "Split..." forms mutate).
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
# Executed in 0.03 second(s)
