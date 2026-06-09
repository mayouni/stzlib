# Narrative
# --------
# Example 13.2: Efficiency Analysis
#
# Extracted from stzgraphplannertest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Understanding search efficiency
  
  Good heuristics explore fewer nodes. This method shows
  the exploration efficiency ratio.
`

pr()

oGraph = new stzGraph("efficiency_test")
oGraph {
	# Create a 3x3 grid
	for y = 0 to 2
		for x = 0 to 2
			cId = "n" + x + "_" + y
			AddNodeXTT(cId, "Node " + x + "," + y, [
				:x = x * 10,
				:y = y * 10
			])
		next
	next
	
	# Connect horizontally and vertically
	for y = 0 to 2
		for x = 0 to 2
			cId = "n" + x + "_" + y
			
			if x < 2
				cRight = "n" + (x+1) + "_" + y
				AddEdgeXTT(cId, cRight, "h", [:distance = 10])
			ok
			
			if y < 2
				cDown = "n" + x + "_" + (y+1)
				AddEdgeXTT(cId, cDown, "v", [:distance = 10])
			ok
		next
	next
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("efficient_path")
	Walk(:From = "n0_0", :To = "n2_2")
	Minimize("distance")
	Execute()

	# EFFICIENCY ANALYSIS
	? @@NL( ExplainEfficiency() ) + NL # Or Efficiency()
	#--> [
	# 	[ "plan", "efficient_path" ],
	# 	[ "nodes_explored", 9 ],
	# 	[ "path_length", 5 ],
	# 	[ "ratio", 1.80 ],
	# 	[ "assessment", "efficient" ]
	# ]
	
	# Path found:
	? @@( Route() )
	#--> [ "n0_0", "n1_0", "n1_1", "n2_1", "n2_2" ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.25

#=======================================#
#  SECTION 14: ALTERNATIVE EXPLORATION  #
#=======================================#
