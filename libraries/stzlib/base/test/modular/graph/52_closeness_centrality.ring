# Narrative
# --------
# Closeness centrality
#
# Extracted from stzgraphtest.ring, block #52.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Network")
oGraph {
	AddNode(:a)
	AddNode(:b)
	AddNode(:c)
	
	Connect(:a, :b)
	Connect(:b, :c)
	
	? ClosenessCentrality(:b)
	#--> 1 (average distance = 1)
	
	? ClosenessCentrality(:a)
	#--> 0.67 (average distance = 1.5)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
