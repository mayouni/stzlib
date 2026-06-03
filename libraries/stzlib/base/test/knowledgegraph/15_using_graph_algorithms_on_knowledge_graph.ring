# Narrative
# --------
# Using graph algorithms on knowledge graph
#
# Extracted from stzknowledgegraphtest.ring, block #15.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Network")
oKG {
	AddFact("A", :ConnectsTo, "B")
	AddFact("B", :ConnectsTo, "C")
	AddFact("C", :ConnectsTo, "D")
	
	# Shortest path from A to D
	? @@( ShortestPath(:From = "A", :To = "D") )
	#--> ["A", "B", "C", "D"]
	
	# Is the knowledge graph connected?
	? IsConnected()
	#--> TRUE
	
	# Critical entities (articulation points)
	? @@( ArticulationPoints() )
	#--> ["B", "C"]
}

pf()
