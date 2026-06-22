# Narrative
# --------
# Growing a list to reach a target position by padding the tail.
#
# ExtendToPosition(n) lengthens the list until index n exists, filling
# the new slots with the default 0. ExtendToPositionXT(n, :With = v)
# does the same but pads with a chosen value instead. Both mutate the
# list in place and are no-ops when the list already reaches n. This is
# the Softanza idiom for ensuring a position is addressable before you
# write to it, rather than checking-and-appending by hand.
#
# Extracted from stzlisttest.ring, block #469.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3])

o1.ExtendToPosition(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

o1.ExtendToPositionXT( 8, :With = 5 )
? @@(o1.Content())
#--> [ 1, 2, 3, 0, 0, 5, 5, 5 ]

pf()
# Executed in almost 0 second(s).
