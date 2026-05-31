# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #22.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "A", "C", "D", "B" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 3 ] ],
#	[ "B", [ 2, 6 ] ],
#	[ "C", [ 4 ] ],
#	[ "D", [ 5 ] ]
# ]

pf()
# Executed in 0.03 second(s)
