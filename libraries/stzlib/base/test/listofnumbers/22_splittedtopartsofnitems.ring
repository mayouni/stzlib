# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #22.

load "../../stzBase.ring"

pr()

o1 = new stzList(["one", "two", "three", "four", "five", "six" ])

? @@( o1.SplittedToPartsOfNItems(3) ) + NL
#--> [ [ "one", "two", "three" ], [ "four", "five", "six" ] ]

? @@( o1.SplittedToNParts(3) )
#--> [ [ "one", "two" ], [ "three", "four" ], [ "five", "six" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
