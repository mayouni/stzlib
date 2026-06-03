# Narrative
# --------
# Example 1.2: Path with Choice - A* Picks Optimal
#
# Extracted from stzgraphplannertest.ring, block #3.

load "../../stzBase.ring"


`
  CONCEPT: When multiple paths exist, A* explores smartly
  
  Graph structure:
       A
      / \
    20   5    ← A can go to B (expensive) or C (cheap)
    /     \
   B       C
    \     /
     5   10   ← Both routes lead to D
      \ /
       D
  
  Possible routes:
  - A -> B -> D: cost = 20 + 5 = 25
  - A -> C -> D: cost = 5 + 10 = 15 ✓ (optimal)
  
  A* will find the 15-cost route because it tracks
  cumulative cost and uses that to guide exploration.
`

pr()

# Create a graph object

oGraph = new stzGraph("diamond")
oGraph {
	AddNodes([ "A", "B", "C", "D" ])
	
	# Two routes from A
	AddEdgeXTT("A", "B", "slow_road", [:distance = 20])
	AddEdgeXTT("A", "C", "fast_road", [:distance = 5])
	
	# Both converge at D
	AddEdgeXTT("B", "D", "road", [:distance = 5])
	AddEdgeXTT("C", "D", "road", [:distance = 10])

}

# Make some planning on the graph created

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {

	# Make a named plan (you can make many)
	AddPlan('optimal_path')

	# Define the path and the planning request
	Walk(:From = "A", :To = "D")
	Minimizing("distance")

	# Run the plan
	Execute()

	# Get some insights of the plan

	? Cost() # Or CostXT("optimal_path")
	#--> 15 (not 25! A* found the cheaper route)

	? @@( Route() ) # Or StatesXT("optimal_path")
	#--> [ "a", "c", "d" ]
	# Took the fast_road to C, then to D

	? @@NL( Actions() ) # Or ActionsXT("optimal_path")
	#--> Full action breakdown showing each transition and its cost
	# [
	# 	[ [ "from", "a" ], [ "to", "c" ], [ "cost", 5 ] ],
	# 	[ [ "from", "c" ], [ "to", "d" ], [ "cost", 10 ] ]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
