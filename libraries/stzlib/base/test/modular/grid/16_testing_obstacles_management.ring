# Narrative
# --------
# Testing obstacles management
#
# Extracted from stzGridTest.ring, block #16.

load "../../../stzBase.ring"


pr()

o1 = new stzGrid([10, 6])

# Add obstacles
o1.AddObstacle(3, 2)
o1.AddObstacle(4, 2)
o1.AddObstacle(5, 2)
o1.AddObstacle(3, 4)
o1.AddObstacle(4, 4)
o1.AddObstacle(5, 4) # In practice you will use AddObstacles([ ... ])

# Adding same obstacle twice (should not duplicate)
o1.AddObstacle(3, 2)

# Number of obstacles
? len(o1.Obstacles())
#--> 6

? o1.IsObstacle(3, 2)
#--> TRUE

? o1.IsObstacle(1, 1) + NL
#--> FALSE

# Show the grid with obstacles

o1.Show()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─────────────────────╮
# 1 │ x . . . . . . . . . │
# 2 │ . . ■ ■ ■ . . . . . │
# 3 │ . . . . . . . . . . │
# 4 │ . . ■ ■ ■ . . . . . │
# 5 │ . . . . . . . . . . │
# 6 │ . . . . . . . . . . │
#   ╰─────────────────────╯

# Change obstacle character

o1.SetObstacleChar("B")
? o1.ObstacleChar()
#--> B

o1.Show()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─────────────────────╮
# 1 │ x . . . . . . . . . │
# 2 │ . . B B B . . . . . │
# 3 │ . . . . . . . . . . │
# 4 │ . . B B B . . . . . │
# 5 │ . . . . . . . . . . │
# 6 │ . . . . . . . . . . │
#   ╰─────────────────────╯

# Remove obstacle and check

o1.RemoveObstacle(3, 2)
? o1.IsObstacle(3, 2)
#--> FALSE

# Clear all obstacles
o1.ClearObstacles()
? len(o1.Obstacles())
#--> 0


pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in almost 0 second(s) in Ring 1.26
