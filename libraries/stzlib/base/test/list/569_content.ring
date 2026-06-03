# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #569.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertAfterManyPositions([ 2, 4, 5 ], "*")
? @@( o1.Content() )
#--> [ "a", "b", "*", "c", "d", "*", "e", "*" ]

pf()
# Executed in almost 0 second(s).
