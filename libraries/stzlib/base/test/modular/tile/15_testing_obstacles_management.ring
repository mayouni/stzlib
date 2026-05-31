# Narrative
# --------
# Testing obstacles management
#
# Extracted from stzTileTest.ring, block #15.

load "../../../stzBase.ring"

pr()

o1 = new stzTile([10, 6])

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

# Show the Tile with obstacles

o1.Show()
#-->
#     1   2   3   4   5   6   7   8   9   0   
#   ╭─v─┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# 1 > ♥ │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 2 │   │   │███│███│███│   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 3 │   │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 4 │   │   │███│███│███│   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 5 │   │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 6 │   │   │   │   │   │   │   │   │   │   │
#   ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

# Change obstacle character

o1.SetObstacleCell("XXX")
? o1.ObstacleChar()
#--> XXX

o1.Show()
#-->
#     1   2   3   4   5   6   7   8   9   0   
#   ╭─v─┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# 1 > ♥ │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 2 │   │   │XXX│XXX│XXX│   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 3 │   │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 4 │   │   │XXX│XXX│XXX│   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 5 │   │   │   │   │   │   │   │   │   │   │
#   ├───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
# 6 │   │   │   │   │   │   │   │   │   │   │
#   ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

# Remove obstacle and check

o1.RemoveObstacle(3, 2)
? o1.IsObstacle(3, 2)
#--> FALSE

# Clear all obstacles
o1.ClearObstacles()
? len(o1.Obstacles())
#--> 0

pf()
# Executed in 0.04 second(s) in Ring 1.22
