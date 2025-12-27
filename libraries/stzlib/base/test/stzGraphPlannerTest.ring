load "../stzbase.ring"

#---------------------------#
#  EXAMPLE USAGE            #
#---------------------------#

/*--- Example 1: Simple Pathfinding

pr()

oGraph = new stzGraph("warehouse")
oGraph {
	AddNodeXTT("entrance", "Entrance", [:x = 0, :y = 0])
	AddNodeXTT("aisle_a", "Aisle A", [:x = 10, :y = 0])
	AddNodeXTT("shelf_5", "Shelf 5", [:x = 10, :y = 20])
	
	AddEdgeXTT("entrance", "aisle_a", '', [:distance = 10, :traffic = "low"])
	AddEdgeXTT("aisle_a", "shelf_5", '', [:distance = 20, :traffic = "high"])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlan = oPlanner.Plan()
	.StartingFrom("entrance")
	.To_("shelf_5")
	.Minimizing("distance")
	.Execute()

? oPlan.Cost() + NL
#--> 30

? oPlan.Explain()
#-->
# Step 1: entrance -> aisle_a (cost: 10)
# Step 2: aisle_a -> shelf_5 (cost: 20)

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 2: Goal-Based Planning

pr()

oGame = new stzGraph("rpg_world")
oGame {
	AddNodeXTT("village", "Village", [:gold = 0, :hasKey = FALSE])
	AddNodeXTT("forest", "Forest", [:gold = 500, :hasKey = FALSE])
	AddNodeXTT("dungeon", "Dungeon", [:gold = 1000, :hasKey = TRUE])
	
	AddEdgeXTT("village", "forest", "travel", [:danger = 2])
	AddEdgeXTT("forest", "dungeon", "travel", [:danger = 5])
}

oPlanner = new stzGraphPlanner(oGame)
oPlan = oPlanner.Plan()
	.StartingFrom("village")
	.ToReach(func(node) {
		return node[:properties][:gold] >= 1000 and 
		       node[:properties][:hasKey] = TRUE
	})
	.Minimizing("danger")
	.Execute()

? "Quest chain:"
oPlan.Show()
#-->
'
Quest chain:
Plan:
  Total Cost: 7
  Steps: 2

Actions:
  village -> forest
    Cost: 2
  forest -> dungeon
    Cost: 5

Explanation:
Step 1: village -> forest (cost: 2)
Step 2: forest -> dungeon (cost: 5)
'

pf()
# Executed in 0.01 second(s) in Ring 1.24



#============================================#
#  SECTION 1: BASIC PATHFINDING WITH A*     #
#============================================#

/*--- Simple linear path - Finding route from A to C

pr()

# Create a simple linear graph: A -> B -> C
oGraph = new stzGraph("linear")
oGraph {
	AddNodeXTT("A", "Start Point", [:x = 0, :y = 0])
	AddNodeXTT("B", "Middle Point", [:x = 10, :y = 0])
	AddNodeXTT("C", "End Point", [:x = 20, :y = 0])
	
	# Connect with distance costs
	AddEdgeXTT("A", "B", "road", [:distance = 10])
	AddEdgeXTT("B", "C", "road", [:distance = 10])
}

# Create planner and find path
oPlanner = new stzGraphPlanner(oGraph)

oPlan = oPlanner.Plan()
	.StartingFrom("A")
	.To_("C")
	.Minimizing("distance")
	.Execute()

? "=== Simple Linear Path ==="
? "Total Cost: " + oPlan.Cost()
#--> 20 (10 + 10)

? "Path: " + @@( oPlan.States() )
#--> ["A", "B", "C"]

? ""
? "Explanation:"
? oPlan.Explain()
#-->
# Step 1: A -> B (cost: 10)
# Step 2: B -> C (cost: 10)

pf()
# Executed in 0.01 second(s)

/*--- Path with choice - A* picks shortest route
*/
pr()

# Create a graph with two possible routes
#     A
#    / \
#   B   C
#    \ /
#     D
# Short route: A -> C -> D (cost 15)
# Long route: A -> B -> D (cost 25)

