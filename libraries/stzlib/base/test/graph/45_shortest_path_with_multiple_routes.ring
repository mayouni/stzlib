# Narrative
# --------
# Shortest path with multiple routes
#
# Extracted from stzgraphtest.ring, block #45.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Network")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	AddNode("d")
	

	Connect(:node = "a", :tonode = "b") # See the named param variations
	Connect("a", :andnode = "c")
	Connect(:node = "b", :tonode = "d")
	Connect(:node = "c", :and = "d")
	
	? @@( ShortestPath(:From = "a", :To = "d") )
	#--> ["a", "b", "d"]
	
	? ShortestPathLength(:From = "a", :To = "d")
	#--> 2
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
