# Narrative
# --------
# Example 8.1: Spatial Heuristics - Smarter Search
#
# Extracted from stzgraphplannertest.ring, block #15.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


`
  CONCEPT: Euclidean distance guides A* exploration
  
  When nodes have x,y coordinates, the planner automatically
  uses Euclidean distance as a heuristic. This helps A*
  explore toward the goal instead of randomly.
  
  Without heuristic: Might explore all 16 nodes
  With Euclidean heuristic: Explores ~7 nodes (toward goal)
  
  This is the "A" in A* - the heuristic makes it "informed"!
`

pr()

oGraph = new stzGraph("spatial")
oGraph {
	# Create 4x4 grid (16 nodes)
	for y = 0 to 3
		for x = 0 to 3
			cId = "p" + x + "_" + y
			AddNodeXTT(cId, "Point(" + x + "," + y + ")", [
				:x = x * 10,  # Spatial coordinate
				:y = y * 10   # Spatial coordinate
			])
		next
	next
	
	# Connect adjacent cells (right and down)
	for y = 0 to 3
		for x = 0 to 3
			cId = "p" + x + "_" + y
			
			if x < 3
				cRight = "p" + (x+1) + "_" + y
				AddEdgeXTT(cId, cRight, "h", [:cost = 10])
			ok
			
			if y < 3
				cDown = "p" + x + "_" + (y+1)
				AddEdgeXTT(cId, cDown, "v", [:cost = 10])
			ok
		next
	next
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Navigate from bottom-left to top-right
	AddPlan("spatial_nav")
	Walk(:From = "p0_0", :To = "p3_3")
	Minimizing("cost")
	Execute()

	? Cost()
	#--> 60 (6 moves × 10 cost each)

	? len(Route())
	#--> 7 (start + 6 moves)

	? @@( Route() )
	#--> [ "p0_0", "p1_0", "p2_0", "p3_0", "p3_1", "p3_2", "p3_3" ]
	# Went right-right-right, then down-down-down
	# Euclidean heuristic guided toward goal efficiently!
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
