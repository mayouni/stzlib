# Narrative
# --------
# Testing multi-Cell movement
#
# Extracted from stzTileTest.ring, block #10.

load "../../stzBase.ring"


pr()

o1 = new stzTile([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Starting position
? @@(o1.Position())
#--> [ 1, 1 ]

# Moving forward 3 Cells
o1.MoveForwardNCells(3)
? @@(o1.Position())
#--> [ 4, 1 ]

# Moving backward 2 Cells
o1.MoveBackwardNCells(2)
? @@(o1.Position())
#--> [ 2, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
