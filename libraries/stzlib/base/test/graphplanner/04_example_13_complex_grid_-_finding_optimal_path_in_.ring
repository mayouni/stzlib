# Narrative
# --------
# Example 1.3: Complex Grid - Finding Optimal Path in Maze
#
# Extracted from stzgraphplannertest.ring, block #4.

load "../../stzBase.ring"


`
  CONCEPT: A* shines when there are many possible routes
  
  Grid layout with edge costs:
  
    1 --10-- 2 --10-- 3
    |        |        |
   10        1       10     ← Middle row has cheap horizontal paths!
    |        |        |
    4 ---1-- 5 ---1-- 6
    |        |        |
   10       10       10
    |        |        |
    7 --10-- 8 --10-- 9
  
  Naive route (right edges): 1->2->3->6->9 = 10+10+10+10 = 40
  Optimal route (drop to middle): 1->2->5->6->9 = 10+1+1+10 = 22
  
  A* will discover the "middle corridor" strategy automatically!
`

pr()

oGraph = new stzGraph("grid3x3")
oGraph {
	for i = 1 to 9
		AddNodeXTT("n" + i, "Node " + i, [
			:x = ((i-1) % 3) * 10,
			:y = floor((i-1) / 3) * 10
		])
	next
	
	AddEdgeXTT("n1", "n2", "h", [:cost = 10])
	AddEdgeXTT("n2", "n3", "h", [:cost = 10])
	AddEdgeXTT("n4", "n5", "h", [:cost = 1])
	AddEdgeXTT("n5", "n6", "h", [:cost = 1])
	AddEdgeXTT("n7", "n8", "h", [:cost = 10])
	AddEdgeXTT("n8", "n9", "h", [:cost = 10])
	
	AddEdgeXTT("n1", "n4", "v", [:cost = 10])
	AddEdgeXTT("n2", "n5", "v", [:cost = 1])
	AddEdgeXTT("n3", "n6", "v", [:cost = 10])
	AddEdgeXTT("n4", "n7", "v", [:cost = 10])
	AddEdgeXTT("n5", "n8", "v", [:cost = 10])
	AddEdgeXTT("n6", "n9", "v", [:cost = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

oPlanner.AddPlan("grid_path")
oPlanner.Walk("n1", "n9")
oPlanner.Minimize("cost")
oPlanner.Execute()

? oPlanner.Cost()
#--> 22
# (found the middle corridor strategy!)
# Breakdown: 10(n1->n2) + 1(n2->n5) + 1(n5->n6) + 10(n6->n9) = 22

? @@( oPlanner.Route() )
#--> [ "n1", "n2", "n5", "n6", "n9" ]
# Path visualization: Goes right, drops to middle row,
# continues right, drops to bottom

#TODO link with stzGrid for visualisation

pf()
# Executed in 0.02 second(s) in Ring 1.24

#==================================#
#  SECTION 2: GOAL-BASED PLANNING  #
#==================================#
