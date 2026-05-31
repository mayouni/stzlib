# Narrative
# --------
# pr()
#
# Extracted from stzTileTest.ring, block #8.

load "../../../stzBase.ring"


o1 = new stzTile([3, 2])

o1.MoveTo(1, 1)

o1.MoveLeft() # Won't move and stays on same position
? @@( o1.Position() )
#--> [ 1, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
