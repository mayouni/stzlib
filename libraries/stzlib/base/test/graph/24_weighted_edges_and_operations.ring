# Narrative
# --------
# Weighted Edges and Operations
#
# Extracted from stzgraphtest.ring, block #24.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("WeightedTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")

	ConnectXTT("a", "b", "link1", [:weight = 5])
	ConnectXTT("b", "c", "link2", [:weight = 3])

	? EdgeProperty("a", "b", "weight")
	#--> 5

	SetEdgeProperty("a", "b", "weight", 10)
	? EdgeProperty("a", "b", "weight")
	#--> 10

	# Total weight along path
	? PathWeight(["a", "b", "c"])
	#--> 13  # Sum of weights
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
