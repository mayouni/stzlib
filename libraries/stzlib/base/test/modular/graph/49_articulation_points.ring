# Narrative
# --------
# Articulation points
#
# Extracted from stzgraphtest.ring, block #49.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Bridge")
oGraph {
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	AddNode(:n4)
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	Connect(:n3, :n4)
	
	? @@( ArticulationPoints() )
	#--> ["n2", "n3"] - Removing either disconnects the graph
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=======================#
#  CENTRALITY MEASURES  #
#=======================#
