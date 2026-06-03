# Narrative
# --------
# Testing path analysis and display utilities
#
# Extracted from stzGridTest.ring, block #19.

load "../../stzBase.ring"


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
