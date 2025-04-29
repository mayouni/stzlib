load "../max/stzmax.ring"


/*--- Testing basic grid initialization and movement

pr()

o1 = new stzGrid([5, 5])

# Grid Size

? o1.NumberOfRows()
#--> 5

? o1.NumberOfColumns() + NL
#--> 5

# Current Position

? @@(o1.CurrentPosition()) + NL
#--> [ 1, 1 ]

# Moving down twice...

o1.MoveDown()
o1.MoveDown()
? @@( o1.CurrentPosition() ) + NL
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
? @@( o1.SizeXY() )
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
? @@(o1.SizeXY()) + NL

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

# Ajacent positions (above, below, left, right)

? @@( o1.NodeAboveLeft() )
#--> [ 2, 2 ]

? @@( o1.NodeAbove() )
#--> [ 3, 2 ]

? @@( o1.NodeAboveRight() ) + NL
#--> [ 4, 2 ]

#--

? @@( o1.NodeToLeft() )
#--> [ 2, 3 ]

? @@( o1.NodeToRight() ) + NL
#--> [ 4, 3 ]

#--

? @@( o1.NodeBelowLeft() )
#--> [ 2, 4 ]

? @@( o1.NodeBelow() )
#--> [ 3, 4 ]

? @@( o1.NodeBelowRight() ) + NL
#--> [ 4, 4 ]

# Adjacent Neighbors

? @@( o1.AdjacentNodes() ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 3, 2 ], [ 3, 4 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ] ]

// o1.PaintNighbors() #TODO

pf()
# Executed in almost 0 second(s) in Ring 1.22

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

o1 = new stzGrid([10, 10])

o1.MoveTo(3, 3)
? @@( o1.Position() )
#--> [ 3, 3 ]

# Manhattan Distance

? o1.DistanceTo(7, 6)
#--> 7

# Euclidean Distance

? @@( o1.EuclideanDistanceTo(7, 6) )
#--> 5

# Moving using MoveBy

o1.MoveBy(4, 3)  # Move 4 columns right, 3 rows down

# New Position

? @@( o1.Position() ) + NL
#--> [ 7, 6 ]

o1.Show()
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

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing edge cases and boundary conditions

pr()

o1 = new stzGrid([3, 2])

o1.MoveTo(0, 0)
#--> ERROR: Invalid position! Column must be between 1 and 3, and row between 1 and 2.

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
? @@( o1.SizeXY() )
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
? @@( o1.SizeXY() )
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
? @@( o1.SizeXY() )
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
? @@(o1.NthNodeAbove(2))
#--> [ 4, 1 ]

# Moving to that position
o1.MoveToNthNodeAbove(2)
? @@(o1.Position())
#--> [ 4, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing next/previous nth node methods

pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXY() )
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
? @@( o1.SizeXY() )
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

##########################
#  ADVANCED TEST SAMPLE  #
##########################
/*

1. Obstacles Management
	1.1. Adding and removing obstacles
	1.2. Checking obstacle status
	1.3. Setting obstacle character

2. Path Management
	2.1. Creating paths manually
	2.2. Measuring path length
	2.3. Setting path-related characters (path, visited, current, empty)

3. Pathfinding Algorithms
	3.1. A* algorithm (FindShortestPath)
	3.2. Manhattan path (horizontal/vertical first)
	3.3. Spiral path generation
	3.4. ZigZag path creation

4. Path Analysis
	4.1. Complexity measurement (number of turns)
	4.2. Efficiency calculation
	4.3. Custom path drawing
	4.4. Painting specific nodes

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

*/

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

o1.ShowObstacles(TRUE)
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

# Remove obstacle and check

o1.RemoveObstacle(3, 2)
? o1.IsObstacle(3, 2)
#--> FALSE

# Clear all obstacles
o1.ClearObstacles()
? len(o1.Obstacles())
#--> 0

# Change obstacle character

o1.SetObstacleChar("B")
? o1.ObstacleChar()
#--> B

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Testing path management

pr()

