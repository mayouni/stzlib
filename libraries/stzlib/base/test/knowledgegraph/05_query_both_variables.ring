# Narrative
# --------
# Query both variables
#
# Extracted from stzknowledgegraphtest.ring, block #5.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Relations")
oKG {
	AddFact("Alice", :Knows, "Bob")
	AddFact("Charlie", :Knows, "Diana")
	AddFact("Alice", :WorksWith, "Eve")
	
	# Who knows whom?

	? @@NL( Query(["?x", :Knows, "?y"]) )
	#--> [
	#     ["Alice", "Bob"],
	#     ["Charlie", "Diana"]
	#    ]
}

pf()
