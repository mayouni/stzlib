# Narrative
# --------
# Example 11.4: The :balanced Profile
#
# Extracted from stzgraphplannertest.ring, block #22.

load "../../stzBase.ring"

`
  CONCEPT: Sometimes you need to balance multiple factors
  
  The :balanced profile considers:
  - time (weight 0.4)
  - cost (weight 0.3)
  - distance (weight 0.3)
  
  Great for general-purpose routing where no single factor dominates.
`

pr()

oGraph = new stzGraph("logistics")
oGraph {
	AddNode("depot")
	AddNode("hub_a")
	AddNode("hub_b")
	AddNode("destination")
	
	# Route A: Fast, expensive, short
	AddEdgeXTT("depot", "hub_a", "express", [
		:time = 10,
		:cost = 50,
		:distance = 15
	])
	AddEdgeXTT("hub_a", "destination", "express", [
		:time = 8,
		:cost = 40,
		:distance = 12
	])
	
	# Route B: Slow, cheap, long
	AddEdgeXTT("depot", "hub_b", "economy", [
		:time = 20,
		:cost = 20,
		:distance = 30
	])
	AddEdgeXTT("hub_b", "destination", "economy", [
		:time = 18,
		:cost = 15,
		:distance = 28
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("balanced_route")
	Walk(:From = "depot", :To = "destination")
	Using(:balanced)  # Balance all factors
	Execute()

	# Chosen route
	? @@( Route() )
	#--> [ "depot", "hub_a", "destination" ]

	? Cost()
	#--> 42.30 (Planner weighs all three factors and chooses best balance)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#===========================================#
#  SECTION 12: COST BREAKDOWN EXPLANATIONS  #
#===========================================#
