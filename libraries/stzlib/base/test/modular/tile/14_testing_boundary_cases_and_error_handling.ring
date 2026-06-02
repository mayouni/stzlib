# Narrative
# --------
# Testing boundary cases and error handling
#
# Extracted from stzTileTest.ring, block #14.

load "../../../stzBase.ring"

pr()

o1 = new stzTile([6, 4])
? @@( o1.SizeXT() )
#--> [ 6, 4 ]

# Try to move beyond upper-left boundary (should stay at starting position)
o1.MoveLeftNCells(1)
? @@(o1.Position())
#--> [ 1, 1 ]

o1.MoveUpNCells(1)
? @@(o1.Position())
#--> [ 1, 1 ]

# Move to lower-right corner
o1.MoveToCell(6, 4)
? @@(o1.Position())
#--> [ 6, 4 ]

# Try to move beyond lower-right boundary (should stay at corner)
o1.MoveRightNCells(1)
? @@(o1.Position())
#--> [ 6, 4 ]

o1.MoveDownNCells(1)
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
	2.3. Setting path-related characters (path, current, empty)

3. Pathfinding Algorithms
	3.1. A* algorithm (ShortestPath)
	3.2. Manhattan path (horizontal/vertical first)
	3.3. Spiral path generation
	3.4. ZigZag path creation

4. Path Analysis
	4.1. Complexity measurement (number of turns)
	4.2. Efficiency calculation
	4.3. Custom path drawing
	4.4. Painting specific Cells

5. Region Management
	5.1. Flood fill algorithm
	5.2. Connectivity testing
	5.3. Finding connected regions

6. Maze Generation
	6.1. Random maze with specified density
	6.2. Maze with guaranteed path

7. Tile Conversion and I/O
	7.1. Converting to list of lists
	7.2. String Tile representation
	7.3. File export/import

*/
