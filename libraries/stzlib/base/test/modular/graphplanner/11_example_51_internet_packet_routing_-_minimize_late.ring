# Narrative
# --------
# Example 5.1: Internet Packet Routing - Minimize Latency
#
# Extracted from stzgraphplannertest.ring, block #11.

load "../../../stzBase.ring"

  
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
