# Narrative
# --------
# Defining class hierarchy
#
# Extracted from stzknowledgegraphtest.ring, block #10.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Taxonomy")
oKG {
	DefineClass("Mammals", "Animals")
	DefineClass("Dogs", "Mammals")
	DefineClass("Cats", "Mammals")
	
	# Class hierarchy as facts

	? @@NL( Facts() )
	#--> [
	#     ["Mammals", :SubClassOf, "Animals"],
	#     ["Dogs", :SubClassOf, "Mammals"],
	#     ["Cats", :SubClassOf, "Mammals"]
	# ]
}

pf()
