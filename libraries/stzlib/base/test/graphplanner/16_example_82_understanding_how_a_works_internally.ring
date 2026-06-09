# Narrative
# --------
# Example 8.2: Understanding How A* Works Internally
#
# Extracted from stzgraphplannertest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

  
`
  CONCEPT: A* balances actual cost vs estimated remaining cost
  
  Given this graph:
    A --1--> B --5--> D
    |                 ^
    4                 1
    v                 |
    C ----------------+
  
  A* maintains: f(n) = g(n) + h(n)
  - g(n) = actual cost so far
  - h(n) = estimated cost to goal
  - f(n) = total estimated cost
  
  At A: Explore B (g=1) and C (g=4)
  At B: Can reach D with g=1+5=6
  At C: Can reach D with g=4+1=5 ✓ (better!)
  
  A* discovers C->D is better even though B looked
  cheaper initially. This is the beauty of A*!
`

pr()

oGraph = new stzGraph("demo")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	AddNode("D")
	
	AddEdgeXTT("A", "B", "path1", [:cost = 1])
	AddEdgeXTT("A", "C", "path2", [:cost = 4])
	AddEdgeXTT("B", "D", "path3", [:cost = 5])
	AddEdgeXTT("C", "D", "path4", [:cost = 1])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("demo_plan")
	Walk(:From = "A", :To = "D")
	Minimizing("cost")
	Execute()

	? Cost()
	#--> 5 (A->C->D, not A->B->D which would be 6)

	? @@( Route() )
	#--> [ "a", "c", "d" ]
	# A* correctly chose the C route even though B looked cheaper at first
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 9: PLAN EXPLANATION               #
#============================================#
