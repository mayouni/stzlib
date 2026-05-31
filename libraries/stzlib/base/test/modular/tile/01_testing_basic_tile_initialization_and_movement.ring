# Narrative
# --------
# Testing basic Tile initialization and movement
#
# Extracted from stzTileTest.ring, block #1.

load "../../../stzBase.ring"


pr()

o1 = new stzTile([5, 5])

# Tile Size

? o1.NumberOfRows()
#--> 5

? o1.NumberOfColumns()
#--> 5

# Current Position

? @@(o1.CurrentCell())
#--> [ 1, 1 ]

# Moving down twice...

o1.MoveDown()
o1.MoveDown()
? @@( o1.CurrentPosition() )
#--> [ 1, 3 ]

#Moving right three times...

o1.MoveRight()
o1.MoveRight()
o1.MoveRight()

? @@( o1.CurrentPosition() ) + NL
#--> [ 4, 3 ]

o1.Show()
#-->
#     1   2   3   4   5   
#   ╭───┬───┬───┬─v─┬───╮
# 1 │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┤
# 2 │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┤
# 3 >   │   │   │ ♥ │   │
#   ├───┼───┼───┼───┼───┤
# 4 │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┤
# 5 │   │   │   │   │   │
#   ╰───┴───┴───┴───┴───╯

pf()
# Executed in almost 0 second(s) in Ring 1.22
