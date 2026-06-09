# Narrative
# --------
# Testing next/previous nth node methods
#
# Extracted from stzGridTest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Set position and direction
o1.MoveToNode(3, 2)
o1.SetDirection(:Forward)
? @@(o1.Position())
#--> [ 3, 2 ]
? o1.Direction()
#--> Forward

# Get position 2 nodes ahead in current direction (without moving)
? @@(o1.NextNthNode(2))
#--> [ 5, 2 ]

# Get position 2 nodes behind in current direction (without moving)
? @@(o1.PreviousNthNode(2))
#--> [ 3, 2 ]

# Move to next nth node in current direction
o1.MoveToNextNthNode(2)
? @@(o1.Position())
#--> [ 5, 2 ]

# Change direction and get nth node
o1.SetDirection(:Down)
? @@(o1.NextNthNode(1))
#--> [ 5, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
