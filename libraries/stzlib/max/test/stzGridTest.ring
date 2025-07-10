load "../stzmax.ring"


/*--- Testing basic grid initialization and movement

pr()

o1 = new stzGrid([5, 5])

# Grid Size

? o1.NumberOfRows()
#--> 5

? o1.NumberOfColumns()
#--> 5

# Current Position

? @@(o1.CurrentPosition())
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
#     1 2 3 4 5 
#   ╭───────v───╮
# 1 │ . . . . . │
# 2 │ . . . . . │
# 3 > . . . x . │
# 4 │ . . . . . │
# 5 │ . . . . . │
#   ╰───────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing hitting the right boundary

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

/*--- Testing different movement directions

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

/*--- Testing forward/backward movement

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

/*--- Testing distance calculations

pr()

StzGridQ([10, 10]) {

	? @@( SizeXT() )
	#--> [ 10, 10 ]

	? @@( CurrentPosition() ) + NL
	#--> [1, 1]

	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > x . . . . . . . . . │
	# 2 │ . . . . . . . . . . │
	# 3 │ . . . . . . . . . . │
	# 4 │ . . . . . . . . . . │
	# 5 │ . . . . . . . . . . │
	# 6 │ . . . . . . . . . . │
	# 7 │ . . . . . . . . . . │
	# 8 │ . . . . . . . . . . │
	# 9 │ . . . . . . . . . . │
	# 0 │ . . . . . . . . . . │
	#   ╰─────────────────────╯
	
	MoveTo(3, 3)
	? @@( Position() )
	#--> [ 3, 3 ]
	
	# Manhattan Distance
	
	? DistanceTo(7, 6)
	#--> 7
	
	# Euclidean Distance
	
	? @@( EuclideanDistanceTo(7, 6) )
	#--> 5
	
	# Moving using MoveBy
	
	MoveBy(4, 3)  # Move 4 columns right, 3 rows down
	
	# New Position
	
	? @@( Position() ) + NL
	#--> [ 7, 6 ]
	
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─────────────v───────╮
	# 1 │ . . . . . . . . . . │
	# 2 │ . . . . . . . . . . │
	# 3 │ . . . . . . . . . . │
	# 4 │ . . . . . . . . . . │
	# 5 │ . . . . . . . . . . │
	# 6 > . . . . . . x . . . │
	# 7 │ . . . . . . . . . . │
	# 8 │ . . . . . . . . . . │
	# 9 │ . . . . . . . . . . │
	# 0 │ . . . . . . . . . . │
	#   ╰─────────────────────╯

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing edge cases and boundary conditions

pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(0, 0)
#--> ERROR: Can't move! The provided position is not valid.

pf()

/*---

pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(3, 1)
? @@( o1.Position() )
#--> [ 3, 1 ]

o1.MoveRight() # Won't move and stays on last node
? @@( o1.Position() )
#--> [ 3, 1 ]

o1.MoveUp() # Idem
? @@( o1.Position() )
#--> [ 3, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(1, 1)

o1.MoveLeft() # Won't move and stays on same position
? @@( o1.Position() )
#--> [ 1, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing direction changes and movement combinations

pr()

o1 = new stzGrid([4, 4])

o1.MoveTo(2, 2)
? o1.Direction()
#--> forward

o1.SetDirection(:down)
? o1.Direction()
#--> down

# Moving in current direction (down)

o1.MoveToNextPosition()
? @@( o1.Position() )
#--> [ 2, 3 ]

# Moving back to previous position (up)

o1.MoveToPreviousPosition()
? @@( o1.Position() )
#--> [ 2, 2 ]

# Changing direction to :right and moving

o1.SetDirection(:right)
o1.MoveToNextPosition()
? @@( o1.Position() )
#--> [ 3, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing multi-node movement

pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Starting position
? @@(o1.Position())
#--> [ 1, 1 ]

# Moving forward 3 nodes
o1.MoveForwardNNodes(3)
? @@(o1.Position())
#--> [ 4, 1 ]

# Moving backward 2 nodes
o1.MoveBackwardNNodes(2)
? @@(o1.Position())
#--> [ 2, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing hitting the right boundary

pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Moving right to edge
o1.MoveToNthNodeToRight(5)
? @@(o1.Position())
#--> [ 6, 1 ]

# Moving right one more (hits boundary and does not move)
o1.MoveRight()
? @@(o1.Position())
#--> [ 6, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing direction-specific movements

pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Moving down 2 nodes
o1.MoveDownNNodes(2)
? @@(o1.Position())
#--> [ 1, 3 ]

# Moving right 3 nodes
o1.MoveRightNNodes(3)
? @@(o1.Position())
#--> [ 4, 3 ]

# Getting the node 2 positions above (without moving)
? @@(o1.NthNodeUp(2))
#--> [ 4, 1 ]

# Moving to that position
o1.MoveToNthNodeUp(2)
? @@(o1.Position())
#--> [ 4, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing next/previous nth node methods

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

/*--- Testing boundary cases and error handling

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

/*#########################
#  ADVANCED TEST SAMPLE  #
#########################

1. Obstacles Management
	1.1. Adding and removing obstacles
	1.2. Checking obstacle status
	1.3. Setting obstacle character

2. Path Management
	2.1. Creating paths manually
	2.2. Measuring path length
	2.3. Setting path-related characters (path, current, empty)

3. Pathfinding Algorithms
	3.1. A* algorithm (ShortestPath)
	3.2. Manhattan path (horizontal/vertical first)
	3.3. Spiral path generation
	3.4. ZigZag path creation

4. Path Analysis
	4.1. Complexity measurement (number of turns)
	4.2. Efficiency calculation
	4.3. Custom path showing
	4.4. Showing specific nodes

5. Region Management
	5.1. Flood fill algorithm
	5.2. Connectivity testing
	5.3. Finding connected regions

6. Maze Generation
	6.1. Random maze with specified density
	6.2. Maze with guaranteed path

7. Grid Conversion and I/O
	7.1. Converting to list of lists
	7.2. String grid representation
	7.3. File export/import

/*--- Testing obstacles management

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

/*--- Testing path management

pr()

StzGridQ([8, 6]) {

	# Add some obstacles

	AddObstacles([ [3, 2], [3, 3], [3, 4], [5, 2], [5, 3], [5, 4] ])
	
	# Create a path manually

	AddPath([

		[1, 1], [2, 1],
			[2, 2],	   [4, 2],
			[2, 3],	   [4, 3],
			[2, 4],	   [4, 4],    [6, 2],
					      [6, 3],
					      [6, 4], [7, 4], [8, 4]
	])
	
	# Path length

	? PathLength()
	#--> 13
	
	# Show the grid with path

	MoveTo(8, 4)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 
	#   ╭───────────────v─╮
	# 1 │ ○ ○ · · · · · · │
	# 2 │ · ○ ■ · ■ ○ · · │
	# 3 │ · ○ ■ ○ ■ ○ · · │
	# 4 > · ○ ■ ○ ■ ○ ○ x │
	# 5 │ · · · · · · · · │
	# 6 │ · · · · · · · · │
	#   ╰─────────────────╯
	
	? PathEfficiency() # in %
	#--> 83.33

	# Clear path

	ClearPath()
	? PathLength()
	#--> 0

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing path finding algorithms
*/
pr()

