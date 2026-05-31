# Narrative
# --------
# Testing forward/backward movement
#
# Extracted from stzGridTest.ring, block #4.

load "../../../stzBase.ring"


pr()

o1 = new stzGrid([4, 3])

# Default Direction
? o1.Direction() + NL

# Starting position [1, 1]

o1.Show() + NL
#-->
#     1 2 3 4 
#   ╭─v───────╮
# 1 > x . . . │
# 2 │ . . . . │
# 3 │ . . . . │
#   ╰─────────╯

# Moving forward three times

o1.MoveForward()
o1.MoveForward()
o1.MoveForward()

# New Position

o1.Show()
#-->
#     1 2 3 4 
#   ╭───────v─╮
# 1 > . . . x │
# 2 │ . . . . │
# 3 │ . . . . │
#   ╰─────────╯

# Moving backward twice

o1.MoveBackward()
o1.MoveBackward()

# New Position

o1.Show()
#-->
#     1 2 3 4 
#   ╭───v─────╮
# 1 > . x . . │
# 2 │ . . . . │
# 3 │ . . . . │
#   ╰─────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22
