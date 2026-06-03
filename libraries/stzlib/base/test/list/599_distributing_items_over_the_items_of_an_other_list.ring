# Narrative
# --------
# DISTRIBUTING ITEMS OVER THE ITEMS OF AN OTHER LIST
#
# Extracted from stzlisttest.ring, block #599.
#ERR Error (R3) : Calling Function without definition: @@sp

load "../../stzBase.ring"


pr()

# Softanza can distribute the items of a list over the items of an other,
# called metaphorically 'Beneficiary Items'  as they benfit from that
# distribution.
		
# The distribution is defined by the share of each item.
		
# The share of each item determines how many items should be given to
# the each beneficiary item.
		
# Let's see:	

o1 = new stzList([ "water", "coca", "milk", "spice", "cofee", "tea", "honey" ] )
? @@SP( o1.DistributeOver([ "arem", "mohsen", "hamma" ]) ) + NL
#--> [
#	[ "arem",   [ "water", "coca", "milk" ] ],
#	[ "mohsen", [ "spice", "cofee" ],
#	[ "hamma",  [ "tea", "honey" ]
# ]

# Same can be made using the extended form of the function, that allows
# us to specify how the items are explicitly shared:

? @@SP( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 3, 2, 2 ] ) ) + NL
#--> [
#	[ "arem",   [ "water", "coca", "milk" ] ],
#	[ "mohsen", [ "spice", "cofee" ],
#	[ "hamma",  [ "tea", "honey" ]
# ]

# And so you can change the share at your will:
? @@SP( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 1, 2, 4 ] ) ) + NL
#--> [
#	[ "arem",   [ "water" ] ] ],
#	[ "mohsen", [ "coca", "milk" ] ],
#	[ "hamma",  [ "spice", "cofee", "tea", "honey" ] ]
# ]

# But if you try to share more items then it exists in the list (1 + 2 + 6 > 7!):
? @@( o1.DistributeOverXT([ :arem, :mohsen, :hamma ], :Using = [ 1, 2, 6 ] ) )
# Softanza won't let you do so and tells you why:

#   	What : Can't distribute the items of the main list over the items of
#	       the provided list!
#   	Why  : Sum of items to be distributed (in anShareOfEachItem) must be
#	       equal to number of items of the main list.
#   	Todo : Provide a share list where the sum of its items is equal to
#	       the number of items of the list.

pf()
# Executed in 0.01 second(s)
