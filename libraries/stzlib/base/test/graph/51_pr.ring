# Narrative
# --------
# pr()
#
# Extracted from stzgraphtest.ring, block #51.

load "../../stzBase.ring"


oGraph = new stzGraph("Star")
oGraph {
	AddNode(:center)
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)

	Connect(:n1, :center)
	Connect(:center, :n1)

	Connect(:n2, :center)
	Connect(:center, :n2)

	Connect(:n3, :center)
	Connect(:center, :n3)

	? BetweennessCentrality(:center)
	#--> 1 (all paths go through center in undirected graph)
	
	? BetweennessCentrality(:n1)
	#--> 0 (no paths go through peripheral nodes)

	View()
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
