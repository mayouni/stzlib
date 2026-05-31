# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #20.

load "../../../stzBase.ring"


o1 = new stzList([ "1", "A", "B", "A", "A", "C", "B", 1 ])
? @@( o1.Withoutduplication() ) + NL
#--> [ "1", "A", "B", "C", 1 ]


? @@( o1.FindItems() ) + NL # Or ItemsZ()
#--> [
#	[ "1", [ 1 ] ],
#	[ "A", [ 2, 4, 5 ] ],
#	[ "B", [ 3, 7 ] ],
#	[ "C", [ 6 ] ],
#	[   1, [ 8 ] ]
# ]

? @@( o1.ItemsCount() )
#--> [ [ "1", 1 ], [ "A", 3 ], [ "B", 2 ], [ "C", 1 ], [ 1, 1 ] ]

pf()
# Executed in 0.04 second(s)
