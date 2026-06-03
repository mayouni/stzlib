# Narrative
# --------
# Testing different movement directions
#
# Extracted from stzGridTest.ring, block #3.

load "../../stzBase.ring"


pr()

o1 = new stzGrid([5, 5])
? @@(o1.SizeXT()) + NL
#--> [ 5, 5 ]

# Moving to center of grid

o1.MoveTo(3, 3) + NL
o1.Show() + NL
#-->
#     1 2 3 4 5 
#   ╭─────v─────╮
# 1 │ . . . . . │
# 2 │ . . . . . │
# 3 > . . x . . │
# 4 │ . . . . . │
# 5 │ . . . . . │
#   ╰───────────╯

# Ajacent positions (up, down, left, right)

? @@( o1.NodeUpLeft() )
#--> [ 2, 2 ]

? @@( o1.NodeUp() )
#--> [ 3, 2 ]

? @@( o1.NodeUpRight() ) + NL
#--> [ 4, 2 ]

#--

? @@( o1.NodeLeft() )
#--> [ 2, 3 ]

? @@( o1.NodeRight() ) + NL
#--> [ 4, 3 ]

#--

? @@( o1.NodeDownLeft() )
#--> [ 2, 4 ]

? @@( o1.NodeDown() )
#--> [ 3, 4 ]

? @@( o1.NodeDownRight() ) + NL
#--> [ 4, 4 ]

# Adjacent Neighbors

? @@( o1.AdjacentNodes() ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 3, 2 ], [ 3, 4 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ] ]

o1.ShowNeighbors()
#-->
#     1 2 3 4 5 
#   ╭─────v─────╮
# 1 │ . . . . . │
# 2 │ . N N N . │
# 3 > . N x N . │
# 4 │ . N N N . │
# 5 │ . . . . . │
#   ╰───────────╯

pf()
# Executed in 0.01 second(s) in Ring 1.22
