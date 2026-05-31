# Narrative
# --------
# No path exists
#
# Extracted from stzgraphtest.ring, block #46.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Disconnected")
oGraph {
	AddNodeXT(:x, "Node X")
	AddNodeXT(:y, "Node Y")
	AddNodeXT(:z, "Node Z")
	
	Connect(:x, :y)
	# z is isolated
	
	? @@( ShortestPath(:From = :x, :To = :z) )
	#--> []
	
	? ShortestPathLength(:From = :x, :To = :z)
	#--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#=======================#
#  CONNECTIVITY TESTS   #
#=======================#
