# Narrative
# --------
# Testing hitting the right boundary
#
# Extracted from stzGridTest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzGrid([6, 4])
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
