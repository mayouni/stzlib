# Narrative
# --------
# Adding facts (triples)
#
# Extracted from stzknowledgegraphtest.ring, block #1.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Animals")
oKG {
	AddFact("Dogs", :IsA, "Animals")
	AddFact("Dogs", :Eats, "Food")
	AddFact("Cats", :IsA, "Animals")
	
	? @@NL( Facts() )
	#--> [
	#     ["Dogs", :IsA, "Animals"],
	#     ["Dogs", :Eats, "Food"],
	#     ["Cats", :IsA, "Animals"]
	#    ]
}

pf()
