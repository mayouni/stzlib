# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #410.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? @@( ( Q([1, 2, 3]) + Q([ 4, 5 ]) ).Content() )
#--> [ 1, 2, 3, [ 4, 5 ] ]

? Q([1, 2, 3]) + Obj(Q([ 4, 5 ]))
#--> [ 1, 2, 3, Q([ 4, 5 ] ]

? Q([1, 2, 3]) + ObjQ(Q([ 4, 5 ])) + 6
#--> [ 1, 2, 3, Q([ 4, 5 ], 6 ]

pf()
# Executed in 0.02 second(s).