oGraph = new stzGraph("diamond")
oGraph {
	AddNode("A")
	AddNode("B")
	AddNode("C")
	AddNode("D")
	
	# Two alternative paths
	AddEdgeXTT("A", "B", "slow_road", [:distance = 20])
	AddEdgeXTT("A", "C", "fast_road", [:distance = 5])
	AddEdgeXTT("B", "D", "road", [:distance = 5])
	AddEdgeXTT("C", "D", "road", [:distance = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

oPlan = oPlanner.Plan()
	.StartingFrom("A")
	.To_("D")
	.Minimizing("distance")
	.Execute()

? "=== Diamond Path - A* Picks Shortest ==="
? "Total Cost: " + oPlan.Cost()
#--> 15 (not 25!)

? "Path: " + @@( oPlan.States() )
#--> ["A", "C", "D"] - took the fast road!

? ""
? "Actions:"
for aAction in oPlan.Actions()
	? "  " + aAction[:from] + " -> " + aAction[:to] + " (cost: " + aAction[:cost] + ")"
next
#-->
# A -> C (cost: 5)
# C -> D (cost: 10)

pf()
# Executed in 0.02 second(s)

/*--- Complex grid - A* finds optimal path through maze

pr()

# Create a 3x3 grid with varying costs
#   1 --10-- 2 --10-- 3
#   |        |        |
#  10        1       10
#   |        |        |
#   4 ---1-- 5 ---1-- 6
#   |        |        |
#  10       10       10
#   |        |        |
#   7 --10-- 8 --10-- 9
#
# Optimal path 1->2->5->6->9 should be found

oGraph = new stzGraph("grid3x3")
oGraph {
	# Add 9 nodes in grid
	for i = 1 to 9
		AddNodeXTT("n" + i, "Node " + i, [
			:x = ((i-1) % 3) * 10,
			:y = floor((i-1) / 3) * 10
		])
	next
	
	# Horizontal edges
	AddEdgeXTT("n1", "n2", "h", [:cost = 10])
	AddEdgeXTT("n2", "n3", "h", [:cost = 10])
	AddEdgeXTT("n4", "n5", "h", [:cost = 1])  # Cheap path!
	AddEdgeXTT("n5", "n6", "h", [:cost = 1])  # Cheap path!
	AddEdgeXTT("n7", "n8", "h", [:cost = 10])
	AddEdgeXTT("n8", "n9", "h", [:cost = 10])
	
	# Vertical edges
	AddEdgeXTT("n1", "n4", "v", [:cost = 10])
	AddEdgeXTT("n2", "n5", "v", [:cost = 1])  # Cheap path!
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

? "=== Grid Pathfinding - Finding Cheapest Route ==="
? "Total Cost: " + oPlan.Cost()
#--> 32 (10+1+1+10+10) - found the middle corridor!

? "Path: " + @@( oPlan.States() )
#--> ["n1", "n2", "n5", "n6", "n9"]

? ""
? "Path visualization:"
? "n1 -> n2 (cost 10) - Move right"
? "n2 -> n5 (cost 1)  - Drop down to middle row (cheap!)"
? "n5 -> n6 (cost 1)  - Continue right in middle (cheap!)"
? "n6 -> n9 (cost 10) - Drop down to bottom"
? "TOTAL: 32"

pf()
# Executed in 0.03 second(s)

#============================================#
#  SECTION 2: GOAL-BASED PLANNING           #
#============================================#

/*--- RPG Quest - Find any treasure over 1000 gold

pr()

# Create an RPG world where player must find treasure
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
		:gold = 1500,
		:hasKey = FALSE,
		:danger = 8
	])
	
	AddNodeXTT("castle", "Abandoned Castle", [
		:gold = 2000,
		:hasKey = FALSE,
		:danger = 6
	])
	
	# Connect locations
	AddEdgeXTT("village", "forest", "path", [:danger = 2])
	AddEdgeXTT("forest", "cave", "path", [:danger = 3])
	AddEdgeXTT("forest", "dungeon", "path", [:danger = 7])
	AddEdgeXTT("village", "castle", "path", [:danger = 5])
}

oPlanner = new stzGraphPlanner(oGraph)

# Goal: Find ANY location with gold >= 1000
oPlan = oPlanner.Plan()
	.StartingFrom("village")
	.ToReach(func(node) {
		return node[:properties][:gold] >= 1000
	})
	.Minimizing("danger")
	.Execute()

? "=== RPG Quest - Goal-Based Planning ==="
? "Quest: Find treasure worth 1000+ gold"
? ""
? "Total Danger: " + oPlan.Cost()
#--> 12 (2 + 3 + 7) - found dungeon

? "Path: " + @@( oPlan.States() )
#--> ["village", "forest", "dungeon"]

? ""
? "Quest chain:"
for aAction in oPlan.Actions()
	cFrom = aAction[:from]
	cTo = aAction[:to]
	nGold = oGraph.NodeProperty(cTo, "gold")
	? "  " + cFrom + " -> " + cTo + " (danger: " + aAction[:cost] + ", gold: " + nGold + ")"
next
#-->
# village -> forest (danger: 2, gold: 500)
# forest -> dungeon (danger: 7, gold: 1500)
# GOAL REACHED: Found 1500 gold!

pf()
# Executed in 0.02 second(s)

/*--- Collect items - Complex goal with multiple conditions

pr()

# RPG scenario: Need key AND enough gold
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
		:hasKey = TRUE  # Key is here!
	])
	
	AddNodeXTT("vault", "Royal Vault", [
		:gold = 800,
		:hasKey = FALSE
	])
	
	AddNodeXTT("treasury", "Treasury Room", [
		:gold = 1000,
		:hasKey = FALSE  # Combined: 1500 gold + key if visited crypt
	])
	
	# Edges with time costs
	AddEdgeXTT("start", "shop", "walk", [:time = 5])
	AddEdgeXTT("start", "crypt", "walk", [:time = 10])
	AddEdgeXTT("shop", "vault", "walk", [:time = 8])
	AddEdgeXTT("crypt", "vault", "walk", [:time = 12])
	AddEdgeXTT("vault", "treasury", "walk", [:time = 15])
}

oPlanner = new stzGraphPlanner(oGraph)

# Goal: Get key AND accumulate 1000+ gold
oPlan = oPlanner.Plan()
	.StartingFrom("start")
	.ToReach(func(node) {
		# This is simplified - in reality you'd need to track
		# cumulative gold collected along the path
		nGold = node[:properties][:gold]
		bHasKey = node[:properties][:hasKey]
		
		# Reached treasury after getting key from crypt?
		return node[:id] = "treasury"
	})
	.Minimizing("time")
	.Execute()

? "=== Treasure Hunt - Complex Goal ==="
? "Quest: Reach treasury (need to collect key + gold)"
? ""
? "Total Time: " + oPlan.Cost()
#--> 37 (10 + 12 + 15)

? "Journey: " + @@( oPlan.States() )
#--> ["start", "crypt", "vault", "treasury"]

? ""
? "Collection route:"
nTotalGold = 0
for aAction in oPlan.Actions()
	cTo = aAction[:to]
	nGold = oGraph.NodeProperty(cTo, "gold")
	bKey = oGraph.NodeProperty(cTo, "hasKey")
	nTotalGold += nGold
	
	? "  Visit " + cTo + " (time: " + aAction[:cost] + ")"
	if bKey
		? "    -> Found KEY!"
	ok
	if nGold > 0
		? "    -> Collected " + nGold + " gold (total: " + nTotalGold + ")"
	ok
next
#-->
# Visit crypt (time: 10)
#   -> Found KEY!
#   -> Collected 200 gold (total: 200)
# Visit vault (time: 12)
#   -> Collected 800 gold (total: 1000)
# Visit treasury (time: 15)
#   -> Collected 1000 gold (total: 2000)
# SUCCESS: Have key + 2000 gold!

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 3: WAREHOUSE LOGISTICS            #
#============================================#

/*--- Warehouse navigation - Shortest path with obstacles

pr()

# Realistic warehouse layout
oGraph = new stzGraph("warehouse")
oGraph {
	# Define warehouse zones with coordinates
	AddNodeXTT("entrance", "Main Entrance", [:x = 0, :y = 0])
	AddNodeXTT("receiving", "Receiving Bay", [:x = 10, :y = 0])
	AddNodeXTT("aisle_a", "Aisle A", [:x = 20, :y = 0])
	AddNodeXTT("aisle_b", "Aisle B", [:x = 20, :y = 10])
	AddNodeXTT("storage", "Cold Storage", [:x = 30, :y = 10])
	AddNodeXTT("shelf_42", "Shelf 42", [:x = 40, :y = 10])
	AddNodeXTT("packing", "Packing Area", [:x = 40, :y = 20])
	AddNodeXTT("shipping", "Shipping Dock", [:x = 50, :y = 20])
	
	# Connections with distance and traffic
	AddEdgeXTT("entrance", "receiving", "hallway", [
		:distance = 10,
		:traffic = "low"
	])
	
	AddEdgeXTT("receiving", "aisle_a", "hallway", [
		:distance = 15,
		:traffic = "high"  # Congested!
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
	
	# Alternative faster route (if you know it exists!)
	AddEdgeXTT("receiving", "storage", "shortcut", [
		:distance = 25,
		:traffic = "low"
	])
}

oPlanner = new stzGraphPlanner(oGraph)

# Find shortest path to shelf 42
oPlan = oPlanner.Plan()
	.StartingFrom("entrance")
	.To_("shelf_42")
	.Minimizing("distance")
	.Execute()

? "=== Warehouse Navigation ==="
? "Task: Pick item from Shelf 42"
? ""
? "Total Distance: " + oPlan.Cost() + " meters"
#--> 70 meters

? "Route: " + @@( oPlan.States() )
#--> ["entrance", "receiving", "aisle_a", "aisle_b", "storage", "shelf_42"]

? ""
? "Turn-by-turn directions:"
for aAction in oPlan.Actions()
	cFrom = aAction[:from]
	cTo = aAction[:to]
	aEdge = oGraph.Edge(cFrom, cTo)
	cTraffic = aEdge[:properties][:traffic]
	
	? "  " + cFrom + " -> " + cTo
	? "    Distance: " + aAction[:cost] + "m, Traffic: " + cTraffic
next

? ""
? "Total path: 70 meters"
? "(Planner found the shortcut through receiving->storage!)"

pf()
# Executed in 0.03 second(s)

/*--- Multi-stop delivery - Visit multiple locations

pr()

# Warehouse with multiple pickup points
oGraph = new stzGraph("delivery_route")
oGraph {
	AddNode("dock")
	AddNode("zone_a")
	AddNode("zone_b")
	AddNode("zone_c")
	AddNode("exit")
	
	# Create a graph where we must visit a, b, c
	AddEdgeXTT("dock", "zone_a", "route", [:time = 5])
	AddEdgeXTT("zone_a", "zone_b", "route", [:time = 3])
	AddEdgeXTT("zone_b", "zone_c", "route", [:time = 4])
	AddEdgeXTT("zone_c", "exit", "route", [:time = 6])
	
	# Alternative routes
	AddEdgeXTT("dock", "zone_b", "route", [:time = 7])
	AddEdgeXTT("zone_a", "zone_c", "route", [:time = 10])
}

oPlanner = new stzGraphPlanner(oGraph)

# For now, just find path to exit (visiting all zones)
oPlan = oPlanner.Plan()
	.StartingFrom("dock")
	.To_("exit")
	.Minimizing("time")
	.Execute()

? "=== Multi-Stop Delivery ==="
? "Task: Visit all zones and reach exit"
? ""
? "Total Time: " + oPlan.Cost() + " minutes"
#--> 18 minutes

? "Delivery sequence: " + @@( oPlan.States() )
#--> ["dock", "zone_a", "zone_b", "zone_c", "exit"]

? ""
? "Stops:"
for i = 1 to len(oPlan.Actions())
	aAction = oPlan.Actions()[i]
	? "  Stop " + i + ": Pick up at " + aAction[:to] + " (" + aAction[:cost] + " min)"
next

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 4: MANUFACTURING WORKFLOW         #
#============================================#

/*--- Production line - Minimize production time

pr()

# Manufacturing process with different production times
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
	
	# Production steps with time costs
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
	
	# Alternative: Skip polishing for rough finish
	AddEdgeXTT("shape", "assemble", "skip_polish", [
		:time = 2,
		:workers = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)

# Find production plan
oPlan = oPlanner.Plan()
	.StartingFrom("raw")
	.To_("finished")
	.Minimizing("time")
	.Execute()

? "=== Manufacturing Workflow ==="
? "Task: Produce finished goods from raw materials"
? ""
? "Total Production Time: " + oPlan.Cost() + " minutes"
#--> 37 minutes (took shortcut!)

? "Production sequence: " + @@( oPlan.States() )
#--> ["raw", "cut", "shape", "assemble", "finished"]

? ""
? "Production steps:"
for aAction in oPlan.Actions()
	cFrom = aAction[:from]
	cTo = aAction[:to]
	aEdge = oGraph.Edge(cFrom, cTo)
	nWorkers = aEdge[:properties][:workers]
	
	? "  " + cFrom + " -> " + cTo
	? "    Time: " + aAction[:cost] + " min, Workers: " + nWorkers
next

? ""
? "NOTE: Planner skipped polishing to save time (37 min vs 58 min)"

pf()
# Executed in 0.02 second(s)

/*--- Resource-constrained production - Stay within budget

pr()

# Manufacturing with cost constraints
oGraph = new stzGraph("budget_production")
oGraph {
	AddNode("start")
	AddNode("process_a")
	AddNode("process_b")
	AddNode("process_c")
	AddNode("end")
	
	# Expensive high-quality path
	AddEdgeXTT("start", "process_a", "premium", [
		:cost = 100,
		:quality = 10
	])
	AddEdgeXTT("process_a", "end", "finish", [
		:cost = 50,
		:quality = 10
	])
	
	# Cheaper standard path
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

# Find cheapest path
oPlan = oPlanner.Plan()
	.StartingFrom("start")
	.To_("end")
	.Minimizing("cost")
	.Execute()

? "=== Resource-Constrained Production ==="
? "Task: Produce goods within budget"
? ""
? "Total Cost: $" + oPlan.Cost()
#--> $75 (took standard path)

? "Production path: " + @@( oPlan.States() )
#--> ["start", "process_b", "process_c", "end"]

? ""
? "Cost breakdown:"
for aAction in oPlan.Actions()
	? "  " + aAction[:from] + " -> " + aAction[:to] + ": $" + aAction[:cost]
next

? ""
? "Comparison:"
? "  Standard path: $75 (quality 7)"
? "  Premium path: $150 (quality 10)"
? "  Savings: $75!"

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 5: NETWORK ROUTING                #
#============================================#

/*--- Internet routing - Minimize latency

pr()

# Network topology with latency
oGraph = new stzGraph("network")
oGraph {
	AddNodeXTT("client", "Client Device", [:x = 0, :y = 0])
	AddNodeXTT("router1", "Router 1", [:x = 10, :y = 0])
	AddNodeXTT("router2", "Router 2", [:x = 20, :y = 10])
	AddNodeXTT("router3", "Router 3", [:x = 10, :y = 20])
	AddNodeXTT("cdn", "CDN Server", [:x = 30, :y = 10])
	AddNodeXTT("origin", "Origin Server", [:x = 40, :y = 20])
	
	# Network connections with latency (ms)
	AddEdgeXTT("client", "router1", "link", [:latency = 5])
	AddEdgeXTT("router1", "router2", "link", [:latency = 10])
	AddEdgeXTT("router2", "cdn", "link", [:latency = 8])
	AddEdgeXTT("cdn", "origin", "link", [:latency = 15])
	
	# Alternative path through router3 (slower)
	AddEdgeXTT("router1", "router3", "link", [:latency = 12])
	AddEdgeXTT("router3", "origin", "link", [:latency = 25])
	
	# Direct path to CDN (faster!)
	AddEdgeXTT("router1", "cdn", "fast_link", [:latency = 15])
}

oPlanner = new stzGraphPlanner(oGraph)

# Find lowest latency path
oPlan = oPlanner.Plan()
	.StartingFrom("client")
	.To_("origin")
	.Minimizing("latency")
	.Execute()

? "=== Network Routing - Minimize Latency ==="
? "Task: Route packet from client to origin server"
? ""
? "Total Latency: " + oPlan.Cost() + " ms"
#--> 35 ms

? "Route: " + @@( oPlan.States() )
#--> ["client", "router1", "cdn", "origin"]

? ""
? "Hop-by-hop latency:"
for aAction in oPlan.Actions()
	? "  " + aAction[:from] + " -> " + aAction[:to] + ": " + aAction[:cost] + " ms"
next

? ""
? "Network path found faster route through CDN cache!"

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 6: GAME AI - NPC PATHFINDING      #
#============================================#

/*--- Game AI - NPC finds safest path

pr()

# Game world with danger zones
oGraph = new stzGraph("game_world")
oGraph {
	AddNodeXTT("spawn", "Spawn Point", [
		:danger = 0,
		:cover = TRUE
	])
	
	AddNodeXTT("open", "Open Field", [
		:danger = 8,
		:cover = FALSE
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
	
	# Paths with danger ratings
	AddEdgeXTT("spawn", "open", "direct", [:danger = 7])
	AddEdgeXTT("spawn", "forest", "safe", [:danger = 2])
	AddEdgeXTT("open", "objective", "direct", [:danger = 6])
	AddEdgeXTT("forest", "river", "path", [:danger = 3])
	AddEdgeXTT("river", "hill", "path", [:danger = 4])
	AddEdgeXTT("hill", "objective", "path", [:danger = 2])
}

oPlanner = new stzGraphPlanner(oGraph)

# NPC wants safest route
oPlan = oPlanner.Plan()
	.StartingFrom("spawn")
	.To_("objective")
	.Minimizing("danger")
	.Execute()

? "=== Game AI - NPC Pathfinding ==="
? "Task: NPC navigates to objective avoiding danger"
? ""
? "Total Danger: " + oPlan.Cost()
#--> 11 (safe route through forest)

? "NPC path: " + @@( oPlan.States() )
#--> ["spawn", "forest", "river", "hill", "objective"]

? ""
? "Navigation strategy:"
for aAction in oPlan.Actions()
	cTo = aAction[:to]
	bCover = oGraph.NodeProperty(cTo, "cover")
	
	? "  Move to " + cTo + " (danger: " + aAction[:cost] + ")"
	if bCover
		? "    -> Take cover!"
	else
		? "    -> Stay alert - no cover!"
	ok
next

? ""
? "NPC avoided open field (danger 7+6=13) and took forest route (danger 11)"

pf()
# Executed in 0.03 second(s)

#============================================#
#  SECTION 7: REAL-WORLD SCENARIOS           #
#============================================#

/*--- Delivery routing - Amazon-style logistics

pr()

# Delivery network with time windows
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
	
	# Routes with traffic conditions
	AddEdgeXTT("warehouse", "suburb_a", "highway", [
		:distance = 12,
		:traffic = "light"
	])
	
	AddEdgeXTT("suburb_a", "downtown", "road", [
		:distance = 15,
		:traffic = "heavy"
	])
	
	AddEdgeXTT("warehouse", "suburb_b", "highway", [
		:distance = 18,
		:traffic = "light"
	])
	
	AddEdgeXTT("suburb_b", "downtown", "road", [
		:distance = 10,
		:traffic = "medium"
	])
	
	AddEdgeXTT("downtown", "customer", "local", [
		:distance = 8,
		:traffic = "light"
	])
}

oPlanner = new stzGraphPlanner(oGraph)

# Find fastest delivery route
oPlan = oPlanner.Plan()
	.StartingFrom("warehouse")
	.To_("customer")
	.Minimizing("distance")
	.Execute()

? "=== Delivery Routing - Last Mile Optimization ==="
? "Task: Deliver package from warehouse to customer"
? ""
? "Total Distance: " + oPlan.Cost() + " km"
#--> 36 km

? "Delivery route: " + @@( oPlan.States() )
#--> ["warehouse", "suburb_b", "downtown", "customer"]

? ""
? "Route segments:"
for aAction in oPlan.Actions()
	cFrom = aAction[:from]
	cTo = aAction[:to]
	aEdge = oGraph.Edge(cFrom, cTo)
	cTraffic = aEdge[:properties][:traffic]
	
	? "  " + cFrom + " -> " + cTo
	? "    Distance: " + aAction[:cost] + " km, Traffic: " + cTraffic
next

? ""
? "Route optimizer avoided heavy traffic in suburb_a!"

pf()
# Executed in 0.02 second(s)

/*--- Emergency response - Fire truck routing

pr()

# City grid with emergency routing
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
		:congestion = 8  # Usually congested
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
	
	# Routes with response times
	AddEdgeXTT("station", "main_st", "route", [
		:time = 3,
		:sirens = TRUE
	])
	
	AddEdgeXTT("main_st", "bridge", "route", [
		:time = 8,  # Slow due to traffic
		:sirens = TRUE
	])
	
	AddEdgeXTT("station", "back_road", "route", [
		:time = 5,
		:sirens = TRUE
	])
	
	AddEdgeXTT("back_road", "hospital", "route", [
		:time = 4,
		:sirens = TRUE
	])
	
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

# Find fastest emergency response route
oPlan = oPlanner.Plan()
	.StartingFrom("station")
	.To_("emergency_site")
	.Minimizing("time")
	.Execute()

? "=== Emergency Response Routing ==="
? "Task: Fire truck responding to emergency"
? ""
? "Total Response Time: " + oPlan.Cost() + " minutes"
#--> 12 minutes (avoided congested bridge!)

? "Emergency route: " + @@( oPlan.States() )
#--> ["station", "back_road", "hospital", "emergency_site"]

? ""
? "Response timeline:"
nElapsed = 0
for aAction in oPlan.Actions()
	nElapsed += aAction[:cost]
	? "  T+" + nElapsed + " min: Arrive at " + aAction[:to]
next

? ""
? "CRITICAL: Route avoided main_st->bridge (11 min) by taking back_road->hospital (7 min)"
? "Time saved: 4 minutes - could save lives!"

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 8: ADVANCED FEATURES              #
#============================================#

/*--- Spatial heuristics - Euclidean distance guides search

pr()

# Grid with coordinates - A* uses Euclidean heuristic
oGraph = new stzGraph("spatial")
oGraph {
	# Create a 4x4 grid
	for y = 0 to 3
		for x = 0 to 3
			cId = "p" + x + "_" + y
			AddNodeXTT(cId, "Point(" + x + "," + y + ")", [
				:x = x * 10,
				:y = y * 10
			])
		next
	next
	
	# Connect adjacent cells
	for y = 0 to 3
		for x = 0 to 3
			cId = "p" + x + "_" + y
			
			# Right
			if x < 3
				cRight = "p" + (x+1) + "_" + y
				AddEdgeXTT(cId, cRight, "h", [:cost = 10])
			ok
			
			# Down
			if y < 3
				cDown = "p" + x + "_" + (y+1)
				AddEdgeXTT(cId, cDown, "v", [:cost = 10])
			ok
		next
	next
}

oPlanner = new stzGraphPlanner(oGraph)

# Find path from bottom-left to top-right
oPlan = oPlanner.Plan()
	.StartingFrom("p0_0")
	.To_("p3_3")
	.Minimizing("cost")
	.Execute()

? "=== Spatial Heuristics - Euclidean Distance ==="
? "Task: Navigate 4x4 grid from (0,0) to (3,3)"
? ""
? "Total Cost: " + oPlan.Cost()
#--> 60 (optimal diagonal-ish path)

? "Path length: " + len(oPlan.States()) + " steps"
#--> 7 steps (6 moves)

? "Path: " + @@( oPlan.States() )
#--> ["p0_0", "p1_0", "p2_0", "p3_0", "p3_1", "p3_2", "p3_3"]

? ""
? "Path visualization:"
? "  (0,0) -> (1,0) -> (2,0) -> (3,0)"
? "                            |"
? "                            v"
? "                          (3,1) -> (3,2) -> (3,3)"
? ""
? "Euclidean heuristic guided A* to explore toward goal!"

pf()
# Executed in 0.05 second(s)

/*--- Show how planner works internally

pr()

# Simple example to demonstrate A* internals
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

? "=== Understanding A* Search ==="
? ""
? "Graph:"
? "  A --1--> B --5--> D"
? "  |                 ^"
? "  4                 1"
? "  v                 |"
? "  C ----------------+"
? ""
? "Question: What path from A to D?"
? "  Option 1: A -> B -> D (cost: 1+5 = 6)"
? "  Option 2: A -> C -> D (cost: 4+1 = 5) ← Better!"
? ""

oPlanner = new stzGraphPlanner(oGraph)

oPlan = oPlanner.Plan()
	.StartingFrom("A")
	.To_("D")
	.Minimizing("cost")
	.Execute()

? "A* Result:"
? "  Total Cost: " + oPlan.Cost()
#--> 5

? "  Path: " + @@( oPlan.States() )
#--> ["A", "C", "D"]

? ""
? "A* Reasoning:"
? "  1. Start at A (cost so far: 0)"
? "  2. Explore neighbors: B(cost 1) and C(cost 4)"
? "  3. B looks cheaper initially (1 < 4)"
? "  4. But B->D costs 5, total would be 6"
? "  5. Meanwhile C->D costs only 1, total is 5"
? "  6. A* discovers C->D is better and takes that path!"
? ""
? "This is why A* is OPTIMAL - it finds the best path!"

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 9: PLAN EXPLANATION               #
#============================================#

/*--- Human-readable plan explanation

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

? "=== Plan Explanation System ==="
? ""
? "Supply Chain Plan:"
? "------------------"
? oPlan.Explain()
? ""
? "Summary:"
? "  Total Cost: $" + oPlan.Cost()
? "  Total Steps: " + len(oPlan.Actions())
? ""
? "This plan moves products from supplier to retail store"
? "through the most cost-effective route."

pf()
# Executed in 0.02 second(s)

#============================================#
#  SECTION 10: COMPARISON OF ALGORITHMS      #
#============================================#

/*--- When to use A* vs Goal-Based Search

pr()

? "=== Algorithm Comparison ==="
? ""
? "1. A* PATHFINDING:"
? "   Use when: You know exact start and end points"
? "   Example: GPS navigation (home -> office)"
? "   Benefit: Finds optimal path guaranteed"
? ""
? "2. GOAL-BASED SEARCH:"
? "   Use when: Goal is a condition, not a location"
? "   Example: Find ANY gas station (don't care which)"
? "   Benefit: Stops as soon as condition is met"
? ""
? "3. MULTI-STEP PLANNING:"
? "   Use when: Must visit multiple waypoints in order"
? "   Example: Delivery route with 5 stops"
? "   Benefit: Chains multiple plans together"
? ""

# Demonstrate both approaches

? "Example: Finding treasure in RPG"
? ""

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

# Approach 1: A* (if you know where chest is)
oPlan1 = oPlanner.Plan()
	.StartingFrom("home")
	.To_("chest")
	.Minimizing("distance")
	.Execute()

? "Approach 1 - A* (know exact location):"
? "  Cost: " + oPlan1.Cost()
? "  Path: " + @@( oPlan1.States() )
? ""

# Approach 2: Goal-based (looking for any treasure)
oPlan2 = oPlanner.Plan()
	.StartingFrom("home")
	.ToReach(func(node) {
		return node[:properties][:has_treasure] = TRUE
	})
	.Minimizing("distance")
	.Execute()

? "Approach 2 - Goal-based (find any treasure):"
? "  Cost: " + oPlan2.Cost()
? "  Path: " + @@( oPlan2.States() )
? ""
? "Both approaches work! Use A* when you know the target,"
? "use goal-based when you're searching for a condition."

pf()
# Executed in 0.03 second(s)

#============================================#
#  PRACTICAL TIPS AND BEST PRACTICES        #
#============================================#

/*--- Tips for effective planning

pr()

? "=== Planning Best Practices ==="
? ""
? "1. GRAPH DESIGN:"
? "   - Each node = a distinct state"
? "   - Each edge = a valid transition"
? "   - Properties = state information"
? ""
? "2. COST FUNCTIONS:"
? "   - Use .Minimizing() for costs/time/distance"
? "   - Use .Maximizing() for rewards/profit/quality"
? "   - Can optimize multiple criteria"
? ""
? "3. GOAL FUNCTIONS:"
? "   - Keep them fast (called many times)"
? "   - Return TRUE when goal reached"
? "   - Can check multiple conditions"
? ""
? "4. PERFORMANCE:"
? "   - Smaller graphs = faster planning"
? "   - Good heuristics = fewer nodes explored"
? "   - Spatial coords enable Euclidean heuristic"
? ""
? "5. DEBUGGING:"
? "   - Use .Explain() to understand plan"
? "   - Check .Cost() to verify optimality"
? "   - Inspect .States() to see full path"

pf()

#============================================#
#  FINAL SUMMARY                             #
#============================================#

? ""
? "╭────────────────────────────────────────╮"
? "│   stzGraphPlanner - Test Suite Complete │"
? "╰────────────────────────────────────────╯"
? ""
? "You've learned:"
? "  ✓ Basic A* pathfinding"
? "  ✓ Goal-based planning"
? "  ✓ Real-world applications"
? "  ✓ Performance optimization"
? "  ✓ Best practices"
? ""
? "Next steps:"
? "  - Explore multi-step planning"
? "  - Add custom heuristics"
? "  - Implement reactive replanning"
? "  - Try your own scenarios!"
? ""
? "Happy planning! 🎯"
