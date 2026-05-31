# Narrative
# --------
# Testing hitting the right boundary
#
# Extracted from stzTileTest.ring, block #2.

load "../../../stzBase.ring"


pr()

o1 = new stzTile([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Moving right to edge

o1.MoveTo(6, 1)
? @@(o1.Position())
#--> [ 6, 1 ]

# Moving right one more (hits boundary and does not move)

o1.MoveRight()
? @@(o1.Position())
#--> [ 6, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
