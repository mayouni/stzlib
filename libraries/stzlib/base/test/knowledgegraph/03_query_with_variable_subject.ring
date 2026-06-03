# Narrative
# --------
# Query with variable subject
#
# Extracted from stzknowledgegraphtest.ring, block #3.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Taxonomy")
oKG {
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Birds", :IsA, "Animals")
	
	# What is a Mammal?
	? @@( Query(["?x", :IsA, "Mammals"]) )
	#--> ["Dogs", "Cats"]
}

pf()
