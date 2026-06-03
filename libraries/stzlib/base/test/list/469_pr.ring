# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #469.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3])

o1.ExtendToPosition(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

o1.ExtendToPositionXT( 8, :With = 5 )
? @@(o1.Content())
#--> [ 1, 2, 3, 0, 0, 5, 5, 5 ]

pf()
# Executed in almost 0 second(s).
