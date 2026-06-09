# Narrative
# --------
# Testing multi-node movement
#
# Extracted from stzGridTest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Starting position
? @@(o1.Position())
#--> [ 1, 1 ]

# Moving forward 3 nodes
o1.MoveForwardNNodes(3)
? @@(o1.Position())
#--> [ 4, 1 ]

# Moving backward 2 nodes
o1.MoveBackwardNNodes(2)
? @@(o1.Position())
#--> [ 2, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
