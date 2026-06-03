# Narrative
# --------
# Company organization knowledge graph
#
# Extracted from stzknowledgegraphtest.ring, block #13.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Company")
oKG {
	AddFact("Alice", :WorksIn, "Engineering")
	AddFact("Alice", :ReportsTo, "Manager1")
	AddFact("Bob", :WorksIn, "Engineering")
	AddFact("Bob", :ReportsTo, "Manager1")
	AddFact("Charlie", :WorksIn, "Sales")
	
	# Who works in Engineering?

	? @@( Query(["?who", :WorksIn, "Engineering"]) )
	#--> ["Alice", "Bob"]

	# Who reports to Manager1?

	? @@( Query(["?who", :ReportsTo, "Manager1"]) )
	#--> ["Alice", "Bob"]
	
	# Similar employees to Alice:

	? @@NL( SimilarTo("Alice") )
	#--> [["Bob", 2], [ "Charlie", 1 ]]
}

pf()
