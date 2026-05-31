# Narrative
# --------
# Example 10.1: When to Use A* vs Goal-Based Search
#
# Extracted from stzgraphplannertest.ring, block #18.

load "../../../stzBase.ring"

`
  CONCEPT: Choose the right algorithm for your problem
  
  A* PATHFINDING:
  - Use when: You know exactly where you want to go
  - Example: GPS navigation from home to office
  - Benefit: Guaranteed optimal path
  
  GOAL-BASED SEARCH:
  - Use when: You know what you're looking for, not where
  - Example: Find ANY gas station, don't care which one
  - Benefit: Stops as soon as condition is met (faster)
  
  This example shows both approaches yielding same result
  when there's only one node satisfying the goal.
`

pr()

oGraph = new stzGraph("rpg")
oGraph {
	AddNodeXT("home", "Home Village")
	AddNodeXT("town", "Market Town")
	AddNodeXT("cave", "Dark Cave")
	AddNodeXT("chest", "Treasure Chest")
	
	SetNodeProperty("chest", "has_treasure", TRUE)
	
	AddEdgeXTT("home", "town", "road", [:distance = 10])
	AddEdgeXTT("town", "cave", "path", [:distance = 15])
	AddEdgeXTT("cave", "chest", "tunnel", [:distance = 5])
}

oPlanner = new stzGraphPlanner(oGraph)

# Approach 1: A* with exact destination
oPlanner {
	AddPlan("exact_dest")
	Walk(:From = "home", :To = "chest")  # Know exact location
	Minimizing("distance")
	Execute()

	? Cost()
	#--> 30

	? @@( Route() )
	#--> [ "home", "town", "cave", "chest" ]
}

# Approach 2: Goal-based search for condition
oPlanner {
	AddPlan("condition_based")
	Walk(
		:From = "home",
		:UntilYouReachF = func(node) {
			return node[:properties][:has_treasure] = TRUE
		}
	)
	Minimizing("distance")
	Execute()

	? Cost()
	#--> 30 (same result)

	? @@( Route() )
	#--> [ "home", "town", "cave", "chest" ]

	# ~> Both approaches work! Choose based on whether you know the exact target.
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=====================================#
#  SECTION 11: OPTIMIZATION PROFILES  #
#=====================================#
