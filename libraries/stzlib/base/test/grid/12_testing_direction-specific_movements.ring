# Narrative
# --------
# Testing direction-specific movements
#
# Extracted from stzGridTest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Moving down 2 nodes
o1.MoveDownNNodes(2)
? @@(o1.Position())
#--> [ 1, 3 ]

# Moving right 3 nodes
o1.MoveRightNNodes(3)
? @@(o1.Position())
#--> [ 4, 3 ]

# Getting the node 2 positions above (without moving)
? @@(o1.NthNodeUp(2))
#--> [ 4, 1 ]

# Moving to that position
o1.MoveUpNNodes(2)
? @@(o1.Position())
#--> [ 4, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
