# Narrative
# --------
# Clustering coefficient
#
# Extracted from stzgraphtest.ring, block #53.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Triangle")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	
	Connect(:a, :b)
	Connect(:b, :c)
	Connect(:c, :a)
	
	? ClusteringCoefficient("a")
	#--> 1 (neighbors are fully connected)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
