# Narrative
# --------
# Testing boundary cases and error handling
#
# Extracted from stzGridTest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Try to move beyond upper-left boundary (should stay at starting position)
o1.MoveLeftNNodes(1)
? @@(o1.Position())
#--> [ 1, 1 ]

o1.MoveUpNNodes(1)
? @@(o1.Position())
#--> [ 1, 1 ]

# Move to lower-right corner
o1.MoveToNode(6, 4)
? @@(o1.Position())
#--> [ 6, 4 ]

# Try to move beyond lower-right boundary (should stay at corner)
o1.MoveRightNNodes(1)
? @@(o1.Position())
#--> [ 6, 4 ]

o1.MoveDownNNodes(1)
? @@(o1.Position())
#--> [ 6, 4 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
