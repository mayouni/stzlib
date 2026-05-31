# Narrative
# --------
# Clustering coefficient in incomplete triangle
#
# Extracted from stzgraphtest.ring, block #54.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Incomplete")
oGraph {
	AddNode(:x)
	AddNode(:y)
	AddNode(:z)
	
	Connect(:x, :y)
	Connect(:x, :z)
	# y and z not connected
	
	? ClusteringCoeff(:x)
	#--> 0 (neighbors not connected)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

#==================#
#  GRAPH METRICS   #
#==================#
