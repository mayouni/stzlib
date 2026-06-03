# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #14.
#ERR Error (R14) : Calling Method without definition: isstzclassname

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.Items() ) + NL
#--> [ "is", "will", "can", "some" ]

? @@( o1.FindItems() ) + NL
#--> [ [ 1, 1 ], [ 3, 1 ], [ 2, 1 ], [ 2, 2 ], [ 4, 2 ], [ 5, 1 ], [ 2, 3 ], [ 2, 5 ], [ 4, 1 ], [ 2, 4 ] ]

? @@( o1.ItemsZ() )
#--> [
#	[ "is", [ [ 2, 1 ] ] ],
#	[ "will", [ [ 2, 2 ], [ 4, 2 ], [ 5, 1 ] ] ],
#	[ "can", [ [ 2, 3 ], [ 2, 5 ], [ 4, 1 ] ] ],
#	[ "some", [ [ 2, 4 ] ] ]
# ]

pf()
# Executed in 0.06 second(s)
