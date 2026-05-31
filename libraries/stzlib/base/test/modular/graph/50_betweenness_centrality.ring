# Narrative
# --------
# Betweenness centrality
#
# Extracted from stzgraphtest.ring, block #50.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Star")
oGraph {
	AddNode(:center)
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	
	Connect(:n1, :center)
	Connect(:center, :n2)
	Connect(:center, :n3)
	
	? BetweennessCentrality(:center)
	#--> 0.33 (2 out of 6 possible paths go through center in directed graph)
	
	? BetweennessCentrality(:n1)
	#--> 0 (no paths go through peripheral nodes)
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
