# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #56.

load "../../stzBase.ring"

pr()

o1 = new stzLists([ "A":"C", 1:3 ])
? @@( o1.Associated() )
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

pf()
# Executed in 0.03 second(s)
