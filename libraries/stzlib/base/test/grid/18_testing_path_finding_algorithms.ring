# Narrative
# --------
# Testing path finding algorithms
#
# Extracted from stzGridTest.ring, block #18.

load "../../stzBase.ring"


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
