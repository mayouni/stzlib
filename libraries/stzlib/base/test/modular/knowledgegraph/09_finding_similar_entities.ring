# Narrative
# --------
# Finding similar entities
#
# Extracted from stzknowledgegraphtest.ring, block #9.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Comparison")
oKG {
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Dogs", :HasLegs, "4")
	AddFact("Dogs", :Eats, "Meat")
	
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Cats", :HasLegs, "4")
	AddFact("Cats", :Eats, "Meat")
	
	AddFact("Birds", :IsA, "Animals")
	AddFact("Birds", :HasLegs, "2")
	
	# Entities similar to Dogs

	? @@NL( SimilarTo("Dogs") )
	#--> [ ["Cats", 3], ["Birds", 2] ]
	# Cats shares 3 predicates, Birds shares 2 predicates
}

pf()

#=====================#
#  ONTOLOGY SUPPORT   #
#=====================#
