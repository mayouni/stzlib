# Narrative
# --------
# Testing direction changes and movement combinations
#
# Extracted from stzTileTest.ring, block #9.

load "../../stzBase.ring"


pr()

o1 = new stzTile([4, 4])

o1.MoveTo(2, 2)
? o1.Direction()
#--> forward

o1.SetDirection(:down)
? o1.Direction()
#--> down

# Moving in current direction (down)

o1.MoveNext()
? @@( o1.Position() )
#--> [ 2, 3 ]

# Moving back to previous position (up)

o1.MovePrevious()
? @@( o1.Position() )
#--> [ 2, 2 ]

# Changing direction to :right and moving

o1.SetDirection(:right)
o1.MoveToNext()
? @@( o1.Position() )
#--> [ 3, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
