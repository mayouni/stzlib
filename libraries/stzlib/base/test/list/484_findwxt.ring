# Narrative
# --------
# FindW / FindWhere: locate items by a predicate that compares neighbours.
#
# Both find the positions where an item is the double of the one before it.
# The expressive cursor form FindW('{ Q(@NextItem).IsDoubleOf(@PreviousItem) }')
# and the raw index-math form FindWhere('{ Q(This[@i+1]).IsDoubleOf(This[@i-1]) }')
# are two spellings of the same relational scan -- both return [ 8, 11 ].
# W is the single performant + expressive conditional form (the old WXT is
# retired); FindWhere is just a readable alias for FindW.
#
# Extracted from stzlisttest.ring, block #484.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? o1.FindW( '{ Q( @NextItem ).IsDoubleOf( @PreviousItem ) }' )
#--> [ 8, 11 ]

? o1.FindWhere( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' )
#--> [ 8, 11 ]

pf()
# Executed in 0.28 second(s).
