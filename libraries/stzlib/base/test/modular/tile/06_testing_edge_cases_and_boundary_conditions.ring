# Narrative
# --------
# Testing edge cases and boundary conditions
#
# Extracted from stzTileTest.ring, block #6.

load "../../../stzBase.ring"


pr()

o1 = new stzTile([3, 2])

o1.MoveTo(0, 0)
#--> ERROR: Can't move! The provided position is not valid.

pf()
