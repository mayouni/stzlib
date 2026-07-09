# Narrative
# --------
# FindW with the @NextNumber cursor vs raw This[@i+1] index math.
#
# Both locate the positions where an item equals its successor. The cursor
# form '{ @Number = @NextNumber }' reads naturally; the index form
# '{ This[@i] = This[@i+1] }' is the same scan written with explicit
# indices. Both return [ 3, 8, 17, 18 ]. W is the single performant +
# expressive conditional form (the old WXT is retired).
#
# Extracted from stzlisttest.ring, block #485.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])

? o1.FindW( '{ @Number = @NextNumber }' )
#--> [ 3, 8, 17, 18 ]

? o1.FindW( '{ This[@i] = This[@i+1] }' )
#--> [ 3, 8, 17, 18 ]

pf()
# Executed in 0.01 second(s) in Ring 1.27
# Executed in 0.29 second(s) before
