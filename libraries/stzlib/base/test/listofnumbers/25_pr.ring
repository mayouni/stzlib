# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #25.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B" ])

? @@( o1.SplittedToNParts(2) )
#--> [ [ "A" ], [ "B" ] ]

? @@( o1.SplittedToNParts(1) )
#--> [ [ "A", "B" ] ]

? @@( o1.SplittedToNParts(0) )
#--> [ ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18
