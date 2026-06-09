# Narrative
# --------
# Testing edge cases and boundary conditions
#
# Extracted from stzGridTest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(0, 0)
#--> ERROR: Can't move! The provided position is not valid.

pf()