StzGridQ([8, 6]) {

	# Add some obstacles

	AddObstacles([ [3, 2], [3, 3], [3, 4], [5, 2], [5, 3], [5, 4] ])
	ShowObstacles(TRUE) # By default ~ TRUE
	
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

	ShowPath(TRUE)
	ShowVisited(TRUE)

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
	
	? PathEfficiency() # %
	#--> 83.33

	# Clear path

	ClearPath()
	? PathLength()
	#--> 0

}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Testing path finding algorithms
*/
pr()

StzGridQ([ 10, 6 ]) {

	# Add obstacles to form a maze
	AddObstacles([ [3, 2], [3, 3], [3, 4] ])
	AddObstacles([ [6, 1], [6, 2], [6, 3] ])
	AddObstacles([ [8, 3], [8, 4], [8, 5] ])

	# Set visualization
	ShowObstacles(TRUE)
	ShowPath(TRUE)
//	ShowVisited(TRUE)
	
	# Testing A* algorithm (FindShortestPath)
	FindShortestPath(1, 1, 10, 6)
	Show()
	#-->
	#     1 2 3 4 5 6 7 8 9 0 
	#   ╭───────────────────v─╮
	# 1 > * * * * * ■ * * * . │
	# 2 │ . . ■ * * ■ . . . . │
	# 3 │ . . ■ * * ■ . ■ . . │
	# 4 │ . . ■ * . . . ■ . . │
	# 5 │ . . . * . . . ■ * * │
	# 6 │ . . . * * * * * * * │
	#   ╰─────────────────────╯
	#  Path Length: 19 nodes
	#  Start: [1,1] | End: [10,6] | Direct Distance: 15 | Path Efficiency: 78%
/*	
	ClearPath()
	
	? "Testing Manhattan path (horizontal first)"
	FindManhattanPath(1, 1, 10, 6)
	Show()
	#-->
	#    1 2 3 4 5 6 7 8 9 0 
	#  ╭────────────────────v╮
	# 1 > * * * * * . . . . . │
	# 2 │ . . . . . . . . . * │
	# 3 │ . . . . . . . . . * │
	# 4 │ . . . . . . . . . * │
	# 5 │ . . . . . . . . . * │
	# 6 │ . . . . . . . . . * │
	#  ╰────────────────────╯
	#  Path Length: 14 nodes
	#  Start: [1,1] | End: [10,6] | Direct Distance: 15 | Path Efficiency: 107%
	
	ClearPath()
	
	? "Testing Manhattan path (vertical first)"
	FindManhattanPathVerticalFirst(1, 1, 10, 6)
	Show()
	#-->
	#    1 2 3 4 5 6 7 8 9 0 
	#  ╭────────────────────v╮
	# 1 > . . . . . . . . . . │
	# 2 │ * . . . . . . . . . │
	# 3 │ * . . . . . . . . . │
	# 4 │ * . . . . . . . . . │
	# 5 │ * . . . . . . . . . │
	# 6 │ * * * * * * * * * * │
	#  ╰────────────────────╯
	#  Path Length: 14 nodes
	#  Start: [1,1] | End: [10,6] | Direct Distance: 15 | Path Efficiency: 107%
	
	ClearPath()
	
	? "Testing Spiral path"
	FindSpiralPath(5, 3, 3)
	Show()
	#-->
	#    1 2 3 4 5 6 7 8 9 0 
	#  ╭────────────────────v╮
	# 1 │ . . . . . . . . . . │
	# 2 │ . . . * * * * . . . │
	# 3 │ . . . * x * * . . . │
	# 4 │ . . . * * * . . . . │
	# 5 │ . . . . . . . . . . │
	# 6 │ . . . . . . . . . . │
	#  ╰────────────────────╯
	#  Path Length: 10 nodes
	#  Start: [5,3] | End: [4,4] | Direct Distance: 2 | Path Efficiency: 20%
	
	ClearPath()
	
	? "Testing ZigZag path"
	FindZigZagPath(1, 1, 10, 6, 2)
	Show()
	#-->
	#    1 2 3 4 5 6 7 8 9 0 
	#  ╭────────────────────v╮
	# 1 > * * . . . . . . . . │
	# 2 │ . * * . . . . . . . │
	# 3 │ . . * * * . . . . . │
	# 4 │ . . . . * * . . . . │
	# 5 │ . . . . . * * * . . │
	# 6 │ . . . . . . . * * * │
	#  ╰────────────────────╯
	#  Path Length: 15 nodes
	#  Start: [1,1] | End: [10,6] | Direct Distance: 15 | Path Efficiency: 100%
*/
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing path analysis and drawing utilities

pr()

o1 = new stzGrid([10, 6])

# Create a zigzag path
o1.AddPathNode(1, 1)
o1.AddPathNode(2, 1)
o1.AddPathNode(3, 2)
o1.AddPathNode(4, 3)
o1.AddPathNode(3, 4)
o1.AddPathNode(2, 5)
o1.AddPathNode(3, 6)
o1.AddPathNode(4, 5)
o1.AddPathNode(5, 4)
o1.AddPathNode(6, 3)
o1.AddPathNode(7, 2)
o1.AddPathNode(8, 1)

o1.ShowPath(TRUE)

? "Path complexity (number of turns): " + o1.PathComplexity()
#--> Path complexity (number of turns): 10

? "Path efficiency: " + o1.PathEfficiency() + "%"
#--> Path efficiency: 70%

# Draw path with custom character
? "Drawing path with '+':"
o1.DrawPath(o1.Path(), "+")
#-->
#    1 2 3 4 5 6 7 8 9 0 
#  ╭────────────────────v╮
# 1 │ + + . . . . . + . . │
# 2 │ . . + . . . + . . . │
# 3 │ . . . + . + . . . . │
# 4 │ . . + . + . . . . . │
# 5 │ . + . + . . . . . . │
# 6 │ . . + . . . . . . . │
#  ╰────────────────────╯
#  Path Length: 12 nodes
#  Start: [1,1] | End: [8,1] | Direct Distance: 7 | Path Efficiency: 58%

# Paint specific nodes
? "Painting specific nodes with '%':"
o1.PaintNodes([[2,2], [3,3], [4,4], [5,5]], "%")
#-->
#    1 2 3 4 5 6 7 8 9 0 
#  ╭────────────────────v╮
# 1 │ . . . . . . . . . . │
# 2 │ . % . . . . . . . . │
# 3 │ . . % . . . . . . . │
# 4 │ . . . % . . . . . . │
# 5 │ . . . . % . . . . . │
# 6 │ . . . . . . . . . . │
#  ╰────────────────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing region management and connectivity

pr()

o1 = new stzGrid([10, 6])

# Create some obstacles to form regions
o1.AddObstacle(3, 1)
o1.AddObstacle(3, 2)
o1.AddObstacle(3, 3)
o1.AddObstacle(3, 4)
o1.AddObstacle(7, 2)
o1.AddObstacle(7, 3)
o1.AddObstacle(7, 4)
o1.AddObstacle(7, 5)
o1.AddObstacle(7, 6)

o1.ShowObstacles(TRUE)
o1.Show()
#-->
#    1 2 3 4 5 6 7 8 9 0 
#  ╭────────────────────v╮
# 1 │ x . # . . . . . . . │
# 2 │ . . # . . . # . . . │
# 3 │ . . # . . . # . . . │
# 4 │ . . # . . . # . . . │
# 5 │ . . . . . . # . . . │
# 6 │ . . . . . . # . . . │
#  ╰────────────────────╯

# Test flood fill
aRegion1 = o1.FloodFill(1, 1)
? "Region 1 size: " + len(aRegion1)
#--> Region 1 size: 12

aRegion2 = o1.FloodFill(5, 3)
? "Region 2 size: " + len(aRegion2)
#--> Region 2 size: 18

# Test connectivity
? "Is (1,1) connected to (2,2)? " + o1.IsConnected(1, 1, 2, 2)
#--> Is (1,1) connected to (2,2)? 1

? "Is (1,1) connected to (4,1)? " + o1.IsConnected(1, 1, 4, 1)
#--> Is (1,1) connected to (4,1)? 0

? "Is (5,5) connected to (8,6)? " + o1.IsConnected(5, 5, 8, 6)
#--> Is (5,5) connected to (8,6)? 1

# Get all connected regions
aRegions = o1.ConnectedRegions()
? "Number of distinct regions: " + len(aRegions)
#--> Number of distinct regions: 2

# Paint each region with different characters
? "Region 1:"
o1.PaintNodes(aRegions[1], "1")
#-->
#    1 2 3 4 5 6 7 8 9 0 
#  ╭────────────────────v╮
# 1 │ 1 1 # . . . . . . . │
# 2 │ 1 1 # . . . # . . . │
# 3 │ 1 1 # . . . # . . . │
# 4 │ 1 1 # . . . # . . . │
# 5 │ 1 1 1 . . . # . . . │
# 6 │ 1 1 1 . . . # . . . │
#  ╰────────────────────╯

? "Region 2:"
o1.PaintNodes(aRegions[2], "2")
#-->
#    1 2 3 4 5 6 7 8 9 0 
#  ╭────────────────────v╮
# 1 │ . . # 2 2 2 2 2 2 2 │
# 2 │ . . # 2 2 2 # 2 2 2 │
# 3 │ . . # 2 2 2 # 2 2 2 │
# 4 │ . . # 2 2 2 # 2 2 2 │
# 5 │ . . . 2 2 2 # 2 2 2 │
# 6 │ . . . 2 2 2 # 2 2 2 │
#  ╰────────────────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing maze generation

pr()

o1 = new stzGrid([15, 8])

# Generate random maze
? "Generating random maze (30% obstacle density):"
o1.GenerateRandomMaze(30)
o1.ShowObstacles(TRUE)
o1.Show()
# Result will be randomized but should have approximately 30% of cells as obstacles

# Clear obstacles
o1.ClearObstacles()

# Generate maze with guaranteed path
? "Generating maze with guaranteed path:"
o1.GenerateMazeWithPath(1, 1, 15, 8)
o1.ShowPath(TRUE)
o1.ShowObstacles(TRUE)
o1.Show()
# Result will show a path from (1,1) to (15,8) with obstacles that don't block the path

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing grid conversion and I/O

pr()

o1 = new stzGrid([5, 5])

# Add obstacles and path
o1.AddObstacle(2, 2)
o1.AddObstacle(3, 3)
o1.AddObstacle(4, 4)

o1.AddPathNode(1, 1)
o1.AddPathNode(1, 2)
o1.AddPathNode(1, 3)
o1.AddPathNode(1, 4)
o1.AddPathNode(1, 5)
o1.AddPathNode(2, 5)
o1.AddPathNode(3, 5)
o1.AddPathNode(4, 5)
o1.AddPathNode(5, 5)

o1.ShowObstacles(TRUE)
o1.ShowPath(TRUE)
o1.MoveTo(5, 5)

o1.Show()
#-->
#    1 2 3 4 5 
#  ╭────────v╮
# 1 │ ○ . . . . │
# 2 │ ○ # . . . │
# 3 │ ○ . # . . │
# 4 │ ○ . . # . │
# 5 │ ○ ○ ○ ○ X │
#  ╰──────────╯
#  Path Length: 9 nodes
#  Start: [1,1] | End: [5,5] | Direct Distance: 8 | Path Efficiency: 88%

# Convert to list of lists
aGrid = o1.ToListOfLists()
? "Grid as list of lists (first row): " + @@(aGrid[1])
#--> Grid as list of lists (first row): [ "○", ".", ".", ".", "." ]

# Convert to string grid
cGrid = o1.ToStringGrid()
? "First 10 characters of string grid: " + left(cGrid, 10)
#--> First 10 characters of string grid: ○....
#○#...

# Export to file and import back
o1.ExportToFile("grid_test.txt")
? "Grid exported to file"
#--> Grid exported to file

o2 = new stzGrid([5, 5])
o2.ImportFromFile("grid_test.txt")
? "Grid imported from file"
#--> Grid imported from file

o2.ShowObstacles(TRUE)
o2.ShowPath(TRUE)
o2.Show()
# Should show the same grid as before

# Clean up test file
remove("grid_test.txt")

pf()
# Executed in almost 0 second(s) in Ring 1.22
