# Narrative
# --------
# Testing path management
#
# Extracted from stzGridTest.ring, block #17.

load "../../stzBase.ring"


pr()

StzGridQ([8, 6]) {

	# Add some obstacles

	AddObstacles([ [3, 2], [3, 3], [3, 4], [5, 2], [5, 3], [5, 4] ])
	
	# Create a path manually

	AddPath([

		[1, 1], [2, 1],		[4, 1], [5, 1], [6, 1],
			[2, 2],	   	[4, 2],		[6, 2],
			[2, 3],	   	[4, 3],		[6, 3],
			[2, 4],	   	[4, 4],   	[6, 4], [7, 4], [8, 4], 
			[2, 5],	[3, 5],	[4, 5]    
					      	
	])
	
	# Path length

	? PathLength()
	#--> 19
	
	# Show the grid with path

	MoveTo(8, 4)
	Show()
	#-->
	`
	    1 2 3 4 5 6 7 8 
	  ╭───────────────v─╮
	1 │ ○ ○ . ○ ○ ○ . . │
	2 │ . ○ ■ ○ ■ ○ . . │
	3 │ . ○ ■ ○ ■ ○ . . │
	4 > . ○ ■ ○ ■ ○ ○ x │
	5 │ . ○ ○ ○ . . . . │
	6 │ . . . . . . . . │
	  ╰─────────────────╯
	`

	? PathEfficiency() # in %
	#--> 38.89

	# Clear path

	ClearPath()
	? PathLength()
	#--> 0

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
