# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #24.

load "../../../stzBase.ring"


o1 = new stzListOfLists([ "A":"C", "A":"B", "A":"C" ])
? @@( o1.Index() )
#--> [
#	[ "A", [ 1, 2, 3 ] ],
#	[ "B", [ 1, 2, 3 ] ],
#	[ "C", [ 1, 3 ] ]
# ]

pf()
#--> Executed in 0.10 second(s)
