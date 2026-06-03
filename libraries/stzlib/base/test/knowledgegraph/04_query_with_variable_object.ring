# Narrative
# --------
# Query with variable object
#
# Extracted from stzknowledgegraphtest.ring, block #4.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Food")
oKG {
	AddFact("Dogs", :Eats, "Meat")
	AddFact("Dogs", :Drinks, "Water")
	AddFact("Cats", :Eats, "Fish")
	
	# What does Dogs eat/drink?

	? @@( Query(["Dogs", :Eats, "?what"]) )
	#--> ["Meat"]
	
	? @@( Query(["Dogs", :Drinks, "?what"]) )
	#--> ["Water"]
}

pf()
