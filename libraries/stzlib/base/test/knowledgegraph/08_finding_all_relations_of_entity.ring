# Narrative
# --------
# Finding all relations of entity
#
# Extracted from stzknowledgegraphtest.ring, block #8.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Network")
oKG {
	AddFact("Node1", :ConnectsTo, "Node2")
	AddFact("Node1", :HasProperty, "Active")
	AddFact("Node1", :PartOf, "System")
	
	# All relations of Node1

	? @@NL( Relations("Node1") )
	#--> [
	#     [:ConnectsTo, "Node2"],
	#     [:HasProperty, "Active"],
	#     [:PartOf, "System"]
	# ]
}

pf()
