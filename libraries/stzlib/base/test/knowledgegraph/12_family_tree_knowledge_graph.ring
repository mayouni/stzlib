# Narrative
# --------
# Family tree knowledge graph
#
# Extracted from stzknowledgegraphtest.ring, block #12.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Family")
oKG {
	AddFact("Alice", :ParentOf, "Bob")
	AddFact("Alice", :ParentOf, "Charlie")
	AddFact("Bob", :SiblingOf, "Charlie")
	AddFact("Bob", :ParentOf, "Diana")
	
	# Who are Alice's children?

	? @@( Query(["Alice", :ParentOf, "?child"]) )
	#--> ["Bob", "Charlie"]

	# Who is Bob's sibling?

	? @@( Query(["Bob", :SiblingOf, "?sibling"]) )
	#--> ["Charlie"]

	# Predicates about Bob:

	? @@( Predicates("Bob") )
	#--> [:SiblingOf, :ParentOf]
}

pf()
