# Narrative
# --------
# Example 2.2: Treasure Hunt - Multi-Condition Goal
#
# Extracted from stzgraphplannertest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`
  CONCEPT: Goal functions can check complex conditions
  
  This example shows a limitation: the planner finds the
  fastest route to the "treasury" node, but doesn't track
  cumulative properties along the path (like total gold
  collected or whether key was found).
  
  For true state accumulation (tracking inventory as you
  move), you'd need to encode accumulated state into node
  IDs (e.g., "vault_haskey_1000gold") which explodes the
  graph size. This is the "state space explosion" problem
  in planning.
  
  Here we simplify: just reach the treasury by fastest route.
`
pr()

oGraph = new stzGraph("treasure_hunt")
oGraph {
	AddNodeXTT("start", "Town Square", [
		:gold = 0,
		:hasKey = FALSE
	])
	
	AddNodeXTT("shop", "Merchant Shop", [
		:gold = 300,
		:hasKey = FALSE
	])
	
	AddNodeXTT("crypt", "Old Crypt", [
		:gold = 200,
		:hasKey = TRUE  # Key location
	])
	
	AddNodeXTT("vault", "Royal Vault", [
		:gold = 800,
		:hasKey = FALSE
	])
	
	AddNodeXTT("treasury", "Treasury Room", [
		:gold = 1000,
		:hasKey = FALSE
	])
	
	AddEdgeXTT("start", "shop", "walk", [:time = 5])
	AddEdgeXTT("start", "crypt", "walk", [:time = 10])
	AddEdgeXTT("shop", "vault", "walk", [:time = 8])
	AddEdgeXTT("crypt", "vault", "walk", [:time = 12])
	AddEdgeXTT("vault", "treasury", "walk", [:time = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("multi_goal_plan")

	Walk(
		:FromNode = "start",
		:UntilYouReachF = func(node) {
			# Simplified: just reach treasury
			return node[:id] = "treasury"
		}
	)

	Minimizing("time")
	Execute()

	? Cost()
	#--> 28 (5 + 8 + 15, via shop route)

	? @@( Route() )
	#--> [ "start", "shop", "vault", "treasury" ]
	# Skipped crypt because shop route is faster

	? @@NL( Actions() )
	#-->
	# [
	# 	[ [ "from", "start" ], [ "to", "shop" ], [ "cost", 5 ] ],
	# 	[ [ "from", "shop" ], [ "to", "vault" ], [ "cost", 8 ] ],
	# 	[ [ "from", "vault" ], [ "to", "treasury" ], [ "cost", 15 ] ]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 3: WAREHOUSE LOGISTICS            #
#============================================#
