# Narrative
# --------
# Graph Metrics
#
# Extracted from stzgraphtest.ring, block #21.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("MetricsTest")
oGraph {
	AddNode("a")
	AddNode("b")
	AddNode("c")
	
	Connect("a", "b")
	Connect("b", "c")
	Connect("a", "c")
	
	? NodeDensity() # Or NodeDensity01() ~> coefficient between 0 and 1
	#--> 0.5

	? NodeDensity100() # Or NodeDensityInPercentage()
	#--> 50 (%)

	? LongestPath()  #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
