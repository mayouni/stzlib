# Narrative
# --------
# Testing direction-specific movements
#
# Extracted from stzTileTest.ring, block #12.

load "../../stzBase.ring"


pr()

o1 = new stzTile([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Moving down 2 Cells
o1.MoveDownNCells(2)
? @@(o1.Position())
#--> [ 1, 3 ]

# Moving right 3 Cells
o1.MoveRightNCells(3)
? @@(o1.Position())
#--> [ 4, 3 ]

# Getting the Cell 2 positions above (without moving)
? @@(o1.NthCellUp(2))
#--> [ 4, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
