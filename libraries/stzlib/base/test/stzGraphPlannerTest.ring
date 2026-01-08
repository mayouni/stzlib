load "../stzbase.ring"

#============================================#
#  stzGraphPlanner - AI PLANNING & PATHFINDING
#============================================#

/*=== WHAT IS GRAPH PLANNING?

`
Imagine you're navigating a city. Each intersection is a NODE (a state),
each street is an EDGE (a transition), and you want to find the best route.
That's graph planning!

CORE CONCEPTS:

1. GRAPH = State Space
   - Nodes represent distinct states (locations, game states, workflow steps)
   - Edges represent valid transitions (roads, actions, processes)
   - Properties store state information (coordinates, costs, conditions)

2. PATHFINDING = Finding Optimal Routes
   - A* Algorithm: Finds shortest path when you know start and goal
   - Goal-Based Search: Finds any state matching a condition
   - Cost Functions: Define what "optimal" means (time, distance, danger)

3. HEURISTICS = Smart Search Guidance
   - Estimate distance to goal without exploring all paths
   - Euclidean distance for spatial problems
   - Domain-specific estimates for other problems
   - Good heuristics = faster planning

WHY USE stzGraphPlanner?

Instead of manually coding search algorithms, you:
1. Build a graph representing your problem space
2. Define what you're optimizing (minimize cost, maximize profit)
3. Let the planner find the optimal solution automatically

REAL-WORLD APPLICATIONS:
- Warehouse robot navigation
- Manufacturing workflow optimization
- Delivery route planning
- Game AI (NPC pathfinding, quest planning)
- Network packet routing
- Supply chain optimization
`

#========================================#
#  SECTION 1: BASIC PATHFINDING WITH A*  #
#========================================#

/*-- Example 1.1: Simple Linear Path

`
  CONCEPT: A* guarantees finding the shortest path
  
  Graph structure:
    A ---10--- B ---10--- C
  
  The path is obvious here, but A* will explore it
  systematically, building up cost as it goes.
`

pr()

oGraph = new stzGraph("linear")
oGraph {
	AddNodeXTT("A", "Start Point", [:x = 0, :y = 0])
	AddNodeXTT("B", "Middle Point", [:x = 10, :y = 0])
	AddNodeXTT("C", "End Point", [:x = 20, :y = 0])
	
	AddEdgeXTT("A", "B", "road", [:distance = 10])
	AddEdgeXTT("B", "C", "road", [:distance = 10])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {

	AddPlan("linear_path") # You can add many plans
	# The current plan is set automatically to the first plan created
	# But you can set it explicitely by SetCurrentPlan(cPlanName)
	# And you can the current plan by CurrentPlan()

	WalkFrom("A", :To = "C")
	Minimizing("distance") # Or MinimizeXT("distance", :InPlan = "linear_path")

	Execute() # Or ExecuteXT("linear_path")

	? Cost()
	#--> 20

	? @@( Route() ) # Or States()
	#--> [ "a", "b", "c" ]

	? Explain()
	#--> Step 1: a -> b (cost: 10)
	#    Step 2: b -> c (cost: 10)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 1.2: Path with Choice - A* Picks Optimal

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

/*--- Example 1.3: Complex Grid - Finding Optimal Path in Maze

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

pf()
# Executed in 0.02 second(s) in Ring 1.24

#==================================#
#  SECTION 2: GOAL-BASED PLANNING  #
#==================================#

/*--- Example 2.1: RPG Quest - Find ANY Treasure Worth 1000+ Gold

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

/*--- Example 2.2: Treasure Hunt - Multi-Condition Goal

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

/*--- Example 3.1: Warehouse Navigation - Discovering Shortcuts
 
`
  CONCEPT: A* automatically discovers shortcuts you define
  
  Warehouse layout:
    entrance -> receiving -> aisle_a -> aisle_b -> storage -> shelf_42
       10         15           12         10         10
  
  But there's a shortcut: receiving -> storage (25)
  
  Long route: 10 + 15 + 12 + 10 + 10 = 57
  Shortcut route: 10 + 25 + 10 = 45 ✓
  
  A* will compare both and choose the shortcut!
`

pr()

oGraph = new stzGraph("warehouse")
oGraph {
	# Node coordinates help with spatial heuristics
	AddNodeXTT("entrance", "Main Entrance", [:x = 0, :y = 0])
	AddNodeXTT("receiving", "Receiving Bay", [:x = 10, :y = 0])
	AddNodeXTT("aisle_a", "Aisle A", [:x = 20, :y = 0])
	AddNodeXTT("aisle_b", "Aisle B", [:x = 20, :y = 10])
	AddNodeXTT("storage", "Cold Storage", [:x = 30, :y = 10])
	AddNodeXTT("shelf_42", "Shelf 42", [:x = 40, :y = 10])
	AddNodeXTT("packing", "Packing Area", [:x = 40, :y = 20])
	AddNodeXTT("shipping", "Shipping Dock", [:x = 50, :y = 20])
	
	# The "normal" route through aisles
	AddEdgeXTT("entrance", "receiving", "hallway", [
		:distance = 10,
		:traffic = "low"
	])
	
	AddEdgeXTT("receiving", "aisle_a", "hallway", [
		:distance = 15,
		:traffic = "high"  # Congested but still on normal route
	])
	
	AddEdgeXTT("aisle_a", "aisle_b", "cross_aisle", [
		:distance = 12,
		:traffic = "low"
	])
	
	AddEdgeXTT("aisle_b", "storage", "hallway", [
		:distance = 10,
		:traffic = "medium"
	])
	
	AddEdgeXTT("storage", "shelf_42", "aisle", [
		:distance = 10,
		:traffic = "low"
	])
	
	AddEdgeXTT("shelf_42", "packing", "hallway", [
		:distance = 15,
		:traffic = "low"
	])
	
	AddEdgeXTT("packing", "shipping", "hallway", [
		:distance = 12,
		:traffic = "medium"
	])
	
	# The SHORTCUT that warehouse workers know about!
	AddEdgeXTT("receiving", "storage", "shortcut", [
		:distance = 25,
		:traffic = "low"
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("shortcut")
	Walk(:FromNode = "entrance", :ToNode = "shelf_42")
	Minimizing(:for = "distance")
	Execute()

	? Cost()
	#--> 45 (used the shortcut!)

	? @@( Route() )
	#--> [ "entrance", "receiving", "storage", "shelf_42" ]
	# Skipped aisle_a and aisle_b entirely
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 3.2: Multi-Stop Delivery

`
  CONCEPT: Simple goal = just reach exit optimally
  
  Note: This doesn't enforce visiting ALL zones, just
  finding the fastest route to exit. For true multi-stop
  optimization (traveling salesman problem), you'd need a
  different approach or chain multiple plans.
`

pr()

oGraph = new stzGraph("delivery_route")
oGraph {
	AddNode("dock")
	AddNode("zone_a")
	AddNode("zone_b")
	AddNode("zone_c")
	AddNode("exit")
	
	# Sequential path through all zones
	AddEdgeXTT("dock", "zone_a", "route", [:time = 5])
	AddEdgeXTT("zone_a", "zone_b", "route", [:time = 3])
	AddEdgeXTT("zone_b", "zone_c", "route", [:time = 4])
	AddEdgeXTT("zone_c", "exit", "route", [:time = 6])
	
	# Alternative shortcuts
	AddEdgeXTT("dock", "zone_b", "route", [:time = 7])  # Skip zone_a
	AddEdgeXTT("zone_a", "zone_c", "route", [:time = 10])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("multi_stop")
	Walk(:FromNode = "dock", :ToNode = "exit")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 17 (skipped zone_a!)

	? @@( Route() )
	#--> [ "dock", "zone_b", "zone_c", "exit" ]
	# Took shortcut directly to zone_b
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 4: MANUFACTURING WORKFLOW         #
#============================================#

/*--- Example 4.1: Production Line Optimization

`
  CONCEPT: Manufacturing often has optional steps
  
  Standard process: raw -> cut -> shape -> polish -> assemble -> finished
  Fast process: raw -> cut -> shape -> assemble -> finished (skip polish!)
  
  The planner will discover that skipping polish saves time.
`

pr()

oGraph = new stzGraph("production_line")
oGraph {
	AddNodeXTT("raw", "Raw Materials", [
		:inventory = 1000,
		:ready = TRUE
	])
	
	AddNodeXTT("cut", "Cutting Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("shape", "Shaping Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("polish", "Polishing Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("assemble", "Assembly Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("finished", "Finished Goods", [
		:inventory = 0,
		:ready = FALSE
	])
	
	# Standard workflow with all steps
	AddEdgeXTT("raw", "cut", "process", [
		:time = 10,
		:workers = 2
	])
	
	AddEdgeXTT("cut", "shape", "process", [
		:time = 15,
		:workers = 3
	])
	
	AddEdgeXTT("shape", "polish", "process", [
		:time = 8,
		:workers = 1
	])
	
	AddEdgeXTT("polish", "assemble", "process", [
		:time = 20,
		:workers = 4
	])
	
	AddEdgeXTT("assemble", "finished", "process", [
		:time = 5,
		:workers = 2
	])
	
	# Alternative: skip polishing for rough finish
	AddEdgeXTT("shape", "assemble", "skip_polish", [
		:time = 2,  # Much faster!
		:workers = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("prod_optim")

	Walk(:FromNode = "raw", :ToNode = "finished")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 32 (skipped polishing!)
	# Breakdown: 10(cut) + 15(shape) + 2(skip_polish) + 5(finish) = 32
	# vs. standard: 10 + 15 + 8 + 20 + 5 = 58
	
	? @@( Route() )
	#--> [ "raw", "cut", "shape", "assemble", "finished" ]
	# No "polish" in the path
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 4.2: Budget Constraints
  
`
  CONCEPT: Different optimization criteria yield different plans
  
  Premium path: start -> process_a -> end (cost: 150, quality: 10)
  Standard path: start -> process_b -> process_c -> end (cost: 75, quality: 7)
  
  When minimizing cost, planner chooses standard path.
`

pr()

oGraph = new stzGraph("budget_production")
oGraph {
	AddNode("start")
	AddNode("process_a")
	AddNode("process_b")
	AddNode("process_c")
	AddNode("end")
	
	# Expensive high-quality route
	AddEdgeXTT("start", "process_a", "premium", [
		:cost = 100,
		:quality = 10
	])
	AddEdgeXTT("process_a", "end", "finish", [
		:cost = 50,
		:quality = 10
	])
	
	# Cheaper standard route
	AddEdgeXTT("start", "process_b", "standard", [
		:cost = 30,
		:quality = 7
	])
	AddEdgeXTT("process_b", "process_c", "continue", [
		:cost = 25,
		:quality = 7
	])
	AddEdgeXTT("process_c", "end", "finish", [
		:cost = 20,
		:quality = 7
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("optim_cost")
	Walk(:From = "start", :To = "end")
	Minimizing("cost")  # Optimize for cost, not quality
	Execute()

	? Cost()
	#--> 75 (chose budget route: 30 + 25 + 20)

	? @@( Route() )
	#--> [ "start", "process_b", "process_c", "end" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 5: NETWORK ROUTING                #
#============================================#

/*--- Example 5.1: Internet Packet Routing - Minimize Latency
  
`
  CONCEPT: Network routing is graph pathfinding
  
  Routers are nodes, connections are edges with latency costs.
  The planner finds the lowest-latency path through the network.
  
  Network topology:
    client -> router1 -> router2 -> cdn -> origin
              5          10         8      15
  
  Alternative: router1 -> cdn (direct, latency 15)
  
  Shorter path exists: client -> router1 -> cdn -> origin
  Total: 5 + 15 + 15 = 35
`

pr()

oGraph = new stzGraph("network")
oGraph {
	AddNodeXTT("client", "Client Device", [:x = 0, :y = 0])
	AddNodeXTT("router1", "Router 1", [:x = 10, :y = 0])
	AddNodeXTT("router2", "Router 2", [:x = 20, :y = 10])
	AddNodeXTT("router3", "Router 3", [:x = 10, :y = 20])
	AddNodeXTT("cdn", "CDN Server", [:x = 30, :y = 10])
	AddNodeXTT("origin", "Origin Server", [:x = 40, :y = 20])
	
	# Standard routing path
	AddEdgeXTT("client", "router1", "link", [:latency = 5])
	AddEdgeXTT("router1", "router2", "link", [:latency = 10])
	AddEdgeXTT("router2", "cdn", "link", [:latency = 8])
	AddEdgeXTT("cdn", "origin", "link", [:latency = 15])
	
	# Alternative slow path
	AddEdgeXTT("router1", "router3", "link", [:latency = 12])
	AddEdgeXTT("router3", "origin", "link", [:latency = 25])
	
	# Fast link directly to CDN
	AddEdgeXTT("router1", "cdn", "fast_link", [:latency = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("network_route")
	Walk(:From = "client", :To = "origin")
	Minimizing("latency")
	Execute()

	? Cost()
	#--> 35 (found fast route through CDN)

	? @@( Route() )
	#--> [ "client", "router1", "cdn", "origin" ]
	# Used direct router1->cdn link, saving 3ms vs. going through router2
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 6: GAME AI - NPC PATHFINDING      #
#============================================#

/*--- Example 6.1: NPC Finds Safest Path
  
`
  CONCEPT: Game AI needs context-aware pathfinding
  
  Open field is fast but dangerous (exposed, no cover).
  Forest route is safer (cover available, less danger).
  
  When minimizing danger, NPC takes the forest route even
  if it's longer. This creates believable AI behavior!
`

pr()

oGraph = new stzGraph("game_world")
oGraph {
	AddNodeXTT("spawn", "Spawn Point", [
		:danger = 0,
		:cover = TRUE
	])
	
	AddNodeXTT("open", "Open Field", [
		:danger = 8,    # Very dangerous!
		:cover = FALSE  # No protection
	])
	
	AddNodeXTT("forest", "Forest", [
		:danger = 3,
		:cover = TRUE
	])
	
	AddNodeXTT("river", "River Crossing", [
		:danger = 5,
		:cover = FALSE
	])
	
	AddNodeXTT("hill", "Hill", [
		:danger = 2,
		:cover = TRUE
	])
	
	AddNodeXTT("objective", "Objective Point", [
		:danger = 0,
		:cover = TRUE
	])
	
	# Direct but dangerous route
	AddEdgeXTT("spawn", "open", "direct", [:danger = 7])
	AddEdgeXTT("open", "objective", "direct", [:danger = 6])
	# Total danger: 7 + 6 = 13
	
	# Safer route through forest
	AddEdgeXTT("spawn", "forest", "safe", [:danger = 2])
	AddEdgeXTT("forest", "river", "path", [:danger = 3])
	AddEdgeXTT("river", "hill", "path", [:danger = 4])
	AddEdgeXTT("hill", "objective", "path", [:danger = 2])
	# Total danger: 2 + 3 + 4 + 2 = 11 ✓
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("safe_path")
	Walk(:From = "spawn", :To = "objective")
	Minimizing("danger")
	Execute()

	? Cost()
	#--> 11 (safer forest route, not 13 from open field)

	? @@( Route() )
	#--> [ "spawn", "forest", "river", "hill", "objective" ]
	# NPC wisely avoided the dangerous open field
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  SECTION 7: REAL-WORLD SCENARIOS           #
#============================================#

/*--- Example 7.1: Last-Mile Delivery Optimization

`
  CONCEPT: Real-world routing considers multiple factors
  
  Like Amazon delivery routing: find fastest path from
  warehouse to customer considering traffic conditions.
  
  Route A: warehouse -> suburb_a -> downtown (heavy traffic on suburb_a->downtown)
  Route B: warehouse -> suburb_b -> downtown (medium traffic, slightly longer distance)
  
  When minimizing time, planner weighs trade-offs automatically.
`

pr()

oGraph = new stzGraph("delivery")
oGraph {
	AddNodeXTT("warehouse", "Fulfillment Center", [
		:packages = 100,
		:x = 0,
		:y = 0
	])
	
	AddNodeXTT("suburb_a", "Suburb A", [
		:packages = 0,
		:x = 10,
		:y = 5
	])
	
	AddNodeXTT("suburb_b", "Suburb B", [
		:packages = 0,
		:x = 15,
		:y = 10
	])
	
	AddNodeXTT("downtown", "Downtown Hub", [
		:packages = 0,
		:x = 20,
		:y = 15
	])
	
	AddNodeXTT("customer", "Customer Address", [
		:packages = 0,
		:x = 25,
		:y = 20
	])
	
	# Route through suburb_a (shorter but may have traffic)
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:traffic = "light",
		:time = 12  # distance * 1
	])
	
	AddEdgeXTT("suburb_a", "downtown", "road", [
		:distance = 15,
		:traffic = "heavy",
		:time = 30  # distance * 2
	])
	
	# Route through suburb_b (longer but better traffic)
	AddEdgeXTT("warehouse", "suburb_b", "highway", [
		:distance = 18,
		:traffic = "light",
		:time = 18  # distance * 1
	])
	
	AddEdgeXTT("suburb_b", "downtown", "road", [
		:distance = 10,
		:traffic = "medium",
		:time = 15  # distance * 1.5
	])
	
	# Final leg to customer
	AddEdgeXTT("downtown", "customer", "local", [
		:distance = 8,
		:traffic = "light",
		:time = 8  # distance * 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("delivery_plan")
	Walk(:From = "warehouse", :To = "customer")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 41

	? @@( Route() )
	#--> [ "warehouse", "suburb_b", "downtown", "customer" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 7.2: Emergency Response - Every Second Counts

`
  CONCEPT: Critical routing where optimization matters most
  
  Fire truck needs fastest route to emergency. Main street
  has a congested bridge (8 minutes), but back road through
  hospital is faster overall.
  
  Route A: station -> main_st -> bridge -> emergency (3 + 8 + 5 = 16)
  Route B: station -> back_road -> hospital -> emergency (5 + 4 + 3 = 12) ✓
  
  4 minutes saved can mean saving lives!
`

pr()

oGraph = new stzGraph("emergency")
oGraph {
	AddNodeXTT("station", "Fire Station", [
		:emergency = TRUE,
		:priority = 10
	])
	
	AddNodeXTT("main_st", "Main Street", [
		:congestion = 5
	])
	
	AddNodeXTT("bridge", "River Bridge", [
		:congestion = 8
	])
	
	AddNodeXTT("back_road", "Back Road", [
		:congestion = 2
	])
	
	AddNodeXTT("hospital", "City Hospital", [
		:congestion = 6
	])
	
	AddNodeXTT("emergency_site", "Emergency Location", [
		:emergency = TRUE,
		:priority = 10
	])
	
	# Main street route (congested bridge bottleneck)
	AddEdgeXTT("station", "main_st", "route", [
		:time = 3,
		:sirens = TRUE
	])
	
	AddEdgeXTT("main_st", "bridge", "route", [
		:time = 8,  # Slow due to traffic
		:sirens = TRUE
	])
	
	# Back road route (less congested)
	AddEdgeXTT("station", "back_road", "route", [
		:time = 5,
		:sirens = TRUE
	])
	
	AddEdgeXTT("back_road", "hospital", "route", [
		:time = 4,
		:sirens = TRUE
	])
	
	# Final legs to emergency site
	AddEdgeXTT("bridge", "emergency_site", "route", [
		:time = 5,
		:sirens = TRUE
	])
	
	AddEdgeXTT("hospital", "emergency_site", "route", [
		:time = 3,
		:sirens = TRUE
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("emergency_response")
	Walk(:From = "station", :To = "emergency_site")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 12 (back road route saves 4 minutes!)

	? @@( Route() )
	#--> [ "station", "back_road", "hospital", "emergency_site" ]
	# Avoided congested bridge, potentially saving lives
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 8: ADVANCED FEATURES              #
#============================================#

/*--- Example 8.1: Spatial Heuristics - Smarter Search

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

/*--- Example 8.2: Understanding How A* Works Internally
  
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

/*--- Example 9.1: Supply Chain Planning with Explanation
  
`
  CONCEPT: Plans include human-readable explanations
  
  The Explain() method generates a narrative of the plan,
  useful for debugging and understanding decisions.
`

pr()

oGraph = new stzGraph("supply_chain")
oGraph {
	AddNodeXT("supplier", "Raw Material Supplier")
	AddNodeXT("factory", "Manufacturing Plant")
	AddNodeXT("warehouse", "Distribution Center")
	AddNodeXT("retail", "Retail Store")
	
	AddEdgeXTT("supplier", "factory", "shipping", [
		:cost = 1000,
		:days = 3
	])
	
	AddEdgeXTT("factory", "warehouse", "shipping", [
		:cost = 500,
		:days = 2
	])
	
	AddEdgeXTT("warehouse", "retail", "delivery", [
		:cost = 200,
		:days = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("supply_chain_plan")
	Walk(:From = "supplier", :To = "retail")
	Minimizing("cost")
	Execute()

	? Cost()
	#--> 1700 	~> (1000 + 500 + 200)

	? Explain()
	#--> (Human-readable step-by-step explanation):
	# Step 1: supplier -> factory (cost: 1000)
	# Step 2: factory -> warehouse (cost: 500)
	# Step 3: warehouse -> retail (cost: 200)

	? @@( Route() )
	#--> [ "supplier", "factory", "warehouse", "retail" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 10: ALGORITHM COMPARISON          #
#============================================#

/*--- Example 10.1: When to Use A* vs Goal-Based Search
  
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
	# Both approaches work! Choose based on whether you know the exact target.
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=====================================#
#  SECTION 11: OPTIMIZATION PROFILES  #
#=====================================#

/*--- Example 11.1: Using the :fastest Profile
`
  CONCEPT: Profiles encode common optimization strategies
  
  The :fastest profile optimizes for:
  - time (weight 0.7)
  - distance (weight 0.3)
  
  This is perfect for delivery services during rush hour.
`

pr()

oGraph = new stzGraph("delivery_network")
oGraph {
	AddNodeXTT("warehouse", "Main Warehouse", [:x = 0, :y = 0])
	AddNodeXTT("suburb_a", "Suburb A", [:x = 10, :y = 5])
	AddNodeXTT("suburb_b", "Suburb B", [:x = 15, :y = 10])
	AddNodeXTT("customer", "Customer Location", [:x = 25, :y = 20])
	
	# Route via suburb_a: short distance, heavy traffic
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:time = 25,  # Heavy traffic
		:cost = 10
	])
	AddEdgeXTT("suburb_a", "customer", "road", [
		:distance = 18,
		:time = 20,
		:cost = 15
	])
	
	# Route via suburb_b: longer distance, light traffic
	AddEdgeXTT("warehouse", "suburb_b", "backroad", [
		:distance = 20,
		:time = 20,  # Light traffic
		:cost = 8
	])
	AddEdgeXTT("suburb_b", "customer", "highway", [
		:distance = 15,
		:time = 15,
		:cost = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("fast_delivery")
	Walk(:From = "warehouse", :To = "customer")
	Using(:fastest)  # Uses the predefined :fastest profile
	Execute()

	? Cost()
	#--> 25 (Lower cost due to time optimization)
	
	? @@( Route() ) + NL
	#--> [ "warehouse", "suburb_b", "customer" ]
	# Chose suburb_b route (lighter traffic)
	
	? Explain()
	#--> Step 1: warehouse -> suburb_b (cost: 14.0)
	#    Step 2: suburb_b -> customer (cost: 13.5)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Example 11.2: Comparing :fastest vs :cheapest Profiles
`
  CONCEPT: Different profiles optimize for different goals
  
  Same graph, same start/end points - but different strategies
  lead to different routes and different trade-offs.
`

pr()

oGraph = new stzGraph("delivery_network")
oGraph {
	AddNodeXTT("warehouse", "Main Warehouse", [:x = 0, :y = 0])
	AddNodeXTT("suburb_a", "Suburb A", [:x = 10, :y = 5])
	AddNodeXTT("suburb_b", "Suburb B", [:x = 15, :y = 10])
	AddNodeXTT("customer", "Customer Location", [:x = 25, :y = 20])
	
	# Route via suburb_a: short distance, heavy traffic
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:time = 25,  # Heavy traffic
		:cost = 10
	])
	AddEdgeXTT("suburb_a", "customer", "road", [
		:distance = 18,
		:time = 20,
		:cost = 15
	])
	
	# Route via suburb_b: longer distance, light traffic
	AddEdgeXTT("warehouse", "suburb_b", "backroad", [
		:distance = 20,
		:time = 20,  # Light traffic
		:cost = 8
	])
	AddEdgeXTT("suburb_b", "customer", "highway", [
		:distance = 15,
		:time = 15,
		:cost = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan 1: Optimize for speed
	AddPlan("speed_focused")
	SetCurrentPlan("speed_focused")
	Walk(:From = "warehouse", :To = "customer")
	Using(:fastest)
	Execute()
	
	# Plan 2: Optimize for cost
	AddPlan("cost_focused")
	SetCurrentPlan("cost_focused")
	Walk(:From = "warehouse", :To = "customer")
	Using(:cheapest)
	Execute()
	
	# Compare the two strategies
	SetCurrentPlan("speed_focused")
	? ExplainDifference("cost_focused")
	#-->
	# PATH ANALYSIS:
	# Plans use SAME route
	#   [ "warehouse", "suburb_b", "customer" ]
	# 
	# COST ANALYSIS:
	#   Plan 1 cost: 35
	#   Plan 2 cost: 20
	#   ✓ Plan 2 is cheaper

}

pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Example 11.3: The :safest Profile for Emergency Routes
`
  CONCEPT: Safety-critical applications need risk minimization
  
  The :safest profile prioritizes:
  - danger (weight 0.8)
  - risk (weight 0.2)
  
  Perfect for ambulance routing through dangerous areas.
`

pr()

oGraph = new stzGraph("city_emergency")
oGraph {
	AddNode("hospital")
	AddNode("downtown")
	AddNode("industrial")
	AddNode("emergency_site")
	
	# Fast but dangerous route through downtown
	AddEdgeXTT("hospital", "downtown", "main_road", [
		:time = 5,
		:danger = 8,  # High crime area
		:risk = 7
	])
	AddEdgeXTT("downtown", "emergency_site", "street", [
		:time = 4,
		:danger = 9,
		:risk = 8
	])
	
	# Slower but safer route through industrial
	AddEdgeXTT("hospital", "industrial", "route", [
		:time = 8,
		:danger = 2,  # Safe area
		:risk = 1
	])
	AddEdgeXTT("industrial", "emergency_site", "route", [
		:time = 7,
		:danger = 3,
		:risk = 2
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("safe_response")
	Walk(:From = "hospital", :To = "emergency_site")
	Using(:safest)  # Prioritize crew safety
	Execute()

	# Route chosen
	? @@( Route() )
	#--> [ "hospital", "industrial", "emergency_site" ]
	# Avoided dangerous downtown route
	
	? Cost()
	#--> 5 (Lower danger cost)
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Example 11.4: The :balanced Profile
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
	#--> 18 (Planner weighs all three factors and chooses best balance)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#===========================================#
#  SECTION 12: COST BREAKDOWN EXPLANATIONS  #
#===========================================#

/*--- Example 12.1: Understanding Where Cost Comes From
`
  CONCEPT: Transparency through detailed breakdowns
  
  When a plan has high cost, you need to see exactly where
  that cost is accumulated step by step.
`

pr()

oGraph = new stzGraph("complex_route")
oGraph {
	AddNode("start")
	AddNode("point_a")
	AddNode("point_b")
	AddNode("end")
	
	AddEdgeXTT("start", "point_a", "road", [
		:distance = 10,
		:traffic = 2
	])
	AddEdgeXTT("point_a", "point_b", "road", [
		:distance = 15,
		:traffic = 8  # Heavy congestion here!
	])
	AddEdgeXTT("point_b", "end", "road", [
		:distance = 5,
		:traffic = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("route_analysis")
	Walk(:From = "start", :To = "end")
	Minimize("distance")
	Minimize("traffic")
	Execute()

	? ExplainCostBreakdown()
	#--> === COST BREAKDOWN ===
	#    
	#    Step 1: start -> point_a
	#      • distance: 10 × 1 (minimize) = 10
	#      • traffic: 2 × 1 (minimize) = 2
	#      Total: 12
	#    
	#    Step 2: point_a -> point_b
	#      • distance: 15 × 1 (minimize) = 15
	#      • traffic: 8 × 1 (minimize) = 8
	#      Total: 23
	#    
	#    Step 3: point_b -> end
	#      • distance: 5 × 1 (minimize) = 5
	#      • traffic: 1 × 1 (minimize) = 1
	#      Total: 6
	
	# ~> Now you can see: Step 2 is the bottleneck (traffic = 8)!
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Example 12.2: Profile Cost Breakdown
`
  CONCEPT: Profiles with weighted criteria show how weights affect cost
  
  When using :fastest profile, see how time and distance
  contributions are weighted differently (0.7 vs 0.3).
`

pr()

oGraph = new stzGraph("weighted_route")
oGraph {
	AddNode("origin")
	AddNode("waypoint")
	AddNode("goal")
	
	AddEdgeXTT("origin", "waypoint", "path", [
		:time = 20,
		:distance = 10
	])
	AddEdgeXTT("waypoint", "goal", "path", [
		:time = 15,
		:distance = 25
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("weighted_analysis")
	Walk(:From = "origin", :To = "goal")
	Using(:fastest)  # time=0.7, distance=0.3
	Execute()

	? ExplainCostBreakdown()
	#-->
	# Step 1: origin -> waypoint
	#   • time: 20 × 0.70 (minimize) = 14
	#   • distance: 10 × 0.30 (minimize) = 3
	#   Total: 17
	# 
	# Step 2: waypoint -> goal
	#   • time: 15 × 0.70 (minimize) = 10.50
	#   • distance: 25 × 0.30 (minimize) = 7.50
	#   Total: 18

}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#==============================#
#  SECTION 13: EXPLAINING WHY  #
#==============================#

/*--- Example 13.1: Why Was This Route Chosen?
`
  CONCEPT: Plans should explain their reasoning
  
  When the planner makes a decision, you should be able to
  ask "why?" and get a clear answer about the optimization
  criteria and exploration process.
`

pr()

oGraph = new stzGraph("decision")
oGraph {
	AddNode("base")
	AddNode("option_a")
	AddNode("option_b")
	AddNode("target")
	
	AddEdgeXTT("base", "option_a", "path", [:cost = 10])
	AddEdgeXTT("base", "option_b", "path", [:cost = 5])
	AddEdgeXTT("option_a", "target", "path", [:cost = 3])
	AddEdgeXTT("option_b", "target", "path", [:cost = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("decision_route")
	Walk(:From = "base", :To = "target")
	Minimize("cost")
	Execute()

	# WHY THIS ROUTE?
	? ExplainWhy("route") + NL
	#--> This route was selected because:
	#    • Total cost: 13
	#    • Explored 4 nodes to find it
	#    • Optimized for: minimize cost
	
	# Chosen path:
	? @@( Route() )
	#--> [ "base", "option_a", "target" ]

	# ~> Chose option_a even though option_b starts cheaper,
	# because total route through option_a is cheaper (13 vs 20)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 13.2: Efficiency Analysis
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
	? ExplainEfficiency() + NL
	#--> Explored 9 nodes for 5-node path (1.80:1 ratio - efficient)
	
	# Path found:
	? @@( Route() )
	#--> [ "n0_0", "n1_0", "n1_1", "n2_1", "n2_2" ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.25

#=======================================#
#  SECTION 14: ALTERNATIVE EXPLORATION  #
#=======================================#

/*--- Example 14.1: What Alternatives Were Considered?
`
  CONCEPT: See the decision points in the search
  
  At each node with multiple neighbors, the planner made
  a choice. ExplainAlternatives() shows these decision points.
`

pr()

oGraph = new stzGraph("choices")
oGraph {
	AddNode("start")
	AddNode("fork_left")
	AddNode("fork_right")
	AddNode("junction_a")
	AddNode("junction_b")
	AddNode("end")
	
	# Multiple paths from start
	AddEdgeXTT("start", "fork_left", "path", [:cost = 5])
	AddEdgeXTT("start", "fork_right", "path", [:cost = 8])
	
	# Fork_left has options
	AddEdgeXTT("fork_left", "junction_a", "path", [:cost = 10])
	AddEdgeXTT("fork_left", "junction_b", "path", [:cost = 3])
	
	# Both junctions reach end
	AddEdgeXTT("junction_a", "end", "path", [:cost = 2])
	AddEdgeXTT("junction_b", "end", "path", [:cost = 5])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("explore_choices")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()

	# ALTERNATIVES EXPLORED
	? ExplainAlternatives() + NL
	#--> Key decisions made:
	#    • At 'start', chose 'fork_left' 		(~> 2 options available)
	#    • At 'fork_left', chose 'junction_a' 	(~> 2 options available)
	
	# Final route:
	? @@( Route() )
	#--> [ "start", "fork_left", "junction_b", "end" ]

	# Total cost:
	? Cost()
	#--> 13
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#===============================#
#  SECTION 15: PLAN COMPARISON  #
#===============================#

/*--- Example 15.1: Comparing Two Strategies
`
  CONCEPT: Compare plans to understand trade-offs
  
  Generate two plans with different optimization criteria,
  then compare them to see the differences.
`

pr()

oGraph = new stzGraph("trade_off")
oGraph {
	AddNode("factory")
	AddNode("process_premium")
	AddNode("process_standard")
	AddNode("shipping")
	
	# Premium process: expensive but fast
	AddEdgeXTT("factory", "process_premium", "flow", [
		:cost = 100,
		:time = 5,
		:quality = 10
	])
	AddEdgeXTT("process_premium", "shipping", "flow", [
		:cost = 50,
		:time = 3,
		:quality = 10
	])
	
	# Standard process: cheap but slow
	AddEdgeXTT("factory", "process_standard", "flow", [
		:cost = 30,
		:time = 15,
		:quality = 7
	])
	AddEdgeXTT("process_standard", "shipping", "flow", [
		:cost = 20,
		:time = 10,
		:quality = 7
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan A: Minimize cost (budget production)
	AddPlan("budget")
	Walk(:From = "factory", :To = "shipping")
	Using(:cheapest)
	Execute()
	
	# Plan B: Minimize time (rush order)
	AddPlan("rush")
	Walk(:From = "factory", :To = "shipping")
	Using(:fastest)
	Execute()
	
	# Compare them
	SetCurrentPlan("budget")
	? ExplainDifference("rush") + NL
	#--> PATH ANALYSIS:
	# Plans use DIFFERENT routes
	#   Plan 1: [ "factory", "process_standard", "shipping" ]
	#   Plan 2: [ "factory", "process_premium", "shipping" ]
	# 
	#   Paths diverge at step 2
	# 
	# COST ANALYSIS:
	#   Plan 1 cost: 50
	#   Plan 2 cost: 8
	#   ✓ Plan 2 is cheaper

	# TRADE-OFF ANALYSIS
	? ShowTradeoffs("rush")
	#--> CRITERION COMPARISON:
	#  Cost:        Plan 2 wins (saves 42)
	#  Path Length: Tie
	# 
	# RECOMMENDATION:
	#   → Choose Plan 2 for cost optimization
}

pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Example 15.2: Which Is Cheaper?
`
  CONCEPT: Quick comparison methods for decision support
  
  When you just need a quick answer: "which plan costs less?"
`

pr()

oGraph = new stzGraph("trade_off")
oGraph {
	AddNode("factory")
	AddNode("process_premium")
	AddNode("process_standard")
	AddNode("shipping")
	
	# Premium process: expensive but fast
	AddEdgeXTT("factory", "process_premium", "flow", [
		:cost = 100,
		:time = 5,
		:quality = 10
	])
	AddEdgeXTT("process_premium", "shipping", "flow", [
		:cost = 50,
		:time = 3,
		:quality = 10
	])
	
	# Standard process: cheap but slow
	AddEdgeXTT("factory", "process_standard", "flow", [
		:cost = 30,
		:time = 15,
		:quality = 7
	])
	AddEdgeXTT("process_standard", "shipping", "flow", [
		:cost = 20,
		:time = 10,
		:quality = 7
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan A: Minimize cost (budget production)
	AddPlan("budget")
	Walk(:From = "factory", :To = "shipping")
	Using(:cheapest)
	Execute()
	
	# Plan B: Minimize time (rush order)
	AddPlan("rush")
	Walk(:From = "factory", :To = "shipping")
	Using(:fastest)
	Execute()

	SetCurrentPlan("budget")
	? WhichIsCheaper("rush")
	#--> Plan rush
	
	# How much cheaper?
	? CostSavings("rush")
	#--> 42
	
	# ~> You can now make informed decisions quickly
}

pf()
# Executed in 0.02 second(s) in Ring 1.25

#=============================================#
#  SECTION 16: REAL-WORLD INTEGRATED EXAMPLE  #
#=============================================#

/*--- Example 16.1: Complete Warehouse Robot Planning
`
  CONCEPT: Putting it all together
  
  A warehouse robot needs to navigate from receiving to
  a shelf. We'll explore multiple strategies, compare them,
  and choose based on the situation.
`

pr()

oGraph = new stzGraph("warehouse_complete")
oGraph {
	AddNodeXTT("receiving", "Receiving Bay", [:x = 0, :y = 0])
	AddNodeXTT("aisle_main", "Main Aisle", [:x = 20, :y = 0])
	AddNodeXTT("aisle_side", "Side Aisle", [:x = 10, :y = 10])
	AddNodeXTT("storage", "Cold Storage", [:x = 30, :y = 10])
	AddNodeXTT("shelf_42", "Target Shelf", [:x = 40, :y = 10])
	
	# Main route: fast but congested
	AddEdgeXTT("receiving", "aisle_main", "path", [
		:distance = 20,
		:time = 5,
		:energy = 10,
		:congestion = 8
	])
	AddEdgeXTT("aisle_main", "storage", "path", [
		:distance = 15,
		:time = 4,
		:energy = 8,
		:congestion = 7
	])
	
	# Alternative: longer but clear
	AddEdgeXTT("receiving", "aisle_side", "path", [
		:distance = 15,
		:time = 8,
		:energy = 12,
		:congestion = 2
	])
	AddEdgeXTT("aisle_side", "storage", "path", [
		:distance = 25,
		:time = 10,
		:energy = 15,
		:congestion = 1
	])
	
	# Final leg to shelf
	AddEdgeXTT("storage", "shelf_42", "path", [
		:distance = 10,
		:time = 3,
		:energy = 5,
		:congestion = 3
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Scenario 1: Rush order - need speed
	AddPlan("urgent")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:fastest)
	Execute()
	
	# Scenario 2: Battery low - need energy efficiency
	AddPlan("energy_saving")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:efficient)
	Execute()
	
	# Scenario 3: Balanced approach
	AddPlan("normal")
	Walk(:From = "receiving", :To = "shelf_42")
	Using(:balanced)
	Execute()
	
	# CENARIO COMPARISON
	
	# Analyze urgent plan
	SetCurrentPlan("urgent")
	? "URGENT PLAN (rush order):"
	? @@( Route() )
	? Cost()
	? ExplainEfficiency() + NL
	
	# Analyze energy-saving plan
	SetCurrentPlan("energy_saving")
	? "ENERGY-SAVING PLAN (low battery):"
	? @@( Route() )
	? Cost() + NL
	
	# Analyze normal plan
	SetCurrentPlan("normal")
	? "NORMAL PLAN (balanced):"
	? @@( Route() )
	? Cost() + NL
	
	# Compare urgent vs energy-saving
	SetCurrentPlan("urgent")
	? "=== URGENT vs ENERGY-SAVING ===" + NL
	? ShowTradeoffs("energy_saving") + NL
	
	#-->
	# URGENT PLAN (rush order):
	# [ "receiving", "aisle_main", "storage", "shelf_42" ]
	# 12
	# Explored 4 nodes for 4-node path (1:1 ratio - very efficient)
	# 
	# ENERGY-SAVING PLAN (low battery):
	# [ "receiving", "aisle_main", "storage", "shelf_42" ]
	# 23
	# 
	# NORMAL PLAN (balanced):
	# [ "receiving", "aisle_main", "storage", "shelf_42" ]
	# 12
	# 
	# === URGENT vs ENERGY-SAVING ===
	# 
	# CRITERION COMPARISON:
	#   Cost:        Plan 1 wins (saves 11)
	#   Path Length: Tie
	# 
	# RECOMMENDATION:
	#   → Choose Plan 1 for cost optimization

	# Based on this analysis :
	# - For rush orders: Use 'urgent' plan
	# - For routine pickups with low battery: Use 'energy_saving' plan
	# - For normal operations: Use 'normal' plan
}

pf()
# Executed in 0.04 second(s) in Ring 1.25

#====================================#
#  SECTION 17: EDUCATIONAL USE CASE  #
#====================================#

/*--- Example 17.1: Teaching A* Through Exploration
`
  CONCEPT: Learn by using, not implementing
  
  Students can explore pathfinding concepts without
  getting bogged down in implementation details.
`

pr()

oGraph = new stzGraph("learning")
oGraph {
	# Simple diamond graph
	AddNode("A")
	AddNode("B")
	AddNode("C")
	AddNode("D")
	
	AddEdgeXTT("A", "B", "path", [:cost = 1])
	AddEdgeXTT("A", "C", "path", [:cost = 4])
	AddEdgeXTT("B", "D", "path", [:cost = 5])
	AddEdgeXTT("C", "D", "path", [:cost = 1])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("learning_astar")
	Walk(:From = "A", :To = "D")
	Minimize("cost")
	Execute()

	# LEARNING A* CONCEPTS

	# 1. What route did A* find?
	? @@( Route() ) + NL
	#--> [ "a", "c", "d" ] (cost 5, not a->b->d cost 6)
	
	# 2. Why did it choose this route?
	? ExplainWhy("route") + NL
	#-->
	# This route was selected because:
	# • Total cost: 5
	# • Explored 4 nodes to find it
	# • Optimized for: minimize cost

	# 3. How efficient was the search?
	? ExplainEfficiency() + NL
	#--> Explored 4 nodes for 3-node path (1.33:1 ratio - very efficient)

	# 4. What's the cost breakdown?
	? ExplainCostBreakdown() + NL
	#--> === COST BREAKDOWN ===
	# 
	# Step 1: a -> c
	#   • cost: 4 × 1 (minimize) = 4
	#   Total: 4
	# 
	# Step 2: c -> d
	#   • cost: 1 × 1 (minimize) = 1
	#   Total: 1

	# ~> Key insight: A* found the cheaper route (5) even though
	# the first edge to C (cost 4) seemed expensive initially.
	# This demonstrates A*'s ability to reason about total path cost!
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#=====================================#
#  SECTION 18: MULTI-PLAN COMPARISON  #
#=====================================#

/*--- Example 18.1: Comparing 4 Different Strategies
`
  CONCEPT: Compare multiple plans simultaneously
  
  When you have several alternative strategies, you need
  to compare them all at once to see which performs best
  under different criteria.
`

pr()

oGraph = new stzGraph("multi_strategy")
oGraph {
	AddNode("warehouse")
	AddNode("route_highway")
	AddNode("route_backroad")
	AddNode("route_express")
	AddNode("destination")
	
	# Highway route: fast but expensive
	AddEdgeXTT("warehouse", "route_highway", "path", [
		:time = 10,
		:cost = 50,
		:distance = 20
	])
	AddEdgeXTT("route_highway", "destination", "path", [
		:time = 8,
		:cost = 40,
		:distance = 15
	])
	
	# Backroad route: slow but cheap
	AddEdgeXTT("warehouse", "route_backroad", "path", [
		:time = 25,
		:cost = 15,
		:distance = 30
	])
	AddEdgeXTT("route_backroad", "destination", "path", [
		:time = 20,
		:cost = 10,
		:distance = 25
	])
	
	# Express route: very fast, very expensive
	AddEdgeXTT("warehouse", "route_express", "path", [
		:time = 5,
		:cost = 80,
		:distance = 18
	])
	AddEdgeXTT("route_express", "destination", "path", [
		:time = 4,
		:cost = 60,
		:distance = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Create 4 different strategy plans
	AddPlan("ultra_fast")
	Walk(:From = "warehouse", :To = "destination")
	Using(:fastest)
	Execute()
	
	AddPlan("budget")
	Walk(:From = "warehouse", :To = "destination")
	Using(:cheapest)
	Execute()
	
	AddPlan("short_distance")
	Walk(:From = "warehouse", :To = "destination")
	Using(:shortest)
	Execute()
	
	AddPlan("balanced")
	Walk(:From = "warehouse", :To = "destination")
	Using(:balanced)
	Execute()
	
	# MULTI-PLAN COMPARISON
	
	# Compare all 4 plans
	oMulti = CompareMultiple(["ultra_fast", "budget", "short_distance", "balanced"])
	
	# All Plans Overview:
	? oMulti.CompareAll() + NL
	#-->
	# === COMPARING 4 PLANS ===
	# 
	# Plan: ultra_fast
	#   Cost: 15.30
	#   Steps: 3
	#   Route: [ "warehouse", "route_express", "destination" ]
	# 
	# Plan: budget
	#   Cost: 31
	#   Steps: 3
	#   Route: [ "warehouse", "route_backroad", "destination" ]
	# 
	# Plan: short_distance
	#   Cost: 30
	#   Steps: 3
	#   Route: [ "warehouse", "route_express", "destination" ]
	# 
	# Plan: balanced
	#   Cost: 42
	#   Steps: 3
	#   Route: [ "warehouse", "route_backroad", "destination" ]
	# 
	# Best by cost: ultra_fast
	# Best by steps: ultra_fast
	
	# Ranking by Cost:
	? "---" + NL

	? @@NL( oMulti.RankBy("cost") ) + NL
	#--> Shows plans ranked from cheapest to most expensive
	# [
	# 	[ "ultra_fast", 15.30 ],
	# 	[ "short_distance", 30 ],
	# 	[ "budget", 31 ],
	# 	[ "balanced", 42 ]
	# ]

	# Ranking by Steps:
	? "---" + NL

	? @@NL( oMulti.RankBy("steps") ) + NL
	#--> [
	# 	[ "ultra_fast", 3 ],
	# 	[ "budget", 3 ],
	# 	[ "short_distance", 3 ],
	# 	[ "balanced", 3 ]
	# ]

	# Complete Ranking Table:
	? "---" + NL

	oMulti.ShowRankingTable()
	#--> === PLAN RANKING TABLE ===
	# 
	#    Rank | Plan Name      | Cost  | Steps
	#    -----+----------------+-------+------
	#    1    | ultra_fast     | 15.30 | 3
	#    2    | short_distance | 30    | 3
	#    3    | budget         | 31    | 3
	#    4    | balanced       | 42    | 3
	
	? NL + "---" + NL

	? "Best by cost: " + oMulti.BestBy("cost")
	#--> ultra_fast
	
	? "Worst by cost: " + oMulti.WorstBy("cost")
	#--> balanced

}

pf()
# Executed in 0.05 second(s) in Ring 1.25

/*--- Example 18.2: Ranking All Plans
`
  CONCEPT: Automatic ranking of all plans in the planner
  
  You don't need to specify which plans to compare -
  RankPlansBy() automatically ranks all executed plans.
`

pr()

oGraph = new stzGraph("multi_strategy")
oGraph {
	AddNode("warehouse")
	AddNode("route_highway")
	AddNode("route_backroad")
	AddNode("route_express")
	AddNode("destination")
	
	# Highway route: fast but expensive
	AddEdgeXTT("warehouse", "route_highway", "path", [
		:time = 10,
		:cost = 50,
		:distance = 20
	])
	AddEdgeXTT("route_highway", "destination", "path", [
		:time = 8,
		:cost = 40,
		:distance = 15
	])
	
	# Backroad route: slow but cheap
	AddEdgeXTT("warehouse", "route_backroad", "path", [
		:time = 25,
		:cost = 15,
		:distance = 30
	])
	AddEdgeXTT("route_backroad", "destination", "path", [
		:time = 20,
		:cost = 10,
		:distance = 25
	])
	
	# Express route: very fast, very expensive
	AddEdgeXTT("warehouse", "route_express", "path", [
		:time = 5,
		:cost = 80,
		:distance = 18
	])
	AddEdgeXTT("route_express", "destination", "path", [
		:time = 4,
		:cost = 60,
		:distance = 12
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Create and execute plans first
	AddPlan("ultra_fast")
	Walk(:From = "warehouse", :To = "destination")
	Using(:fastest)
	Execute()
	
	AddPlan("budget")
	Walk(:From = "warehouse", :To = "destination")
	Using(:cheapest)
	Execute()
	
	# NOW rank them
	? "=== AUTO-RANKING ALL PLANS ==="
	
	aRankedCost = RankPlansBy("cost")
	? "Plans ranked by cost:"
	? @@NL( aRankedCost )
	#--> [
	# 	[ "ultra_fast", 15.30 ],
	# 	[ "budget", 31 ]
	# ]

}

pf()
# Executed in 0.03 second(s) in Ring 1.25

#=====================================#
#  SECTION 19: HISTORICAL COMPARISON  #
#=====================================#

/*--- Example 19.1: Learning from Past Executions
`
  CONCEPT: Compare current plans with historical data
  
  Every time you execute a plan, it's stored in history.
  You can then compare new plans against past performance
  to see if you're improving or degrading.
`

pr()

oGraph = new stzGraph("evolving_network")
oGraph {
	AddNode("start")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("end")
	
	AddEdgeXTT("start", "mid1", "path", [:cost = 10])
	AddEdgeXTT("start", "mid2", "path", [:cost = 15])
	AddEdgeXTT("mid1", "end", "path", [:cost = 20])
	AddEdgeXTT("mid2", "end", "path", [:cost = 8])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	? "=== HISTORICAL LEARNING ===" + NL
	
	# Attempt 1: Initial optimal route
	AddPlan("attempt1")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 1 cost: " + Cost() + " via " + @@(Route())
	#--> 23 via ["start", "mid2", "end"]
	
	# Network degrades - mid2 route becomes congested
	@oGraph.SetEdgeProperty("mid2", "end", "cost", 25)
	
	# Attempt 2: Same plan, worse network
	AddPlan("attempt2")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 2 cost: " + Cost() + " via " + @@(Route())
	#--> 30 via ["start", "mid1", "end"] (switched routes!)
	
	# Network improves - mid1 route optimized
	@oGraph.SetEdgeProperty("mid1", "end", "cost", 12)
	
	# Attempt 3: Same plan, improved network
	AddPlan("attempt3")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 3 cost: " + Cost() + " via " + @@(Route())
	#--> 22 via ["start", "mid1", "end"] (best yet!)
	
	? NL + "Total executions: " + HistoryCount()
	? "Historical average cost: " + HistoricalAverage("cost")
	? "Best historical plan: " + BestHistoricalPlan("cost")
	
	SetCurrentPlan("attempt3")
	oHistComp = CompareWithHistory()
	
	? NL + oHistComp.Explain()
	#--> Shows attempt3 is better than average (22 vs 25)
	
	? NL + "Is this an improvement? " + oHistComp.IsImprovement()
	#--> TRUE
	
	? "Improvement percentage: " + oHistComp.ImprovementPercentage() + "%"
	#--> ~12% improvement
}
#-->
# === HISTORICAL LEARNING ===
# 
# Attempt 1 cost: 23 via [ "start", "mid2", "end" ]
# Attempt 2 cost: 30 via [ "start", "mid1", "end" ]
# Attempt 3 cost: 22 via [ "start", "mid1", "end" ]
# 
# Total executions: 3
# Historical average cost: 25
# Best historical plan: attempt3
# 
# === HISTORICAL COMPARISON ===
# 
# Current Plan: attempt3
#   Cost: 22
#   Steps: 3
# 
# Historical Average:
#   Cost: 25
#   Steps: 3
# 
# ✓ Current plan is 12% better than average
# 
# Best historical plan: attempt3
# 
# Is this an improvement? 1
# Improvement percentage: 12%

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- A simular example demonstrating history tracking with identical results

pr()

oGraph = new stzGraph("evolving_network")
oGraph {
	AddNode("start")
	AddNode("mid1")
	AddNode("mid2")
	AddNode("end")
	
	# Simulate network that changes over time
	AddEdgeXTT("start", "mid1", "path", [:cost = 10])
	AddEdgeXTT("start", "mid2", "path", [:cost = 15])
	AddEdgeXTT("mid1", "end", "path", [:cost = 20])
	AddEdgeXTT("mid2", "end", "path", [:cost = 8])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	? "=== HISTORICAL LEARNING ==="
	
	# Execute plan 1 (first attempt)
	AddPlan("attempt1")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 1 cost: " + Cost()
	#--> 23 (start->mid2->end)
	
	# Execute plan 2 (second attempt with different graph state)
	AddPlan("attempt2")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 2 cost: " + Cost()
	
	# Execute plan 3
	AddPlan("attempt3")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	? "Attempt 3 cost: " + Cost()
	
	? NL + "Total executions in history: " + HistoryCount()
	#--> 3
	
	? NL + "Historical average cost: " + HistoricalAverage("cost")
	? "Historical average steps: " + HistoricalAverage("steps")
	
	? NL + "Best historical plan: " + BestHistoricalPlan("cost")
	
	# Compare current plan with history
	SetCurrentPlan("attempt3")
	oHistComp = CompareWithHistory()
	
	? NL + oHistComp.Explain()
	#--> === HISTORICAL COMPARISON ===
	#    Current Plan: attempt3
	#    Cost: 23
	#    Steps: 3
	#    
	#    Historical Average:
	#    Cost: 23
	#    Steps: 3
	#    
	#    = Current plan matches historical average
	
	? NL + "Is this an improvement? " + oHistComp.IsImprovement() #--> FALSE
	? "Improvement percentage: " + oHistComp.ImprovementPercentage() + "%" #--> 0%
}

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Example 19.2: Tracking Performance Over Time
`
  CONCEPT: Identify performance trends and degradation
  
  Monitor how route performance changes as network conditions
  fluctuate, helping you detect when intervention is needed.
`

pr()

oGraph = new stzGraph("performance_tracking")
oGraph {
	AddNode("depot")
	AddNode("hub")
	AddNode("customer")
	
	AddEdgeXTT("depot", "hub", "route", [:cost = 20, :time = 10])
	AddEdgeXTT("hub", "customer", "route", [:cost = 15, :time = 8])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	? "=== PERFORMANCE TRACKING ===" + NL
	
	# Simulate 5 delivery runs with increasing congestion
	for i = 1 to 5
		cPlanName = "delivery_" + i
		AddPlan(cPlanName)
		Walk(:From = "depot", :To = "customer")
		Minimize("cost")
		Execute()
		
		? "Run " + i + " cost: " + Cost()
		
		# Simulate traffic building up
		nCurrentCost = @oGraph.EdgeProperty("depot", "hub", "cost")
		@oGraph.SetEdgeProperty("depot", "hub", "cost", nCurrentCost + 3)
	next
	
	? NL + "=== HISTORICAL ANALYSIS ==="
	? "Total runs: " + HistoryCount()
	? "Average cost: " + HistoricalAverage("cost")
	? "Best run: " + BestHistoricalPlan("cost")
	? "Worst run: " + WorstHistoricalPlan("cost")  # Need WorstHistoricalPlan()
	
	# Latest run comparison
	SetCurrentPlan("delivery_5")
	oHistComp = CompareWithHistory()
	? NL + oHistComp.Explain()
	#--> Shows degradation trend: 35, 38, 41, 44, 47
}
#-->
# === PERFORMANCE TRACKING ===
# 
# Run 1 cost: 35
# Run 2 cost: 38
# Run 3 cost: 41
# Run 4 cost: 44
# Run 5 cost: 47
# 
# === HISTORICAL ANALYSIS ===
# Total runs: 5
# Average cost: 41
# Best run: delivery_1
# Worst run: delivery_5
# 
# === HISTORICAL COMPARISON ===
# 
# Current Plan: delivery_5
#   Cost: 47
#   Steps: 3
# 
# Historical Average:
#   Cost: 41
#   Steps: 3
# 
# ✗ Current plan is 14.63% worse than average
# 
# Best historical plan: delivery_1

pf()
# Executed in 0.03 second(s) in Ring 1.25

#==========================================#
#  SECTION 20: CONSTRAINT-BASED FILTERING  #
#==========================================#

/*--- Example 20.1: Finding Plans Within Budget
`
  CONCEPT: Filter plans by constraints
  
  Create plans with genuinely different routes, then filter
  by cost, avoided nodes, or other criteria.
`

pr()

oGraph = new stzGraph("filtered_network")
oGraph {
	AddNode("origin")
	AddNode("cheap_route")
	AddNode("expensive_route")
	AddNode("medium_route")
	AddNode("avoid_me")
	AddNode("destination")
	
	# Cheap route: 15 total
	AddEdgeXTT("origin", "cheap_route", "path", [:cost = 10])
	AddEdgeXTT("cheap_route", "destination", "path", [:cost = 5])
	
	# Expensive route through avoid_me: 80 total
	AddEdgeXTT("origin", "expensive_route", "path", [:cost = 50])
	AddEdgeXTT("expensive_route", "avoid_me", "path", [:cost = 20])
	AddEdgeXTT("avoid_me", "destination", "path", [:cost = 10])
	
	# Medium route: 35 total
	AddEdgeXTT("origin", "medium_route", "path", [:cost = 20])
	AddEdgeXTT("medium_route", "destination", "path", [:cost = 15])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Plan 1: Cheap route
	AddPlan("plan_cheap")
	Walk(:From = "origin", :To = "destination")
	Minimize("cost")
	Execute()
	
	# Plan 2: Force expensive route by making it goal
	AddPlan("plan_via_avoid")
	Walk(:From = "origin", :To = "avoid_me")
	Minimize("cost")
	Execute()
	
	# Plan 3: Force medium route
	AddPlan("plan_via_medium")
	Walk(:From = "origin", :To = "medium_route")
	Minimize("cost")
	Execute()
	
	? "=== CONSTRAINT-BASED FILTERING ===" + NL
	
	# Filter 1: Plans with max cost of 50
	? "Plans with cost <= 50:"
	oFilter1 = FilterPlans([:maxCost = 50])
	? "Found " + oFilter1.Count() + " plans" + NL
	oFilter1.Show()
	
	# Filter 2: Plans avoiding a specific node
	? NL + "Plans that avoid 'avoid_me' node:"
	oFilter2 = PlansAvoiding("avoid_me")
	? "Found " + oFilter2.Count() + " plans" + NL
	oFilter2.Show()
	
	# Filter 3: Plans with minimum cost
	? NL + "Plans with cost >= 20:"
	oFilter3 = FilterPlans([:minCost = 20])
	? "Found " + oFilter3.Count() + " plans" + NL
	oFilter3.Show()
}
#-->
# === CONSTRAINT-BASED FILTERING ===
# 
# Plans with cost <= 50:
# Found 2 plans
# 
# === FILTERED PLANS ===
# 
# Constraints applied: [ [ "maxcost", 50 ] ]
# 
# Plans matching: 2
# 
# 1. plan_cheap
#    Cost: 15
#    Steps: 3
#    Route: [ "origin", "cheap_route", "destination" ]
# 2. plan_via_medium
#    Cost: 20
#    Steps: 2
#    Route: [ "origin", "medium_route" ]
# 
# Plans that avoid 'avoid_me' node:
# Found 2 plans
# 
# === FILTERED PLANS ===
# 
# Constraints applied: [ [ "avoid", "avoid_me" ] ]
# 
# Plans matching: 2
# 
# 1. plan_cheap
#    Cost: 15
#    Steps: 3
#    Route: [ "origin", "cheap_route", "destination" ]
# 2. plan_via_medium
#    Cost: 20
#    Steps: 2
#    Route: [ "origin", "medium_route" ]
# 
# Plans with cost >= 20:
# Found 2 plans
# 
# === FILTERED PLANS ===
# 
# Constraints applied: [ [ "mincost", 20 ] ]
# 
# Plans matching: 2
#
# 1. plan_via_avoid
#    Cost: 70
#    Steps: 3
#    Route: [ "origin", "expensive_route", "avoid_me" ]
# 2. plan_via_medium
#    Cost: 20
#    Steps: 2
#   Route: [ "origin", "medium_route" ]

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Example 20.2: Finding Plans Within Percentage of Optimal
`
  CONCEPT: Tolerance-based filtering
  
  Sometimes you want "good enough" solutions - plans that
  are within 10% of the optimal cost. This gives you
  flexibility while maintaining efficiency.
`

pr()

oGraph = new stzGraph("tolerance_test")
oGraph {
	AddNode("base")
	AddNode("option_a")
	AddNode("option_b")
	AddNode("option_c")
	AddNode("target")
	
	# Optimal route: cost 100
	AddEdgeXTT("base", "option_a", "path", [:cost = 40])
	AddEdgeXTT("option_a", "target", "path", [:cost = 60])
	
	# Near-optimal route: cost 105 (5% worse)
	AddEdgeXTT("base", "option_b", "path", [:cost = 45])
	AddEdgeXTT("option_b", "target", "path", [:cost = 60])
	
	# Suboptimal route: cost 130 (30% worse)
	AddEdgeXTT("base", "option_c", "path", [:cost = 70])
	AddEdgeXTT("option_c", "target", "path", [:cost = 60])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Create plans via different routes
	# Plan 1: Optimal via option_a
	AddPlan("optimal")
	Walk(:From = "base", :To = "option_a")
	Minimize("cost")
	Execute()
	
	# Plan 2: Near-optimal via option_b
	AddPlan("near_optimal")
	Walk(:From = "base", :To = "option_b")
	Minimize("cost")
	Execute()
	
	# Plan 3: Suboptimal via option_c
	AddPlan("suboptimal")
	Walk(:From = "base", :To = "option_c")
	Minimize("cost")
	Execute()
	
	? "=== TOLERANCE-BASED FILTERING ==="
	
	# Find plans within 10% of optimal
	? NL + "Plans within 15% of optimal:"
	oFilter = PlansWithin(15, :of = "optimal")
	? "Found " + oFilter.Count() + " plans"
	oFilter.Show()
	#--> Should include optimal and near_optimal, but not suboptimal
	
	? NL + "Best plan from filtered set:"
	? oFilter.BestBy("cost")
	
	? NL + "Ranking of filtered plans:"
	oFilter.ShowRankingTable()
}
#-->
# === TOLERANCE-BASED FILTERING ===
# 
# Plans within 10% of optimal:
# Found 2 plans
# === FILTERED PLANS ===
# 
# Constraints applied: [ [ "maxcost", 46 ] ]
# 
# Plans matching: 2
# 
# 1. optimal
#    Cost: 40
#    Steps: 2
#    Route: [ "base", "option_a" ]
# 2. near_optimal
#    Cost: 45
#    Steps: 2
#    Route: [ "base", "option_b" ]
# 
# Best plan from filtered set:
# optimal
# 
# Ranking of filtered plans:
# === PLAN RANKING TABLE ===
# 
# Rank | Plan Name          | Cost  | Steps
# -----+--------------------+-------+------
# 1    | optimal            | 40    | 2
# 2    | near_optimal       | 45    | 2
#
pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Example 20.3: Complex Multi-Constraint Filtering
`
  CONCEPT: Combine multiple constraints
  
  Real-world scenarios often have multiple constraints:
  "Find plans under $50 that avoid downtown and have
  fewer than 5 steps."
`
#ERR

pr()

oGraph = new stzGraph("complex_filter")
oGraph {
	AddNode("start")
	AddNode("downtown")  # Want to avoid this
	AddNode("suburbs")
	AddNode("industrial")
	AddNode("end")
	
	# Route through downtown: cheap but risky
	AddEdgeXTT("start", "downtown", "path", [:cost = 15])
	AddEdgeXTT("downtown", "end", "path", [:cost = 10])
	
	# Route through suburbs: moderate
	AddEdgeXTT("start", "suburbs", "path", [:cost = 25])
	AddEdgeXTT("suburbs", "end", "path", [:cost = 20])
	
	# Route through industrial: safe but longer
	AddEdgeXTT("start", "industrial", "path", [:cost = 30])
	AddEdgeXTT("industrial", "suburbs", "path", [:cost = 10])

}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	# Create various route plans
	AddPlan("through_downtown")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	
	AddPlan("through_suburbs")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	
	AddPlan("through_industrial")
	Walk(:From = "start", :To = "end")
	Minimize("cost")
	Execute()
	
	? "=== MULTI-CONSTRAINT FILTERING ==="
	
	# Filter with multiple constraints
	? NL + "Plans that: cost <= 50 AND avoid downtown AND steps <= 4"
	oFilter = FilterPlans([
		:maxCost, 50,
		:avoid, "downtown",
		:maxSteps, 4
	])
	
	? "Found " + oFilter.Count() + " plans matching all constraints"
	oFilter.Show()
	
	if oFilter.Count() > 0
		? NL + "Best option from filtered set:"
		? oFilter.BestBy("cost")
	ok
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Example 20.4: Requiring Specific Waypoints
`
  CONCEPT: Plans must pass through certain nodes
  
  Sometimes you need to ensure a plan visits a specific
  location - like a delivery truck that must stop at
  a distribution center.
`
*/
#ERR
pr()

oGraph = new stzGraph("waypoint_test")
oGraph {
	AddNode("warehouse")
	AddNode("distribution_center")  # Must visit this
	AddNode("direct_route")
	AddNode("customer")
	
	# Direct route: skips distribution center
	AddEdgeXTT("warehouse", "direct_route", "path", [:cost = 20])
	AddEdgeXTT("direct_route", "customer", "path", [:cost = 15])
	
	# Route via distribution center
	AddEdgeXTT("warehouse", "distribution_center", "path", [:cost = 25])
	AddEdgeXTT("distribution_center", "customer", "path", [:cost = 20])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("direct")
	Walk(:From = "warehouse", :To = "customer")
	Minimize("cost")
	Execute()
	
	AddPlan("via_dc")
	Walk(:From = "warehouse", :To = "customer")
	Minimize("cost")
	Execute()
	
	? "=== WAYPOINT REQUIREMENT FILTERING ==="
	
	? NL + "Plans that must visit distribution_center:"
	oFilter = PlansRequiring("distribution_center")
	? "Found " + oFilter.Count() + " plans"
	oFilter.Show()
	#--> Only shows plans that pass through distribution_center
}

pf()
# Executed in 0.02 second(s) in Ring 1.24
