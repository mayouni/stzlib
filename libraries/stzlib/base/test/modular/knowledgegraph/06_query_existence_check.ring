# Narrative
# --------
# Query existence check
#
# Extracted from stzknowledgegraphtest.ring, block #6.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Check")
oKG {
	AddFact("Earth", :OrbitsAround, "Sun")
	AddFact("Moon", :OrbitsAround, "Earth")
	
	# Does Earth orbit Sun?

	? Query(["Earth", :OrbitsAround, "Sun"])
	#--> TRUE
	
	# Does Sun orbit Earth?

	? Query(["Sun", :OrbitsAround, "Earth"])
	#--> FALSE
}

pf()

#======================#
#  ENTITY ANALYSIS     #
#======================#
