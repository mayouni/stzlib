# Narrative
# --------
# Example 2.1: RPG Quest - Find ANY Treasure Worth 1000+ Gold
#
# Extracted from stzgraphplannertest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

`  
  CONCEPT: Sometimes you don't know the exact destination,
           you just know what conditions it must satisfy.
  
  This is GOAL-BASED SEARCH: Instead of specifying a target
  node, you provide a function that returns TRUE when the
  goal is reached.
  
  World map:
                     Castle (800 gold)
                    /
    Village ------ Forest (500 gold)
                    \
                     Cave (800 gold, has key)
                      \
                       Dungeon (1500 gold)
  
  Goal: Find ANY location with gold >= 1000
  
  The planner will explore paths and stop as soon as it
  reaches a node satisfying the condition. It still
  minimizes danger, so it takes the safest route to
  the first qualifying treasure.
`

pr()

oGraph = new stzGraph("rpg_world")
oGraph {
	AddNodeXTT("village", "Starting Village", [
		:gold = 0,
		:hasKey = FALSE,
		:danger = 0
	])
	
	AddNodeXTT("forest", "Dark Forest", [
		:gold = 500,
		:hasKey = FALSE,
		:danger = 3
	])
	
	AddNodeXTT("cave", "Mysterious Cave", [
		:gold = 800,
		:hasKey = TRUE,
		:danger = 5
	])
	
	AddNodeXTT("dungeon", "Ancient Dungeon", [
		:gold = 1500,  # This qualifies!
		:hasKey = FALSE,
		:danger = 8
	])
	
	AddNodeXTT("castle", "Abandoned Castle", [
		:gold = 800,  # Less than 1000, doesn't qualify
		:hasKey = FALSE,
		:danger = 6
	])
	
	# Edge costs represent danger level
	AddEdgeXTT("village", "forest", "path", [:danger = 2])
	AddEdgeXTT("forest", "cave", "path", [:danger = 3])
	AddEdgeXTT("forest", "dungeon", "path", [:danger = 7])
	AddEdgeXTT("village", "castle", "path", [:danger = 5])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {

	AddPlan("rpg_plan")

	Walk(
		:FromNode = "village",
		:UntilYouReachF = func(node) {
			# Called for each node explored
			# Return TRUE when this is an acceptable goal
			return node[:properties][:gold] >= 1000
		}
	)

	Minimizing(:for = "danger")  # Still optimize for safety
	Execute()

	? Cost()
	#--> 9 (danger: 2 to forest, 7 to dungeon)

	? @@( Route() )
	#--> [ "village", "forest", "dungeon" ]
	# Went to dungeon because it's the closest location with 1000+ gold

	? @@NL( Actions() )
	#--> Action sequence showing the quest path
	# [
	# 	[ [ "from", "village" ], [ "to", "forest" ], [ "cost", 2 ] ],
	# 	[ [ "from", "forest" ], [ "to", "dungeon" ], [ "cost", 7 ] ]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
