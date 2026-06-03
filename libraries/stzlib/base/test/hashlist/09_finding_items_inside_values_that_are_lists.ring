# Narrative
# --------
# FINDING ITEMS INSIDE VALUES THAT ARE LISTS
#
# Extracted from stzhashlisttest.ring, block #9.

load "../../stzBase.ring"


pr()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindItem(:can) ) + NL
#--> [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ]

? @@( o1.ItemZ(:can) ) + NL
#--> [ "can", [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ] ]

? @@( o1.FindTheseItems([ :can, :will ]) ) + NL
#--> [ [ 2, 3 ], [ 2, 5 ], [ 4, 1 ], [ 2, 2 ], [ 4, 2 ], [ 5, 1 ] ]

? @@( o1.TheseItemsZ([ :can, :will ]) ) + NL
#--> [
#	[ "can",  [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ] ],
#	[ "will", [ [ 2, [ 2 ] ], [ 4, [ 2 ] ], [ 5, [ 1 ] ] ] ]
# ]

pf()
# Executed in 0.04 second(s)
