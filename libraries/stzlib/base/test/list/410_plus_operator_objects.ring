# Narrative
# --------
# Obj() / ObjQ(): keep adding, but store the stzList AS AN OBJECT.
#
# `Q([1,2,3]) + Q([4,5])` adds [4,5]'s content as one sublist item. Wrap
# the operand in Obj() (alias AsObject / O) and the stz OBJECT itself is
# stored instead; ObjQ() does the same but keeps the chain elevated so you
# can add 6 afterwards.
#
# NOTE: the original block printed these with a bare `?`, which dumps the
# embedded object's internal attributes; switched to @@ here, which renders
# an embedded stz object compactly as "@noname". Outputs corrected to the
# real render.
#
# Extracted from stzlisttest.ring, block #410.

load "../../stzBase.ring"

pr()

? @@( ( Q([1, 2, 3]) + Q([ 4, 5 ]) ).Content() )
#--> [ 1, 2, 3, [ 4, 5 ] ]

? @@( Q([1, 2, 3]) + Obj(Q([ 4, 5 ])) )
#--> [ 1, 2, 3, @noname ]

? @@( Q([1, 2, 3]) + ObjQ(Q([ 4, 5 ])) + 6 )
#--> [ 1, 2, 3, @noname, 6 ]

pf()
# Executed in 0.02 second(s)