StzGridQ([ 10, 6 ]) {

	# Add obstacles to form a maze
	AddObstacles([ [3, 2], [3, 3], [3, 4] ])
	AddObstacles([ [6, 1], [6, 2], [6, 3] ])
	AddObstacles([ [8, 3], [8, 4], [8, 5] ])
	
	# Testing A* algorithm (ShortestPath)
	ShortestPath([1, 1], [10, 6])
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > x . . . . ■ . . . . │
	# 2 │ ○ . ■ . . ■ . . . . │
	# 3 │ ○ . ■ . . ■ . ■ . . │
	# 4 │ ○ . ■ . . . . ■ . . │
	# 5 │ ○ . . . . . . ■ . . │
	# 6 │ ○ ○ ○ ○ ○ ○ ○ ○ ○ ○ │
	#   ╰─────────────────────╯

	#--

	ClearObstacles()
	ClearPath()
	
	# Testing Manhattan path (horizontal first)

	ManhattanPath([1, 1], [10, 6])
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > x ○ ○ ○ ○ ○ ○ ○ ○ ○ │
	# 2 │ . . . . . . . . . ○ │
	# 3 │ . . . . . . . . . ○ │
	# 4 │ . . . . . . . . . ○ │
	# 5 │ . . . . . . . . . ○ │
	# 6 │ . . . . . . . . . ○ │
	#   ╰─────────────────────╯

	ClearPath()
	
	# Testing Manhattan path (vertical first)
	ManhattanPathXT([1, 1], [10, 6], :VerticalFirst)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > x . . . . . . . . . │
	# 2 │ ○ . . . . . . . . . │
	# 3 │ ○ . . . . . . . . . │
	# 4 │ ○ . . . . . . . . . │
	# 5 │ ○ . . . . . . . . . │
	# 6 │ ○ ○ ○ ○ ○ ○ ○ ○ ○ ○ │
	#   ╰─────────────────────╯

	ClearPath()
	
	# Testing Spiral path
	SpiralPath([5, 3], :Rings = 3)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > . . ○ ○ ○ ○ ○ . . . │
	# 2 │ . . ○ ○ ○ ○ ○ . . . │
	# 3 │ . . ○ ○ x ○ ○ . . . │
	# 4 │ . . ○ ○ ○ ○ ○ . . . │
	# 5 │ . . ○ ○ ○ ○ ○ . . . │
	# 6 │ . . . . . . . . . . │
	#   ╰─────────────────────╯

	ClearPath()
	
	# Testing ZigZag path
	ZigZagPath([1, 1], [10, 6], :Width = 2)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭─v───────────────────╮
	# 1 > x ○ ○ . ○ ○ ○ . ○ ○ │
	# 2 │ . . ○ . ○ . ○ . ○ ○ │
	# 3 │ . . ○ ○ ○ . ○ ○ ○ ○ │
	# 4 │ . . . . . . . . . ○ │
	# 5 │ . . . . . . . . . ○ │
	# 6 │ . . . . . . . . . ◌ │
	#   ╰─────────────────────╯

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Testing path analysis and showing utilities

pr()

o1 = new stzGrid([10, 6])

# Create a zigzag path
o1.AddPathNodes([
	[1, 1],
	[2, 1],
	[3, 2],
	[4, 3],
	[3, 4],
	[2, 5],
	[3, 6],
	[4, 5],
	[5, 4],
	[6, 3],
	[7, 2],
	[8, 1]
])

# Analyze path complexity based on number of turns and direction changes
? o1.PathComplexity()
#--> 10

# Calculate path efficiency compared to direct distance
? o1.PathEfficiency() # In %
#--> 63.64

# Show path with custom character

o1.ShowPath(o1.Path(), "+")
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x + . . . . . + . . │
# 2 │ . . + . . . + . . . │
# 3 │ . . . + . + . . . . │
# 4 │ . . + . + . . . . . │
# 5 │ . + . + . . . . . . │
# 6 │ . . + . . . . . . . │
#   ╰─────────────────────╯

# Showing specific nodes with '%'
o1.ShowNodes([[2,2], [3,3], [4,4], [5,5]], "%")
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x . . . . . . . . . │
# 2 │ . % . . . . . . . . │
# 3 │ . . % . . . . . . . │
# 4 │ . . . % . . . . . . │
# 5 │ . . . . % . . . . . │
# 6 │ . . . . . . . . . . │
#   ╰─────────────────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing region management and connectivity

pr()

o1 = new stzGrid([10, 6])

# Create some obstacles to form regions
o1.AddObstacles([
	[3, 1],
	[3, 2],
	[3, 3],
	[3, 4],
	[3, 6],

	[7, 1],
	[7, 2],
	[7, 3],
	[7, 4],
	[7, 5],
	[7, 6]
])

o1.Show()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x . ■ . . . ■ . . . │
# 2 │ . . ■ . . . ■ . . . │
# 3 │ . . ■ . . . ■ . . . │
# 4 │ . . ■ . . . ■ . . . │
# 5 │ . . . . . . ■ . . . │
# 6 │ . . ■ . . . ■ . . . │
#   ╰─────────────────────╯

# Test flood fill

aRegion1 = o1.FloodFill(1, 1)
? len(aRegion1)
#--> 31

aRegion2 = o1.FloodFill(10, 6)
? len(aRegion2)
#--> 18

# Test connectivity
? o1.AreConnected([1, 1], [2, 2])
#--> TRUE

? o1.AreConnected([1, 1], [5, 1])
#--> TRUE

? o1.AreConnected([5, 5], [8, 6]) + NL
#--> FALSE

# Get all connected regions (list of lists of nodes)

aRegions = o1.ConnectedRegions()
? len(aRegions)
#--> 2

# Show each region with different characters

o1.ShowNodes(aRegions[1], "1")
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x 1 ■ 1 1 1 ■ . . . │
# 2 │ 1 1 ■ 1 1 1 ■ . . . │
# 3 │ 1 1 ■ 1 1 1 ■ . . . │
# 4 │ 1 1 ■ 1 1 1 ■ . . . │
# 5 │ 1 1 1 1 1 1 ■ . . . │
# 6 │ 1 1 ■ 1 1 1 ■ . . . │
#   ╰─────────────────────╯

o1.ShowNodes(aRegions[2], "2")
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x . ■ . . . ■ 2 2 2 │
# 2 │ . . ■ . . . ■ 2 2 2 │
# 3 │ . . ■ . . . ■ 2 2 2 │
# 4 │ . . ■ . . . ■ 2 2 2 │
# 5 │ . . . . . . ■ 2 2 2 │
# 6 │ . . ■ . . . ■ 2 2 2 │
#   ╰─────────────────────╯

# Show the tow regions togethor

o1.ShowRegions()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > 1 1 ■ 1 1 1 ■ 2 2 2 │
# 2 │ 1 1 ■ 1 1 1 ■ 2 2 2 │
# 3 │ 1 1 ■ 1 1 1 ■ 2 2 2 │
# 4 │ 1 1 ■ 1 1 1 ■ 2 2 2 │
# 5 │ 1 1 1 1 1 1 ■ 2 2 2 │
# 6 │ 1 1 ■ 1 1 1 ■ 2 2 2 │
#   ╰─────────────────────╯

o1.ShowRegionsXT([ "A", "B" ])
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > A A ■ A A A ■ B B B │
# 2 │ A A ■ A A A ■ B B B │
# 3 │ A A ■ A A A ■ B B B │
# 4 │ A A ■ A A A ■ B B B │
# 5 │ A A A A A A ■ B B B │
# 6 │ A A ■ A A A ■ B B B │
#   ╰─────────────────────╯

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*--- Testing maze generation

pr()

StzGridQ([15, 8]) {

	# Generating random maze (30% obstacle density)
	# ~> Result will be randomized but should have
	# approximately 30% of cells as obstacles

	RandomMaze(30)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 
	#   ╭─v─────────────────────────────╮
	# 1 > x . . . . ■ . ■ . . ■ ■ ■ ■ . │
	# 2 │ . . . ■ . . . . . ■ ■ . . . . │
	# 3 │ . . ■ . ■ . . . . . ■ . . . ■ │
	# 4 │ . . . ■ . . . . . . . . . . ■ │
	# 5 │ . . ■ ■ ■ ■ . . ■ . . . . ■ ■ │
	# 6 │ . ■ ■ . . . . . . . . . . ■ . │
	# 7 │ ■ ■ . . ■ . ■ . . ■ ■ . ■ . . │
	# 8 │ . ■ . . . . . . ■ . . . . ■ . │
	#   ╰───────────────────────────────╯

	ClearObstacles()

	# Generating maze with guaranteed path
	# ~> Result will show a path from (1,1) to (15,8)
	# with obstacles that don't block the path

	MazeWithPath([1, 1], [15, 8])
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 
	#   ╭─v─────────────────────────────╮
	# 1 > x . . ■ . . . . ■ ■ . ■ . . . │
	# 2 │ ◌ . ■ . . . . . ■ . . . . . . │
	# 3 │ ◌ . . . . . . . ■ . . . ■ . ■ │
	# 4 │ ◌ ■ . . ■ . ■ ■ . . . . ■ . . │
	# 5 │ ◌ . . . ■ ■ ■ . ■ . ■ . . . . │
	# 6 │ ◌ . . ■ ■ . . . . . . . . . . │
	# 7 │ ◌ . ■ . ■ . . . . ■ . . . . . │
	# 8 │ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ ◌ │
	#   ╰───────────────────────────────╯

}

pf()
# Executed in almost 0.12 second(s) in Ring 1.22

/*--- Testing moving and hitting an obstacle

pr()

o1 = new stzGrid([10, 6])

# Create some obstacles to form regions
o1.AddObstacles([
	[3, 1],
	[3, 2],
	[3, 3],
	[3, 4],
	[3, 6],

	[7, 1],
	[7, 2],
	[7, 3],
	[7, 4],
	[7, 5],
	[7, 6]
])

o1.Show()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > x . ■ . . . . . . . │
# 2 │ . . ■ . . . ■ . . . │
# 3 │ . . ■ . . . ■ . . . │
# 4 │ . . ■ . . . ■ . . . │
# 5 │ . . . . . . ■ . . . │
# 6 │ . . . . . . ■ . . . │
#   ╰─────────────────────╯

o1.MoveRight()
o1.MoveDown()
o1.MoveDown()
o1.Show()
#-->
#     1 2 3 4 5 6 7 8 9 0 
#   ╭─v───────────────────╮
# 1 > . . ■ . . . . . . . │
# 2 │ . . ■ . . . ■ . . . │
# 3 │ . x ■ . . . ■ . . . │
# 4 │ . . ■ . . . ■ . . . │
# 5 │ . . . . . . ■ . . . │
# 6 │ . . . . . . ■ . . . │
#   ╰─────────────────────╯

o1.MoveRight() # Won't move, hitted an obstacle.
? @@( o1.Position() )
#--> [2, 3]

pf()
# Executed in almost 0 second(s) in Ring 1.22
