# Narrative
# --------
# Testing next/previous nth Cell methods
#
# Extracted from stzTileTest.ring, block #13.

load "../../../stzBase.ring"


pr()

o1 = new stzTile([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Set position and direction
o1.MoveToCell(3, 2)
o1.SetDirection(:Forward)
? @@(o1.Position())
#--> [ 3, 2 ]
? o1.Direction()
#--> Forward

# Get position 2 Cells ahead in current direction (without moving)
? @@(o1.NextNthCell(2))
#--> [ 5, 2 ]

# Get position 2 Cells behind in current direction (without moving)
? @@(o1.PreviousNthCell(2))
#--> [ 3, 2 ]

# Change direction and get nth Cell
o1.SetDirection(:Down)
? @@(o1.NextNthCell(1))
#--> [ 5, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
