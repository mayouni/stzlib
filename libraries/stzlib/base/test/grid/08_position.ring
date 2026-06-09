# Narrative
# --------
# pr()
#
# Extracted from stzGridTest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(1, 1)

o1.MoveLeft() # Won't move and stays on same position
? @@( o1.Position() )
#--> [ 1, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
