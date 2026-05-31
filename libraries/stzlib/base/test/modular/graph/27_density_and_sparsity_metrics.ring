# Narrative
# --------
# Density and Sparsity Metrics
#
# Extracted from stzgraphtest.ring, block #27.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("DensityTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")

	Connect("a", :to = "b")
	Connect("b", :to = "c")

	? Density() # Direct Graph : 3 nodes, 2 edges → density = 2/(3×2) = 0.33
	#--> 0.33

	? IsSparse() # Assuming threshold < 0.5 is dense, else sparse
	#--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
