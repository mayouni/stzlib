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
	# Each node has x,y coordinates for spatial heuristics
	AddNodeXTT("A", "Start Point", [:x = 0, :y = 0])
	AddNodeXTT("B", "Middle Point", [:x = 10, :y = 0])
	AddNodeXTT("C", "End Point", [:x = 20, :y = 0])
	
	# Edges have a "distance" property that becomes the cost
	AddEdgeXTT("A", "B", "road", [:distance = 10])
	AddEdgeXTT("B", "C", "road", [:distance = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

# Fluent API: StartingFrom -> To_ -> Minimizing -> Execute
oPlan = oPlanner.Plan()
	.StartingFrom("A")      # Where we begin
	.To_("C")               # Where we want to go
	.Minimizing("distance") # What property to optimize
	.Execute()              # Run the planner

? oPlan.Cost()
#--> 20 (total distance: 10 + 10)

? @@( oPlan.States() )
#--> [ "a", "b", "c" ]
# Note: Node IDs are normalized to lowercase

? oPlan.Explain()
#--> Step 1: a -> b (cost: 10)
#    Step 2: b -> c (cost: 10)

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

oGraph = new stzGraph("diamond")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	AddNode("D")
	
	# Two routes from A
	AddEdgeXTT("A", "B", "slow_road", [:distance = 20])
	AddEdgeXTT("A", "C", "fast_road", [:distance = 5])
	
	# Both converge at D
	AddEdgeXTT("B", "D", "road", [:distance = 5])
	AddEdgeXTT("C", "D", "road", [:distance = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

oPlan = oPlanner.Plan()
	.StartingFrom("A")
	.To_("D")
	.Minimizing("distance")
	.Execute()

? oPlan.Cost()
#--> 15 (not 25! A* found the cheaper route)

? @@( oPlan.States() )
#--> [ "a", "c", "d" ]
# Took the fast_road to C, then to D

? @@NL( oPlan.Actions() )
#--> Full action breakdown showing each transition and its cost
# [
# 	[ [ "from", "a" ], [ "to", "c" ], [ "cost", 5 ] ],
# 	[ [ "from", "c" ], [ "to", "d" ], [ "cost", 10 ] ]
# ]

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
	# Create 9 nodes in a 3x3 grid
	for i = 1 to 9
		AddNodeXTT("n" + i, "Node " + i, [
			:x = ((i-1) % 3) * 10,      # Column position
			:y = floor((i-1) / 3) * 10  # Row position
		])
	next
	
	# Horizontal edges (most are expensive except middle row)
	AddEdgeXTT("n1", "n2", "h", [:cost = 10])
	AddEdgeXTT("n2", "n3", "h", [:cost = 10])
	AddEdgeXTT("n4", "n5", "h", [:cost = 1])  # Cheap!
	AddEdgeXTT("n5", "n6", "h", [:cost = 1])  # Cheap!
	AddEdgeXTT("n7", "n8", "h", [:cost = 10])
	AddEdgeXTT("n8", "n9", "h", [:cost = 10])
	
	# Vertical edges (only n2->n5 is cheap)
	AddEdgeXTT("n1", "n4", "v", [:cost = 10])
	AddEdgeXTT("n2", "n5", "v", [:cost = 1])  # Cheap!
	AddEdgeXTT("n3", "n6", "v", [:cost = 10])
	AddEdgeXTT("n4", "n7", "v", [:cost = 10])
	AddEdgeXTT("n5", "n8", "v", [:cost = 10])
	AddEdgeXTT("n6", "n9", "v", [:cost = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

oPlan = oPlanner.Plan()
	.StartingFrom("n1")
	.To_("n9")
	.Minimizing("cost")
	.Execute()

? oPlan.Cost()
#--> 22 (found the middle corridor strategy!)
# Breakdown: 10(n1->n2) + 1(n2->n5) + 1(n5->n6) + 10(n6->n9) = 22

? @@( oPlan.States() )
#--> [ "n1", "n2", "n5", "n6", "n9" ]
# Path visualization: Goes right, drops to middle row, continues right, drops to bottom

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

# ToReach() takes a function that checks if goal is met
oPlan = oPlanner.Plan()
	.StartingFrom("village")
	.ToReachF(func(node) {
		# Called for each node explored
		# Return TRUE when this is an acceptable goal
		return node[:properties][:gold] >= 1000
	})
	.Minimizing("danger")  # Still optimize for safety
	.Execute()

? oPlan.Cost()
#--> 9 (danger: 2 to forest, 7 to dungeon)

? @@( oPlan.States() )
#--> [ "village", "forest", "dungeon" ]
# Went to dungeon because it's the closest location with 1000+ gold

? @@NL( oPlan.Actions() )
#--> Action sequence showing the quest path
# [
# 	[ [ "from", "village" ], [ "to", "forest" ], [ "cost", 2 ] ],
# 	[ [ "from", "forest" ], [ "to", "dungeon" ], [ "cost", 7 ] ]
# ]

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

oPlan = oPlanner.Plan()
	.StartingFrom("start")
	.ToReach(func(node) {
		# Simplified: just reach treasury
		return node[:id] = "treasury"
	})
	.Minimizing("time")
	.Execute()

? oPlan.Cost()
#--> 28 (5 + 8 + 15, via shop route)

? @@( oPlan.States() )
#--> [ "start", "shop", "vault", "treasury" ]
# Skipped crypt because shop route is faster

? @@NL( oPlan.Actions() )
#-->
# [
# 	[ [ "from", "start" ], [ "to", "shop" ], [ "cost", 5 ] ],
# 	[ [ "from", "shop" ], [ "to", "vault" ], [ "cost", 8 ] ],
# 	[ [ "from", "vault" ], [ "to", "treasury" ], [ "cost", 15 ] ]
# ]

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

oPlan = oPlanner.Plan()
	.StartingFrom("entrance")
	.To_("shelf_42")
	.Minimizing("distance")
	.Execute()

? oPlan.Cost()
#--> 45 (used the shortcut!)

? @@( oPlan.States() )
#--> [ "entrance", "receiving", "storage", "shelf_42" ]
# Skipped aisle_a and aisle_b entirely

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
oPlan = oPlanner.Plan()
	.StartingFrom("dock")
	.To_("exit")
	.Minimizing("time")
	.Execute()

? oPlan.Cost()
#--> 17 (skipped zone_a!)

? @@( oPlan.States() )

#--> [ "dock", "zone_b", "zone_c", "exit" ]
# Took shortcut directly to zone_b

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

oPlan = oPlanner.Plan()
	.StartingFrom("raw")
	.To_("finished")
	.Minimizing("time")
	.Execute()

? oPlan.Cost()
#--> 32 (skipped polishing!)
# Breakdown: 10(cut) + 15(shape) + 2(skip_polish) + 5(finish) = 32
# vs. standard: 10 + 15 + 8 + 20 + 5 = 58

? @@( oPlan.States() )
#--> [ "raw", "cut", "shape", "assemble", "finished" ]
# No "polish" in the path

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

oPlan = oPlanner.Plan()
	.StartingFrom("start")
	.To_("end")
	.Minimizing("cost")  # Optimize for cost, not quality
	.Execute()

? oPlan.Cost()
#--> 75 (chose budget route: 30 + 25 + 20)

? @@( oPlan.States() )
#--> [ "start", "process_b", "process_c", "end" ]

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

oPlan = oPlanner.Plan()
	.StartingFrom("client")
	.To_("origin")
	.Minimizing("latency")
	.Execute()

? oPlan.Cost()
#--> 35 (found fast route through CDN)

? @@( oPlan.States() )
#--> [ "client", "router1", "cdn", "origin" ]
# Used direct router1->cdn link, saving 3ms vs. going through router2

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

oPlan = oPlanner.Plan()
	.StartingFrom("spawn")
	.To_("objective")
	.Minimizing("danger")
	.Execute()

? oPlan.Cost()
#--> 11 (safer forest route, not 13 from open field)

? @@( oPlan.States() )
#--> [ "spawn", "forest", "river", "hill", "objective" ]
# NPC wisely avoided the dangerous open field

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

oPlan = oPlanner.Plan()
	.StartingFrom("warehouse")
	.To_("customer")
	.Minimizing("time")
	.Execute()

? oPlan.Cost()
#--> 41

? @@( oPlan.States() )
#--> [ "warehouse", "suburb_b", "downtown", "customer" ]

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

oPlan = oPlanner.Plan()
	.StartingFrom("station")
	.To_("emergency_site")
	.Minimizing("time")
	.Execute()

? oPlan.Cost()
#--> 12 (back road route saves 4 minutes!)

? @@( oPlan.States() )
#--> [ "station", "back_road", "hospital", "emergency_site" ]
# Avoided congested bridge, potentially saving lives

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

# Navigate from bottom-left to top-right
oPlan = oPlanner.Plan()
	.StartingFrom("p0_0")
	.To_("p3_3")
	.Minimizing("cost")
	.Execute()

? oPlan.Cost()
#--> 60 (6 moves × 10 cost each)

? len(oPlan.States())
#--> 7 (start + 6 moves)

? @@( oPlan.States() )
#--> [ "p0_0", "p1_0", "p2_0", "p3_0", "p3_1", "p3_2", "p3_3" ]
# Went right-right-right, then down-down-down
# Euclidean heuristic guided toward goal efficiently!

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
    C -----------------+
  
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

oPlan = oPlanner.Plan()
	.StartingFrom("A")
	.To_("D")
	.Minimizing("cost")
	.Execute()

? oPlan.Cost()
#--> 5 (A->C->D, not A->B->D which would be 6)

? @@( oPlan.States() )
#--> [ "a", "c", "d" ]
# A* correctly chose the C route even though B looked cheaper at first

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

oPlan = oPlanner.Plan()
	.StartingFrom("supplier")
	.To_("retail")
	.Minimizing("cost")
	.Execute()

? oPlan.Cost()
#--> 1700 (1000 + 500 + 200)

? oPlan.Explain()
#--> Human-readable step-by-step explanation
# Step 1: supplier -> factory (cost: 1000)
# Step 2: factory -> warehouse (cost: 500)
# Step 3: warehouse -> retail (cost: 200)

? @@( oPlan.States() )
#--> [ "supplier", "factory", "warehouse", "retail" ]

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
oPlan1 = oPlanner.Plan()
	.StartingFrom("home")
	.To_("chest")  # Know exact location
	.Minimizing("distance")
	.Execute()

? oPlan1.Cost()
#--> 30

? @@( oPlan1.States() )
#--> [ "home", "town", "cave", "chest" ]

# Approach 2: Goal-based search for condition
oPlan2 = oPlanner.Plan()
	.StartingFrom("home")
	.ToReach(func(node) {
		return node[:properties][:has_treasure] = TRUE
	})
	.Minimizing("distance")
	.Execute()

? oPlan2.Cost()
#--> 30 (same result)

? @@( oPlan2.States() )
#--> [ "home", "town", "cave", "chest" ]
# Both approaches work! Choose based on whether you know the exact target.

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---
`
  END OF TESTS
  
  You've now seen:
  - Basic A* pathfinding with cost optimization
  - Goal-based search with condition functions
  - Real-world applications (warehouse, delivery, emergency, games)
  - Advanced features (spatial heuristics, plan explanations)
  - Algorithm comparisons and when to use each
  
  Key takeaways:
  1. Graph planning turns complex routing problems into simple API calls
  2. A* finds optimal paths automatically using smart heuristics
  3. Goal-based search is powerful when destinations are conditions
  4. Same framework works for physical routing, workflow optimization, and AI
  
  Next steps:
  - Try your own graphs and scenarios
  - Experiment with different cost functions
  - Chain multiple plans for complex multi-step tasks
  - Add custom heuristics for domain-specific problems
  
  Happy planning! 🎯
`
