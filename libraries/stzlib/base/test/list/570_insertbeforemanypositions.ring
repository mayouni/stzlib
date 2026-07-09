# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #570.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c", "d", "e" ])

o1.InsertBeforeManyPositions([ 2, 4, 5 ], "*")
? @@( o1.Content() )
#--> [ "a", "*", "b",  "c", "*", "d", "*", "e" ]

pf()
# Executed in almost 0 second(s).
